# Employee Master (Employee Onboarding) — Handoff

_Last updated: 2026-09-11. Written for the next Claude Code session (or developer) picking this up._

This module lives in **two near-identical Flutter apps**. Every change is made in Globenex first, then copied to Newdigitalerpp. Read the "Keeping the two apps in sync" section before editing anything.

| App | Path | Brand shown on ID card |
|---|---|---|
| Globenex | `C:\Users\Admin\StudioProjects\DigitalERP_Globenex_ravi` | `GLOBENEX` |
| Newdigitalerpp | `C:\Users\Admin\Desktop\Newdigitalerpp` | `DIGITAL ERP` |

Both apps share the same backend: `http://supportapi.digitalerp.biz/api/`. Package name in both is `digitalerp`.

---

## 1. What it does

An HR onboarding module. The ERP menu is called **"Employee onboarding"** (menu id **2812**).

```
Home grid tile "Employee onboarding"
   └─ Employee list  (search, pull-to-refresh, "+" FAB)
        ├─ tap a row  → read-only Detail screen → "Card" button → ID card
        └─ "+" FAB    → Create form → Save → ID card (Share / Download PDF)
```

The Create form has five sections, in this order:

1. **Vendor & Site** — two dropdowns
2. **General Details** — photo, name*, gender, department, designation, PF No, ESI No, phone, date of joining, date of birth
3. **Salary & Work** — salary type, week off, OT applicable, work hours (Default → Shift dropdown / Manual → Daily Working Hours field)
4. **Document Details** — Aadhar no + attachment, PAN no + attachment
5. **Address Details** — full address, state*, city, pincode

There is a **Preview** button in the form's app bar that shows the ID card from the unsaved form. It was added when the APIs were dead so the card could be tested; safe to remove now.

There is **no edit and no delete** — the user chose view-only.

---

## 2. Files

All under `lib/screen/ui/home/employee_master/` unless noted.

| File | Purpose |
|---|---|
| `employee_widgets.dart` | Colour tokens, `EmpCard`, `EmpField`, `EmpDropdown` (searchable bottom-sheet), `EmpAttachment`, `EmpPrimaryBtn`, `EmpQrCode` (QR painter). **Contains `empCardBrand` — the one line that differs per app.** |
| `employee_response/employee_model.dart` | `EmpOption` (generic dropdown item) and `EmployeeMasterPayload` (the save body — **field names are the ERP's exact ones, do not rename**). |
| `employee_response/employee_read_models.dart` | `EmployeeListItem`, `EmployeeDetail`, `EmployeeCardInfo` + tolerant `pick()` / `extractRows()` / `extractRecord()` helpers. |
| `employee_controller/employee_master_controller.dart` | The form: dropdown loading, attachments, validation, save, ID-card snapshot. |
| `employee_controller/employee_list_controller.dart` | The list: fetch, search, empty/error states. |
| `employee_screens/employee_list_screen.dart` | List UI. This is what the menu route opens. |
| `employee_screens/employee_master_screen.dart` | Create form UI. |
| `employee_screens/employee_detail_screen.dart` | Read-only detail UI + "Card" button. |
| `employee_screens/employee_card_screen.dart` | `EmpCardData`, `EmployeeCardScreen`, on-screen `EmpIdCard`, and `EmployeeCardPdf`. |
| `lib/repo/employee_master_repo.dart` | All API calls + `succeeded()` / `isNotDeployed()` helpers. |
| `lib/repo/base_url.dart` | Endpoint names (`MethodName.saveEmployeeMaster` etc.). |

Wiring outside the module:

- `lib/app_routes/app_routes.dart` — `AppRoutes.employeeMaster = '/employeeMaster'`
- `lib/app_routes/app_pages.dart` — route → `EmployeeListScreen`
- `lib/homeview_new_controller.dart` — `kEmployeeMasterMenuId = 2812`, icon map entry for `'Employee onboarding'`
- `lib/home_view_new.dart` — `_getDirectRoute` has `2812`, and `_getRouteByName` matches any menu name containing "employee" + "master/onboard" as a backstop
- `pubspec.yaml` — `barcode: ^2.2.9` declared explicitly (was already a transitive dep of `pdf`; needed because the QR painter imports it directly)

---

## 3. The API contract (hard-won — read this before touching the network code)

Five endpoints, all live. Full probe notes were in the session scratchpad; the essentials:

### `employeeonboarding` — SAVE
- **multipart/form-data ONLY.** A JSON body is refused with `"Please send data as multipart/form-data"` — **while still returning HTTP 200**.
- **Required:** `name`, `stateid`, and at least one of `aadharno` / `panno`.
- **Field names are NOT the obvious ones.** A wrong key is silently dropped, not rejected. The correct ones (already in `EmployeeMasterPayload.toJson()`):
  `name` (not employeename), `mobile`, `joiningdate`, `dob`, `aadharno`, `panno`, `address`, `workinghours`, `shiftid`, `vendorid`, `vendorname`, `siteid`, `sitename`, `genderid`, `gender`, `departmentid`, `designationid`, `designation`, `pfno`, `esino`, `salarytype`, `weekoff`, `otapplicable`, `stateid`, `statename`, `cityid`, `cityname`, `pincode`
- **Scans go up as multipart FILE parts** named `photo`, `aadharfile`, `panfile` on this same request. There is no separate upload step.
- Reply: `{"success":true,"data":{"partyid":256471,"empid":"…","photo":"","aadharfile":"","panfile":""},...}` — **`partyid` is the record id** used by every other endpoint.
- **Request size limit ≈ 4 MB** (classic ASP.NET default). Verified 2026-09-11: 3 MB accepted, 4 MB fails with `"Error reading MIME multipart body part."` See §6.

### `employeeonboardinglist` — LIST
- **JSON only** (rejects multipart with a media-type error).
- Body: `{compid, branchid, userid}`.
- Rows use `employeename`, `partyid`, `mobileno`, `photourl`, `vendorname`, `sitename`, `aadharno`, `panno`.

### `employeeonboarddetail` — DETAIL
- JSON. Key is **`partyid`** — sending `employeeid` returns "Employee detail Not Available".
- Returns `name` (not employeename), `mobile`, `joiningdate`, `dob`, `workinghours`, `aadharno`, `panno`, `address`, `partycode`, `aadharfileurl`, `panfileurl`, `photourl`, `vendorname`, `sitename`, and more.
- Note the three read/write APIs **disagree on key names** (`name` vs `employeename`, `mobile` vs `mobileno`). `pick()` in the read models tries all spellings, so don't "tidy" those lists.

### `employeeidcard` — ID CARD DATA
- JSON, `partyid`. This is the card's source of truth. Returns `companyname`, `companylogourl`, `employeename`, `photourl`, `empid`, `designation`, `sitename`, `phone`, and **`qrdata`**.
- `qrdata` is currently a **URL** (`https://supportapi.digitalerp.biz/api/employeecard?p=…&c=…&k=…`) to a server-rendered HTML page. The app just encodes whatever string it gets.
- Does **not** return `vendorname` or `department` — the card carries those over from the form/detail instead.

### `shifttiming` — SHIFT DROPDOWN
- JSON, `{compid, branchid, userid}`. Loaded lazily, only when Work Hours = Default is chosen.

### Two helpers you must use
- **`EmployeeMasterRepo.succeeded(res)`** instead of `res.status == true`. These APIs answer HTTP 200 even when rejecting; `BaseApiHelper` marks any 200 as success. Trusting the HTTP code once showed a "Saved" toast for a record that was never written.
- **`EmployeeMasterRepo.isNotDeployed(res)`** — true on 404 **or** message "bad response format" (IIS serves an HTML 404 page for a missing route, which the JSON decoder chokes on).

---

## 4. Rules and validation

- **Required:** Name, State, and one identity document **attachment** (Aadhar or PAN — either one).
- **PF No** = exactly 12 digits (UAN). **ESI No** = exactly 17 digits. Both digits-only at the keyboard, length-capped, and exact-length-checked on Save. Blank is allowed; partial is rejected.
- **PAN** must match `ABCDE1234F`; auto-uppercased as typed.
- **Phone** 10 digits, **Pincode** 6 digits, **Aadhar** 12 digits (when filled).
- **Work Hours:** Default → **Shift** dropdown (required); Manual → **Daily Working Hours** field (required). Never both; switching clears the other side.
- Required-field red outlines only appear **after** a Save attempt (`showErrors` flag).
- City dropdown is locked until a State is chosen; changing State clears City.

---

## 5. The ID card

- CR80 ratio (85.6 × 54 mm) both on screen and in the PDF, so the printed card matches the preview.
- Layout: company logo + name in a navy→blue header band; left rail = photo (3:4) with the **QR directly beneath**; right = name, designation, then rows **EMP ID / VENDOR / SITE / DEPARTMENT / PHONE** (blank rows are omitted); footer band reads **EMPLOYEE ID CARD**.
- All sizes are multiples of 1% of card width, so it scales to any screen.
- **QR is painted with the `barcode` package** — `EmpQrCode` (`CustomPainter`) on screen, `pw.BarcodeWidget` in the PDF. Same encoder → identical codes. No `qr_flutter` needed.
- The card screen takes a `partyId`; it paints the caller's snapshot immediately, then fetches `employeeidcard` and swaps in the authoritative version (company, logo, QR). If that fails, the snapshot stays.
- PDF: `EmployeeCardPdf.build()` writes `employee_card_<name>.pdf` to app documents; Share via `share_plus`, open via `open_filex`. Photo/logo are downloaded for the PDF (15 s timeout, silent fallback).
- `empCardBrand` in `employee_widgets.dart` is only a fallback — the real company name comes from `employeeidcard`.

---

## 6. Attachment size limit (the client-reported bug, fixed 2026-09-11)

A client got `"Error reading MIME multipart body part."` on Save. Root cause: three iPhone camera shots exceeded the server's ~4 MB request limit; IIS truncated the body.

App-side fixes in `employee_master_controller.dart`:
- Camera/gallery images are resized on pick: `maxWidth/maxHeight = kAttachmentMaxPx (1600)`. Brings each scan to ~200–400 KB.
- Before Save, `attachmentBytes` is checked against `kAttachmentBudgetBytes` (3.5 MB) — blocks with a clear message including the actual sizes. PDFs from storage can't be resized, so this can still trigger.
- If the server's MIME error ever comes back anyway, it's translated into "Attachments too large…".

**Ask the backend** to raise the limit in `web.config`:
```xml
<httpRuntime maxRequestLength="20480" />
<requestLimits maxAllowedContentLength="20971520" />
```

---

## 7. Keeping the two apps in sync

**Build in Globenex, then copy to Newdigitalerpp.** The module files are meant to be identical.

```bash
SRC="C:/Users/Admin/StudioProjects/DigitalERP_Globenex_ravi/lib"
DST="C:/Users/Admin/Desktop/Newdigitalerpp/lib"
cp "$SRC/repo/employee_master_repo.dart" "$DST/repo/"
cp "$SRC/screen/ui/home/employee_master/employee_widgets.dart" "$DST/screen/ui/home/employee_master/"
cp "$SRC/screen/ui/home/employee_master/employee_response/"*.dart   "$DST/screen/ui/home/employee_master/employee_response/"
cp "$SRC/screen/ui/home/employee_master/employee_controller/"*.dart "$DST/screen/ui/home/employee_master/employee_controller/"
cp "$SRC/screen/ui/home/employee_master/employee_screens/"*.dart    "$DST/screen/ui/home/employee_master/employee_screens/"
# The ONE intended difference — re-apply after every copy:
sed -i "s|const String empCardBrand = 'GLOBENEX';|const String empCardBrand = 'DIGITAL ERP';|" "$DST/screen/ui/home/employee_master/employee_widgets.dart"
```

Then `flutter analyze lib/screen/ui/home/employee_master` in both.

**Do NOT copy these wholesale** — they differ between apps and must be patched by hand:
`base_url.dart`, `app_pages.dart`, `app_routes.dart`, `homeview_new_controller.dart`, `home_view_new.dart`, `screen/ui/home/home_view.dart`, `pubspec.yaml`.
(A wholesale copy of `base_url.dart` was done once on 2026-08-26; `git diff` showed additions only, so nothing was lost — but don't rely on that.)

**Known drift:** on 2026-09-07 someone stripped the explanatory comments from the Newdigitalerpp copies of most module files. Logic is identical (verified by diffing with comments removed). A fresh copy from Globenex will bring the comments back — decide whether that's wanted.

---

## 8. Testing

Test values that pass validation:

| Field | Value |
|---|---|
| Name | Test Person |
| PF No | `100234567891` |
| ESI No | `31001234560000101` |
| Phone | `9876543210` |
| Aadhar | `123412341234` |
| PAN | `ABCDE1234F` |
| Pincode | `110058` |

Pick any Vendor/Site/State/City; attach at least one of Aadhar/PAN. For Work Hours pick Manual and type `8` unless you want to exercise the shift API.

Watch the run log for these lines:
- `SaveEmployeeMaster fields: {...}` — what was sent
- `POST(form) …/employeeonboarding [200]: {...}` — the server's **actual** reply (the HTTP code alone tells you nothing here)
- `reply from …/employeeonboardinglist: …` etc. — list/detail/card replies

Every save creates a real record in the live ERP — there is no test tenant and **no delete API**.

---

## 9. Open items / things owed by the backend

1. **Company name on the QR landing page.** The QR opens `api/employeecard?p=…` — a server-rendered HTML page whose header shows only the employee name and EMP ID. It needs `companyname` (and ideally the logo) added. This is backend HTML; nothing in the app controls it. `employeeidcard` already returns both for the same `partyid`.
2. **Request size limit** — see §6.
3. **`employeeidcard` should return `vendorname` and `department`** so the card is self-contained from one call (currently carried over from the caller).
4. **Junk record to delete from the web ERP:** `partyid 256471`, name "ProbeOnly", Aadhar `123412341234`. Created by accident while probing field names. No delete API exists.
5. The detail page's **Personal** section rendered empty on the probe record — may show as a blank white card for sparse records.

---

## 10. Gotchas that bit us

- **Nothing from these sessions is committed.** `git checkout -- <file>` on any touched file discards the work. This happened once (lost the menu matcher + 2812 route; restored). Commit to a branch before doing anything git-destructive.
- Heredocs in the Bash tool break on large Dart files — use the Write tool for anything over ~100 lines.
- `perl -0pi` substitutions can match **commented-out** duplicate code in `home_view.dart` / `home_view_new.dart` (those files carry huge `//` blocks of old versions). Check `grep -n` results before and after.
- `image_picker` filenames on iOS look like `image_picker_86F8BEF2-….jpg` — that's normal.
- The app only renders images / opens links whose value **starts with `http`**. A bare filename from the API is ignored on purpose.

---

## 11. Related but separate: the "More" tab

Not part of this module, but changed in the same sessions: tapping **More** in the bottom nav no longer navigates to a page. It opens the Quick Links module grid as a **sheet over the current tab** (`showQuickLinksSheet()` in `home_view_new.dart`, wired in `screen/ui/home/home_view.dart`). Tiles inside the sheet pass `insideSheet: true` so the sheet closes before navigating. `HomeViewNew` still exists as the `AppRoutes.homeNew` fallback route. Identical in both apps.
