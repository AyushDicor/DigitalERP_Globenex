// ─────────────────────────────────────────────────────────────────────────────
// employee_master_controller.dart
// State + API wiring for the Employee Master entry form.
//
// Dropdowns: Vendor (MRN Party), Site, Department, Designation, State and City
// all come from endpoints that are ALREADY live in this app — no new dropdown
// APIs were needed. Only the save itself waits on the backend team.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:digitalerp/repo/employee_master_repo.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/services/api_service/request_keys.dart';
import 'package:digitalerp/utils/show_message.dart';

import '../../home_controller.dart';
import '../employee_response/employee_model.dart';
import '../employee_response/employee_read_models.dart';
import '../employee_screens/employee_card_screen.dart';

/// Which attachment slot a pick/upload is running for.
enum EmpFileSlot { photo, aadhar, pan }

/// PF numbers are the 12-digit UAN; ESI insurance numbers are 17 digits.
/// Enforced as exact lengths so a half-typed number cannot reach the ERP.
const int kPfNoLength = 12;
const int kEsiNoLength = 17;

/// The save endpoint sits behind classic ASP.NET's default 4 MB request limit
/// (probed 2026-09-11: a 3 MB body is accepted, 4 MB fails with "Error reading
/// MIME multipart body part"). Three phone-camera shots blow straight through
/// that, so images are shrunk on pick and the total is checked before Save.
const int kServerRequestLimitBytes = 4 * 1024 * 1024;

/// Headroom for the text fields and multipart boundaries.
const int kAttachmentBudgetBytes = 3500 * 1024;

/// Longest edge for a picked image. An ID scan or a passport photo is
/// perfectly legible at this size and lands around 200–400 KB, versus
/// 2–4 MB straight off a modern phone camera.
const double kAttachmentMaxPx = 1600;

class EmployeeMasterController extends AppBaseController {
  final HomeController _home = Get.find<HomeController>();

  // ── Text fields ────────────────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final pfNoCtrl = TextEditingController();
  final esiNoCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dojCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final aadharNoCtrl = TextEditingController();
  final panNoCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  // ── Vendor (MRN's Party master — the ERP's supplier/vendor list) ─────────
  List<EmpOption> vendorList = [];
  EmpOption? selectedVendor;
  bool isLoadingVendor = false;

  // ── Site (shared indent/issue dropdown, type = Site) ─────────────────────
  List<EmpOption> siteList = [];
  EmpOption? selectedSite;
  bool isLoadingSite = false;

  // ── Gender (static — no API needed) ───────────────────────────────────────
  final List<EmpOption> genderList = const [
    EmpOption(id: '1', label: 'Male'),
    EmpOption(id: '2', label: 'Female'),
    EmpOption(id: '3', label: 'Other'),
  ];
  EmpOption? selectedGender;

  // ── Salary + work terms (fixed option lists — no API behind any of them) ──
  final List<EmpOption> salaryTypeList = const [
    EmpOption(id: 'Monthly', label: 'Monthly'),
    EmpOption(id: 'Daily', label: 'Daily'),
  ];
  EmpOption? selectedSalaryType;

  /// Week off 1–5.
  final List<EmpOption> weekOffList = const [
    EmpOption(id: '1', label: '1'),
    EmpOption(id: '2', label: '2'),
    EmpOption(id: '3', label: '3'),
    EmpOption(id: '4', label: '4'),
    EmpOption(id: '5', label: '5'),
  ];
  EmpOption? selectedWeekOff;

  final List<EmpOption> otApplicableList = const [
    EmpOption(id: 'Yes', label: 'Yes'),
    EmpOption(id: 'No', label: 'No'),
  ];
  EmpOption? selectedOtApplicable;

  static const String workHoursDefault = 'Default';
  static const String workHoursManual = 'Manual';

  final List<EmpOption> workHoursModeList = const [
    EmpOption(id: workHoursDefault, label: workHoursDefault),
    EmpOption(id: workHoursManual, label: workHoursManual),
  ];
  EmpOption? selectedWorkHoursMode;

  final dailyWorkingHoursCtrl = TextEditingController();

  /// Shift options behind the "Default" mode (POST api/shifttiming).
  List<EmpOption> shiftList = [];
  EmpOption? selectedShift;
  bool isLoadingShift = false;

  bool get isWorkHoursManual => selectedWorkHoursMode?.id == workHoursManual;
  bool get isWorkHoursDefault => selectedWorkHoursMode?.id == workHoursDefault;

  /// Default picks a shift; Manual types the hours. Switching between them
  /// clears the other side so a stale value from the mode they abandoned can
  /// never reach the payload.
  void onWorkHoursModeChanged(EmpOption? v) {
    selectedWorkHoursMode = v;
    if (v?.id == workHoursDefault) {
      dailyWorkingHoursCtrl.clear();
      if (shiftList.isEmpty && !isLoadingShift) fetchShifts();
    } else {
      selectedShift = null;
    }
    update();
  }

  void onShiftChanged(EmpOption? v) {
    selectedShift = v;
    update();
  }

  /// Fetched lazily — only someone choosing "Default" needs the shift list, so
  /// the form does not pay for this call on every open.
  Future<void> fetchShifts() async {
    isLoadingShift = true;
    update();
    try {
      final res = await EmployeeMasterRepo.getShiftList({
        'compid': _home.currentUserData?.compId ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
        'userid': _home.currentUserData?.userid ?? 0,
      });
      if (EmployeeMasterRepo.succeeded(res)) {
        shiftList = extractRows(res.data)
            .map((r) => EmpOption(
                  id: pick(r, ['id', 'Id', 'shiftid', 'ShiftId']),
                  label: pick(r, [
                    'shiftname',
                    'ShiftName',
                    'shift',
                    'name',
                    'Name',
                    'label'
                  ]),
                ))
            .where((o) => o.label.isNotEmpty)
            .toList();
      } else {
        log('fetchShifts failed: ${res.message}');
      }
    } catch (e) {
      log('fetchShifts error: $e');
    } finally {
      isLoadingShift = false;
      update();
    }
  }

  void onSalaryTypeChanged(EmpOption? v) {
    selectedSalaryType = v;
    update();
  }

  void onWeekOffChanged(EmpOption? v) {
    selectedWeekOff = v;
    update();
  }

  void onOtApplicableChanged(EmpOption? v) {
    selectedOtApplicable = v;
    update();
  }

  // ── Department (shared indent/issue dropdown, type = Department) ──────────
  List<EmpOption> departmentList = [];
  EmpOption? selectedDepartment;
  bool isLoadingDepartment = false;

  // ── Designation (live endpoint) ──────────────────────────────────────────
  List<EmpOption> designationList = [];
  EmpOption? selectedDesignation;
  bool isLoadingDesignation = false;

  // ── State / City (live endpoints, City depends on State) ─────────────────
  List<EmpOption> stateList = [];
  EmpOption? selectedState;
  bool isLoadingState = false;

  List<EmpOption> cityList = [];
  EmpOption? selectedCity;
  bool isLoadingCity = false;

  // ── Attachments ──────────────────────────────────────────────────────────
  final _picker = ImagePicker();

  String photoFileName = '';
  String aadharFileName = '';
  String panFileName = '';

  /// Local paths of the picked files. These are what actually get sent — the
  /// *FileName fields above are only the labels shown on the form.
  String photoLocalPath = '';
  String aadharLocalPath = '';
  String panLocalPath = '';

  EmpFileSlot? uploadingSlot;
  bool isUploading(EmpFileSlot slot) => uploadingSlot == slot;

  // ── Submit state ─────────────────────────────────────────────────────────
  bool isSubmitting = false;

  /// Set once the save has been attempted, so required-field outlines only turn
  /// red after the user actually pressed Save.
  bool showErrors = false;

  @override
  void onInit() {
    super.onInit();
    _loadDropdowns();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    pfNoCtrl.dispose();
    esiNoCtrl.dispose();
    phoneCtrl.dispose();
    dojCtrl.dispose();
    dobCtrl.dispose();
    aadharNoCtrl.dispose();
    panNoCtrl.dispose();
    addressCtrl.dispose();
    pincodeCtrl.dispose();
    dailyWorkingHoursCtrl.dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DROPDOWNS
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadDropdowns() async {
    await Future.wait([
      fetchVendors(),
      fetchSites(),
      fetchDepartments(),
      fetchDesignations(),
      fetchStates(),
    ]);
  }

  /// Vendors come from the MRN "Party" dropdown — that endpoint serves the
  /// ERP's supplier/vendor master, which is what MRN labels "Party / Supplier".
  Future<void> fetchVendors() async {
    isLoadingVendor = true;
    update();
    try {
      final res = await api.getMrnDropdownList({
        'type': 'Party',
        'compid': _home.currentUserData?.compId ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
        'userid': _home.currentUserData?.userid ?? 0,
        'partyid': 0,
        'siteid': 0,
        'dependentid': 0,
      });
      if ((res.status == 200 || res.success == true) && res.data != null) {
        vendorList = res.data!
            .map((o) => EmpOption(id: o.id, label: o.label))
            .where((o) => o.label.isNotEmpty)
            .toList();
      }
    } catch (e) {
      log('fetchVendors error: $e');
    } finally {
      isLoadingVendor = false;
      update();
    }
  }

  /// Sites reuse the same shared dropdown endpoint as Department, so this
  /// screen only talks to endpoints the app already depends on.
  Future<void> fetchSites() async {
    isLoadingSite = true;
    update();
    try {
      final res = await api.getIndentDropdownList({
        'type': 'Site',
        'compid': _home.currentUserData?.compId ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
        'userid': _home.currentUserData?.userid ?? 0,
        'siteid': 0,
        'partyid': 0,
        'dependentid': 0,
      });
      if (res.success == true || res.status == 200) {
        siteList = res.data
            .map((o) => EmpOption(id: o.id, label: o.label))
            .where((o) => o.label.isNotEmpty)
            .toList();
      }
    } catch (e) {
      log('fetchSites error: $e');
    } finally {
      isLoadingSite = false;
      update();
    }
  }

  void onVendorChanged(EmpOption? v) {
    selectedVendor = v;
    update();
  }

  void onSiteChanged(EmpOption? v) {
    selectedSite = v;
    update();
  }

  Future<void> fetchDepartments() async {
    isLoadingDepartment = true;
    update();
    try {
      final res = await api.getIndentDropdownList({
        'type': 'Department',
        'compid': _home.currentUserData?.compId ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
        'userid': _home.currentUserData?.userid ?? 0,
        'siteid': 0,
        'partyid': 0,
        'dependentid': 0,
      });
      if (res.success == true || res.status == 200) {
        departmentList =
            res.data.map((o) => EmpOption(id: o.id, label: o.label)).toList();
      }
    } catch (e) {
      log('fetchDepartments error: $e');
    } finally {
      isLoadingDepartment = false;
      update();
    }
  }

  Future<void> fetchDesignations() async {
    isLoadingDesignation = true;
    update();
    try {
      final res = await api.getSDesignationDropdown({
        RequestKeys.compId: '${_home.currentUserData?.compId ?? ''}',
      });
      if (res.status == 200) {
        designationList = (res.data ?? [])
            .map((d) => EmpOption(
                  id: '${d.designnationid ?? ''}',
                  label: d.designnation ?? '',
                ))
            .where((o) => o.label.isNotEmpty)
            .toList();
      }
    } catch (e) {
      log('fetchDesignations error: $e');
    } finally {
      isLoadingDesignation = false;
      update();
    }
  }

  Future<void> fetchStates() async {
    isLoadingState = true;
    update();
    try {
      final res = await api.getStateData({
        RequestKeys.compId: '${_home.currentUserData?.compId ?? ''}',
      });
      if (res.status == 200) {
        stateList = (res.data ?? [])
            .map((s) => EmpOption(
                  id: '${s.stateid ?? ''}',
                  label: s.statename ?? '',
                ))
            .where((o) => o.label.isNotEmpty)
            .toList();
      }
    } catch (e) {
      log('fetchStates error: $e');
    } finally {
      isLoadingState = false;
      update();
    }
  }

  /// Changing State invalidates whatever City was chosen underneath it.
  Future<void> onStateChanged(EmpOption? value) async {
    selectedState = value;
    selectedCity = null;
    cityList = [];
    update();
    if (value == null || value.id.isEmpty) return;
    await fetchCities(value.id);
  }

  Future<void> fetchCities(String stateId) async {
    isLoadingCity = true;
    update();
    try {
      final res = await api.getCityData({
        RequestKeys.compId: '${_home.currentUserData?.compId ?? ''}',
        RequestKeys.stateId: stateId,
      });
      if (res.status == 200) {
        cityList = (res.data ?? [])
            .map((c) => EmpOption(
                  id: '${c.cityid ?? ''}',
                  label: c.cityname ?? '',
                ))
            .where((o) => o.label.isNotEmpty)
            .toList();
      }
    } catch (e) {
      log('fetchCities error: $e');
    } finally {
      isLoadingCity = false;
      update();
    }
  }

  void onGenderChanged(EmpOption? v) {
    selectedGender = v;
    update();
  }

  void onDepartmentChanged(EmpOption? v) {
    selectedDepartment = v;
    update();
  }

  void onDesignationChanged(EmpOption? v) {
    selectedDesignation = v;
    update();
  }

  void onCityChanged(EmpOption? v) {
    selectedCity = v;
    update();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATES
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> pickDateOfJoining(BuildContext ctx) =>
      _pickDate(ctx, dojCtrl, DateTime.now());

  /// Birth dates open on a plausible year rather than today, so the user is not
  /// scrolling back three decades from the current month.
  Future<void> pickDateOfBirth(BuildContext ctx) => _pickDate(
        ctx,
        dobCtrl,
        DateTime(DateTime.now().year - 25),
        last: DateTime.now(),
      );

  Future<void> _pickDate(
    BuildContext ctx,
    TextEditingController ctrl,
    DateTime initial, {
    DateTime? last,
  }) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: last ?? DateTime(2100),
      builder: (c, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF5B6CF6)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
      update();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ATTACHMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Employee photo — camera or gallery.
  Future<void> pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 65,
      maxWidth: kAttachmentMaxPx,
      maxHeight: kAttachmentMaxPx,
    );
    if (picked == null) return;
    photoLocalPath = picked.path;
    update();
    await _upload(EmpFileSlot.photo, picked.path);
  }

  /// Aadhar / PAN — image or PDF.
  /// Aadhar / PAN captured with the camera — the common case in the field,
  /// where the card is in hand and there is no scan sitting on the phone.
  Future<void> captureDocument(EmpFileSlot slot, ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: kAttachmentMaxPx,
      maxHeight: kAttachmentMaxPx,
    );
    if (picked == null) return;
    await _upload(slot, picked.path);
  }

  /// Aadhar / PAN chosen from storage, where a PDF scan is also acceptable.
  Future<void> pickDocument(EmpFileSlot slot) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    await _upload(slot, path);
  }

  /// Attachments are NOT uploaded here.
  ///
  /// api/employeeonboarding takes the scans itself, as multipart file parts
  /// named photo / aadharfile / panfile, and answers with the stored
  /// photourl / aadharfileurl / panfileurl. So the picked file is just held
  /// until Save and sent with the record — one round trip instead of two, and
  /// no orphaned uploads when a form is abandoned.
  Future<void> _upload(EmpFileSlot slot, String path) async {
    final displayName = path.split(RegExp(r'[/\\]')).last;
    switch (slot) {
      case EmpFileSlot.photo:
        photoLocalPath = path;
        photoFileName = displayName;
        break;
      case EmpFileSlot.aadhar:
        aadharLocalPath = path;
        aadharFileName = displayName;
        break;
      case EmpFileSlot.pan:
        panLocalPath = path;
        panFileName = displayName;
        break;
    }
    update();
  }

  void removeFile(EmpFileSlot slot) {
    switch (slot) {
      case EmpFileSlot.photo:
        photoFileName = '';
        photoLocalPath = '';
        break;
      case EmpFileSlot.aadhar:
        aadharFileName = '';
        aadharLocalPath = '';
        break;
      case EmpFileSlot.pan:
        panFileName = '';
        panLocalPath = '';
        break;
    }
    update();
  }

  /// The scans to attach to the save, keyed by the ERP's form part names.
  Map<String, String> get attachmentParts => {
        'photo': photoLocalPath,
        'aadharfile': aadharLocalPath,
        'panfile': panLocalPath,
      }..removeWhere((_, v) => v.isEmpty);

  /// Combined size of every attachment queued for the save.
  int get attachmentBytes => attachmentParts.values
      .map((p) => File(p).existsSync() ? File(p).lengthSync() : 0)
      .fold(0, (a, b) => a + b);

  static String _mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  /// The form shows dates as dd/MM/yyyy, but the ERP parses a slashed date as
  /// MM/dd/yyyy (US order): verified 2026-09-11 — "11/09/2026" was stored as
  /// 9 November. ISO yyyy-MM-dd cannot be misread, so that is what goes over
  /// the wire. Anything unparseable is passed through untouched rather than
  /// silently dropped.
  static String _toApiDate(String ddMMyyyy) {
    final s = ddMMyyyy.trim();
    if (s.isEmpty) return '';
    try {
      return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parseStrict(s));
    } catch (_) {
      return s;
    }
  }

  File? get photoFile => photoLocalPath.isEmpty ? null : File(photoLocalPath);

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION + SUBMIT
  // ═══════════════════════════════════════════════════════════════════════════
  bool get nameMissing => nameCtrl.text.trim().isEmpty;
  bool get stateMissing => selectedState == null;
  bool get siteMissing => selectedSite == null;

  /// Every employee needs at least one identity document on file, but which one
  /// is up to them — an Aadhar upload or a PAN upload satisfies this.
  bool get idProofMissing => aadharFileName.isEmpty && panFileName.isEmpty;

  /// Whichever half of the Work Hours choice was made has to be filled in.
  bool get workHoursMissing =>
      isWorkHoursManual && dailyWorkingHoursCtrl.text.trim().isEmpty;
  bool get shiftMissing => isWorkHoursDefault && selectedShift == null;

  /// A PF or ESI number is either blank or complete — a partial one is a typo,
  /// not a shorter valid number, so both are checked on exact length.
  bool get pfNoInvalid =>
      pfNoCtrl.text.isNotEmpty && pfNoCtrl.text.length != kPfNoLength;
  bool get esiNoInvalid =>
      esiNoCtrl.text.isNotEmpty && esiNoCtrl.text.length != kEsiNoLength;

  /// Name, State and one identity document are the hard requirements — State
  /// because the web form marks it with an asterisk, Name because a nameless
  /// employee record is meaningless. Everything else may be left blank, but
  /// anything that IS filled in has to be well-formed.
  String? _firstProblem() {
    if (nameMissing) return 'Please enter the employee name';
    if (stateMissing) return 'Please select a state';
    if (siteMissing) return 'Please select a site';
    if (idProofMissing) {
      return 'Please upload at least one document — Aadhar card or PAN card';
    }
    if (shiftMissing) return 'Please select a shift';
    if (workHoursMissing) {
      return 'Please enter the daily working hours';
    }
    if (pfNoInvalid) {
      return 'PF number (UAN) must be $kPfNoLength digits';
    }
    if (esiNoInvalid) {
      return 'ESI number must be $kEsiNoLength digits';
    }
    final phone = phoneCtrl.text.trim();
    if (phone.isNotEmpty && phone.length != 10) {
      return 'Personal phone number must be 10 digits';
    }
    final pin = pincodeCtrl.text.trim();
    if (pin.isNotEmpty && pin.length != 6) {
      return 'Pincode must be 6 digits';
    }
    final aadhar = aadharNoCtrl.text.replaceAll(' ', '');
    if (aadhar.isNotEmpty && aadhar.length != 12) {
      return 'Aadhar card number must be 12 digits';
    }
    final pan = panNoCtrl.text.trim().toUpperCase();
    if (pan.isNotEmpty && !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
      return 'PAN must look like ABCDE1234F';
    }
    return null;
  }

  Future<void> save() async {
    showErrors = true;
    update();

    final problem = _firstProblem();
    if (problem != null) {
      ShowMessage.showSnackBar('Incomplete', problem);
      return;
    }

    if (uploadingSlot != null) {
      ShowMessage.showSnackBar('Please wait', 'A file is still uploading');
      return;
    }

    // PDFs picked from storage are not resized, so this can still trip even
    // though camera images are shrunk on pick. Better a clear message here
    // than the server's "Error reading MIME multipart body part".
    if (attachmentBytes > kAttachmentBudgetBytes) {
      ShowMessage.showSnackBar(
          'Attachments too large',
          'Photo + Aadhar + PAN come to ${_mb(attachmentBytes)} MB; the server '
              'accepts about ${_mb(kServerRequestLimitBytes)} MB per save. '
              'Please retake the larger ones, or use a smaller PDF.');
      return;
    }

    isSubmitting = true;
    update();

    try {
      final payload = EmployeeMasterPayload(
        compId: _home.currentUserData?.compId ?? 0,
        branchId: _home.currentUserData?.branchId ?? 0,
        userId: _home.currentUserData?.userid ?? 0,
        vendorId: selectedVendor?.id ?? '',
        vendorName: selectedVendor?.label ?? '',
        siteId: selectedSite?.id ?? '',
        siteName: selectedSite?.label ?? '',
        employeePhoto: photoFileName,
        employeeName: nameCtrl.text.trim(),
        genderId: selectedGender?.id ?? '',
        genderName: selectedGender?.label ?? '',
        departmentId: selectedDepartment?.id ?? '',
        departmentName: selectedDepartment?.label ?? '',
        pfNo: pfNoCtrl.text.trim(),
        esiNo: esiNoCtrl.text.trim(),
        designationId: selectedDesignation?.id ?? '',
        designationName: selectedDesignation?.label ?? '',
        personalPhoneNo: phoneCtrl.text.trim(),
        dateOfJoining: _toApiDate(dojCtrl.text),
        dateOfBirth: _toApiDate(dobCtrl.text),
        salaryType: selectedSalaryType?.id ?? '',
        weekOff: selectedWeekOff?.id ?? '',
        otApplicable: selectedOtApplicable?.id ?? '',
        workHoursMode: selectedWorkHoursMode?.id ?? '',
        shiftId: selectedShift?.id ?? '',
        shiftName: selectedShift?.label ?? '',
        dailyWorkingHours: dailyWorkingHoursCtrl.text.trim(),
        aadharCardNo: aadharNoCtrl.text.trim(),
        aadharCardFile: aadharFileName,
        panCardNo: panNoCtrl.text.trim().toUpperCase(),
        panCardFile: panFileName,
        fullAddress: addressCtrl.text.trim(),
        stateId: selectedState?.id ?? '',
        stateName: selectedState?.label ?? '',
        cityId: selectedCity?.id ?? '',
        cityName: selectedCity?.label ?? '',
        pincode: pincodeCtrl.text.trim(),
      );

      final res = await EmployeeMasterRepo.saveEmployeeMaster(
        payload.toJson(),
        files: attachmentParts,
      );

      // Deliberately NOT `res.status == true` — this API answers HTTP 200 even
      // when it rejects the request, so trusting the HTTP code once showed a
      // "Saved" toast for a record that was never written.
      if (EmployeeMasterRepo.succeeded(res)) {
        ShowMessage.showSnackBar(
            'Saved',
            res.message?.isNotEmpty == true
                ? res.message!
                : 'Employee saved successfully');
        // Card first, form cleared behind it — the card is built from a
        // snapshot, so resetting the form does not blank it out.
        final card = buildCardData(res.data);
        final partyId = partyIdOf(res.data);
        resetForm();
        // partyId lets the card screen pull the authoritative version — company
        // name, logo and QR — from api/employeeidcard.
        Get.off(() => EmployeeCardScreen(data: card, partyId: partyId));
        return;
      }

      if (EmployeeMasterRepo.isNotDeployed(res)) {
        ShowMessage.showSnackBar('Not available yet',
            'The Employee Master save API is not live yet. The form is ready and will work as soon as the backend deploys it.');
      } else if ((res.message ?? '').toLowerCase().contains('mime multipart')) {
        // The server's wording for "your request was over the size limit".
        // Say that, in words a site supervisor can act on.
        ShowMessage.showSnackBar(
            'Attachments too large',
            'The server could not read the upload — the files are probably '
                'over its ${_mb(kServerRequestLimitBytes)} MB limit '
                '(this save was ${_mb(attachmentBytes)} MB). '
                'Please retake the photos or use smaller files.');
      } else {
        ShowMessage.showSnackBar(
            'Save failed',
            res.message?.isNotEmpty == true
                ? res.message!
                : 'Could not save the employee');
      }
    } catch (e) {
      log('saveEmployeeMaster error: $e');
      ShowMessage.showSnackBar('Save failed', '$e');
    } finally {
      isSubmitting = false;
      update();
    }
  }

  /// The ERP's record id from a save response — the key everything downstream
  /// (detail, ID card) is looked up by.
  static String partyIdOf(dynamic saveResponse) {
    if (saveResponse is! Map) return '';
    final data = saveResponse['data'];
    return ((data is Map ? data['partyid'] : null) ??
            saveResponse['partyid'] ??
            '')
        .toString();
  }

  /// Snapshot of what the ID card shows, taken before the form is cleared.
  ///
  /// This is only the starting picture — once the card screen has a partyId it
  /// replaces these with api/employeeidcard's version, which is the only source
  /// for the company name, logo and QR payload. The photo here is the local
  /// file, so the card is not blank while that call is in flight.
  EmpCardData buildCardData([dynamic saveResponse]) {
    String employeeId = '';
    if (saveResponse is Map) {
      final data = saveResponse['data'];
      // The save answers {"data":{"partyid":256471,"empid":"…"}} — partyid is
      // the ERP's record id and what the detail endpoint is keyed on.
      employeeId = ((data is Map ? (data['partyid'] ?? data['empid']) : null) ??
              saveResponse['partyid'] ??
              '')
          .toString();
    }
    return EmpCardData(
      name: nameCtrl.text.trim(),
      designation: selectedDesignation?.label ?? '',
      department: selectedDepartment?.label ?? '',
      vendor: selectedVendor?.label ?? '',
      site: selectedSite?.label ?? '',
      phone: phoneCtrl.text.trim(),
      employeeId: employeeId,
      photoPath: photoLocalPath,
    );
  }

  void resetForm() {
    nameCtrl.clear();
    pfNoCtrl.clear();
    esiNoCtrl.clear();
    phoneCtrl.clear();
    dojCtrl.clear();
    dobCtrl.clear();
    aadharNoCtrl.clear();
    panNoCtrl.clear();
    addressCtrl.clear();
    pincodeCtrl.clear();
    dailyWorkingHoursCtrl.clear();

    selectedVendor = null;
    selectedSite = null;
    selectedSalaryType = null;
    selectedWeekOff = null;
    selectedOtApplicable = null;
    selectedWorkHoursMode = null;
    selectedShift = null;
    selectedGender = null;
    selectedDepartment = null;
    selectedDesignation = null;
    selectedState = null;
    selectedCity = null;
    cityList = [];

    photoFileName = '';
    photoLocalPath = '';
    aadharFileName = '';
    aadharLocalPath = '';
    panFileName = '';
    panLocalPath = '';

    showErrors = false;
    update();
  }
}
