import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../mrn_controller/mrn_controller.dart';
import '../mrn_response/mrn_models.dart';
import '../mrn_widgets.dart';

class MrnSourceScreen extends StatelessWidget {
  const MrnSourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MrnController>(builder: (ctrl) {
      return Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            child: Column(children: [

              // ── MRN Header ───────────────────────────────────────────────
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('MRN Header'),
                  // Row 1: Series Type + MRN Date
                  Row(children: [
                    Expanded(
                      child: MrnSearchableDropdown<MrnDropdownOption>(
                        label: 'Series Type',
                        value: ctrl.selectedSeriesType,
                        items: ctrl.seriesTypeList,
                        isLoading: ctrl.isLoadingSeriesType,
                        itemLabel: (o) => o.label,
                        onChanged: ctrl.setSeriesType,
                        hint: 'Select series',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MrnField(
                        label: 'MRN Date',
                        controller: ctrl.mrnDateCtrl,
                        readOnly: true,
                        onTap: () => ctrl.pickMrnDate(context),
                        suffix: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.calendar_today_outlined,
                              size: 18, color: newTextSecondary),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  // MRN Number (read-only, full width)
                  MrnField(
                    label: 'MRN No.',
                    controller: TextEditingController(text: ctrl.mrnNumber),
                    readOnly: true,
                  ),
                ]),
              ),

              // ── Source selection (3 tiles only) ──────────────────────────
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('Select Item Source'),
                  Row(children: [
                    Expanded(
                      child: _sourceChip(ctrl, MrnSourceType.purchaseOrder,
                          '📄', 'Purchase Order', 'Import from PO',
                          newBlueLightColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _sourceChip(ctrl, MrnSourceType.directPurchase,
                          '🛒', 'Direct Purchase', 'Manual entry',
                          newOrangeLightColor),
                    ),
                  ]),
                ]),
              ),

              // ── Party / Site details ──────────────────────────────────────
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('Party & Site Details'),

                  // Party Name (free text)
                  // ── Party Name (searchable dropdown) ──────────────────────────────────────
                  MrnSearchableDropdown<MrnDropdownOption>(
                    label: 'Party Name',
                    value: ctrl.selectedParty,
                    items: ctrl.partyList,
                    isLoading: ctrl.isLoadingParty,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setParty,
                    hint: 'Search party / supplier…',
                  ),
                  const SizedBox(height: 10),

                  // Site (searchable dropdown)
                  MrnSearchableDropdown<MrnDropdownOption>(
                    label: 'Site',
                    value: ctrl.selectedSite,
                    items: ctrl.siteList,
                    isLoading: ctrl.isLoadingSite,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setSite,
                    hint: 'Search site…',
                  ),
                  const SizedBox(height: 10),

                  // Godown (searchable dropdown)
                  MrnSearchableDropdown<MrnDropdownOption>(
                    label: 'Godown',
                    value: ctrl.selectedGodown,
                    items: ctrl.godownList,
                    isLoading: ctrl.isLoadingGodown,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setGodown,
                    hint: 'Search godown…',
                  ),


                  // After existing Godown dropdown:
                  const SizedBox(height: 10),

// Addresses (read-only, from backend)
//                   if (ctrl.isLoadingAddresses)
//                     const Center(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10),
//                         child: CircularProgressIndicator(strokeWidth: 1.5, color: newBlueColor),
//                       ),
//                     )
//                   else ...[
//                     if (ctrl.shippingAddress != null)
//                       _addressTile(
//                         icon: Icons.local_shipping_outlined,
//                         label: 'Shipping Address',
//                         address: ctrl.shippingAddress!,
//                         color: newBlueColor,
//                         bg: newBlueLightColor,
//                       ),
//                     if (ctrl.shippingAddress != null && ctrl.billingAddress != null)
//                       const SizedBox(height: 10),
//                     if (ctrl.billingAddress != null)
//                       _addressTile(
//                         icon: Icons.receipt_long_outlined,
//                         label: 'Billing Address',
//                         address: ctrl.billingAddress!,
//                         color: newGreenColor,
//                         bg: newGreenLightColor,
//                       ),
//                   ],

                  // Bill No + Bill Date
                  Row(children: [
                    Expanded(
                      child: MrnField(
                        label: 'Bill No.',
                        controller: ctrl.billNoCtrl,
                        hint: 'Enter bill number',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MrnField(
                        label: 'Bill Date',
                        controller: ctrl.billDateCtrl,
                        readOnly: true,
                        hint: 'DD/MM/YYYY',
                        onTap: () => ctrl.pickBillDate(context),
                        suffix: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.calendar_today_outlined,
                              size: 16, color: newTextSecondary),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),

                  // Received By (non-editable)
                  MrnField(
                    label: 'Received By',
                    controller: TextEditingController(text: ctrl.receivedByName),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),

                  // Challan No + Challan Date
                  Row(children: [
                    Expanded(
                      child: MrnField(
                        label: 'Challan No.',
                        controller: ctrl.challanNoCtrl,
                        hint: 'Enter challan number',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MrnField(
                        label: 'Challan Date',
                        controller: ctrl.challanDateCtrl,
                        readOnly: true,
                        hint: 'DD/MM/YYYY',
                        onTap: () => ctrl.pickChallanDate(context),
                        suffix: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.calendar_today_outlined,
                              size: 16, color: newTextSecondary),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),

              // ── Attachments ───────────────────────────────────────────────
              MrnCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MrnSectionHead('Attachments'),

                      // Attachment Type checklist dropdown
                      _attachmentTypeChecklist(ctrl),
                      const SizedBox(height: 12),

                      // Bill Attachment (shown when Bill is checked)
                      if (ctrl.selectedAttachmentTypes
                          .contains(MrnAttachmentType.bill)) ...[
                        _attachmentSection(
                          context: context,
                          label: 'Bill Attachment',
                          docs: ctrl.billAttachments,
                          onCamera: ctrl.pickBillFromCamera,
                          onGallery: ctrl.pickBillFromGallery,
                          onFile: ctrl.pickBillFile,
                          onRemove: ctrl.removeBillAttachment,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Challan Attachment (shown when Challan is checked)
                      if (ctrl.selectedAttachmentTypes
                          .contains(MrnAttachmentType.challan)) ...[
                        _attachmentSection(
                          context: context,
                          label: 'Challan Attachment',
                          docs: ctrl.challanAttachments,
                          onCamera: ctrl.pickChallanFromCamera,
                          onGallery: ctrl.pickChallanFromGallery,
                          onFile: ctrl.pickChallanFile,
                          onRemove: ctrl.removeChallanAttachment,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Reason for N/A (shown when no attachments uploaded)
                      if (ctrl.billAttachments.isEmpty &&
                          ctrl.challanAttachments.isEmpty) ...[
                        MrnField(
                          label: 'Reason for N/A Attachment',
                          controller: ctrl.reasonNACtrl,
                          hint: 'Explain why no attachment is available…',
                          minLines: 3,
                        ),
                      ],
                    ]),
              ),

              // ── Additional details ────────────────────────────────────────
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('Additional Details'),

                  // Paid Type (searchable)
                  MrnSearchableDropdown<MrnDropdownOption>(
                    label: 'Paid Type',
                    value: ctrl.selectedPaidType,
                    items: ctrl.paidTypeList,
                    isLoading: false,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setPaidType,
                    hint: 'Select paid type…',
                  ),
                  const SizedBox(height: 10),

// Paid By — only shown when Employee is selected
                  if (ctrl.selectedPaidType?.id == 'Employee') ...[
                    MrnSearchableDropdown<MrnDropdownOption>(
                      label: 'Paid By',
                      value: ctrl.selectedPaidBy,
                      items: ctrl.paidByList,
                      isLoading: ctrl.isLoadingPaidBy,
                      itemLabel: (o) => o.label,
                      onChanged: ctrl.setPaidBy,
                      hint: 'Search employee…',
                    ),
                    const SizedBox(height: 10),
                  ],

                  // QC Required (Yes / No only)
                  MrnDropdown(
                    label: 'QC Required',
                    value: ctrl.selectedQcRequired,
                    items: ctrl.qcRequiredOptions,
                    onChanged: (v) => ctrl.setQcRequired(v ?? 'Yes'),
                  ),
                  const SizedBox(height: 10),

                  // Customer PO (searchable)
                  MrnSearchableDropdown<MrnDropdownOption>(
                    label: 'Customer PO',
                    value: ctrl.selectedCustomerPo,
                    items: ctrl.customerPoList,
                    isLoading: ctrl.isLoadingCustomerPo,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setCustomerPo,
                    hint: 'Search customer PO…',
                  ),
                  const SizedBox(height: 10),

                  // Job Type (searchable)
                  MrnSearchableDropdown<MrnDropdownOption>(
                    label: 'Job Type',
                    value: ctrl.selectedJobType,
                    items: ctrl.jobTypeList,
                    isLoading: ctrl.isLoadingJobType,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setJobType,
                    hint: 'Search job type…',
                  ),
                  const SizedBox(height: 10),

                  // Work Order No. (searchable)
                  MrnSearchableDropdown<MrnDropdownOption>(
                    label: 'Work Order No.',
                    value: ctrl.selectedWorkOrder,
                    items: ctrl.workOrderList,
                    isLoading: ctrl.isLoadingWorkOrder,
                    itemLabel: (o) => o.label,
                    onChanged: ctrl.setWorkOrder,
                    hint: 'Search work order…',
                  ),

                  const SizedBox(height: 10),

// Lot No + GRN No row
                  Row(children: [
                    Expanded(
                      child: MrnField(
                        label: 'Lot No.',
                        controller: ctrl.lotNoCtrl,
                        hint: 'Enter lot number',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MrnField(
                        label: 'GRN No.',
                        controller: ctrl.grnNoCtrl,
                        hint: 'Enter GRN number',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),

// GRN Date + Gate Entry No row
                  Row(children: [
                    Expanded(
                      child: MrnField(
                        label: 'GRN Date',
                        controller: ctrl.grnDateCtrl,
                        readOnly: true,
                        hint: 'DD/MM/YYYY',
                        onTap: () => ctrl.pickGrnDate(context),
                        suffix: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.calendar_today_outlined,
                              size: 16, color: newTextSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MrnField(
                        label: 'Gate Entry No.',
                        controller: ctrl.gateEntryNoCtrl,
                        hint: 'Enter gate entry no.',
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),

        // ── Bottom CTA ───────────────────────────────────────────────────────
        _bottomCta(ctrl),
      ]);
    });
  }

  // ── Source chip (3-column horizontal layout) ──────────────────────────────
  Widget _sourceChip(MrnController ctrl, MrnSourceType type,
      String emoji, String title, String sub, Color iconBg) {
    final isSelected = ctrl.selectedSource == type;
    return GestureDetector(
      onTap: () => ctrl.setSource(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? newBlueLightColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? newBlueColor : newBorderColor,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: isSelected ? newBlueColor : newTextPrimary)),
            Text(sub,
                style: const TextStyle(fontSize: 9, color: newTextSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ── Attachment type checklist widget ──────────────────────────────────────
  Widget _attachmentTypeChecklist(MrnController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Attachment Type',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: newTextPrimary)),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: newSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: newBorderColor),
        ),
        child: Column(children: [
          _checkItem(
            label: 'Bill',
            checked: ctrl.selectedAttachmentTypes.contains(MrnAttachmentType.bill),
            onTap: () => ctrl.toggleAttachmentType(MrnAttachmentType.bill),
          ),
          const Divider(height: 1, color: newBorderColor),
          _checkItem(
            label: 'Challan',
            checked: ctrl.selectedAttachmentTypes.contains(MrnAttachmentType.challan),
            onTap: () => ctrl.toggleAttachmentType(MrnAttachmentType.challan),
          ),
        ]),
      ),
    ]);
  }

  Widget _checkItem({required String label, required bool checked, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: checked ? newBlueColor : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: checked ? newBlueColor : newBorderColor,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: checked
                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: newTextPrimary)),
        ]),
      ),
    );
  }

  // ── Attachment section (files list + upload buttons) ──────────────────────
  Widget _attachmentSection({
    required BuildContext context,
    required String label,
    required List<MrnDocument> docs,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onFile,
    required void Function(String id) onRemove,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: newTextPrimary)),
      const SizedBox(height: 6),

      // Upload buttons
      Row(children: [
        _uploadBtn(Icons.camera_alt_outlined, 'Camera', onCamera),
        const SizedBox(width: 8),
        _uploadBtn(Icons.photo_library_outlined, 'Gallery', onGallery),
        const SizedBox(width: 8),
        _uploadBtn(Icons.attach_file_rounded, 'File', onFile),
      ]),

      // Attached files list
      if (docs.isNotEmpty) ...[
        const SizedBox(height: 8),
        ...docs.map((doc) => _fileChip(doc, onRemove)),
      ],
    ]);
  }

  Widget _uploadBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: newBlueLightColor,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: newBlueColor.withValues(alpha: 0.3)),
          ),
          child: Column(children: [
            Icon(icon, size: 18, color: newBlueColor),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: newBlueColor)),
          ]),
        ),
      ),
    );
  }

  Widget _fileChip(MrnDocument doc, void Function(String) onRemove) {
    final isPdf = doc.fileType == 'pdf';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: newSurfaceColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: newBorderColor),
      ),
      child: Row(children: [
        Icon(
          isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
          size: 18,
          color: isPdf ? Colors.redAccent : newBlueColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.fileName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: newTextPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(doc.fileSize,
                style: const TextStyle(
                    fontSize: 10, color: newTextSecondary)),
          ]),
        ),
        GestureDetector(
          onTap: () => onRemove(doc.id),
          child: const Icon(Icons.close_rounded,
              size: 16, color: newTextSecondary),
        ),
      ]),
    );
  }

  // ── Bottom CTA ─────────────────────────────────────────────────────────────
  Widget _bottomCta(MrnController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: newBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: MrnPrimaryBtn(
          label: 'Continue → Select Items',
          icon: Icons.arrow_forward_rounded,
          onTap: () => ctrl.nextStep(),
        ),
      ),
    );
  }

  Widget _addressTile({
    required IconData icon,
    required String label,
    required MrnAddress address,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('READ ONLY',
                    style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey)),
              ),
            ]),
            const SizedBox(height: 4),
            if (address.line1.isNotEmpty)
              Text(address.line1,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: newTextPrimary)),
            if (address.line2.isNotEmpty)
              Text(address.line2,
                  style: const TextStyle(fontSize: 11, color: newTextSecondary)),
            if (address.city.isNotEmpty || address.state.isNotEmpty)
              Text(
                [address.city, address.state]
                    .where((s) => s.isNotEmpty)
                    .join(', '),
                style: const TextStyle(fontSize: 11, color: newTextSecondary),
              ),
            if (address.pincode.isNotEmpty)
              Text('PIN: ${address.pincode}',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: newTextSecondary)),
          ]),
        ),
      ]),
    );
  }
}