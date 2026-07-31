# White-label Globenex → new Balaji app — Gap Audit

Audited 2026-07-30 against both live backends with the shared test login
(`9981705001` / `123456` → userid 462675, compid 68, branchid 122).

**New direction:** Balaji is no longer being revamped. The **Globenex** app becomes
the product base and gets white-labelled as the new Balaji app. This document lists
what actually differs and what must change in Globenex.

---

## 1. THE BIG DECISION: which backend? — verified, needs sign-off

`supportapi.digitalerp.biz` (Globenex) is a **superset** of
`salewebservice.digitalerp.biz` (Balaji).

**Same Balaji data on both hosts** — tested at the same moment, compid 68:

| Check | salewebservice | supportapi |
|---|---|---|
| Login (mobile 9981705001) | userid 462675, compid 68, branch 122 | identical |
| Approval list (PurchaseOrder/Pending, 30d) | 6 records | 6 records |
| Party list (`AccountCustomer`) | 199 parties | 199 parties |
| Reimbursement list | ExpenseId 2056 … | identical records |
| Menu tree (`Userwisemenu`, 2382) | 2392 → 2398 | identical |

**But supportapi has endpoints salewebservice does NOT:**

| Endpoint | salewebservice | supportapi |
|---|---|---|
| `getmrnlist` | **404** | 200 |
| `getgrnlist` | **404** | 200 |
| `getindentlist` | **404** | 200 |
| `issuelist` | **404** | 200 |
| `pendingindent` | **404** | 200 |
| `GetPaymentRequestList` | **404** | 200 |
| `TaskDropdown` | **404** | responds |
| `mrnandqcdetail` | **404** | responds |
| `GetExpenseListNew` | **404** | 200 |

### Recommendation: keep the white-labelled app on `supportapi`

Pointing it at `salewebservice` would 404 **nine modules**: MRN, GRN, Indent, Issue
Item, MRN-QC, Payment Request, Approval Hub, Create Task, and Globenex's
Reimbursement module. Since supportapi already serves Balaji's real data, there is
no data reason to switch.

> **MUST CONFIRM WITH BACKEND TEAM before shipping:** is `supportapi` the
> authoritative *production* host for Balaji's live data, or a support/secondary
> instance? The name suggests it may not be intended as production. This is the
> single biggest open risk in the whole white-label.

Note `lib/services/api_service/api_client.dart` currently has a commented-out
`salewebservice` line — leave it commented.

---

## 2. Modules Globenex has that Balaji never did — BONUS, keep

These were all "API-blocked / deferred" for Balaji because salewebservice lacks
their endpoints. On supportapi they work, so the white-label **gains** them:

MRN (two parallel implementations — see §5), GRN, Indent, Issue Item, MRN-QC,
Payment Request (list/detail/filter), Approval Hub (dashboard/list/detail/action/bulk),
Create Task, Globenex's own Reimbursement module.

**Action:** confirm with the client which of these Balaji users should actually see.
Visibility is server-driven via `Userwisemenu/usermenu`, so anything not granted in
the ERP menu simply won't appear — but verify per module rather than assuming.

---

## 3. Modules Balaji has that Globenex is MISSING — must port

### 3a. Issue Ticket / Complaints — ENTIRELY ABSENT from Globenex — HIGH
Balaji has: `screen/ui/issue_ticket/issue_ticket_screen.dart`,
`issue_tickit_controller/ticket_list_screen.dart`, `issue_ticket_controller.dart`,
`repo/create_issue_ticket_repo.dart`, plus models
(`get_tickit_list_issue_response_model`, `issue_type_response_model`,
`module_response_model`, `organization_response_model`,
`related_servies_response_model`, `user_name_response_model`).

Menu **2700 "Complaints"** IS present in the live menu tree, so users will expect
this screen. Nothing renders it in Globenex today.

### 3b. Lead Management support layer — verify
Balaji has `repo/lead_management_repo.dart` and ~20 lead models that Globenex
lacks. Globenex has the lead screens but its list may be unwired — Balaji's lead
list was previously broken (rendered hardcoded dummy data) and was fixed by wiring
`getleadentry/getleadentry` through `LeadManagementRepo`. **Check whether Globenex's
lead list actually loads real leads.**

Note: Balaji's `screen/ui/issue_ticket/lead_view/*` (8 screens) is confirmed
**unreachable dead code** — do NOT port it.

### 3c. Shared utils — low effort
`utils/app_drop_down.dart`, `utils/file_attachment_wigets.dart`,
`utils/battery_indicator.dart`, `fix/text_theme_fix.dart`.

---

## 4. Bug fixes made in Balaji — port status

### Already ported to Globenex ✅
Accounts menu-access filtering · `isInCart` JSON-parse fix · Order qty
type-to-enter · Cart qty edit fix · Product-detail app bar · Executive screen
trimmed to attendance-only · Image Preview redesign · Visit Plan Detail revamp ·
Collection revamp

### NOT yet in Globenex ❌

| Fix | Evidence | Priority |
|---|---|---|
| **Date-picker year restriction** — users can't select previous years | **9 live occurrences** in Globenex; 0 in Balaji | High |
| **Party dropdown uses dead endpoint** (`partydetail/Fullpartydetail` hangs) | **7 live callers** in Globenex; 2 in Balaji (those 2 intentionally left, need `executiveid`) | High |
| **Dashboard approval count** — all-time total, not 30-day | Globenex label still `PENDING APPROVALS`; Balaji `PENDING APPROVALS (30D)` | Medium |
| **Graph/Analytics revamp** — still old design | `_sectionCard` count 0 in Globenex, 4 in Balaji | Low (cosmetic) |

---

## 5. Divergences needing a decision

1. **Reimbursement — two different modules, different APIs.**
   - Balaji: `issue_ticket/reimbursemnt_view/` → `getexpenselist/getexpenselist`
     etc. Works on **both** hosts. Has the new status/type/date filter.
   - Globenex: `home/reimbursements/` → `GetExpenseListNew`, `SaveReimbursement`,
     `UploadReimbursementFile`. **404 on salewebservice**, fine on supportapi.
     Already has its own filter sheet.
   - **Decide which one ships.** Globenex's is richer (file upload); Balaji's is
     more portable. Do not ship both.

2. **MRN appears twice in Globenex:** `screen/ui/home/mrn/` and
   `screen/ui/home/mrn_module/`. Determine which is live and delete the other.

---

## 6. Branding / identity changes required

| Item | Globenex now | Change to |
|---|---|---|
| `applicationId` | `com.globenex.erp` | Balaji's (`balajialloys.digitalerp.biz` or a new id) |
| Firebase project | `digitalerp-globenex` | new Balaji project (or existing `digital-erp-c1233`) |
| `pubspec` version | `1.0.3+8` | **must exceed Play Store's current Balaji versionCode (24)** — else upload is rejected |
| Android label | `DigitalERP` | already correct |
| Signing keystore | Globenex's | Balaji's upload keystore |
| Logo / splash / icons | Globenex assets | Balaji assets |

Also sweep for hardcoded "Globenex" strings in assets and copy.

---

## 7. Suggested order of work

1. **Confirm supportapi is production-authoritative for Balaji** (blocks everything).
2. Decide the Reimbursement module; delete the duplicate MRN.
3. Port the 4 outstanding Balaji fixes (§4) — date picker and party dropdown first,
   both are user-facing breakage.
4. Port the Issue Ticket / Complaints module (§3a).
5. Verify Globenex's lead list loads real data (§3b).
6. Branding + version bump + keystore + Firebase (§6).
7. Confirm per-module menu visibility for Balaji users (§2).
8. Full on-device regression pass — little of this session's work has been
   device-tested in either app.

---

## 8. Cross-reference

Outstanding **backend** defects affecting both apps are documented separately in
`BACKEND_ISSUES.md` in the Balaji repo — notably the hanging party endpoint, the
approval status filter, and the unimplemented lead create / lead follow-up saves
(which need endpoint contracts from the backend team).
