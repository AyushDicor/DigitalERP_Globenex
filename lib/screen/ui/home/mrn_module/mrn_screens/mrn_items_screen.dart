import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
                  14, 14, 14,
                  MediaQuery.of(context).viewInsets.bottom + 110,
                ),
                child: Column(children: [

                  // ── Direct purchase — show entry form ──────────────────
                  if (ctrl.selectedSource == MrnSourceType.directPurchase)
                    const MrnDirectItemForm(),

                  if (ctrl.selectedSource == MrnSourceType.purchaseOrder)
                    MrnCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        // ── Card header ──────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: MrnSectionHead('Select Purchase Order',
                            trailing: ctrl.isLoadingPO
                                ? const SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: newBlueColor))
                                : GestureDetector(
                              onTap: () => ctrl.fetchPendingPoList(),
                              child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: newBlueColor),
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
                            child: _emptyState(
                                'No pending POs found',
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

                  // ── PO / GRN items list ────────────────────────────────
                  if (ctrl.selectedSource == MrnSourceType.purchaseOrder &&
                      (ctrl.itemLines.isNotEmpty || ctrl.isLoadingItems))
                    MrnCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                          child: MrnSectionHead(
                            'Item Details',
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (ctrl.isLoadingItems)
                                    const SizedBox(
                                        width: 14, height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: newBlueColor)),
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
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: newBorderColor),
                            itemBuilder: (_, i) => _ItemCard(
                                ctrl: ctrl,
                                item: ctrl.itemLines[i],
                                index: i),
                          ),
                        if (!ctrl.isLoadingItems && ctrl.itemLines.isNotEmpty)
                          _totalsFooter(ctrl),
                      ]),
                    ),
                ]),
              ),
            ),

            // ── Bottom CTA ───────────────────────────────────────────────
            if (MediaQuery.of(context).viewInsets.bottom == 0)
              _bottomBar(ctrl),
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
            width: 20, height: 20,
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
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle))
                : null,
          ),
          const SizedBox(width: 12),

          // ── PO info ───────────────────────────────────────────────────────
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PO number (orderno)
                  Text(po.orderno.isNotEmpty ? po.orderno : '#${po.orderid}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: newTextPrimary,
                          letterSpacing: .2)),
                  const SizedBox(height: 3),

                  // Party name
                  if (po.partyname.isNotEmpty)
                    Text(po.partyname,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: newTextPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),

                  const SizedBox(height: 3),

                  // Date + qty pill row
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: newSurfaceColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: newBorderColor)),
                        child: Text('${po.totalqty} item${po.totalqty == 1 ? '' : 's'}',
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
            // Grand total (incl GST)
            Text('₹${MrnUtils.inr(po.grandtotal)}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
            const SizedBox(height: 2),
            // Subtotal label
            Text('₹${MrnUtils.inr(po.totalamount)} + GST',
                style: const TextStyle(
                    fontSize: 9, color: newTextSecondary)),
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
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
            Text(MrnUtils.inr(ctrl.grandTotal),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800,
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
                fontSize: 12, fontWeight: FontWeight.w700, color: newTextPrimary)),
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
      Text(msg, style: const TextStyle(fontSize: 13, color: newTextSecondary)),
    ]),
  );

  Widget _countBadge(int count, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
        color: newBlueLightColor, borderRadius: BorderRadius.circular(20)),
    child: Text('$count $label',
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: newBlueColor)),
  );

  // ── REMOVE this entire broken _inr ────────────────────────────────────────
  // ✅ Fixed Indian number formatter
  static String _inr(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)} L';

    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimal = parts[1];

    if (whole.length <= 3) return '₹$whole.$decimal';

    // Indian format: last 3 digits, then groups of 2 from right
    final last3 = whole.substring(whole.length - 3);
    final rest = whole.substring(0, whole.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '₹$buf,$last3.$decimal';
  }
}

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
        // ── Selected PO summary ─────────────────────────────────────────────
        Row(children: [
          const Icon(Icons.receipt_long_rounded, size: 16, color: newBlueColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    po.orderno.isNotEmpty ? po.orderno : '#${po.orderid}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: newBlueColor),
                  ),
                  if (po.partyname.isNotEmpty)
                    Text(po.partyname,
                        style: const TextStyle(
                            fontSize: 11, color: newTextSecondary)),
                  if (po.orderdate.isNotEmpty)
                    Text(po.orderdate,
                        style: const TextStyle(
                            fontSize: 10, color: newTextSecondary)),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${MrnUtils.inr(po.grandtotal)}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: newBlueColor)),
            Text('${po.totalqty} item${po.totalqty == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 10, color: newTextSecondary)),
          ]),
        ]),

        const SizedBox(height: 10),

        // ── Process button ──────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: ctrl.isLoadingItems
                ? null
                : () => ctrl.processSelectedPO(),
            style: ElevatedButton.styleFrom(
              backgroundColor: newBlueColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: ctrl.isLoadingItems
                ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              ctrl.isLoadingItems ? 'Loading Items…' : 'Process PO',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ]),
    );
  }

  static String _inr(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)} L';

    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimal = parts[1];

    if (whole.length <= 3) return '₹$whole.$decimal';

    final last3 = whole.substring(whole.length - 3);
    final rest = whole.substring(0, whole.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '₹$buf,$last3.$decimal';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Individual item card
// ═══════════════════════════════════════════════════════════════════════════════
class _ItemCard extends StatelessWidget {
  final MrnController ctrl;
  final MrnItemLine item;
  final int index;

  const _ItemCard({required this.ctrl, required this.item, required this.index});

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

        // ── Compact summary row (always visible) ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Index bubble
            Container(
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
            const SizedBox(width: 10),

            // Item info + godown inline
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.itemName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: newTextPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  _pill(item.itemCode, newSurfaceColor, newTextSecondary),
                  const SizedBox(width: 5),
                  _pill(item.unit, newSurfaceColor, newTextSecondary),
                  const SizedBox(width: 5),
                  _pill('PO: ${item.poQty.toInt()}', newBlueLightColor, newBlueColor),
                ]),
                const SizedBox(height: 6),

                // ── Inline godown selector ────────────────────────────────
                _InlineGodownSelector(ctrl: ctrl, item: item),
              ]),
            ),
            const SizedBox(width: 8),

            // Qty stepper
            _QtyField(ctrl: ctrl, item: item),

            // Expand toggle
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

        // ── Expanded detail panel ─────────────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _expandedPanel(context),
          crossFadeState:
          item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),

        // ── Qty warning strip ─────────────────────────────────────────────────
        if (isOverReceived)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: newRedLightColor,
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 13, color: newRedColor),
              const SizedBox(width: 5),
              Text(
                'Exceeds PO balance. Max: ${item.maxReceivable.toInt()} ${item.unit}',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: newRedColor),
              ),
            ]),
          )
        else
          const SizedBox(height: 10),
      ]),
    );
  }

  // ── Expanded detail panel ──────────────────────────────────────────────────
  Widget _expandedPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(height: 1, color: newBorderColor),
        const SizedBox(height: 12),

        // ── Financial grid (read-only) ──────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: newSurfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: newBorderColor),
          ),
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: newBlueLightColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(9), topRight: Radius.circular(9)),
              ),
              child: Row(children: [
                const Icon(Icons.calculate_outlined, size: 13, color: newBlueColor),
                const SizedBox(width: 5),
                const Text('Financial Details',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800,
                        color: newBlueColor, letterSpacing: .3)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: newBlueColor, borderRadius: BorderRadius.circular(4)),
                  child: const Text('READ ONLY',
                      style: TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: .5)),
                ),
              ]),
            ),
            _finRow('Order No', item.orderNo, mono: true),
            _finRow('Rate', '₹${item.rate.toStringAsFixed(2)}'),
            _finRow('Discount',
                '${item.discountPercent.toStringAsFixed(1)}%  (₹${item.discountAmount.toStringAsFixed(2)})'),
            _finRow('Amount', '₹${item.amount.toStringAsFixed(2)}'),
            _finRow('GST %', '${item.gstPercent.toStringAsFixed(1)}%'),
            _finRow('GST Amount', '₹${item.gstAmount.toStringAsFixed(2)}'),
            _finRowTotal('Total Amount', '₹${item.totalAmount.toStringAsFixed(2)}'),
          ]),
        ),

        const SizedBox(height: 12),

        // ── PO quantity summary ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: newSurfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: newBorderColor),
          ),
          child: Row(children: [
            _qtyBlock('PO Qty', item.poQty.toInt(), newBlueLightColor, newBlueColor),
            _qDivider(),
            _qtyBlock('Prev Rcvd', item.previouslyReceivedQty.toInt(),
                newOrangeLightColor, newOrangeColor),
            _qDivider(),
            _qtyBlock('Balance', item.maxReceivable.toInt(),
                newGreenLightColor, newGreenColor),
            _qDivider(),
            _qtyBlock('Now Rcvg', item.receiveNowQty.toInt(),
                newBlueLightColor, newBlueColor,
                bold: true),
          ]),
        ),

        const SizedBox(height: 12),

        // ── Remarks ─────────────────────────────────────────────────────────
        MrnField(
          label: 'Remarks',
          hint: 'Optional delivery note for this item…',
          controller: TextEditingController(text: item.remarks)
            ..selection =
            TextSelection.collapsed(offset: item.remarks.length),
          minLines: 2,
          onChanged: (v) => ctrl.setItemRemarks(item, v),
        ),

        const SizedBox(height: 10),

        // ── Remove item ──────────────────────────────────────────────────────
        GestureDetector(
          onTap: () => ctrl.removeItem(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
                color: newRedLightColor,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: newRedColor.withValues(alpha: 0.3))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.remove_circle_outline_rounded, size: 14, color: newRedColor),
              SizedBox(width: 6),
              Text('Remove this item',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: newRedColor)),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Financial row helpers ──────────────────────────────────────────────────
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
                fontSize: 12, fontWeight: FontWeight.w800, color: newBlueColor)),
        Text(val,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: newBlueColor)),
      ]),
    );
  }

  Widget _qtyBlock(String label, int val, Color bg, Color fg, {bool bold = false}) {
    return Expanded(
      child: Column(children: [
        Text('$val',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: fg)),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
          child: Text(label,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
        ),
      ]),
    );
  }

  Widget _qDivider() =>
      Container(width: 1, height: 36, color: newBorderColor);

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(text,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Inline Godown Selector (compact row — always visible)
// ═══════════════════════════════════════════════════════════════════════════════
class _InlineGodownSelector extends StatelessWidget {
  final MrnController ctrl;
  final MrnItemLine item;

  const _InlineGodownSelector({required this.ctrl, required this.item});

  @override
  Widget build(BuildContext context) {
    // Resolved godown: item override > header godown > fallback text
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
          Icon(
            Icons.warehouse_outlined,
            size: 12,
            color: isOverridden ? newOrangeColor : newTextSecondary,
          ),
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
          Icon(
            Icons.arrow_drop_down_rounded,
            size: 16,
            color: isOverridden ? newOrangeColor : newTextSecondary,
          ),
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

// ── Godown picker bottom sheet ──────────────────────────────────────────────
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
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        const SizedBox(height: 10),
        Container(
          width: 38, height: 4,
          decoration: BoxDecoration(
              color: newBorderColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 14),
        // Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Select Godown',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
          ),
        ),
        const SizedBox(height: 10),
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search godown…',
              hintStyle:
              const TextStyle(fontSize: 13, color: newTextHint),
              prefixIcon: const Icon(Icons.search, size: 18, color: newTextSecondary),
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
        // "Use header godown" option
        if (widget.ctrl.selectedGodown != null)
          _godownTile(
            godown: widget.ctrl.selectedGodown!,
            currentId: currentId,
            isDefault: true,
          ),
        // List
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final g = filtered[i];
              // Skip if same as header (already shown above)
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
        // If tapping the header godown, clear item-level override
        if (isDefault) {
          widget.ctrl.setItemGodown(widget.item, null);
        } else {
          widget.ctrl.setItemGodown(widget.item, godown);
        }
        Get.back();
      },
      leading: Container(
        width: 32, height: 32,
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
                    fontSize: 9, fontWeight: FontWeight.w700,
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
        // Minus
        GestureDetector(
          onTap: () {
            widget.ctrl.decreaseQty(widget.item);
            _sync();
          },
          child: Container(
            width: 30, height: 34,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8))),
            alignment: Alignment.center,
            child: const Icon(Icons.remove, size: 14, color: newBlueColor),
          ),
        ),
        // Text input
        SizedBox(
          width: 40,
          child: TextField(
            controller: _tc,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: newTextPrimary),
            decoration: const InputDecoration(
                border: InputBorder.none, contentPadding: EdgeInsets.zero),
            onChanged: (v) {
              final parsed = double.tryParse(v) ?? 0;
              widget.ctrl.setReceivedQty(widget.item, parsed);
            },
          ),
        ),
        // Plus
        GestureDetector(
          onTap: () {
            widget.ctrl.increaseQty(widget.item);
            _sync();
          },
          child: Container(
            width: 30, height: 34,
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