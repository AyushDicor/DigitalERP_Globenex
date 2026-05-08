import 'dart:io';

import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../mrn_controller/mrn_controller.dart';
import '../mrn_response/mrn_models.dart';
import '../mrn_widgets.dart';

class MrnReviewScreen extends StatelessWidget {
  const MrnReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MrnController>(builder: (ctrl) {
      return Stack(children: [
        Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
              child: Column(children: [
                _masterCard(ctrl),
                _supplierCard(ctrl),
                _itemsCard(ctrl),
                _summaryCard(ctrl),
                _remarksCard(ctrl),
                _documentsCard(ctrl, context),
              ]),
            ),
          ),
          _bottomBar(ctrl),
        ]),

        //  Success overlay (controller handles via Get.back + snackbar) 
      ]);
    });
  }

  //  MRN Master card 
  Widget _masterCard(MrnController ctrl) {
    return MrnCard(
      child: Column(children: [
        const MrnSectionHead('MRN Master Details'),
        _infoGrid([
          _InfoTile('MRN Number', ctrl.mrnNumber, mono: true),
          _InfoTile('MRN Date', ctrl.mrnDateCtrl.text),
          _InfoTile('Warehouse', ctrl.selectedWarehouse),
          _InfoTile('Source Type', ctrl.sourceLabel(ctrl.selectedSource)),
          _InfoTile('Linked PO',
              ctrl.poList.where((p) => p.isSelected).map((p) => p.poNumber).join(', '),
              full: true),
        ]),
      ]),
    );
  }

  //  Supplier card 
  Widget _supplierCard(MrnController ctrl) {
    return MrnCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MrnSectionHead('Supplier Details'),
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: newBlueLightColor,
                borderRadius: BorderRadius.circular(11)),
            alignment: Alignment.center,
            child: const Text('🏢', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ctrl.selectedSupplier,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: newTextPrimary)),
              const Text('GST: 27AABCG1234F1ZX · Mumbai, MH',
                  style: TextStyle(fontSize: 11, color: newTextSecondary)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        _infoGrid([
          _InfoTile('Invoice No.', ctrl.invoiceNoCtrl.text.isEmpty ? '—' : ctrl.invoiceNoCtrl.text, mono: true),
          _InfoTile('Invoice Date', ctrl.invoiceDateCtrl.text.isEmpty ? '—' : ctrl.invoiceDateCtrl.text),
          _InfoTile('Payment Terms', 'Net 30'),
          _InfoTile('Outstanding', '₹1,20,000', valueColor: newRedColor),
        ]),
      ]),
    );
  }

  //  Items card 
  Widget _itemsCard(MrnController ctrl) {
    final items = ctrl.allItems;
    return MrnCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: MrnSectionHead(
            'Items Received',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: newBlueLightColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${items.length} items',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: newBlueColor)),
            ),
          ),
        ),
        ...items.map((item) => _reviewItemRow(item)),
      ]),
    );
  }

  Widget _reviewItemRow(MrnItemLine item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: newBorderColor))),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.itemName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: newTextPrimary)),
            Row(children: [
              Text('${item.itemCode} · ${item.unit}',
                  style: const TextStyle(
                      fontSize: 10, color: newTextSecondary)),
              if (item.source == 'Scan') ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: newGreenLightColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Scanned',
                      style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: newGreenColor)),
                ),
              ],
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Qty: ${item.receiveNowQty.toInt()}',
              style: const TextStyle(fontSize: 11, color: newTextSecondary)),
          Text('₹${_fmt(item.lineTotal)}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: newTextPrimary)),
        ]),
      ]),
    );
  }

  //  Summary card 
  Widget _summaryCard(MrnController ctrl) {
    return MrnCard(
      child: Column(children: [
        const MrnSectionHead('Amount Summary'),
        _sumRow('Subtotal (${ctrl.allItems.length} items)',
            '₹${_fmt(ctrl.subtotal)}'),
        _sumRow('GST (${ctrl.gstPercent.toInt()}%)',
            '₹${_fmt(ctrl.gstAmount)}'),
        _sumRow('Transport Charges',
            '₹${_fmt(ctrl.transportCharges)}'),
        _sumRow('Discount', '− ₹${_fmt(ctrl.discount)}',
            valueColor: newGreenColor),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: newBorderColor, width: 1.5))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: newTextPrimary)),
              Text('₹${_fmt(ctrl.grandTotal)}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800,
                      color: newBlueColor)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _sumRow(String label, String val, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: newTextSecondary)),
          Text(val,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: valueColor ?? newTextPrimary)),
        ],
      ),
    );
  }

  //  Remarks card 
  Widget _remarksCard(MrnController ctrl) {
    return MrnCard(
      child: Column(children: [
        const MrnSectionHead('Remarks / Notes'),
        TextFormField(
          controller: ctrl.remarksCtrl,
          minLines: 3, maxLines: 5,
          style: const TextStyle(fontSize: 13, color: newTextPrimary),
          decoration: InputDecoration(
            hintText: 'Add delivery remarks, quality notes, discrepancies...',
            hintStyle: const TextStyle(color: newTextHint, fontSize: 13),
            filled: true, fillColor: newSurfaceColor,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: newBorderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: newBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: newBlueColor, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  //  Documents card 
  Widget _documentsCard(MrnController ctrl, BuildContext context) {
    return MrnCard(
      child: Column(children: [
        // Header
        Row(children: [
          const Expanded(
            child: Text('Supporting Documents',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800,
                    color: newTextSecondary, letterSpacing: .6)),
          ),
          if (ctrl.attachedDocuments.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: newBlueLightColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${ctrl.attachedDocuments.length} file${ctrl.attachedDocuments.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: newBlueColor),
              ),
            ),
        ]),
        const SizedBox(height: 10),

        // Doc type tabs
        _DocTypeTabs(ctrl: ctrl),
        const SizedBox(height: 12),

        // Upload zone (when no files)
        if (ctrl.attachedDocuments.isEmpty)
          _UploadZone(ctrl: ctrl)
        else ...[
          // File rows
          ...ctrl.attachedDocuments.map((doc) => _docRow(ctrl, doc)),
          const SizedBox(height: 8),
          // Add more
          GestureDetector(
            onTap: () => _showUploadSheet(context, ctrl),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: newBlueLightColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: newBlueColor, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: newBlueColor),
                  SizedBox(width: 6),
                  Text('Add Another Document',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: newBlueColor)),
                ],
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _docRow(MrnController ctrl, MrnDocument doc) {
    final isPdf = doc.fileType == 'pdf';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: newBorderColor),
      ),
      child: Row(children: [
        // Thumbnail
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isPdf ? newRedLightColor : const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: isPdf
              ? const Text('PDF',
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800,
                      color: newRedColor))
              : ((doc.filePath.isEmpty || doc.filePath.startsWith('assets'))
                  ? const Icon(Icons.image_outlined,
                      size: 20, color: Color(0xFF8B5CF6))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.file(File(doc.filePath),
                          width: 40, height: 40, fit: BoxFit.cover),
                    )),
        ),
        const SizedBox(width: 10),
        // Info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.fileName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: newTextPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${doc.fileSize} · ${ctrl.docTypeLabel(doc.docType)} · ${doc.source}',
              style: const TextStyle(fontSize: 10, color: newTextSecondary),
            ),
            const SizedBox(height: 4),
            // Completed progress bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                  color: newGreenColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        // Action buttons
        Column(children: [
          _actionBtn(Icons.visibility_outlined, newBlueColor, newBlueLightColor,
              () => _showPreview(doc)),
          const SizedBox(height: 5),
          _actionBtn(Icons.close_rounded, newRedColor, newRedLightColor,
              () => ctrl.removeDocument(doc.id)),
        ]),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, Color fg, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: fg),
      ),
    );
  }

  void _showPreview(MrnDocument doc) {
    Get.dialog(Dialog(
      backgroundColor: const Color(0xFF0F172A),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(children: [
            Expanded(
              child: Text(doc.fileName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('✕ Close',
                  style: TextStyle(color: Colors.white60)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Text(doc.fileType == 'pdf' ? '📄' : '🖼',
                style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 10),
            Text(doc.fileName,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text('${doc.fileSize} · ${doc.source}',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white60)),
          ]),
        ),
      ]),
    ));
  }

  void _showUploadSheet(BuildContext context, MrnController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _UploadSheet(ctrl: ctrl),
    );
  }

  //  Bottom bar 
  Widget _bottomBar(MrnController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: newBorderColor))),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: newBlueColor,
                side: const BorderSide(color: newBlueColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Draft',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: MrnPrimaryBtn(
              label: 'Submit MRN',
              icon: Icons.check_rounded,
              color: newGreenColor,
              isLoading: ctrl.isBusy,
              onTap: () => ctrl.submitMRN(),
            ),
          ),
        ]),
      ),
    );
  }

  //  Info grid builder 
  Widget _infoGrid(List<_InfoTile> tiles) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tiles.map((t) {
        return SizedBox(
          width: t.full
              ? double.infinity
              : (Get.width - 28 - 14 - 8) / 2,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: newSurfaceColor,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: newBorderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.label,
                    style: const TextStyle(
                        fontSize: 10, color: newTextSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(t.value,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: t.valueColor ?? newTextPrimary,
                        fontFamily: t.mono ? 'monospace' : null),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) {
      final s = v.toStringAsFixed(0);
      // Add commas
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 2 == 0 && i >= s.length - 5) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return v.toStringAsFixed(0);
  }
}

class _InfoTile {
  final String label, value;
  final bool mono, full;
  final Color? valueColor;
  const _InfoTile(this.label, this.value,
      {this.mono = false, this.full = false, this.valueColor});
}

//  Doc type tabs 
class _DocTypeTabs extends StatelessWidget {
  final MrnController ctrl;
  const _DocTypeTabs({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MrnDocType.values.map((t) {
          final isActive = ctrl.selectedDocType == t;
          return GestureDetector(
            onTap: () => ctrl.setDocType(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? newBlueLightColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? newBlueColor : newBorderColor,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Text(ctrl.docTypeLabel(t),
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: isActive ? newBlueColor : newTextSecondary)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

//  Upload zone 
class _UploadZone extends StatelessWidget {
  final MrnController ctrl;
  const _UploadZone({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: newSurfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: newBorderColor,
              style: BorderStyle.solid, width: 1.5),
        ),
        child: Column(children: [
          // Pulsing cloud icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.1),
            duration: const Duration(milliseconds: 900),
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: const Icon(Icons.cloud_upload_outlined,
                size: 38, color: newBlueColor),
          ),
          const SizedBox(height: 8),
          const Text('Upload soft copy or click a photo',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: newTextPrimary)),
          const SizedBox(height: 4),
          const Text('PDF · JPG · PNG · Max 10 MB per file',
              style: TextStyle(fontSize: 10, color: newTextHint)),
          const SizedBox(height: 14),
          // Three action buttons
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _quickBtn('📷', 'Camera', const Color(0xFFFEE2E2), newRedColor,
                () { ctrl.pickFromCamera(); }),
            const SizedBox(width: 8),
            _quickBtn('🖼', 'Gallery', const Color(0xFFEDE9FE),
                const Color(0xFF8B5CF6), () { ctrl.pickFromGallery(); }),
            const SizedBox(width: 8),
            _quickBtn('📁', 'Files', newBlueLightColor, newBlueColor,
                () { ctrl.pickFile(); }),
          ]),
        ]),
      ),
    );
  }

  Widget _quickBtn(String emoji, String label, Color bg, Color fg,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(9)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        ]),
      ),
    );
  }

  void _showSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _UploadSheet(ctrl: ctrl),
    );
  }
}

//  Upload bottom sheet 
class _UploadSheet extends StatelessWidget {
  final MrnController ctrl;
  const _UploadSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38, height: 4,
          decoration: BoxDecoration(
              color: newBorderColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Add Supporting Document',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: newTextPrimary)),
        ),
        const SizedBox(height: 12),
        // Doc type dropdown in sheet
        GetBuilder<MrnController>(builder: (c) {
          return MrnDropdown(
            label: 'Document Type',
            value: c.docTypeLabel(c.selectedDocType),
            items: MrnDocType.values.map(c.docTypeLabel).toList(),
            onChanged: (v) {
              if (v != null) {
                c.setDocType(MrnDocType.values
                    .firstWhere((t) => c.docTypeLabel(t) == v));
              }
            },
          );
        }),
        const SizedBox(height: 14),
        // Options
        _optRow(context, '📷', 'Take Photo',
            'Capture hard copy invoice or challan', const Color(0xFFFEE2E2),
            () { Get.back(); ctrl.pickFromCamera(); }),
        _optRow(context, '🖼', 'Choose from Gallery',
            'Pick an existing scanned image', const Color(0xFFEDE9FE),
            () { Get.back(); ctrl.pickFromGallery(); }),
        _optRow(context, '📁', 'Upload File (PDF / Doc)',
            'Browse and attach a soft copy', newBlueLightColor,
            () { Get.back(); ctrl.pickFile(); }),
        _optRow(context, '🔍', 'Scan & Auto-enhance',
            'Multi-page scan with perspective fix', newGreenLightColor,
            () { Get.back(); ctrl.pickFromCamera(); }),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: newTextSecondary,
              side: const BorderSide(color: newBorderColor),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _optRow(BuildContext ctx, String emoji, String title, String sub,
      Color iconBg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: newBorderColor))),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: newTextPrimary)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10, color: newTextSecondary)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: newTextHint),
        ]),
      ),
    );
  }
}
