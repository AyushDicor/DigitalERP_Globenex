// ─────────────────────────────────────────────────────────────────────────────
// employee_master_controller.dart
// State + API wiring for the Employee Master entry form.
//
// Dropdowns: Designation, State and City come from endpoints that are ALREADY
// live in this app; Department comes from the shared indent/issue dropdown.
// Only the save itself waits on the backend team.
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

/// Which attachment slot a pick/upload is running for.
enum EmpFileSlot { photo, aadhar, pan }

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

  // ── Gender (static — no API needed) ───────────────────────────────────────
  final List<EmpOption> genderList = const [
    EmpOption(id: '1', label: 'Male'),
    EmpOption(id: '2', label: 'Female'),
    EmpOption(id: '3', label: 'Other'),
  ];
  EmpOption? selectedGender;

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

  /// Local path of the picked photo, so the form can preview it immediately
  /// instead of waiting for a round trip.
  String photoLocalPath = '';

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
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DROPDOWNS
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadDropdowns() async {
    await Future.wait([
      fetchDepartments(),
      fetchDesignations(),
      fetchStates(),
    ]);
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
        departmentList = res.data
            .map((o) => EmpOption(id: o.id, label: o.label))
            .toList();
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
    final picked = await _picker.pickImage(source: source, imageQuality: 65);
    if (picked == null) return;
    photoLocalPath = picked.path;
    update();
    await _upload(EmpFileSlot.photo, picked.path);
  }

  /// Aadhar / PAN — image or PDF.
  Future<void> pickDocument(EmpFileSlot slot) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    await _upload(slot, path);
  }

  Future<void> _upload(EmpFileSlot slot, String path) async {
    uploadingSlot = slot;
    update();
    try {
      final res = await EmployeeMasterRepo.uploadEmployeeFile(path);
      if (res.status == true && res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>?;
        final fileName = data?['data']?['filename'] as String? ??
            data?['filename'] as String? ??
            '';
        if (fileName.isEmpty) {
          ShowMessage.showSnackBar(
              'Upload', 'Upload succeeded but no file name came back');
        } else {
          switch (slot) {
            case EmpFileSlot.photo:
              photoFileName = fileName;
              break;
            case EmpFileSlot.aadhar:
              aadharFileName = fileName;
              break;
            case EmpFileSlot.pan:
              panFileName = fileName;
              break;
          }
        }
      } else {
        // Clear the optimistic photo preview so the UI never shows an image
        // the server does not actually have.
        if (slot == EmpFileSlot.photo) photoLocalPath = '';
        ShowMessage.showSnackBar(
            'Upload failed', res.message ?? 'Could not upload the file');
      }
    } catch (e) {
      if (slot == EmpFileSlot.photo) photoLocalPath = '';
      log('upload error: $e');
      ShowMessage.showSnackBar('Upload failed', '$e');
    } finally {
      uploadingSlot = null;
      update();
    }
  }

  void removeFile(EmpFileSlot slot) {
    switch (slot) {
      case EmpFileSlot.photo:
        photoFileName = '';
        photoLocalPath = '';
        break;
      case EmpFileSlot.aadhar:
        aadharFileName = '';
        break;
      case EmpFileSlot.pan:
        panFileName = '';
        break;
    }
    update();
  }

  File? get photoFile =>
      photoLocalPath.isEmpty ? null : File(photoLocalPath);

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION + SUBMIT
  // ═══════════════════════════════════════════════════════════════════════════
  bool get nameMissing => nameCtrl.text.trim().isEmpty;
  bool get stateMissing => selectedState == null;

  /// Name and State are the only hard requirements — State because the web form
  /// marks it with an asterisk, Name because a nameless employee record is
  /// meaningless. Everything else the ERP accepts blank.
  String? _firstProblem() {
    if (nameMissing) return 'Please enter the employee name';
    if (stateMissing) return 'Please select a state';
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

    isSubmitting = true;
    update();

    try {
      final payload = EmployeeMasterPayload(
        compId: _home.currentUserData?.compId ?? 0,
        branchId: _home.currentUserData?.branchId ?? 0,
        userId: _home.currentUserData?.userid ?? 0,
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
        dateOfJoining: dojCtrl.text.trim(),
        dateOfBirth: dobCtrl.text.trim(),
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

      final res =
          await EmployeeMasterRepo.saveEmployeeMaster(payload.toJson());

      if (res.status == true) {
        ShowMessage.showSnackBar(
            'Saved', res.message?.isNotEmpty == true
                ? res.message!
                : 'Employee saved successfully');
        resetForm();
        Get.back();
        return;
      }

      // An undeployed endpoint is a very different problem from a rejected
      // form, so name it. IIS answers a missing route with an HTML 404 page,
      // which BaseApiHelper cannot json-decode — it surfaces as "Bad response
      // format" with no status code rather than as a 404. Treat both as
      // "not deployed": a live JSON API always answers with JSON.
      final looksUndeployed = res.statusCode == 404 ||
          (res.message ?? '').toLowerCase().contains('bad response format');
      if (looksUndeployed) {
        ShowMessage.showSnackBar('Not available yet',
            'The Employee Master save API is not live yet. The form is ready and will work as soon as the backend deploys it.');
      } else {
        ShowMessage.showSnackBar(
            'Save failed', res.message?.isNotEmpty == true ? res.message! : 'Could not save the employee');
      }
    } catch (e) {
      log('saveEmployeeMaster error: $e');
      ShowMessage.showSnackBar('Save failed', '$e');
    } finally {
      isSubmitting = false;
      update();
    }
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

    selectedGender = null;
    selectedDepartment = null;
    selectedDesignation = null;
    selectedState = null;
    selectedCity = null;
    cityList = [];

    photoFileName = '';
    photoLocalPath = '';
    aadharFileName = '';
    panFileName = '';

    showErrors = false;
    update();
  }
}
