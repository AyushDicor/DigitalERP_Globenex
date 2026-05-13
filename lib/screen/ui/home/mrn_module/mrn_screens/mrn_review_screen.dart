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
      return Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
            child: Column(children: [

              // ── Read-only notice banner ───────────────────────────────────
              _reviewBanner(),

              // ── MRN Info card ─────────────────────────────────────────────
              _mrnInfoCard(ctrl),

              // ── Party & Site card ─────────────────────────────────────────
              _partyCard(ctrl),

              // ── Items card ────────────────────────────────────────────────
              _itemsCard(ctrl),

              // ── Amount summary card ───────────────────────────────────────
              _summaryCard(ctrl),

              // ── Final remarks (only editable field in review) ─────────────
              _remarksCard(ctrl),
            ]),
          ),
        ),

        // ── Bottom bar ────────────────────────────────────────────────────────
        _bottomBar(ctrl),
      ]);
    });
  }

  // ── Review notice banner ────────────────────────────────────────────────────
  Widget _reviewBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC02)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFE6A817)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Please review all details carefully. Go back to make any changes.',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: Color(0xFF8A6200)),
          ),
        ),
      ]),
    );
  }

  // ── MRN Info card ───────────────────────────────────────────────────────────
  Widget _mrnInfoCard(MrnController ctrl) {
    return MrnCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MrnSectionHead('MRN Details'),
        _infoGrid([
          _InfoTile('MRN No.',      ctrl.mrnNumber, mono: true),
          _InfoTile('MRN Date',     ctrl.mrnDateCtrl.text),
          _InfoTile('Series Type',  ctrl.selectedSeriesType?.label ?? '—'),
          _InfoTile('Source',       ctrl.sourceLabel(ctrl.selectedSource)),
        ]),

        if (ctrl.selectedSource == MrnSourceType.purchaseOrder) ...[
          const SizedBox(height: 8),
          _infoGrid([
            _InfoTile(
              'Linked PO',
              // Use orderno for display (e.g. "GP09/0030/PO/26-27")
              // Fall back to orderid int if orderno is empty
              ctrl.processingPo != null
                  ? (ctrl.processingPo!.orderno.isNotEmpty
                  ? ctrl.processingPo!.orderno
                  : '#${ctrl.processingPo!.orderid}')
                  : '—',
              full: true,
              mono: true,
            ),
          ]),

          // Also show party name from the PO if partyNameCtrl is empty
          if (ctrl.processingPo?.partyname.isNotEmpty == true &&
              ctrl.partyNameCtrl.text.isEmpty) ...[
            const SizedBox(height: 8),
            _infoGrid([
              _InfoTile('Party', ctrl.processingPo!.partyname, full: true),
            ]),
          ],
        ],
      ]),
    );
  }

  // ── Party & Site card ───────────────────────────────────────────────────────
  Widget _partyCard(MrnController ctrl) {
    return MrnCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MrnSectionHead('Party & Site Details'),

        // Party name highlight
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: newBlueLightColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: newBlueColor.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                  color: newBlueColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: const Text('🏢', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ctrl.partyNameCtrl.text.isEmpty ? '—' : ctrl.partyNameCtrl.text,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: newBlueColor),
                    ),
                    const Text('Party / Supplier',
                        style: TextStyle(fontSize: 10, color: newTextSecondary)),
                  ]),
            ),
          ]),
        ),

        const SizedBox(height: 10),

        // Row 1: Site + Godown
        _infoGrid([
          _InfoTile('Site',    ctrl.selectedSite?.label   ?? '—'),
          _InfoTile('Godown',  ctrl.selectedGodown?.label ?? '—'),
        ]),
        const SizedBox(height: 8),

        // Row 2: Bill No + Bill Date
        _infoGrid([
          _InfoTile('Bill No.',   ctrl.billNoCtrl.text.isEmpty   ? '—' : ctrl.billNoCtrl.text,   mono: true),
          _InfoTile('Bill Date',  ctrl.billDateCtrl.text),
        ]),
        const SizedBox(height: 8),

        // Row 3: Challan No + Challan Date
        _infoGrid([
          _InfoTile('Challan No.',   ctrl.challanNoCtrl.text.isEmpty ? '—' : ctrl.challanNoCtrl.text, mono: true),
          _InfoTile('Challan Date',  ctrl.challanDateCtrl.text),
        ]),
        const SizedBox(height: 8),

        // Row 4: Received By (full width)
        _infoGrid([
          _InfoTile('Received By', ctrl.receivedByName, full: true),
        ]),

        // Attachments summary
        if (ctrl.billAttachments.isNotEmpty ||
            ctrl.challanAttachments.isNotEmpty) ...[
          const SizedBox(height: 10),
          _attachmentSummary(ctrl),

          // if (ctrl.shippingAddress != null || ctrl.billingAddress != null) ...[
          //   const SizedBox(height: 10),
          //   _addressRow(ctrl),
          // ],
        ],
      ]),
    );
  }

  Widget _attachmentSummary(MrnController ctrl) {
    final total = ctrl.billAttachments.length + ctrl.challanAttachments.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: newGreenLightColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: newGreenColor.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.attach_file_rounded, size: 14, color: newGreenColor),
        const SizedBox(width: 6),
        Text(
          '$total attachment${total == 1 ? '' : 's'} uploaded'
              '${ctrl.billAttachments.isNotEmpty ? '  ·  ${ctrl.billAttachments.length} Bill' : ''}'
              '${ctrl.challanAttachments.isNotEmpty ? '  ·  ${ctrl.challanAttachments.length} Challan' : ''}',
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: newGreenColor),
        ),
      ]),
    );
  }

  // ── Items card ──────────────────────────────────────────────────────────────
  Widget _itemsCard(MrnController ctrl) {
    return MrnCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: MrnSectionHead(
            'Items Received',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: newBlueLightColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${ctrl.itemLines.length} items',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: newBlueColor)),
            ),
          ),
        ),

        if (ctrl.itemLines.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const Text('No items added',
                  style: TextStyle(fontSize: 13, color: newTextSecondary)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ctrl.itemLines.length,
            itemBuilder: (_, i) =>
                _ReviewItemRow(item: ctrl.itemLines[i], ctrl: ctrl, index: i),
          ),
      ]),
    );
  }

  // ── Amount summary card ─────────────────────────────────────────────────────
  Widget _summaryCard(MrnController ctrl) {
    // Group GST by percentage slab
    final Map<double, double> gstByRate = {};
    for (final item in ctrl.itemLines) {
      if (item.gstPercent > 0) {
        gstByRate[item.gstPercent] =
            (gstByRate[item.gstPercent] ?? 0) + item.gstAmount;
      }
    }
    final sortedRates = gstByRate.keys.toList()..sort();

    // ✅ Compute total discount across all items
    final totalDiscount = ctrl.itemLines.fold(
        0.0, (s, i) => s + i.discountAmount);

    return MrnCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MrnSectionHead('Amount Summary'),
        const SizedBox(height: 4),

        // Gross amount before discount
        _sumRow('Gross Amount',
            _fmt(ctrl.itemLines.fold(0.0, (s, i) => s + (i.receiveNowQty * i.rate)))),

        // ✅ Discount row — only show if any discount exists
        if (totalDiscount > 0)
          _sumRow('Total Discount (-)  ', '- ${_fmt(totalDiscount)}'),

        _sumRow('Subtotal (${ctrl.itemLines.length} items)', _fmt(ctrl.subtotal)),

        // GST breakdown
        if (sortedRates.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: newSurfaceColor,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: newBorderColor),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GST Breakdown',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: newTextSecondary)),
                  Text(_fmt(ctrl.totalGst),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: newTextSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              ...sortedRates.map((rate) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: newBlueLightColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('GST ${rate.toInt()}%',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: newBlueColor)),
                    ),
                    Text(_fmt(gstByRate[rate]!),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: newTextPrimary)),
                  ],
                ),
              )),
            ]),
          ),
        ] else
          _sumRow('Total GST', _fmt(ctrl.totalGst)),

        // Round off
        if (ctrl.roundOff != 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Round Off',
                    style: TextStyle(fontSize: 12, color: newTextSecondary)),
                Text(
                  '${ctrl.roundOff >= 0 ? '+' : ''}${ctrl.roundOff.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ctrl.roundOff >= 0 ? newGreenColor : newRedColor),
                ),
              ],
            ),
          ),

        // Grand Total
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: newTextPrimary)),
              Text(_fmt(ctrl.grandTotalRounded),
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: newBlueColor)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _sumRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: newTextSecondary)),
          Text(val,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: newTextPrimary)),
        ],
      ),
    );
  }

  // ── Remarks card (only editable field in review) ────────────────────────────
  Widget _remarksCard(MrnController ctrl) {
    return MrnCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MrnSectionHead('Final Remarks'),
        const SizedBox(height: 2),
        const Text(
          'Add any delivery notes, quality observations or discrepancies.',
          style: TextStyle(fontSize: 11, color: newTextSecondary),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: ctrl.reviewRemarksCtrl,
          minLines: 3,
          maxLines: 6,
          style: const TextStyle(fontSize: 13, color: newTextPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Material arrived in good condition. 2 items damaged.',
            hintStyle: const TextStyle(color: newTextHint, fontSize: 12),
            filled: true,
            fillColor: newSurfaceColor,
            contentPadding: const EdgeInsets.all(12),
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
      ]),
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────────────
  Widget _bottomBar(MrnController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: newBorderColor))),
      child: SafeArea(
        top: false,
        child: Row(children: [
          // Back to edit
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => ctrl.prevStep(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Edit',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: newBlueColor,
                side: const BorderSide(color: newBlueColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Submit
          Expanded(
            flex: 2,
            child: MrnPrimaryBtn(
              label: ctrl.isBusy ? 'Uploading & Saving…' :
              ctrl.selectedSource == MrnSourceType.grn
                  ? 'Submit GRN'
                  : 'Submit MRN',
              icon: ctrl.isBusy ? Icons.cloud_upload_outlined : Icons.check_rounded,
              color: newGreenColor,
              isLoading: ctrl.isBusy,
              onTap: () => ctrl.selectedSource == MrnSourceType.grn   // ✅
                  ? ctrl.submitGRN()
                  : ctrl.submitMRN(),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Info grid ───────────────────────────────────────────────────────────────
  Widget _infoGrid(List<_InfoTile> tiles) {
    return LayoutBuilder(builder: (context, constraints) {
      final tileWidth = (constraints.maxWidth - 8) / 2; // 2 columns, 8 = spacing
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tiles.map((t) {
          return SizedBox(
            width: t.full ? constraints.maxWidth : tileWidth,
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
                            fontSize: 10,
                            color: newTextSecondary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(
                      t.value.isEmpty ? '—' : t.value,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: t.valueColor ?? newTextPrimary,
                          fontFamily: t.mono ? 'monospace' : null),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
            ),
          );
        }).toList(),
      );
    });
  }

  static String _fmt(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000)   return '₹${(v / 100000).toStringAsFixed(2)} L';

    // ✅ Use proper Indian formatting for values < 1 lakh
    final formatted = v.toStringAsFixed(2);
    final parts = formatted.split('.');
    final whole = parts[0];
    final decimal = parts[1];

    if (whole.length <= 3) return '₹$whole.$decimal';

    // Indian format: last 3 digits, then groups of 2
    final last3 = whole.substring(whole.length - 3);
    final rest = whole.substring(0, whole.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '₹$buf,$last3.$decimal';
  }

  // Widget _addressRow(MrnController ctrl) {
  //   return _infoGrid([
  //     if (ctrl.shippingAddress != null)
  //       _InfoTile(
  //         'Shipping Address',
  //         ctrl.shippingAddress!.formatted,
  //         full: ctrl.billingAddress == null,
  //       ),
  //     if (ctrl.billingAddress != null)
  //       _InfoTile(
  //         'Billing Address',
  //         ctrl.billingAddress!.formatted,
  //         full: ctrl.shippingAddress == null,
  //       ),
  //   ]);
  // }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Review item row — shows all item fields, read-only
// ═══════════════════════════════════════════════════════════════════════════════
class _ReviewItemRow extends StatelessWidget {
  final MrnItemLine item;
  final MrnController ctrl;
  final int index;

  const _ReviewItemRow(
      {required this.item, required this.ctrl, required this.index});

  @override
  Widget build(BuildContext context) {
    final godownLabel = item.selectedGodownId != null
        ? (ctrl.godownList
        .firstWhereOrNull((g) => g.id == item.selectedGodownId)
        ?.label ??
        ctrl.selectedGodown?.label ??
        '—')
        : (ctrl.selectedGodown?.label ?? '—');

    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: newBorderColor))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
          const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          // ── Collapsed title ──────────────────────────────────────────────
          leading: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
                color: newBlueLightColor,
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    color: newBlueColor)),
          ),
          title: Text(item.itemName,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: newTextPrimary)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(children: [
              _pill(item.itemCode, newSurfaceColor, newTextSecondary),
              const SizedBox(width: 5),
              _pill(item.unit, newSurfaceColor, newTextSecondary),
              const SizedBox(width: 5),
              _pill('Rcvd: ${item.receiveNowQty.toInt()}',
                  newGreenLightColor, newGreenColor),
            ]),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${item.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: newTextPrimary)),
              Text('incl. GST',
                  style: const TextStyle(
                      fontSize: 9, color: newTextSecondary)),
            ],
          ),

          // ── Expanded: all item fields ────────────────────────────────────
          children: [
            const Divider(height: 1, color: newBorderColor),
            const SizedBox(height: 10),

            // ── Quantity block ─────────────────────────────────────────────
            _sectionLabel('Quantity'),
            const SizedBox(height: 6),
            _fieldGrid([
              _FieldTile('PO Qty', '${item.poQty.toInt()} ${item.unit}'),
              _FieldTile('Prev Received',
                  '${item.previouslyReceivedQty.toInt()} ${item.unit}'),
              _FieldTile('Balance',
                  '${item.maxReceivable.toInt()} ${item.unit}',
                  valueColor: newGreenColor),
              _FieldTile('Now Receiving',
                  '${item.receiveNowQty.toInt()} ${item.unit}',
                  valueColor: newBlueColor, bold: true),
            ]),

            const SizedBox(height: 12),

            // ── Financials block ───────────────────────────────────────────
            _sectionLabel('Financials'),
            const SizedBox(height: 6),
            _fieldGrid([
              _FieldTile('Rate', '₹${item.rate.toStringAsFixed(2)}'),
              _FieldTile('Discount %', '${item.discountPercent.toStringAsFixed(1)}%'),
              _FieldTile('Discount (₹)', '₹${item.discountAmount.toStringAsFixed(2)}'),
              _FieldTile('Amount', '₹${item.amount.toStringAsFixed(2)}'),
              _FieldTile('GST ${item.gstPercent.toInt()}%',
                  '₹${item.gstAmount.toStringAsFixed(2)}'),
              _FieldTile('Total', '₹${item.totalAmount.toStringAsFixed(2)}',
                  valueColor: newBlueColor, bold: true, full: true),
            ]),

            const SizedBox(height: 12),

            // ── Godown & Remarks ───────────────────────────────────────────
            _sectionLabel('Storage & Notes'),
            const SizedBox(height: 6),
            _fieldGrid([
              _FieldTile('Godown', godownLabel,
                  valueColor: item.selectedGodownId != null &&
                      item.selectedGodownId != ctrl.selectedGodown?.id
                      ? newOrangeColor
                      : null,
                  full: true),
              if (item.remarks.isNotEmpty)
                _FieldTile('Remarks', item.remarks, full: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: newTextSecondary,
            letterSpacing: 0.6));
  }

  Widget _fieldGrid(List<_FieldTile> tiles) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tiles.map((t) {
        return SizedBox(
          width: t.full
              ? double.infinity
              : (Get.width - 28 - 28 - 8) / 2,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: newSurfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: newBorderColor)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.label,
                      style: const TextStyle(
                          fontSize: 9,
                          color: newTextSecondary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(t.value,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: t.bold
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: t.valueColor ?? newTextPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ]),
          ),
        );
      }).toList(),
    );
  }

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

// ── Helper data classes ────────────────────────────────────────────────────────
class _InfoTile {
  final String label, value;
  final bool mono, full;
  final Color? valueColor;
  const _InfoTile(this.label, this.value,
      {this.mono = false, this.full = false, this.valueColor});
}

class _FieldTile {
  final String label, value;
  final bool full, bold;
  final Color? valueColor;
  const _FieldTile(this.label, this.value,
      {this.full = false, this.bold = false, this.valueColor});
}