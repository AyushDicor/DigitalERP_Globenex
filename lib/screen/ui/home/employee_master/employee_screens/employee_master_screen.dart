// ─────────────────────────────────────────────────────────────────────────────
// employee_master_screen.dart
// Employee Master entry form — General / Document / Address details,
// mirroring the sections of the web ERP screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../employee_controller/employee_master_controller.dart';
import '../employee_response/employee_model.dart';
import '../employee_widgets.dart';

class EmployeeMasterScreen extends StatelessWidget {
  const EmployeeMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeMasterController>(
      init: EmployeeMasterController(),
      builder: (ctrl) => Scaffold(
        backgroundColor: empSurfaceColor,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _appBar(),
            const Divider(height: 1, color: empBorderColor),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(children: [
                  _generalDetails(context, ctrl),
                  _documentDetails(ctrl),
                  _addressDetails(ctrl),
                ]),
              ),
            ),
            _bottomBar(ctrl),
          ]),
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _appBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
      child: Row(children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: empTextPrimary),
          ),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Employee Master',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: empTextPrimary)),
            Text('Add a new employee',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: empTextSecondary)),
          ]),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL DETAILS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _generalDetails(BuildContext context, EmployeeMasterController ctrl) {
    return EmpCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const EmpSectionHead('General Details'),

        // Photo + Name
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _photoPicker(context, ctrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmpField(
                    label: 'Employee Name',
                    controller: ctrl.nameCtrl,
                    hint: 'Full name',
                    required: true,
                    hasError: ctrl.showErrors && ctrl.nameMissing,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => ctrl.update(),
                  ),
                  const SizedBox(height: 10),
                  EmpDropdown<EmpOption>(
                    label: 'Gender',
                    value: ctrl.selectedGender,
                    items: ctrl.genderList,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.onGenderChanged,
                  ),
                ]),
          ),
        ]),
        const SizedBox(height: 10),

        // Department + Designation
        Row(children: [
          Expanded(
            child: EmpDropdown<EmpOption>(
              label: 'Department',
              value: ctrl.selectedDepartment,
              items: ctrl.departmentList,
              isLoading: ctrl.isLoadingDepartment,
              itemLabel: (o) => o.label,
              onChanged: ctrl.onDepartmentChanged,
              emptyNote: 'No departments returned',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: EmpDropdown<EmpOption>(
              label: 'Designation',
              value: ctrl.selectedDesignation,
              items: ctrl.designationList,
              isLoading: ctrl.isLoadingDesignation,
              itemLabel: (o) => o.label,
              onChanged: ctrl.onDesignationChanged,
              emptyNote: 'No designations returned',
            ),
          ),
        ]),
        const SizedBox(height: 10),

        // PF No + ESI No
        Row(children: [
          Expanded(
            child: EmpField(
              label: 'PF No',
              controller: ctrl.pfNoCtrl,
              hint: 'PF number',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: EmpField(
              label: 'ESI No',
              controller: ctrl.esiNoCtrl,
              hint: 'ESI number',
            ),
          ),
        ]),
        const SizedBox(height: 10),

        // Personal phone
        EmpField(
          label: 'Personal Phone Number',
          controller: ctrl.phoneCtrl,
          hint: '10-digit mobile number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 10),

        // Dates
        Row(children: [
          Expanded(
            child: EmpField(
              label: 'Date of Joining',
              controller: ctrl.dojCtrl,
              hint: 'dd/mm/yyyy',
              readOnly: true,
              onTap: () => ctrl.pickDateOfJoining(context),
              suffix: const Icon(Icons.calendar_today_rounded,
                  size: 15, color: empTextSecondary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: EmpField(
              label: 'Date of Birth',
              controller: ctrl.dobCtrl,
              hint: 'dd/mm/yyyy',
              readOnly: true,
              onTap: () => ctrl.pickDateOfBirth(context),
              suffix: const Icon(Icons.cake_outlined,
                  size: 15, color: empTextSecondary),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _photoPicker(BuildContext context, EmployeeMasterController ctrl) {
    final busy = ctrl.isUploading(EmpFileSlot.photo);
    final file = ctrl.photoFile;
    return GestureDetector(
      onTap: busy ? null : () => _photoSourceSheet(context, ctrl),
      child: Column(children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: empSurfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: ctrl.photoFileName.isNotEmpty
                    ? empGreenColor.withValues(alpha: 0.5)
                    : empBorderColor),
            image: file != null
                ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                : null,
          ),
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: empBlueColor))
              : file == null
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 20, color: empTextSecondary),
                        SizedBox(height: 4),
                        Text('Photo',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: empTextSecondary)),
                      ],
                    )
                  : null,
        ),
        if (file != null && !busy) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => ctrl.removeFile(EmpFileSlot.photo),
            child: const Text('Remove',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: empRedColor)),
          ),
        ],
      ]),
    );
  }

  void _photoSourceSheet(BuildContext context, EmployeeMasterController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 14),
          const Text('Employee Photo',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: empTextPrimary)),
          const SizedBox(height: 6),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined,
                color: empBlueColor, size: 20),
            title: const Text('Take a photo',
                style: TextStyle(fontSize: 13, color: empTextPrimary)),
            onTap: () {
              Navigator.pop(ctx);
              ctrl.pickPhoto(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: empBlueColor, size: 20),
            title: const Text('Choose from gallery',
                style: TextStyle(fontSize: 13, color: empTextPrimary)),
            onTap: () {
              Navigator.pop(ctx);
              ctrl.pickPhoto(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOCUMENT DETAILS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _documentDetails(EmployeeMasterController ctrl) {
    return EmpCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const EmpSectionHead('Document Details'),

        // Aadhar
        EmpField(
          label: 'Aadhar Card No',
          controller: ctrl.aadharNoCtrl,
          hint: '12-digit Aadhar number',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
        ),
        const SizedBox(height: 10),
        EmpAttachment(
          label: 'Aadhar Card Attachment',
          fileName: ctrl.aadharFileName,
          isUploading: ctrl.isUploading(EmpFileSlot.aadhar),
          onPick: () => ctrl.pickDocument(EmpFileSlot.aadhar),
          onRemove: () => ctrl.removeFile(EmpFileSlot.aadhar),
        ),
        const SizedBox(height: 14),

        // PAN
        EmpField(
          label: 'Pan Card No',
          controller: ctrl.panNoCtrl,
          hint: 'ABCDE1234F',
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(10),
            _UpperCaseFormatter(),
          ],
        ),
        const SizedBox(height: 10),
        EmpAttachment(
          label: 'Pan Card Attachment',
          fileName: ctrl.panFileName,
          isUploading: ctrl.isUploading(EmpFileSlot.pan),
          onPick: () => ctrl.pickDocument(EmpFileSlot.pan),
          onRemove: () => ctrl.removeFile(EmpFileSlot.pan),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADDRESS DETAILS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _addressDetails(EmployeeMasterController ctrl) {
    return EmpCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const EmpSectionHead('Address Details'),
        EmpField(
          label: 'Full Address',
          controller: ctrl.addressCtrl,
          hint: 'House / street / locality',
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: EmpDropdown<EmpOption>(
              label: 'State',
              value: ctrl.selectedState,
              items: ctrl.stateList,
              isLoading: ctrl.isLoadingState,
              required: true,
              hasError: ctrl.showErrors && ctrl.stateMissing,
              itemLabel: (o) => o.label,
              onChanged: ctrl.onStateChanged,
              emptyNote: 'No states returned',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: EmpDropdown<EmpOption>(
              label: 'City',
              value: ctrl.selectedCity,
              items: ctrl.cityList,
              isLoading: ctrl.isLoadingCity,
              // City is meaningless before a state is chosen, and the list is
              // fetched per state, so keep it locked until then.
              enabled: ctrl.selectedState != null,
              hint: ctrl.selectedState == null ? 'Select state first' : 'Select',
              itemLabel: (o) => o.label,
              onChanged: ctrl.onCityChanged,
              emptyNote: 'No cities for this state',
            ),
          ),
        ]),
        const SizedBox(height: 10),
        EmpField(
          label: 'Pincode',
          controller: ctrl.pincodeCtrl,
          hint: '6-digit pincode',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ]),
    );
  }

  // ── Save bar ───────────────────────────────────────────────────────────────
  Widget _bottomBar(EmployeeMasterController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: empBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: ctrl.isSubmitting ? null : ctrl.resetForm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: empSurfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: empBorderColor),
                ),
                child: const Text('Reset',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: empTextSecondary)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: EmpPrimaryBtn(
              label: 'Save',
              icon: Icons.check_rounded,
              isBusy: ctrl.isSubmitting,
              onTap: ctrl.save,
            ),
          ),
        ]),
      ),
    );
  }
}

/// PAN numbers are stored uppercase in the ERP; upper-casing as the user types
/// avoids a mismatch between what they see and what gets posted.
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
