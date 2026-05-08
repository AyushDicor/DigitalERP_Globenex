
import 'package:digitalerp/utils/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mrn_controller/mrn_controller.dart';
import 'mrn_screens/mrn_items_screen.dart';
import 'mrn_screens/mrn_review_screen.dart';
import 'mrn_screens/mrn_scan_screen.dart';
import 'mrn_screens/mrn_source_screen.dart';
import 'mrn_widgets.dart';

class MrnEntryView extends StatelessWidget {
  const MrnEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MrnController>(
      init: MrnController(),
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              //  App bar 
              _appBar(ctrl),

              //  Step progress bar 
              MrnStepBar(current: ctrl.currentStep),
              const Divider(height: 1, color: newBorderColor),

              //  Page view (4 steps) 
              Expanded(
                child: PageView(
                  controller: ctrl.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    MrnSourceScreen(),
                    MrnItemsScreen(),
                    MrnScanScreen(),
                    MrnReviewScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar(MrnController ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Row(children: [
        // Back / close
        GestureDetector(
          onTap: () {
            if (ctrl.currentStep > 0) {
              ctrl.prevStep();
            } else {
              Get.back();
            }
          },
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: newSurfaceColor,
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: newTextPrimary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('New MRN Entry',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
            Text(ctrl.mrnNumber,
                style: const TextStyle(
                    fontSize: 11, color: newTextSecondary,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        // Print icon (visible on review step)
        if (ctrl.currentStep == 3)
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: newBlueLightColor,
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: const Icon(Icons.print_outlined,
                size: 20, color: newBlueColor),
          ),
      ]),
    );
  }
}
