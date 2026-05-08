
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
              //  MRN Header 
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('MRN Header'),
                  MrnField(
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
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: MrnDropdown(
                        label: 'Warehouse',
                        value: ctrl.selectedWarehouse,
                        items: ctrl.warehouseList,
                        onChanged: (v) => ctrl.setWarehouse(v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MrnField(
                        label: 'MRN No.',
                        controller: TextEditingController(text: ctrl.mrnNumber),
                        readOnly: true,
                      ),
                    ),
                  ]),
                ]),
              ),

              //  Source selection 
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('Select Item Source'),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      _sourceChip(ctrl, MrnSourceType.purchaseOrder,
                          '📄', 'Purchase Order', 'Import from PO',
                          newBlueLightColor),
                      _sourceChip(ctrl, MrnSourceType.indent,
                          '📋', 'Indent / MR', 'Material Request',
                          const Color(0xFFEDE9FE)),
                      _sourceChip(ctrl, MrnSourceType.directPurchase,
                          '🛒', 'Direct Purchase', 'Manual entry',
                          newOrangeLightColor),
                      _sourceChip(ctrl, MrnSourceType.barcodeScan,
                          '📷', 'Barcode Scan', 'Scan & add items',
                          newGreenLightColor),
                    ],
                  ),
                ]),
              ),

              //  Supplier 
              MrnCard(
                child: Column(children: [
                  const MrnSectionHead('Supplier / Party'),
                  MrnDropdown(
                    label: 'Supplier Name',
                    value: ctrl.selectedSupplier,
                    items: ctrl.supplierList,
                    onChanged: (v) => ctrl.setSupplier(v ?? ''),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: MrnField(
                        label: 'Invoice No.',
                        controller: ctrl.invoiceNoCtrl,
                        hint: 'INV-XXXX',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MrnField(
                        label: 'Invoice Date',
                        controller: ctrl.invoiceDateCtrl,
                        readOnly: true,
                        hint: 'DD/MM/YYYY',
                        onTap: () => ctrl.pickInvoiceDate(context),
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
            ]),
          ),
        ),

        //  Bottom CTA 
        _bottomCta(ctrl),
      ]);
    });
  }

  Widget _sourceChip(MrnController ctrl, MrnSourceType type,
      String emoji, String title, String sub, Color iconBg) {
    final isSelected = ctrl.selectedSource == type;
    return GestureDetector(
      onTap: () => ctrl.setSource(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
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
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const Spacer(),
            Text(title,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? newBlueColor : newTextPrimary)),
            Text(sub,
                style: const TextStyle(fontSize: 10, color: newTextSecondary)),
          ],
        ),
      ),
    );
  }

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
}
