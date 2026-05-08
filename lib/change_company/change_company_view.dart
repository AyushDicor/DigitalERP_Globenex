// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:digitalerp/change_company/change_companay_controller.dart';
// import 'package:digitalerp/response/login_response.dart';
// import 'package:digitalerp/screen/base/base_controller.dart';
// import 'package:digitalerp/utils/app_assets.dart';
// import 'package:digitalerp/utils/app_constant.dart';
// import 'package:digitalerp/utils/my_app_bar_new.dart';
// import 'package:digitalerp/utils/shared_pre.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:restart_app/restart_app.dart';
//
// class ChangeCompanyView extends StatefulWidget {
//   const ChangeCompanyView({Key? key}) : super(key: key);
//
//   @override
//   State<ChangeCompanyView> createState() => _ChangeCompanyState();
// }
//
// class _ChangeCompanyState extends State<ChangeCompanyView> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ChangeCompanyController>(
//         init: ChangeCompanyController(),
//         builder: (controller) {
//           return Scaffold(
//             body: Center(
//               child: Stack(
//                 children: [
//                   Positioned(
//                     top: 0,
//                     left: 0,
//                     right: 0,
//                     bottom: 0,
//                     child: Container(
//                       decoration: const BoxDecoration(
//                         image: DecorationImage(
//                           image: AssetImage('assets/images/dashboard_bg.png'),
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                       child: SafeArea(
//                         child: MyAppBar(
//                           title: 'Change Company',
//                           onBackTap: () => Get.back(),
//                           showApprovalIcon: false,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: Get.height * 0.200,
//                     left: 0,
//                     right: 0,
//                     bottom: 0,
//                     child: Column(
//                       children: [
//                         companyDetails(controller),
//                         SizedBox(
//                           height: Get.height * 0.0500,
//                         ),
//                         submitButton(controller)
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   Widget companyDetails(ChangeCompanyController controller) {
//     return Column(
//       children: [
//         DropdownButtonHideUnderline(
//           child: DropdownButton2(
//             buttonHeight: Get.height * 0.0550,
//             buttonWidth: Get.width * 0.900,
//             buttonPadding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//             dropdownDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: dropdownBoxColor,
//             ),
//             dropdownMaxHeight: 200,
//             buttonDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: dropdownBoxColor,
//               gradient: LinearGradient(
//                 colors: [
//                   grBottomColor.withValues(alpha:0.2),
//                   grTopColor.withValues(alpha:0.2)
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             isExpanded: true,
//             hint: Text(
//               "Company Name",
//               style: const TextStyle().newstyle.copyWith(
//                     color: Colors.black,
//                   ),
//               // overflow: TextOverflow.ellipsis,
//             ),
//             // value: controller.selectedDocument,
//             icon: Image.asset(
//               AppAssets.dropdownIcon,
//               width: 15,
//               height: 15,
//             ),
//             value: controller.selectCompany?.compid,
//             items: controller.companyList.map(
//               (items) {
//                 return DropdownMenuItem(
//                   value: items.compid,
//                   child: Text(
//                     items.companyname.toString(),
//                     style: TextStyle().newstyle.copyWith(color: Colors.black),
//                   ),
//                 );
//               },
//             ).toList(),
//             onChanged: (newValue) => controller.setSelectCompanyDropdownValue(
//                 controller.companyList
//                     .firstWhere((element) => element.compid == newValue)
//
//             ),
//             // items: controller.filterDocumentData.map(
//             //       (items) {
//             //     return DropdownMenuItem(
//             //       value: items,
//             //       child: Text(
//             //         items.documentname ?? '',
//             //       ),
//             //     );
//             //   },
//             // ).toList(),
//             // onChanged: (newValue){
//             //   controller.onChangedDocumentDataValue(newValue);
//             //   controller.update();
//             // },
//           ),
//         ),
//         SizedBox(
//           height: Get.height * 0.0100,
//         ),
//         DropdownButtonHideUnderline(
//           child: DropdownButton2(
//             buttonHeight: Get.height * 0.0550,
//             buttonWidth: Get.width * 0.900,
//             buttonPadding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//             dropdownDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: dropdownBoxColor,
//             ),
//             dropdownMaxHeight: 200,
//             buttonDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: dropdownBoxColor,
//               gradient: LinearGradient(
//                 colors: [
//                   grBottomColor.withValues(alpha:0.2),
//                   grTopColor.withValues(alpha:0.2)
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             isExpanded: true,
//             hint: Text(
//               "Branch Name",
//               style: const TextStyle().newstyle.copyWith(
//                     color: Colors.black,
//                   ),
//               // overflow: TextOverflow.ellipsis,
//             ),
//             // value: controller.selectedDocument,
//             icon: Image.asset(
//               AppAssets.dropdownIcon,
//               width: 15,
//               height: 15,
//             ),
//             value: controller.selectBranch?.branchid,
//             items: controller.branchList.map(
//               (items) {
//                 return DropdownMenuItem(
//                   value: items.branchid,
//                   child: Text(
//                     items.branchname.toString(),
//                     style: TextStyle().newstyle.copyWith(color: Colors.black),
//                   ),
//                 );
//               },
//             ).toList(),
//             onChanged: (newValue) => controller.setSelectBranchDropdownValue(
//                 controller.branchList
//                     .firstWhere((element) => element.branchid == newValue)),
//             // items: controller.filterDocumentData.map(
//             //       (items) {
//             //     return DropdownMenuItem(
//             //       value: items,
//             //       child: Text(
//             //         items.documentname ?? '',
//             //       ),
//             //     );
//             //   },
//             // ).toList(),
//             // onChanged: (newValue){
//             //   controller.onChangedDocumentDataValue(newValue);
//             //   controller.update();
//             // },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget submitButton(ChangeCompanyController controller) {
//     return Container(
//       height: Get.height * 0.05,
//       width: Get.height * 0.120,
//       decoration: ShapeDecoration(
//         shape: const StadiumBorder(),
//         gradient: customGradient(topColor: orangeColor, bottomColor: red2Color),
//       ),
//       child: MaterialButton(
//         onPressed: () async {
//           print('ComId =>  ${controller.selectCompany!.compid}');
//           print("BranceID => ${controller.selectBranch!.branchid} ");
//        UserData userData =   controller.homeController.currentUserData!;
//        print('Branch ID => ${userData.branchId}');
//        userData.compId=controller.selectCompany!.compid;
//        userData.branchId=controller.selectBranch!.branchid;
//           print('After Branch ID => ${userData.branchId}');
//
//           log('User Data=> ${jsonEncode(userData.toJson())}');
//           var obj = await SharedPre.setValue(SharedPre.userData,userData.toJson());
//
//           Restart.restartApp();
//
//         },
//         shape: const StadiumBorder(),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 5,
//             ),
//             Text(
//               'Submit',
//               style: TextStyle(fontSize: 15, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:digitalerp/change_company/change_companay_controller.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/utils/shared_pre.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import '../utils/app_constant_new.dart';

//  Design tokens 
const Color _kWhite = Colors.white;
const Color _kBorder = Color(0xFFE2E8F0);
const Color _kTextPrimary = newTextPrimary;
const Color _kTextSub = newTextSecondary;
const Color _kTextHint = newTextHint;

//  Shared helpers 
Widget _appBar(String title, {VoidCallback? onFilter}) {
  return Container(
    color: _kWhite,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(Icons.arrow_back_ios_new,
            color: _kTextPrimary, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary)),
      ),
      if (onFilter != null)
        GestureDetector(
          onTap: onFilter,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: purpleLightest, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.filter_list_sharp,
                color: purpleColor, size: 20),
          ),
        ),
    ]),
  );
}

Widget _styledDropdown({required Widget child}) => Container(
      decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder)),
      child: child,
    );

Widget _sectionLabel(String label) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: _kTextPrimary)),
    );

DropdownButton2 _buildDropdown2<T>({
  required String hint,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?) onChanged,
}) =>
    DropdownButton2<T>(
      buttonHeight: 50,
      buttonPadding: const EdgeInsets.symmetric(horizontal: 14),
      dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), color: _kWhite),
      dropdownMaxHeight: 220,
      buttonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), color: Colors.transparent),
      isExpanded: true,
      hint: Text(hint, style: const TextStyle(fontSize: 14, color: _kTextHint)),
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: _kTextSub, size: 22),
      items: items,
      onChanged: onChanged,
    );

class ChangeCompanyView extends StatefulWidget {
  const ChangeCompanyView({Key? key}) : super(key: key);
  @override
  State<ChangeCompanyView> createState() => _ChangeCompanyState();
}

class _ChangeCompanyState extends State<ChangeCompanyView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangeCompanyController>(
      init: ChangeCompanyController(),
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(children: [
            _appBar('Change Company'),
            Expanded(
                child: controller.isPageLoading
                    ? showLoader(color: purpleColor)
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Company name dropdown
                            _sectionLabel('Company Name'),
                            _styledDropdown(
                              child: DropdownButtonHideUnderline(
                                child: _buildDropdown2<dynamic>(
                                  hint: 'Company Name',
                                  value: controller.selectCompany?.compid,
                                  items: controller.companyList.map((items) {
                                    return DropdownMenuItem(
                                      value: items.compid,
                                      child: Text(items.companyname.toString(),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: _kTextPrimary)),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) =>
                                      controller.setSelectCompanyDropdownValue(
                                          controller.companyList.firstWhere(
                                              (e) => e.compid == newValue)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Branch name dropdown
                            _sectionLabel('Branch Name'),
                            _styledDropdown(
                              child: DropdownButtonHideUnderline(
                                child: _buildDropdown2<dynamic>(
                                  hint: 'Branch Name',
                                  value: controller.selectBranch?.branchid,
                                  items: controller.branchList.map((items) {
                                    return DropdownMenuItem(
                                      value: items.branchid,
                                      child: Text(items.branchname.toString(),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: _kTextPrimary)),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) =>
                                      controller.setSelectBranchDropdownValue(
                                          controller.branchList.firstWhere(
                                              (e) => e.branchid == newValue)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final userData = controller
                                      .homeController.currentUserData!;
                                  userData.compId =
                                      controller.selectCompany!.compid;
                                  userData.branchId =
                                      controller.selectBranch!.branchid;
                                  await SharedPre.setValue(
                                      SharedPre.userData, userData.toJson());
                                  Restart.restartApp();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: purpleColor,
                                  foregroundColor: _kWhite,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Text('Submit',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ]),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
