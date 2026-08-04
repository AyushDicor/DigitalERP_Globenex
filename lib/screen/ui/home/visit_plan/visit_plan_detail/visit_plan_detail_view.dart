import 'package:digitalerp/response/visit_plan_detail_data_response.dart';
import 'package:digitalerp/screen/ui/home/visit_plan/visit_plan_detail/visit_plan_detail_controller.dart';
import 'package:digitalerp/utils/all_screens_dialog_box/dialog_bg_widget.dart';
import 'package:digitalerp/utils/app_constant_new.dart'
    show
        newTextPrimary,
        newTextSecondary,
        newBorderColor,
        newSurfaceColor,
        newBlueColor,
        newGreenColor,
        newGreenLightColor,
        newOrangeColor,
        newOrangeLightColor,
        newRedColor,
        newRedLightColor;
import 'package:digitalerp/utils/dottedline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VisitPlanDetailView extends StatelessWidget {
  const VisitPlanDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VisitPlanDetailController>(
      init: VisitPlanDetailController(),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: newSurfaceColor,
        body: SafeArea(
          child: Column(
            children: [
              _appBar(controller),
              Expanded(
                child: controller.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : controller.visitPlanDetailList.isEmpty
                        ? Center(
                            child: Text(
                              'Not Available',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: newTextSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.visitPlanDetailList.length,
                            itemBuilder: (context, index) {
                              return card(controller, index, context);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar(VisitPlanDetailController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => controller.backTap(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: newTextPrimary, size: 20),
          ),
          Text(
            'Visit Plan Detail',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: newTextPrimary),
          ),
        ],
      ),
    );
  }

  Widget card(VisitPlanDetailController controller, int index, BuildContext context) {
    var item = controller.visitPlanDetailList[index];
    final bool isCheckedOutForActions = !(item.checkstatus == 'Check In' ||
        item.checkstatus == '' ||
        (controller.visitCheckOutList.isEmpty ? false : controller.visitCheckOutList[index].checkstatus == ''));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: newBorderColor),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Name',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: newTextSecondary),
                    ),
                    _statusChip(controller, index, item),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.customername ?? 'N/A',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: newTextPrimary),
                ),
                const SizedBox(height: 14),
                // Both columns are Expanded — they hold free-text values
                // (executive name, status) that would otherwise overflow the
                // Row, the same way the plan and preview cards did.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Date'),
                          _value(item.visitdate ?? 'N/A'),
                          const SizedBox(height: 10),
                          _label('Status'),
                          _value(item.visitstatus ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _label('Timing'),
                          _value(item.visittime ?? 'N/A'),
                          const SizedBox(height: 10),
                          _label('Executive'),
                          _value(controller.argument?.executive ?? 'N/A'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DottedLine(
            color: newBorderColor,
            width: double.maxFinite,
            strokeWidth: 1.0,
            dottedLength: 5.0,
            space: 2.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickAction(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Order',
                  color: newOrangeColor,
                  enabled: isCheckedOutForActions,
                  onTap: () => controller.tapOnOrder(index),
                ),
                DottedLine(color: newBorderColor, height: 15, strokeWidth: 1.0, dottedLength: 5.0, space: 0.0),
                _quickAction(
                  icon: Icons.show_chart_rounded,
                  label: 'Stock',
                  color: newBlueColor,
                  enabled: isCheckedOutForActions,
                  onTap: () => controller.tapOnStock(item),
                ),
                DottedLine(color: newBorderColor, height: 15, strokeWidth: 1.0, dottedLength: 5.0, space: 0.0),
                _quickAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Collection',
                  color: newRedColor,
                  enabled: isCheckedOutForActions,
                  onTap: () => controller.tapOnPayment(item.partyid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: newTextSecondary),
      );

  Widget _value(String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: newTextPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );

  Widget _statusChip(VisitPlanDetailController controller, int index, VisitPlanDetailsDataList item) {
    final Color fg;
    final Color bg;
    if (item.checkstatus == 'Check In') {
      fg = newOrangeColor;
      bg = newOrangeLightColor;
    } else if (item.checkstatus == 'Check Out') {
      fg = newGreenColor;
      bg = newGreenLightColor;
    } else if (item.checkstatus == 'Checked Out') {
      fg = newRedColor;
      bg = newRedLightColor;
    } else {
      fg = newTextSecondary;
      bg = newBorderColor;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (item.checkstatus == 'Check In') {
          controller.tapOnCheckIn(index);
        } else if (item.checkstatus == 'Check Out' ||
            (controller.visitCheckInList.isEmpty ? false : controller.visitCheckInList[index].checkstatus == 'Check Out')) {
          showRemarkDialog(controller, index, Get.context!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(
          item.checkstatus ?? '',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final Color effectiveColor = enabled ? color : newTextSecondary;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: effectiveColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: effectiveColor),
            ),
          ],
        ),
      ),
    );
  }

  showRemarkDialog(VisitPlanDetailController controller, int index, BuildContext context) {
    Get.dialog(
      DialogNewWidget(
        onApplyOrDoneButtonTap: () {
          controller.tapOnCheckOut(index);
          Get.back();
        },
        isEdit: true,
        text: "Remark :",
        buttonName: "Check Out",
        children: [
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.only(left: 10),
            width: Get.width * 0.900,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: newBorderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: controller.remarkController,
              maxLines: 5,
              style: TextStyle(color: newTextPrimary),
              decoration: const InputDecoration(
                hintText: "Enter Remark....",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
