import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/show_message.dart';
import '../mrn_controller/mrn_controller.dart';
import '../mrn_response/mrn_models.dart';
import '../mrn_widgets.dart';
import 'mrn_direct_item_form.dart';

class MrnItemsScreen extends StatelessWidget {
  const MrnItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MrnController>(builder: (ctrl) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  MediaQuery.of(context).viewInsets.bottom + 110,
                ),
                child: Column(children: [
                  // ── Direct purchase — show entry form ──────────────────
                  if (ctrl.selectedSource == MrnSourceType.directPurchase)
                    const MrnDirectItemForm(),

                  // ── PO source — PO selection card ──────────────────────
                  if (ctrl.selectedSource == MrnSourceType.purchaseOrder)
                    MrnCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        // ── Card header ──────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: MrnSectionHead(
                            'Select Purchase Order',
                            trailing: ctrl.isLoadingPO
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.5, color: newBlueColor))
                                : GestureDetector(
                                    onTap: () => ctrl.fetchPendingPoList(),
                                    child: const Icon(Icons.refresh_rounded,
                                        size: 18, color: newBlueColor),
                                  ),
                          ),
                        ),

                        // ── PO list ──────────────────────────────────────
                        if (ctrl.isLoadingPO)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: _poShimmer(),
                          )
                        else if (ctrl.poList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: _emptyState('No pending POs found',
                                Icons.receipt_long_outlined),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: Column(
                              children: ctrl.poList
                                  .map((po) => _poTile(ctrl, po))
                                  .toList(),
                            ),
                          ),

                        // ── Process button (shown when a PO is selected) ─
                        if (ctrl.processingPo != null && !ctrl.isLoadingPO)
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: _ProcessButton(ctrl: ctrl),
                          ),
                      ]),
                    ),

                  // ── PO items list ──────────────────────────────────────
                  if (ctrl.selectedSource == MrnSourceType.purchaseOrder &&
                      (ctrl.itemLines.isNotEmpty || ctrl.isLoadingItems))
                    MrnCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                          child: MrnSectionHead(
                            'Item Details',
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              if (ctrl.isLoadingItems)
                                const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.5, color: newBlueColor)),
                              const SizedBox(width: 6),
                              _countBadge(ctrl.itemLines.length, 'items'),
                            ]),
                          ),
                        ),
                        if (ctrl.isLoadingItems)
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: _itemsShimmer(),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ctrl.itemLines.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: newBorderColor),
                            itemBuilder: (_, i) => _ItemCard(
                                ctrl: ctrl, item: ctrl.itemLines[i], index: i),
                          ),
                        if (!ctrl.isLoadingItems && ctrl.itemLines.isNotEmpty)
                          _totalsFooter(ctrl),
                      ]),
                    ),

                  // ── Job Type, Customer PO & Work Order card ────────────
                  // Shown in both PO and Direct once items are present
                  // (or always visible so user can fill before adding items)
                  _OrderLinkCard(ctrl: ctrl),

                  // ── Attachments card ───────────────────────────────────
                  // Shown in both PO and Direct
                  _AttachmentsCard(ctrl: ctrl, context: context),
                ]),
              ),
            ),

            // ── Bottom CTA ───────────────────────────────────────────────
            if (MediaQuery.of(context).viewInsets.bottom == 0) _bottomBar(ctrl),
          ]),
        ),
      );
    });
  }

  // ── PO tile ────────────────────────────────────────────────────────────────
  Widget _poTile(MrnController ctrl, PendingPoItem po) {
    return GestureDetector(
      onTap: () => ctrl.togglePOSelection(po),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: po.isSelected ? newBlueLightColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: po.isSelected ? newBlueColor : newBorderColor,
            width: po.isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(children: [
          // ── Radio circle ─────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: po.isSelected ? newBlueColor : Colors.white,
              border: Border.all(
                  color: po.isSelected ? newBlueColor : newBorderColor,
                  width: 2),
            ),
            alignment: Alignment.center,
            child: po.isSelected
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle))
                : null,
          ),
          const SizedBox(width: 12),

          // ── PO info ───────────────────────────────────────────────────────
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(po.orderno.isNotEmpty ? po.orderno : '#${po.orderid}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: newTextPrimary,
                      letterSpacing: .2)),
              const SizedBox(height: 3),
              if (po.partyname.isNotEmpty)
                Text(po.partyname,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: newTextPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                if (po.orderdate.isNotEmpty) ...[
                  const Icon(Icons.calendar_today_outlined,
                      size: 10, color: newTextSecondary),
                  const SizedBox(width: 3),
                  Text(po.orderdate,
                      style: const TextStyle(
                          fontSize: 10, color: newTextSecondary)),
                  const SizedBox(width: 8),
                ],
                if (po.totalqty > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: newSurfaceColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: newBorderColor)),
                    child: Text(
                        '${po.totalqty} item${po.totalqty == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: newTextSecondary)),
                  ),
              ]),
            ]),
          ),

          const SizedBox(width: 8),

          // ── Amount column ─────────────────────────────────────────────────
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${MrnUtils.inr(po.grandtotal)}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
            const SizedBox(height: 2),
            Text('₹${MrnUtils.inr(po.totalamount)} + GST',
                style: const TextStyle(fontSize: 9, color: newTextSecondary)),
          ]),
        ]),
      ),
    );
  }

  // ── Totals footer ──────────────────────────────────────────────────────────
  Widget _totalsFooter(MrnController ctrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
          color: newSurfaceColor,
          border: Border(top: BorderSide(color: newBorderColor))),
      child: Column(children: [
        _totalRow('Subtotal', MrnUtils.inr(ctrl.subtotal)),
        const SizedBox(height: 6),
        _totalRow('Total GST', MrnUtils.inr(ctrl.totalGst)),
        const Divider(height: 16, color: newBorderColor),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Grand Total',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
            Text(MrnUtils.inr(ctrl.grandTotal),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: newBlueColor)),
          ],
        ),
      ]),
    );
  }

  Widget _totalRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: newTextSecondary)),
        Text(val,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: newTextPrimary)),
      ],
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _bottomBar(MrnController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: newBorderColor))),
      child: SafeArea(
        top: false,
        child: MrnPrimaryBtn(
          label: 'Review & Submit →',
          icon: Icons.arrow_forward_rounded,
          onTap: () {
            if (ctrl.itemLines.isEmpty) {
              ShowMessage.showSnackBar(
                'No Items',
                ctrl.selectedSource == MrnSourceType.purchaseOrder
                    ? 'Please select and process a PO'
                    : 'Please add at least one item',
              );
              return;
            }
            if (ctrl.itemLines.any((i) => i.receiveNowQty <= 0)) {
              ShowMessage.showSnackBar(
                  'Invalid Qty', 'All items must have received qty > 0');
              return;
            }
            ctrl.nextStep();
          },
        ),
      ),
    );
  }

  // ── Shimmer placeholders ───────────────────────────────────────────────────
  Widget _poShimmer() => Column(
        children: List.generate(
            3,
            (i) => Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      color: newBorderColor,
                      borderRadius: BorderRadius.circular(12)),
                )),
      );

  Widget _itemsShimmer() => Column(
        children: List.generate(
            3,
            (i) => Container(
                  height: 70,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      color: newBorderColor,
                      borderRadius: BorderRadius.circular(10)),
                )),
      );

  Widget _emptyState(String msg, IconData icon) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(children: [
          Icon(icon, size: 36, color: newBorderColor),
          const SizedBox(height: 8),
          Text(msg,
              style: const TextStyle(fontSize: 13, color: newTextSecondary)),
        ]),
      );

  Widget _countBadge(int count, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: newBlueLightColor, borderRadius: BorderRadius.circular(20)),
        child: Text('$count $label',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: newBlueColor)),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Order-link card: Job Type + Customer PO + Work Order
// Shown below items in BOTH PO and Direct modes
// ═══════════════════════════════════════════════════════════════════════════════
class _OrderLinkCard extends StatelessWidget {
  final MrnController ctrl;
  const _OrderLinkCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isPO = ctrl.selectedSource == MrnSourceType.purchaseOrder;

    return MrnCard(
      child: Column(children: [
        const MrnSectionHead('Order Linkage'),

        // ── Customer PO ──────────────────────────────────────────────────
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

        // ── Job Type ──────────────────────────────────────────────────────
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

        // ── Work Order ────────────────────────────────────────────────────
        // In PO mode: contextual info shows the linked PO / Site
        // In Direct mode: free-select Work Order dropdown
        if (isPO) ...[
          // For PO mode — show the processed PO as a read-only context chip
          // and let user optionally link a Work Order
          if (ctrl.processingPo != null) _PoContextChip(po: ctrl.processingPo!),
          const SizedBox(height: 10),
        ],

        // MrnSearchableDropdown<MrnDropdownOption>(
        //   label: 'Work Order No.',
        //   value: ctrl.selectedWorkOrder,
        //   items: ctrl.workOrderList,
        //   isLoading: ctrl.isLoadingWorkOrder,
        //   itemLabel: (o) => o.label,
        //   onChanged: ctrl.setWorkOrder,
        //   hint: isPO
        //       ? 'Link work order to this PO…'
        //       : 'Link work order to items…',
        // ),
      ]),
    );
  }
}

// ── Compact PO context chip (PO mode only) ─────────────────────────────────
class _PoContextChip extends StatelessWidget {
  final PendingPoItem po;
  const _PoContextChip({required this.po});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: newBlueLightColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: newBlueColor.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        const Icon(Icons.receipt_long_outlined, size: 14, color: newBlueColor),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Linked PO: ${po.orderno.isNotEmpty ? po.orderno : '#${po.orderid}'}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: newBlueColor),
            ),
            if (po.partyname.isNotEmpty)
              Text(po.partyname,
                  style:
                      const TextStyle(fontSize: 10, color: newTextSecondary)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: newBlueColor, borderRadius: BorderRadius.circular(4)),
          child: const Text('PO',
              style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Attachments card — shown in BOTH PO and Direct modes
// ═══════════════════════════════════════════════════════════════════════════════
class _AttachmentsCard extends StatelessWidget {
  final MrnController ctrl;
  final BuildContext context;
  const _AttachmentsCard({required this.ctrl, required this.context});

  @override
  Widget build(BuildContext context) {
    return MrnCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MrnSectionHead('Attachments'),

        // Attachment Type checklist
        _attachmentTypeChecklist(ctrl),
        const SizedBox(height: 12),

        // Bill Attachment
        if (ctrl.selectedAttachmentTypes.contains(MrnAttachmentType.bill)) ...[
          _attachmentSection(
            context: context,
            label: 'Bill Attachment',
            docs: ctrl.billAttachments,
            existingUrls: ctrl.existingBillFiles,
            onCamera: ctrl.pickBillFromCamera,
            onGallery: ctrl.pickBillFromGallery,
            onFile: ctrl.pickBillFile,
            onRemove: ctrl.removeBillAttachment,
            onRemoveExisting: ctrl.removeExistingBillFile,
          ),
          const SizedBox(height: 12),
        ],

        // Challan Attachment
        if (ctrl.selectedAttachmentTypes
            .contains(MrnAttachmentType.challan)) ...[
          _attachmentSection(
            context: context,
            label: 'Challan Attachment',
            docs: ctrl.challanAttachments,
            existingUrls: ctrl.existingDcFiles,
            onCamera: ctrl.pickChallanFromCamera,
            onGallery: ctrl.pickChallanFromGallery,
            onFile: ctrl.pickChallanFile,
            onRemove: ctrl.removeChallanAttachment,
            onRemoveExisting: ctrl.removeExistingDcFile,
          ),
          const SizedBox(height: 12),
        ],

        // Reason for N/A
        if (ctrl.billAttachments.isEmpty &&
            ctrl.challanAttachments.isEmpty &&
            ctrl.existingBillFiles.isEmpty &&
            ctrl.existingDcFiles.isEmpty) ...[
          MrnField(
            label: 'Reason for N/A Attachment',
            controller: ctrl.reasonNACtrl,
            hint: 'Explain why no attachment is available…',
            minLines: 3,
          ),
        ],
      ]),
    );
  }

  // ── Checklist ──────────────────────────────────────────────────────────────
  Widget _attachmentTypeChecklist(MrnController ctrl) {
    if (ctrl.isLoadingDocumentTypes) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: newBlueColor),
          ),
        ),
      );
    }

    if (ctrl.documentTypeList.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Document Type',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: newTextPrimary)),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: newSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: newBorderColor),
        ),
        child: Column(
          children: ctrl.documentTypeList.asMap().entries.map((entry) {
            final i = entry.key;
            final doc = entry.value;
            final checked = ctrl.selectedDocumentTypeIds.contains(doc.id);
            return Column(children: [
              if (i > 0) const Divider(height: 1, color: newBorderColor),
              _checkItem(
                label: doc.label,
                checked: checked,
                onTap: () => ctrl.toggleDocumentType(doc.id),
              ),
            ]);
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _checkItem(
      {required String label,
      required bool checked,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18,
            height: 18,
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

  // ── Attachment section (upload row + file chips) ───────────────────────────
  Widget _attachmentSection({
    required BuildContext context,
    required String label,
    required List<MrnDocument> docs,
    required List<String> existingUrls,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onFile,
    required void Function(String id) onRemove,
    required void Function(int index) onRemoveExisting,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: newTextPrimary)),
      const SizedBox(height: 6),

      // Existing server files
      if (existingUrls.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: newGreenLightColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(children: [
            const Icon(Icons.cloud_done_rounded,
                size: 12, color: newGreenColor),
            const SizedBox(width: 5),
            Text('${existingUrls.length} file(s) already on server',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: newGreenColor)),
          ]),
        ),
        const SizedBox(height: 6),
        ...existingUrls.asMap().entries.map((e) => _ExistingFileChip(
              url: e.value,
              onRemove: () => onRemoveExisting(e.key),
            )),
        const SizedBox(height: 6),
      ],

      // Upload buttons
      Row(children: [
        _uploadBtn(Icons.camera_alt_outlined, 'Camera', onCamera),
        const SizedBox(width: 8),
        _uploadBtn(Icons.photo_library_outlined, 'Gallery', onGallery),
        const SizedBox(width: 8),
        _uploadBtn(Icons.attach_file_rounded, 'File', onFile),
      ]),

      // New local files
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
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.fileName,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: newTextPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(doc.fileSize,
                style: const TextStyle(fontSize: 10, color: newTextSecondary)),
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
}

// ── Existing server attachment chip ────────────────────────────────────────
class _ExistingFileChip extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const _ExistingFileChip({required this.url, required this.onRemove});

  Future<void> _openFile() async {
    String fullUrl = url.trim();

    // If it's just a filename or relative path, prepend the base
    if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
      fullUrl = 'https://supportapi.digitalerp.biz/Images/$fullUrl';
    }

    final uri = Uri.tryParse(fullUrl);
    if (uri == null) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('❌ Could not launch: $fullUrl');
      }
    } catch (e) {
      debugPrint('❌ launchUrl error: $e — url: $fullUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = url.split('/').last;
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final isImage = ['jpg', 'jpeg', 'png', 'webp']
        .any((ext) => fileName.toLowerCase().endsWith(ext));

    return GestureDetector(               // ← wrap entire chip
      onTap: _openFile,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: newGreenLightColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: newGreenColor.withValues(alpha: 0.4)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: newGreenColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Icon(
                  isPdf
                      ? Icons.picture_as_pdf_outlined
                      : isImage
                      ? Icons.image_outlined
                      : Icons.attach_file_rounded,
                  size: 18,
                  color: newGreenColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName.length > 30
                            ? '${fileName.substring(0, 27)}…'
                            : fileName,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: newTextPrimary),
                      ),
                      Row(children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: newGreenColor,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('SERVER',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                        const SizedBox(width: 5),         // ← new
                        const Icon(Icons.open_in_new_rounded,  // ← new
                            size: 10, color: newTextSecondary),
                        const SizedBox(width: 3),         // ← new
                        const Text('Tap to open',         // ← new
                            style: TextStyle(
                                fontSize: 9,
                                color: newTextSecondary)),
                      ]),
                    ]),
              ),
              // ── Delete button stops propagation ──────────────────────
              GestureDetector(
                onTap: onRemove,           // does NOT bubble up to _openFile
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: newRedLightColor,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: newRedColor.withValues(alpha: 0.3))),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 14, color: newRedColor),
                ),
              ),
            ]),
          ),
          if (isImage && url.startsWith('http'))
            GestureDetector(
              onTap: _openFile,            // image preview also tappable
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
                child: Image.network(
                  url,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 60,
                    color: newSurfaceColor,
                    alignment: Alignment.center,
                    child: const Text('Preview unavailable',
                        style:
                        TextStyle(fontSize: 11, color: newTextSecondary)),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Process PO button
// ═══════════════════════════════════════════════════════════════════════════════
class _ProcessButton extends StatelessWidget {
  final MrnController ctrl;
  const _ProcessButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final po = ctrl.processingPo!;
    return Container(
      decoration: BoxDecoration(
        color: newBlueLightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: newBlueColor.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.receipt_long_rounded, size: 16, color: newBlueColor),
          const SizedBox(width: 8),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                po.orderno.isNotEmpty ? po.orderno : '#${po.orderid}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: newBlueColor),
              ),
              if (po.partyname.isNotEmpty)
                Text(po.partyname,
                    style:
                        const TextStyle(fontSize: 11, color: newTextSecondary)),
              if (po.orderdate.isNotEmpty)
                Text(po.orderdate,
                    style:
                        const TextStyle(fontSize: 10, color: newTextSecondary)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${MrnUtils.inr(po.grandtotal)}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: newBlueColor)),
            Text('${po.totalqty} item${po.totalqty == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 10, color: newTextSecondary)),
          ]),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed:
                ctrl.isLoadingItems ? null : () => ctrl.processSelectedPO(),
            style: ElevatedButton.styleFrom(
              backgroundColor: newBlueColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: ctrl.isLoadingItems
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              ctrl.isLoadingItems ? 'Loading Items…' : 'Process PO',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Individual item card
// ═══════════════════════════════════════════════════════════════════════════════
class _ItemCard extends StatelessWidget {
  final MrnController ctrl;
  final MrnItemLine item;
  final int index;

  const _ItemCard(
      {required this.ctrl, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final isOverReceived = item.receiveNowQty > item.maxReceivable;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      color: isOverReceived
          ? newRedLightColor
          : item.isExpanded
              ? newBlueLightColor.withValues(alpha: 0.4)
              : Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                  color: newBlueLightColor,
                  borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text('${index + 1}',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: newBlueColor)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: newTextPrimary)),
                    const SizedBox(height: 3),
                    Row(children: [
                      _pill(item.itemCode, newSurfaceColor, newTextSecondary),
                      const SizedBox(width: 5),
                      _pill(item.unit, newSurfaceColor, newTextSecondary),
                      const SizedBox(width: 5),
                      _pill('PO: ${item.poQty.toInt()}', newBlueLightColor,
                          newBlueColor),
                    ]),
                    const SizedBox(height: 6),
                    _InlineGodownSelector(ctrl: ctrl, item: item),
                  ]),
            ),
            const SizedBox(width: 8),
            _QtyField(ctrl: ctrl, item: item),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => ctrl.toggleItemExpanded(item),
              child: AnimatedRotation(
                turns: item.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22, color: newTextSecondary),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _expandedPanel(context),
          crossFadeState: item.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
        if (isOverReceived)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: newRedLightColor,
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 13, color: newRedColor),
              const SizedBox(width: 5),
              Text(
                'Exceeds PO balance. Max: ${item.maxReceivable.toInt()} ${item.unit}',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: newRedColor),
              ),
            ]),
          )
        else
          const SizedBox(height: 10),
      ]),
    );
  }

  Widget _expandedPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(height: 1, color: newBorderColor),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: newSurfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: newBorderColor),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: newBlueLightColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(9), topRight: Radius.circular(9)),
              ),
              child: Row(children: [
                const Icon(Icons.calculate_outlined,
                    size: 13, color: newBlueColor),
                const SizedBox(width: 5),
                const Text('Financial Details',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: newBlueColor,
                        letterSpacing: .3)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: newBlueColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('READ ONLY',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: .5)),
                ),
              ]),
            ),
            _finRow('Order No', item.orderNo, mono: true),
            _finRow('Rate', '₹${item.rate.toStringAsFixed(2)}'),
            _finRow(
                'Discount',
                '${item.discountPercent.toStringAsFixed(1)}%  '
                    '(₹${item.discountAmount.toStringAsFixed(2)})'),
            _finRow('Amount', '₹${item.amount.toStringAsFixed(2)}'),
            _finRow('GST %', '${item.gstPercent.toStringAsFixed(1)}%'),
            _finRow('GST Amount', '₹${item.gstAmount.toStringAsFixed(2)}'),
            _finRowTotal(
                'Total Amount', '₹${item.totalAmount.toStringAsFixed(2)}'),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: newSurfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: newBorderColor),
          ),
          child: Row(children: [
            _qtyBlock(
                'PO Qty', item.poQty.toInt(), newBlueLightColor, newBlueColor),
            _qDivider(),
            _qtyBlock('Prev Rcvd', item.previouslyReceivedQty.toInt(),
                newOrangeLightColor, newOrangeColor),
            _qDivider(),
            _qtyBlock('Balance', item.maxReceivable.toInt(), newGreenLightColor,
                newGreenColor),
            _qDivider(),
            _qtyBlock('Now Rcvg', item.receiveNowQty.toInt(), newBlueLightColor,
                newBlueColor,
                bold: true),
          ]),
        ),
        const SizedBox(height: 12),
        MrnField(
          label: 'Remarks',
          hint: 'Optional delivery note for this item…',
          controller: TextEditingController(text: item.remarks)
            ..selection = TextSelection.collapsed(offset: item.remarks.length),
          minLines: 2,
          onChanged: (v) => ctrl.setItemRemarks(item, v),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => ctrl.removeItem(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
                color: newRedLightColor,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: newRedColor.withValues(alpha: 0.3))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.remove_circle_outline_rounded,
                  size: 14, color: newRedColor),
              SizedBox(width: 6),
              Text('Remove this item',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: newRedColor)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _finRow(String label, String val, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: newBorderColor))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: newTextSecondary)),
        Text(val,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: newTextPrimary,
                fontFamily: mono ? 'monospace' : null)),
      ]),
    );
  }

  Widget _finRowTotal(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: newBlueLightColor,
          border: const Border(top: BorderSide(color: newBlueColor)),
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(9), bottomRight: Radius.circular(9))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: newBlueColor)),
        Text(val,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: newBlueColor)),
      ]),
    );
  }

  Widget _qtyBlock(String label, int val, Color bg, Color fg,
      {bool bold = false}) {
    return Expanded(
      child: Column(children: [
        Text('$val',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: fg)),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
        ),
      ]),
    );
  }

  Widget _qDivider() => Container(width: 1, height: 36, color: newBorderColor);

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(text,
          style:
              TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Inline godown selector
// ═══════════════════════════════════════════════════════════════════════════════
class _InlineGodownSelector extends StatelessWidget {
  final MrnController ctrl;
  final MrnItemLine item;

  const _InlineGodownSelector({required this.ctrl, required this.item});

  @override
  Widget build(BuildContext context) {
    final resolvedGodown = item.selectedGodownId != null
        ? ctrl.godownList.firstWhereOrNull((g) => g.id == item.selectedGodownId)
        : ctrl.selectedGodown;

    final label = resolvedGodown?.label ?? '— Select Godown —';
    final isOverridden = item.selectedGodownId != null &&
        item.selectedGodownId != ctrl.selectedGodown?.id;

    return GestureDetector(
      onTap: () => _showGodownSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isOverridden ? newOrangeLightColor : newSurfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOverridden ? newOrangeColor : newBorderColor,
            width: isOverridden ? 1.2 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.warehouse_outlined,
              size: 12,
              color: isOverridden ? newOrangeColor : newTextSecondary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOverridden ? newOrangeColor : newTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down_rounded,
              size: 16,
              color: isOverridden ? newOrangeColor : newTextSecondary),
        ]),
      ),
    );
  }

  void _showGodownSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _GodownPickerSheet(ctrl: ctrl, item: item),
    );
  }
}

// ── Godown picker sheet ─────────────────────────────────────────────────────
class _GodownPickerSheet extends StatefulWidget {
  final MrnController ctrl;
  final MrnItemLine item;
  const _GodownPickerSheet({required this.ctrl, required this.item});

  @override
  State<_GodownPickerSheet> createState() => _GodownPickerSheetState();
}

class _GodownPickerSheetState extends State<_GodownPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.ctrl.godownList
        .where((g) => g.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final currentId =
        widget.item.selectedGodownId ?? widget.ctrl.selectedGodown?.id;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
              color: newBorderColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Select Godown',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search godown…',
              hintStyle: const TextStyle(fontSize: 13, color: newTextHint),
              prefixIcon:
                  const Icon(Icons.search, size: 18, color: newTextSecondary),
              filled: true,
              fillColor: newSurfaceColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: newBorderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: newBorderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: newBlueColor, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (widget.ctrl.selectedGodown != null)
          _godownTile(
            godown: widget.ctrl.selectedGodown!,
            currentId: currentId,
            isDefault: true,
          ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final g = filtered[i];
              if (widget.ctrl.selectedGodown?.id == g.id) {
                return const SizedBox.shrink();
              }
              return _godownTile(
                godown: g,
                currentId: currentId,
                isDefault: false,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _godownTile({
    required MrnDropdownOption godown,
    required String? currentId,
    required bool isDefault,
  }) {
    final isSelected = godown.id == currentId;
    return ListTile(
      dense: true,
      onTap: () {
        if (isDefault) {
          widget.ctrl.setItemGodown(widget.item, null);
        } else {
          widget.ctrl.setItemGodown(widget.item, godown);
        }
        Get.back();
      },
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: isSelected ? newBlueLightColor : newSurfaceColor,
            borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Icon(Icons.warehouse_outlined,
            size: 16, color: isSelected ? newBlueColor : newTextSecondary),
      ),
      title: Row(children: [
        Text(godown.label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? newBlueColor : newTextPrimary)),
        if (isDefault) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: newBlueLightColor,
                borderRadius: BorderRadius.circular(4)),
            child: const Text('Default',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: newBlueColor)),
          ),
        ],
      ]),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded,
              size: 18, color: newBlueColor)
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Qty stepper field
// ═══════════════════════════════════════════════════════════════════════════════
class _QtyField extends StatefulWidget {
  final MrnController ctrl;
  final MrnItemLine item;
  const _QtyField({required this.ctrl, required this.item});

  @override
  State<_QtyField> createState() => _QtyFieldState();
}

class _QtyFieldState extends State<_QtyField> {
  late final TextEditingController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TextEditingController(
        text: widget.item.receiveNowQty.toInt().toString());
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _sync() {
    final newVal = widget.item.receiveNowQty.toInt().toString();
    if (_tc.text != newVal) {
      _tc.value = _tc.value.copyWith(
        text: newVal,
        selection: TextSelection.collapsed(offset: newVal.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _sync();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: newBorderColor),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () {
            widget.ctrl.decreaseQty(widget.item);
            _sync();
          },
          child: Container(
            width: 30,
            height: 34,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8))),
            alignment: Alignment.center,
            child: const Icon(Icons.remove, size: 14, color: newBlueColor),
          ),
        ),
        SizedBox(
          width: 40,
          child: TextField(
            controller: _tc,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: newTextPrimary),
            decoration: const InputDecoration(
                border: InputBorder.none, contentPadding: EdgeInsets.zero),
            onChanged: (v) {
              final parsed = double.tryParse(v) ?? 0;
              widget.ctrl.setReceivedQty(widget.item, parsed);
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.ctrl.increaseQty(widget.item);
            _sync();
          },
          child: Container(
            width: 30,
            height: 34,
            decoration: const BoxDecoration(
                color: newBlueColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8))),
            alignment: Alignment.center,
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
