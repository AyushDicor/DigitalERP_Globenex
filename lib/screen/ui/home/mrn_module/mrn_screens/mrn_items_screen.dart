
import 'package:digitalerp/utils/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../mrn_controller/mrn_controller.dart';
import '../mrn_response/mrn_models.dart';
import '../mrn_widgets.dart';

class MrnItemsScreen extends StatelessWidget {
  const MrnItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MrnController>(builder: (ctrl) {
      return Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            child: Column(children: [
              //  Notice banner 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: newOrangeLightColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: newOrangeColor),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: newOrangeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing open POs for ${ctrl.selectedSupplier}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E)),
                    ),
                  ),
                ]),
              ),

              //  Available POs 
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('Available Purchase Orders'),
                  ...ctrl.poList.map((po) => _poRow(ctrl, po)),
                ]),
              ),

              //  Items from selected PO 
              MrnCard(
                child: Column(children: [
                  MrnSectionHead(
                    'Items from PO',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: newBlueLightColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${ctrl.itemLines.length} items',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: newBlueColor),
                      ),
                    ),
                  ),
                  ...ctrl.itemLines.asMap().entries.map(
                      (e) => _itemRow(ctrl, e.key, e.value)),
                ]),
              ),
            ]),
          ),
        ),

        //  Bottom CTA 
        _bottomBar(ctrl),
      ]);
    });
  }

  //  PO Row 
  Widget _poRow(MrnController ctrl, MrnPOItem po) {
    return GestureDetector(
      onTap: () => ctrl.togglePO(po),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: po.isSelected ? newBlueLightColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: po.isSelected ? newBlueColor : newBorderColor,
            width: po.isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: po.isSelected ? newBlueColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: po.isSelected ? newBlueColor : newBorderColor,
                  width: 1.5),
            ),
            alignment: Alignment.center,
            child: po.isSelected
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(po.poNumber,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: newTextPrimary, fontFamily: 'monospace')),
              Text('${po.date} · ${po.itemCategory}',
                  style: const TextStyle(fontSize: 10, color: newTextSecondary)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${_fmt(po.amount)}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: newBlueColor)),
            const SizedBox(height: 3),
            MrnBadge.status(po.status),
          ]),
        ]),
      ),
    );
  }

  //  Item Row 
  Widget _itemRow(MrnController ctrl, int index, MrnItemLine item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: newSurfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: newBorderColor),
      ),
      child: Row(children: [
        // Index circle
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
              color: newBlueLightColor,
              borderRadius: BorderRadius.circular(7)),
          alignment: Alignment.center,
          child: Text('${index + 1}',
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, color: newBlueColor)),
        ),
        const SizedBox(width: 8),
        // Info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.itemName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: newTextPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${item.itemCode} · PO: ${item.poQty.toInt()} · Rcvd: ${item.receivedQty.toInt()}',
              style: const TextStyle(fontSize: 10, color: newTextSecondary),
            ),
          ]),
        ),
        const SizedBox(width: 6),
        // Qty control
        MrnQtyControl(
          qty: item.receiveNowQty,
          onIncrease: () => ctrl.increaseQty(item),
          onDecrease: () => ctrl.decreaseQty(item),
        ),
        const SizedBox(width: 6),
        // Rate
        SizedBox(
          width: 52,
          child: Text('₹${_fmt(item.rate)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: newBlueColor)),
        ),
      ]),
    );
  }

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
            child: OutlinedButton.icon(
              onPressed: () => ctrl.goToStep(2),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Scan More',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
          Expanded(
            child: MrnPrimaryBtn(
              label: 'Review →',
              onTap: () => ctrl.goToStep(3),
            ),
          ),
        ]),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}
