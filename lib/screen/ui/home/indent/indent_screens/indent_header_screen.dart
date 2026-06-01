// ─────────────────────────────────────────────────────────────────────────────
// indent_header_screen.dart
// Step 0 — Indent header details (mirrors GrnSourceScreen pattern).
// Fields: Indent No (read-only), Indent Date, Request By, Department,
//         Job Type, Site, Godown, Priority, Work Order, Site Incharge, Remarks
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../indent_controller/indent_controller.dart';
import '../indent_response/indent_model.dart';
import '../indent_widgets.dart';

class IndentHeaderScreen extends StatelessWidget {
  const IndentHeaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IndentController>(builder: (ctrl) {
      return Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            child: Column(children: [
              // ── Indent Header card ──────────────────────────────────────
              IndentCard(
                child: Column(children: [
                  const IndentSectionHead('Indent Header'),
                  Row(children: [
                    Expanded(
                      child: IndentField(
                        label: 'Indent No.',
                        controller: ctrl.indentDisplayNoCtrl,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: IndentField(
                        label: 'Indent Date',
                        controller: ctrl.indentDateCtrl,
                        readOnly: true,
                        onTap: () => ctrl.pickIndentDate(context),
                        suffix: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.calendar_today_outlined,
                              size: 16, color: indTextSecondary),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),

              // ── Request Details card ────────────────────────────────────
              IndentCard(
                child: Column(children: [
                  const IndentSectionHead('Request Details'),

                  // Request By (pre-filled with logged-in user, editable)
                  IndentField(
                    label: 'Request By',
                    controller: ctrl.requestByCtrl,
                    hint: 'Enter requester name',
                  ),
                  const SizedBox(height: 10),

                  // Department
                  IndentSearchableDropdown<IndentDropdownOption>(
                    label: 'Department',
                    value: ctrl.selectedDepartment,
                    items: ctrl.departmentList,
                    isLoading: ctrl.isLoadingDepartment,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setDepartment,
                    hint: 'Select department…',
                  ),
                  const SizedBox(height: 10),

                  // Job Type
                  IndentSearchableDropdown<IndentDropdownOption>(
                    label: 'Job Type',
                    value: ctrl.selectedJobType,
                    items: ctrl.jobTypeList,
                    isLoading: ctrl.isLoadingJobType,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setJobType,
                    hint: 'Select job type…',
                  ),
                  const SizedBox(height: 10),

                  // Priority
                  IndentDropdown(
                    label: 'Priority',
                    value: ctrl.selectedPriority,
                    items: ctrl.priorityOptions,
                    onChanged: (v) => ctrl.setPriority(v ?? 'Medium'),
                  ),
                ]),
              ),

              // ── Site & Godown card ──────────────────────────────────────
              IndentCard(
                child: Column(children: [
                  const IndentSectionHead('Site & Godown'),

                  // Site (searchable)
                  IndentSearchableDropdown<IndentDropdownOption>(
                    label: 'Site Name',
                    value: ctrl.selectedSite,
                    items: ctrl.siteList,
                    isLoading: ctrl.isLoadingSite,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setSite,
                    hint: 'Select site…',
                  ),
                  const SizedBox(height: 10),

                  // Godown
                  IndentSearchableDropdown<IndentDropdownOption>(
                    label: 'Godown',
                    value: ctrl.selectedGodown,
                    items: ctrl.godownList,
                    isLoading: ctrl.isLoadingGodown,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setGodown,
                    hint: 'Select godown…',
                  ),
                  const SizedBox(height: 10),

                  // Work Order No.
                  IndentSearchableDropdown<IndentDropdownOption>(
                    label: 'Work Order No.',
                    value: ctrl.selectedWorkOrder,
                    items: ctrl.workOrderList,
                    isLoading: ctrl.isLoadingWorkOrder,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setWorkOrder,
                    hint: 'Search work order…',
                  ),
                  const SizedBox(height: 10),

                  // Site Incharge
                  IndentField(
                    label: 'Site Incharge',
                    controller: ctrl.siteInchargeCtrl,
                    hint: 'Enter site incharge name',
                  ),
                ]),
              ),

              // ── Remarks card ────────────────────────────────────────────
              IndentCard(
                child: Column(children: [
                  const IndentSectionHead('Remarks'),
                  IndentField(
                    label: 'Remarks',
                    controller: ctrl.remarksCtrl,
                    hint: 'Any additional notes…',
                    minLines: 3,
                    maxLines: 5,
                  ),
                ]),
              ),
            ]),
          ),
        ),

        // ── Bottom CTA ───────────────────────────────────────────────────
        _bottomCta(ctrl),
      ]);
    });
  }

  Widget _bottomCta(IndentController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: indBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: IndentPrimaryBtn(
          label: 'Continue → Add Items',
          icon: Icons.arrow_forward_rounded,
          onTap: () {
            if (ctrl.selectedSite == null) {
              // Show snack via GetX
              Get.snackbar('Validation', 'Please select a site',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                  margin: const EdgeInsets.all(12));
              return;
            }
            ctrl.nextStep();
          },
        ),
      ),
    );
  }
}