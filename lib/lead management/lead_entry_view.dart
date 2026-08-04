// // import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
// // import 'package:digitalerp/screen/base/base_controller.dart';
// // import 'package:digitalerp/utils/app_assets.dart';
// // import 'package:digitalerp/utils/app_constant.dart';
// // import 'package:digitalerp/utils/date_widget.dart';
// // import 'package:digitalerp/utils/my_app_bar_new.dart';
// // import 'package:dropdown_button2/dropdown_button2.dart';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:get/get_core/src/get_main.dart';
// // import 'package:intl/intl.dart';
// //
// // class LeadEntryView extends StatefulWidget {
// //   const LeadEntryView({Key? key}) : super(key: key);
// //
// //   @override
// //   State<LeadEntryView> createState() => _LeadEntryViewState();
// // }
// //
// // class _LeadEntryViewState extends State<LeadEntryView> {
// //   DateTime selectedDate = DateTime.now();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GetBuilder<LeadManagementController>(
// //         init: LeadManagementController(),
// //         builder: (controller) {
// //           return Scaffold(
// //             resizeToAvoidBottomInset: false,
// //             body: Center(
// //               child: Stack(
// //                 children: [
// //                   Positioned(
// //                     top: 0,
// //                     left: 0,
// //                     right: 0,
// //                     bottom: 0,
// //                     child: Container(
// //                       decoration: const BoxDecoration(
// //                         image: DecorationImage(
// //                           image: AssetImage('assets/images/dashboard_bg.png'),
// //                           fit: BoxFit.fill,
// //                         ),
// //                       ),
// //                       child: SafeArea(
// //                         child: MyAppBar(
// //                           title: 'Lead Entry',
// //                           onBackTap: () => Get.back(),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   Positioned(
// //                     right: 0,
// //                     left: 0,
// //                     bottom: 0,
// //                     top: Get.height * 0.135,
// //                     child: SingleChildScrollView(
// //                       padding: EdgeInsets.only(
// //                           bottom: (MediaQuery.of(context).viewInsets.bottom > 0)
// //                               ? 200
// //                               : 0,
// //                           left: 20,
// //                           right: 20),
// //                       child: Column(
// //                         children: [
// //                           SizedBox(height: Get.height * 0.02),
// //                           _leadDetail(controller),
// //                           SizedBox(height: Get.height * 0.08),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                             children: [
// //                               submitButton(controller),
// //                               editButton(),
// //                               resetButton(controller)
// //                             ],
// //                           ),
// //                           SizedBox(height: Get.height * 0.08),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         });
// //   }
// //
// //   Widget _leadDetail(LeadManagementController controller) {
// //     return Column(
// //       // mainAxisSize: MainAxisSize.min,
// //       children: [
// //         customTextFieldNumber(
// //           focusNode: controller.leadNoFocus,
// //           controller: controller.leadNumberController,
// //           hintText: AppString.enterLeadNo,
// //         ),
// //         /*   Container(
// //           height:Get.height * 0.0600,
// //           width: Get.width * 0.900,
// //           decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [
// //                   grBottomColor.withValues(alpha:0.2),
// //                   grTopColor.withValues(alpha:0.2)
// //                 ],
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //               ),
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: TextFormField(
// //             // controller: controller.searchController,
// //             textInputAction: TextInputAction.done,
// //             focusNode: FocusNode(),
// //             // onChanged: (value) {
// //             //   controller.onSearchTextChanged(value);
// //             // },
// //             style: TextStyle().newstyle.copyWith(
// //               color: Colors.black,
// //             ),
// //             decoration: InputDecoration().textFieldStylenew(hintText: AppString.leadNo)
// //           ),
// //         ),*/
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //          AppDateWidgetNew(
// //              value: controller.selectDate, onSelectDate: controller.setSelectedDate),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             focusNode: controller.requirementFocus,
// //             controller: controller.requirementController,
// //             hintText: AppString.enterRequirementSpecification),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         DropdownButtonHideUnderline(
// //           child: DropdownButton2(
// //             buttonHeight: Get.height * 0.0600,
// //             buttonWidth: Get.width * 0.900,
// //             buttonPadding:
// //                 const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
// //             dropdownDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(15),
// //               color: dropdownBoxColor,
// //             ),
// //             dropdownMaxHeight: 200,
// //             buttonDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(10),
// //               color: dropdownBoxColor,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   grBottomColor.withValues(alpha:0.2),
// //                   grTopColor.withValues(alpha:0.2)
// //                 ],
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //               ),
// //             ),
// //             isExpanded: true,
// //             hint: Text(
// //               "Lead Type",
// //               style: const TextStyle().newstyle.copyWith(
// //                     // fontSize: 15,
// //                     // fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //               // overflow: TextOverflow.ellipsis,
// //             ),
// //             // value: controller.selectedDocument,
// //             icon: Image.asset(
// //               AppAssets.dropdownIcon,
// //               width: 15,
// //               height: 15,
// //             ),
// //             items: [],
// //             // items: controller.filterDocumentData.map(
// //             //       (items) {
// //             //     return DropdownMenuItem(
// //             //       value: items,
// //             //       child: Text(
// //             //         items.documentname ?? '',
// //             //       ),
// //             //     );
// //             //   },
// //             // ).toList(),
// //             // onChanged: (newValue){
// //             //   controller.onChangedDocumentDataValue(newValue);
// //             //   controller.update();
// //             // },
// //           ),
// //         ),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             controller: controller.companyNameController,
// //             focusNode: controller.companyNameFocus,
// //             hintText: AppString.enterCompanyName),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             controller: controller.ownerNameController,
// //             focusNode: controller.ownerNameFocus,
// //             hintText: AppString.enterOwnerName),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             controller: controller.contactPersonController,
// //             focusNode: controller.contactPersonFocus,
// //             hintText: AppString.enterContactPerson),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         DropdownButtonHideUnderline(
// //           child: DropdownButton2(
// //             buttonHeight: Get.height * 0.0600,
// //             buttonWidth: Get.width * 0.900,
// //             buttonPadding:
// //                 const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
// //             dropdownDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(15),
// //               color: dropdownBoxColor,
// //             ),
// //             dropdownMaxHeight: 200,
// //             buttonDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(10),
// //               color: dropdownBoxColor,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   grBottomColor.withValues(alpha:0.2),
// //                   grTopColor.withValues(alpha:0.2)
// //                 ],
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //               ),
// //             ),
// //             isExpanded: true,
// //             hint: Text(
// //               "Designation",
// //               style: const TextStyle().newstyle.copyWith(
// //                     // fontSize: 15,
// //                     // fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //               // overflow: TextOverflow.ellipsis,
// //             ),
// //             // value: controller.selectedDocument,
// //             icon: Image.asset(
// //               AppAssets.dropdownIcon,
// //               width: 15,
// //               height: 15,
// //             ),
// //             items: [],
// //             // items: controller.filterDocumentData.map(
// //             //       (items) {
// //             //     return DropdownMenuItem(
// //             //       value: items,
// //             //       child: Text(
// //             //         items.documentname ?? '',
// //             //       ),
// //             //     );
// //             //   },
// //             // ).toList(),
// //             // onChanged: (newValue){
// //             //   controller.onChangedDocumentDataValue(newValue);
// //             //   controller.update();
// //             // },
// //           ),
// //         ),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldNumber(
// //             controller: controller.mobileNumberController,
// //             focusNode: controller.mobileNoFocus,
// //             hintText: AppString.enterMobileTxt),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldNumber(
// //             controller: controller.alternateNumberController,
// //             focusNode: controller.alternateNoFocus,
// //             hintText: AppString.enterAlternateMobileNo),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             controller: controller.emailController,
// //             focusNode: controller.emailIdFocus,
// //             hintText: AppString.enterEmailIdTxt),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             controller: controller.websiteController,
// //             focusNode: controller.websiteFocus,
// //             hintText: AppString.enterWebsite),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             controller: controller.companyAddressController,
// //             focusNode: controller.companyAddresFocus,
// //             hintText: AppString.enterCompanyAddress),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldNumber(
// //             controller: controller.phoneNumberController,
// //             focusNode: controller.phoneFocus,
// //             hintText: AppString.enterPhoneNo),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         DropdownButtonHideUnderline(
// //           child: DropdownButton2(
// //             buttonHeight: Get.height * 0.0600,
// //             buttonWidth: Get.width * 0.900,
// //             buttonPadding:
// //                 const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
// //             dropdownDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(15),
// //               color: dropdownBoxColor,
// //             ),
// //             dropdownMaxHeight: 200,
// //             buttonDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(10),
// //               color: dropdownBoxColor,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   grBottomColor.withValues(alpha:0.2),
// //                   grTopColor.withValues(alpha:0.2)
// //                 ],
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //               ),
// //             ),
// //             isExpanded: true,
// //             hint: Text(
// //               "Source",
// //               style: const TextStyle().newstyle.copyWith(
// //                     // fontSize: 15,
// //                     // fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //               // overflow: TextOverflow.ellipsis,
// //             ),
// //             // value: controller.selectedDocument,
// //             icon: Image.asset(
// //               AppAssets.dropdownIcon,
// //               width: 15,
// //               height: 15,
// //             ),
// //             items: [],
// //             // items: controller.filterDocumentData.map(
// //             //       (items) {
// //             //     return DropdownMenuItem(
// //             //       value: items,
// //             //       child: Text(
// //             //         items.documentname ?? '',
// //             //       ),
// //             //     );
// //             //   },
// //             // ).toList(),
// //             // onChanged: (newValue){
// //             //   controller.onChangedDocumentDataValue(newValue);
// //             //   controller.update();
// //             // },
// //           ),
// //         ),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         customTextFieldText(
// //             controller: controller.businessNatureController,
// //             focusNode: controller.businessFocus,
// //             hintText: AppString.enterBusinessNature),
// //         SizedBox(
// //           height: Get.height * 0.0100,
// //         ),
// //         DropdownButtonHideUnderline(
// //           child: DropdownButton2(
// //             buttonHeight: Get.height * 0.0600,
// //             buttonWidth: Get.width * 0.900,
// //             buttonPadding:
// //                 const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
// //             dropdownDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(15),
// //               color: dropdownBoxColor,
// //             ),
// //             dropdownMaxHeight: 200,
// //             buttonDecoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(10),
// //               color: dropdownBoxColor,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   grBottomColor.withValues(alpha:0.2),
// //                   grTopColor.withValues(alpha:0.2)
// //                 ],
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //               ),
// //             ),
// //             isExpanded: true,
// //             hint: Text(
// //               "Priority",
// //               style: const TextStyle().newstyle.copyWith(
// //                     // fontSize: 15,
// //                     // fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //               // overflow: TextOverflow.ellipsis,
// //             ),
// //             // value: controller.selectedDocument,
// //             icon: Image.asset(
// //               AppAssets.dropdownIcon,
// //               width: 15,
// //               height: 15,
// //             ),
// //             items: [],
// //             // items: controller.filterDocumentData.map(
// //             //       (items) {
// //             //     return DropdownMenuItem(
// //             //       value: items,
// //             //       child: Text(
// //             //         items.documentname ?? '',
// //             //       ),
// //             //     );
// //             //   },
// //             // ).toList(),
// //             // onChanged: (newValue){
// //             //   controller.onChangedDocumentDataValue(newValue);
// //             //   controller.update();
// //             // },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget submitButton(LeadManagementController controller) {
// //     return Container(
// //       height: 38,
// //       // width: 120,
// //       decoration: ShapeDecoration(
// //         shape: const StadiumBorder(),
// //         gradient: customGradient(topColor: orangeColor, bottomColor: red2Color),
// //       ),
// //       child: MaterialButton(
// //         onPressed: () => controller.addleadApi(),
// //         shape: const StadiumBorder(),
// //         child: Row(
// //           children: [
// //             SizedBox(
// //               width: 5,
// //             ),
// //             Text(
// //               'Submit',
// //               style: TextStyle(fontSize: 15, color: Colors.white),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget editButton() {
// //     return Container(
// //       height: 38,
// //       // width: 120,
// //       decoration: ShapeDecoration(
// //         shape: const StadiumBorder(),
// //         gradient: customGradient(topColor: orangeColor, bottomColor: red2Color),
// //       ),
// //       child: MaterialButton(
// //         onPressed: () {},
// //         shape: const StadiumBorder(),
// //         child: Row(
// //           children: [
// //             SizedBox(
// //               width: 5,
// //             ),
// //             Text(
// //               'Edit/Search',
// //               style: TextStyle(fontSize: 15, color: Colors.white),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget resetButton(LeadManagementController controller) {
// //     return Container(
// //       height: 38,
// //       // width: 120,
// //       decoration: ShapeDecoration(
// //         shape: const StadiumBorder(),
// //         gradient: customGradient(topColor: orangeColor, bottomColor: red2Color),
// //       ),
// //       child: MaterialButton(
// //         onPressed: () {
// //           controller.leadNumberController.clear();
// //           controller.requirementController.clear();
// //           controller.companyNameController.clear();
// //           controller.ownerNameController.clear();
// //           controller.contactPersonController.clear();
// //           controller.mobileNumberController.clear();
// //           controller.alternateNumberController.clear();
// //           controller.emailController.clear();
// //           controller.websiteController.clear();
// //           controller.companyAddressController.clear();
// //           controller.phoneNumberController.clear();
// //           controller.businessNatureController.clear();
// //           controller.clearSelectedDate();
// //
// //         },
// //         shape: const StadiumBorder(),
// //         child: Row(
// //           children: [
// //             SizedBox(
// //               width: 5,
// //             ),
// //             Text(
// //               'Reset',
// //               style: TextStyle(fontSize: 15, color: Colors.white),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //
// //
// //   // Widget _dateView(BuildContext context, LeadManagementController ctrl) {
// //   //   DropdownButtonHideUnderline(
// //   //     child: DropdownButton2(
// //   //       dropdownDecoration: BoxDecoration(
// //   //         borderRadius: BorderRadius.circular(15),
// //   //         color: dropdownBoxColor,
// //   //       ),
// //   //       dropdownMaxHeight: 200,
// //   //       buttonDecoration: BoxDecoration(
// //   //         borderRadius: BorderRadius.circular(10),
// //   //         color: dropdownBoxColor,
// //   //         gradient: LinearGradient(
// //   //           colors: [
// //   //             grBottomColor.withValues(alpha:0.2),
// //   //             grTopColor.withValues(alpha:0.2)
// //   //           ],
// //   //           begin: Alignment.topCenter,
// //   //           end: Alignment.bottomCenter,
// //   //         ),
// //   //       ),
// //   //       isExpanded: true,
// //   //       // value: controller.selectedDocument,
// //   //       items: [],
// //   //       // items: controller.filterDocumentData.map(
// //   //       //       (items) {
// //   //       //     return DropdownMenuItem(
// //   //       //       value: items,
// //   //       //       child: Text(
// //   //       //         items.documentname ?? '',
// //   //       //       ),
// //   //       //     );
// //   //       //   },
// //   //       // ).toList(),
// //   //       // onChanged: (newValue){
// //   //       //   controller.onChangedDocumentDataValue(newValue);
// //   //       //   controller.update();
// //   //       // },
// //   //     ),
// //   //   );
// //   //   return InkWell(
// //   //     onTap: () async {
// //   //       DateTime? pickedDate = await showDatePicker(
// //   //           context: context,
// //   //           initialDate: DateTime.now(),
// //   //           firstDate: AppConst.calenderFirstDate ??
// //   //               DateTime(DateTime.now().year, 1, 1),
// //   //           //DateTime.now() - not to allow to choose before today.
// //   //           lastDate: AppConst.calenderLastDate ??
// //   //               DateTime(DateTime.now().year, 12, 31));
// //   //
// //   //       if (pickedDate != null) {
// //   //         String formattedDate =
// //   //             DateFormat(AppString.ddMMyyyy).format(pickedDate);
// //   //         ctrl.setSelectedDate(formattedDate);
// //   //       } else {
// //   //         if (kDebugMode) {
// //   //           print('Date is not selected');
// //   //         }
// //   //       }
// //   //     },
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       mainAxisSize: MainAxisSize.min,
// //   //       children: [
// //   //         const SizedBox(height: 15),
// //   //         Row(
// //   //           mainAxisAlignment: MainAxisAlignment.spaceAround,
// //   //           children: [
// //   //
// //   //              Text(ctrl.selectDate.toString(), style: const TextStyle().xstyle.copyWith(
// //   //                fontSize: 16
// //   //              )),
// //   //             SizedBox(width: Get.width * 0.37,),
// //   //             Image.asset(
// //   //               AppAssets.calendarIcon,
// //   //               width: 18,
// //   //               height: 18,
// //   //             ),
// //   //           ],
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// // }
//
//
// import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
// import 'package:digitalerp/screen/base/base_controller.dart';
// import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filter_controller.dart';
// import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/documentname_responce.dart';
// import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/status_list_responce.dart';
// import 'package:digitalerp/screen/ui/home/home_controller.dart';
// import 'package:digitalerp/screen/ui/home/order/select_brand/select_brand_view.dart';
// import 'package:digitalerp/utils/app_constant_new.dart';
// import 'package:digitalerp/utils/date_widget.dart';
// import 'package:digitalerp/utils/show_message.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// //  Design tokens 
// const Color _kBg          = Color(0xFFF5F6FA);
// const Color _kWhite       = Colors.white;
// const Color _kBlue        = purpleColor;
// final Color _kBlueBg      = purpleLightest;
// const Color _kBorder      = Color(0xFFE2E8F0);
// const Color _kTextPrimary = Color(0xFF0F172A);
// const Color _kTextSub     = Color(0xFF64748B);
// const Color _kTextHint    = Color(0xFF94A3B8);
//
// //  Shared helpers 
// Widget _appBar(String title, {VoidCallback? onFilter, VoidCallback? onAdd}) {
//   return Container(
//     color: _kWhite,
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     child: Row(children: [
//       GestureDetector(
//         onTap: () => Get.back(),
//         child: const Icon(Icons.arrow_back_ios_new, color: _kTextPrimary, size: 22),
//       ),
//       const SizedBox(width: 12),
//       Expanded(
//         child: Text(title,
//             style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: _kTextPrimary)),
//       ),
//       if (onAdd != null)
//         GestureDetector(
//           onTap: onAdd,
//           child: Container(
//             height: 40, width: 40,
//             decoration: BoxDecoration(
//                 color: _kBlue, borderRadius: BorderRadius.circular(18)),
//             child: const Icon(Icons.add, color: _kWhite, size: 22),
//           ),
//         ),
//       if (onAdd != null && onFilter != null) const SizedBox(width: 8),
//       if (onFilter != null)
//         GestureDetector(
//           onTap: onFilter,
//           child: Container(
//             height: 40, width: 40,
//             decoration: BoxDecoration(
//                 color: _kBlueBg, borderRadius: BorderRadius.circular(18)),
//             child: const Icon(Icons.filter_list_sharp, color: _kBlue, size: 20),
//           ),
//         ),
//     ]),
//   );
// }
//
// Widget _styledDropdown({required Widget child}) => Container(
//   decoration: BoxDecoration(
//       color: _kWhite,
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: _kBorder)),
//   child: child,
// );
//
// Widget _sectionLabel(String label) => Padding(
//   padding: const EdgeInsets.only(bottom: 8),
//   child: Text(label,
//       style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: _kTextPrimary)),
// );
//
// Widget _textField({
//   required TextEditingController controller,
//   required FocusNode focusNode,
//   required String hint,
//   int maxLines = 1,
//   TextInputType keyboardType = TextInputType.text,
// }) =>
//     Container(
//       decoration: BoxDecoration(
//           color: _kWhite,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: _kBorder)),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       child: TextFormField(
//         controller: controller,
//         focusNode: focusNode,
//         maxLines: maxLines,
//         keyboardType:
//         maxLines > 1 ? TextInputType.multiline : keyboardType,
//         textInputAction:
//         maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
//         style: const TextStyle(fontSize: 14, color: _kTextPrimary),
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           hintText: hint,
//           hintStyle: const TextStyle(color: _kTextHint, fontSize: 14),
//         ),
//       ),
//     );
//
// Widget _dropdownShell({required String hint, List<DropdownMenuItem>? items}) =>
//     _styledDropdown(
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2(
//           buttonHeight: 50,
//           buttonPadding: const EdgeInsets.symmetric(horizontal: 14),
//           dropdownDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(18), color: _kWhite),
//           dropdownMaxHeight: 200,
//           buttonDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(18),
//               color: Colors.transparent),
//           isExpanded: true,
//           hint: Text(hint,
//               style: const TextStyle(fontSize: 14, color: _kTextHint)),
//           icon: const Icon(Icons.keyboard_arrow_down_rounded,
//               color: _kTextSub, size: 22),
//           items: items ?? [],
//           onChanged: null,
//         ),
//       ),
//     );
//
// Widget _solidButton(String label, VoidCallback onTap) => SizedBox(
//   height: 48,
//   child: ElevatedButton(
//     onPressed: onTap,
//     style: ElevatedButton.styleFrom(
//       backgroundColor: _kBlue,
//       foregroundColor: _kWhite,
//       elevation: 0,
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//     ),
//     child:
//     Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//   ),
// );
//
// Widget _outlineButton(String label, VoidCallback onTap) => SizedBox(
//   height: 48,
//   child: OutlinedButton(
//     onPressed: onTap,
//     style: OutlinedButton.styleFrom(
//       foregroundColor: _kBlue,
//       side: const BorderSide(color: _kBorder, width: 1.5),
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//     ),
//     child:
//     Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//   ),
// );
//
// class LeadEntryView extends StatefulWidget {
//   const LeadEntryView({Key? key}) : super(key: key);
//   @override
//   State<LeadEntryView> createState() => _LeadEntryViewState();
// }
//
// class _LeadEntryViewState extends State<LeadEntryView> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<LeadManagementController>(
//       init: LeadManagementController(),
//       builder: (controller) => Scaffold(
//         backgroundColor: const Color(0xFFF5F6FA),
//         resizeToAvoidBottomInset: true,
//         body: SafeArea(
//           child: Column(
//             children: [
//               _appBar('Lead Entry'),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.only(
//                     left: 16, right: 16, top: 16,
//                     bottom: MediaQuery.of(context).viewInsets.bottom > 0
//                         ? 200
//                         : 24,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _sectionLabel('Lead No.'),
//                       customTextFieldNumber(
//                           focusNode: controller.leadNoFocus,
//                           controller: controller.leadNumberController,
//                           hintText: AppString.enterLeadNo),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Lead Date'),
//                       AppDateWidgetNew(
//                           value: controller.selectDate,
//                           onSelectDate: controller.setSelectedDate),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Requirement Specification'),
//                       _textField(
//                           controller: controller.requirementController,
//                           focusNode: controller.requirementFocus,
//                           hint: AppString.enterRequirementSpecification,
//                           maxLines: 3),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Lead Type'),
//                       _dropdownShell(hint: 'Lead Type'),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Company Name'),
//                       _textField(
//                           controller: controller.companyNameController,
//                           focusNode: controller.companyNameFocus,
//                           hint: AppString.enterCompanyName),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Owner Name'),
//                       _textField(
//                           controller: controller.ownerNameController,
//                           focusNode: controller.ownerNameFocus,
//                           hint: AppString.enterOwnerName),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Contact Person'),
//                       _textField(
//                           controller: controller.contactPersonController,
//                           focusNode: controller.contactPersonFocus,
//                           hint: AppString.enterContactPerson),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Designation'),
//                       _dropdownShell(hint: 'Designation'),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Mobile No.'),
//                       customTextFieldNumber(
//                           controller: controller.mobileNumberController,
//                           focusNode: controller.mobileNoFocus,
//                           hintText: AppString.enterMobileTxt),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Alternate Mobile No.'),
//                       customTextFieldNumber(
//                           controller: controller.alternateNumberController,
//                           focusNode: controller.alternateNoFocus,
//                           hintText: AppString.enterAlternateMobileNo),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Email ID'),
//                       _textField(
//                           controller: controller.emailController,
//                           focusNode: controller.emailIdFocus,
//                           hint: AppString.enterEmailIdTxt,
//                           keyboardType: TextInputType.emailAddress),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Website'),
//                       _textField(
//                           controller: controller.websiteController,
//                           focusNode: controller.websiteFocus,
//                           hint: AppString.enterWebsite),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Company Address'),
//                       _textField(
//                           controller: controller.companyAddressController,
//                           focusNode: controller.companyAddresFocus,
//                           hint: AppString.enterCompanyAddress,
//                           maxLines: 2),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Phone No.'),
//                       customTextFieldNumber(
//                           controller: controller.phoneNumberController,
//                           focusNode: controller.phoneFocus,
//                           hintText: AppString.enterPhoneNo),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Source'),
//                       _dropdownShell(hint: 'Source'),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Business Nature'),
//                       _textField(
//                           controller: controller.businessNatureController,
//                           focusNode: controller.businessFocus,
//                           hint: AppString.enterBusinessNature),
//                       const SizedBox(height: 14),
//
//                       _sectionLabel('Priority'),
//                       _dropdownShell(hint: 'Priority'),
//                       const SizedBox(height: 28),
//
//                       // Action buttons
//                       Row(
//                         children: [
//                           Expanded(
//                               child: _solidButton(
//                                   'Submit', () => controller.addleadApi())),
//                           const SizedBox(width: 10),
//                           Expanded(
//                               child: _outlineButton('Edit/Search', () {})),
//                           const SizedBox(width: 10),
//                           Expanded(
//                               child: _outlineButton('Reset', () {
//                                 controller.leadNumberController.clear();
//                                 controller.requirementController.clear();
//                                 controller.companyNameController.clear();
//                                 controller.ownerNameController.clear();
//                                 controller.contactPersonController.clear();
//                                 controller.mobileNumberController.clear();
//                                 controller.alternateNumberController.clear();
//                                 controller.emailController.clear();
//                                 controller.websiteController.clear();
//                                 controller.companyAddressController.clear();
//                                 controller.phoneNumberController.clear();
//                                 controller.businessNatureController.clear();
//                                 controller.clearSelectedDate();
//                               })),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//

import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
import 'package:digitalerp/contactsview/Designation_dropdown_responce.dart';
import 'package:digitalerp/model/lead_businesstype_response_model.dart';
import 'package:digitalerp/model/lead_existing_client_response_model.dart';
import 'package:digitalerp/model/lead_industry_response_model.dart';
import 'package:digitalerp/model/lead_sources_response_model.dart';
import 'package:digitalerp/response/area_data_response.dart';
import 'package:digitalerp/response/city_data_response.dart';
import 'package:digitalerp/response/state_data_response.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/client_list_responce.dart';
import 'package:digitalerp/screen/ui/home/indent/indent_response/indent_model.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:digitalerp/utils/date_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

//  Design tokens 
const Color _kPrimary = purpleColor;
const Color _kBg = Color(0xFFF6F7FB);
const Color _kSurface = Colors.white;
const Color _kBorder = Color(0xFFE4E7F0);
const Color _kBorderFocus = Color(0xFF4361EE);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kTextHint = Color(0xFFB0B8C8);
const Color _kDanger = newRedColor;
const Color _kDangerLight = newRedLightColor;
const Color _kSuccess = Color(0xFF10B981);
const Color _kCardShadow = Color(0x0A000000);

//  Section card 
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(color: _kCardShadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

//  Labeled text field 
class _LeadTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboard;
  final List<TextInputFormatter>? formatters;
  final int maxLines;

  const _LeadTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.keyboard = TextInputType.text,
    this.formatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboard,
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        inputFormatters: formatters,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 14,
          color: _kTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: _kTextSecondary),
          floatingLabelStyle: const TextStyle(
            fontSize: 12,
            color: _kPrimary,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: _kBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorderFocus, width: 1.8),
          ),
        ),
      ),
    );
  }
}

//  Plain dropdown row 
/// A real, working dropdown for the lead form.
///
/// [_DropdownRow] below is the original placeholder — a grey box with a chevron
/// and no items, no selection and no tap handler. This one is backed by data.
class _LeadDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool isLoading;

  /// Message shown when [items] is empty — usually "pick the parent first".
  final String emptyHint;

  const _LeadDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.isLoading = false,
    this.emptyHint = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || items.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: disabled ? _kBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            // Guard against the "exactly one item with value" assertion: if a
            // stale selection is no longer in the list, fall back to null.
            value: items.contains(value) ? value : null,
            hint: Row(
              children: [
                if (isLoading) ...[
                  const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    isLoading
                        ? 'Loading $label…'
                        : (items.isEmpty && emptyHint.isNotEmpty
                            ? emptyHint
                            : 'Select $label'),
                    style: const TextStyle(fontSize: 14, color: _kTextHint),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: items
                .map((e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(
                        itemLabel(e),
                        style: const TextStyle(
                            fontSize: 14, color: _kTextPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: disabled ? null : onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: _kTextSecondary, size: 20),
            buttonHeight: 48,
            buttonPadding: EdgeInsets.zero,
            dropdownMaxHeight: 320,
            dropdownDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

//  Company Name picker
/// Company Name was a plain text field. It now opens the client master used by
/// the Approval filter's Client dropdown (`Allclientlistfilter/clientdrpdon`).
///
/// The list is ~274 rows on a live account, so it opens in a searchable sheet
/// rather than an inline menu. A lead is often a company that is not a client
/// yet, so the sheet also offers the typed text as-is — picking from the list
/// additionally keeps the client id, typing does not.
class _CompanyPickerField extends StatelessWidget {
  final LeadManagementController controller;

  const _CompanyPickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final String current = controller.companyNameController.text.trim();
    final bool hasValue = current.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GestureDetector(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _CompanyPickerSheet(controller: controller),
        ),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? current : 'Select Company Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: hasValue ? _kTextPrimary : _kTextHint,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.isClientLoading)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: _kTextSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyPickerSheet extends StatefulWidget {
  final LeadManagementController controller;

  const _CompanyPickerSheet({required this.controller});

  @override
  State<_CompanyPickerSheet> createState() => _CompanyPickerSheetState();
}

class _CompanyPickerSheetState extends State<_CompanyPickerSheet> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.text = widget.controller.companyNameController.text.trim();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ClientListData> get _matches {
    final q = _search.text.trim().toLowerCase();
    final all = widget.controller.clientOptions;
    if (q.isEmpty) return all;
    return all
        .where((e) => (e.clientname ?? '').toLowerCase().contains(q))
        .toList();
  }

  /// True when the typed text is not already a client — the only case where
  /// offering "use this name" adds anything.
  bool get _canUseTyped {
    final q = _search.text.trim();
    if (q.isEmpty) return false;
    return !widget.controller.clientOptions
        .any((e) => (e.clientname ?? '').toLowerCase() == q.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Company Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded,
                        color: _kTextSecondary, size: 20),
                  ),
                ],
              ),
            ),

            //  Search / free-text entry
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Search or type a new company',
                  hintStyle: const TextStyle(fontSize: 14, color: _kTextHint),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _kTextSecondary, size: 20),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : GestureDetector(
                          onTap: () {
                            _search.clear();
                            setState(() {});
                          },
                          child: const Icon(Icons.clear_rounded,
                              color: _kTextSecondary, size: 18),
                        ),
                  filled: true,
                  fillColor: _kBg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorderFocus, width: 1.8),
                  ),
                ),
              ),
            ),

            //  Use the typed name — a lead need not be an existing client
            if (_canUseTyped)
              ListTile(
                dense: true,
                leading: const Icon(Icons.add_circle_outline_rounded,
                    color: _kPrimary, size: 20),
                title: Text(
                  'Use "${_search.text.trim()}"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text(
                  'Not in the client list',
                  style: TextStyle(fontSize: 11, color: _kTextSecondary),
                ),
                onTap: () {
                  widget.controller.setCompanyNameManually(_search.text);
                  Navigator.of(context).pop();
                },
              ),

            const Divider(height: 16, color: _kBorder),

            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Text(
                        widget.controller.isClientLoading
                            ? 'Loading companies…'
                            : 'No matching company',
                        style: const TextStyle(
                            fontSize: 13, color: _kTextSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: matches.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: _kBorder),
                      itemBuilder: (_, i) {
                        final client = matches[i];
                        final bool isSelected =
                            widget.controller.selectedClient?.clientid ==
                                client.clientid;
                        return ListTile(
                          dense: true,
                          title: Text(
                            client.clientname ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: _kTextPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: _kPrimary, size: 18)
                              : null,
                          onTap: () {
                            widget.controller.onClientChanged(client);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String label;
  const _DropdownRow(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kTextHint,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: _kTextSecondary, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  Action button 
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final _ButtonStyle style;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.style = _ButtonStyle.primary,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case _ButtonStyle.primary:
        return SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white, size: 16),
            label: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      case _ButtonStyle.secondary:
        return SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 15, color: _kTextSecondary),
            label: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              side: const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      case _ButtonStyle.danger:
        return SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.refresh_rounded, size: 15, color: _kDanger),
            label: const Text(
              'Reset',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kDanger,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              backgroundColor: _kDangerLight,
              side: const BorderSide(color: Color(0xFFFECACA)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
    }
  }
}

enum _ButtonStyle { primary, secondary, danger }

//  Main screen 
class LeadEntryView extends StatefulWidget {
  const LeadEntryView({Key? key}) : super(key: key);

  @override
  State<LeadEntryView> createState() => _LeadEntryViewState();
}

class _LeadEntryViewState extends State<LeadEntryView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadManagementController>(
      init: LeadManagementController(),
      builder: (controller) => Scaffold(
        backgroundColor: _kBg,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: _kSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: _kBorder,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              // decoration: BoxDecoration(
              //   color: _kBg,
              //   borderRadius: BorderRadius.circular(10),
              //   border: Border.all(color: _kBorder),
              // ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _kTextPrimary, size: 20),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Lead Entry',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              Text(
                'Create a new lead record',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: _kTextSecondary,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Basic Info 
              _SectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline_rounded,
                iconColor: _kPrimary,
                children: [
                  _LeadTextField(
                    label: 'Lead No.',
                    controller: controller.leadNumberController,
                    focusNode: controller.leadNoFocus,
                    keyboard: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: AppDateWidgetNew(
                      value: controller.selectDate,
                      onSelectDate: controller.setSelectedDate,
                    ),
                  ),
                  _LeadTextField(
                    label: 'Requirement Specification',
                    controller: controller.requirementController,
                    focusNode: controller.requirementFocus,
                    maxLines: 3,
                  ),
                  // Lead Type — fixed two-value list, no API behind it.
                  _LeadDropdown<String>(
                    label: 'Lead Type',
                    value: controller.selectedLeadType,
                    items: controller.leadTypeOptions,
                    itemLabel: (e) => e,
                    onChanged: controller.onLeadTypeChanged,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              //  Company Details 
              _SectionCard(
                title: 'Company Details',
                icon: Icons.business_outlined,
                iconColor: const Color(0xFF7C3AED),
                children: [
                  // Company Name — picker over the client master, the same
                  // list the Approval filter's Client dropdown uses.
                  _CompanyPickerField(controller: controller),
                  _LeadTextField(
                    label: 'Owner Name',
                    controller: controller.ownerNameController,
                    focusNode: controller.ownerNameFocus,
                  ),
                  // Contact Person is a dropdown of the selected client's own
                  // contacts, and falls back to a plain field for a company
                  // that is not a client yet (or has no contacts on file).
                  if (controller.isClientDetailLoading)
                    _LeadDropdown<ClientContact>(
                      label: 'Contact Person',
                      value: null,
                      items: const [],
                      itemLabel: (e) => e.contactperson ?? '',
                      isLoading: true,
                      onChanged: controller.onContactPersonChanged,
                    )
                  else if (controller.clientContacts.isNotEmpty)
                    _LeadDropdown<ClientContact>(
                      label: 'Contact Person',
                      value: controller.selectedContact,
                      items: controller.clientContacts,
                      itemLabel: (e) => e.contactperson ?? '',
                      onChanged: controller.onContactPersonChanged,
                    )
                  else
                    _LeadTextField(
                      label: 'Contact Person',
                      controller: controller.contactPersonController,
                      focusNode: controller.contactPersonFocus,
                    ),
                  // Designation — the master always existed; what was missing
                  // was a column to store it. leadentrywithstatecity has one.
                  _LeadDropdown<DesignationData>(
                    label: 'Designation',
                    value: controller.selectedDesignation,
                    items: controller.designationOptions,
                    itemLabel: (e) => e.designnation ?? '',
                    isLoading: controller.isDesignationLoading,
                    onChanged: controller.onDesignationChanged,
                  ),
                  _LeadTextField(
                    label: 'Company Address',
                    controller: controller.companyAddressController,
                    focusNode: controller.companyAddresFocus,
                    maxLines: 2,
                  ),

                  //  State → City → Area (cascading)
                  _LeadDropdown<StateDataList>(
                    label: 'State',
                    value: controller.selectedState,
                    items: controller.stateList,
                    itemLabel: (e) => e.statename ?? '',
                    isLoading: controller.isStateLoading,
                    onChanged: controller.onStateChanged,
                  ),
                  _LeadDropdown<CityDataList>(
                    label: 'City',
                    value: controller.selectedCity,
                    items: controller.cityList,
                    itemLabel: (e) => e.cityname ?? '',
                    isLoading: controller.isCityLoading,
                    emptyHint: 'Select a State first',
                    onChanged: controller.onCityChanged,
                  ),
                  _LeadDropdown<AreaDataList>(
                    label: 'Area',
                    value: controller.selectedArea,
                    items: controller.areaList,
                    itemLabel: (e) => e.areaname ?? '',
                    isLoading: controller.isAreaLoading,
                    emptyHint: 'Select a City first',
                    onChanged: controller.onAreaChanged,
                  ),

                  // Source is a real dropdown now — leadsource/leadsourcedropdown
                  _LeadDropdown<LeadSourcesData>(
                    label: 'Source',
                    value: controller.selectedSource,
                    items: controller.sourceList,
                    itemLabel: (e) => e.sourcename ?? '',
                    onChanged: controller.onSourceChanged,
                  ),
                  // Business Type — was a free-text "Business Nature" field.
                  // Fed by the same master the lead detail screen reads.
                  _LeadDropdown<LeadBusinessList>(
                    label: 'Business Type',
                    value: controller.selectedBusinessType,
                    items: controller.businessTypeOptions,
                    itemLabel: (e) => e.businessType ?? '',
                    isLoading: controller.isBusinessTypeLoading,
                    onChanged: controller.onBusinessTypeChanged,
                  ),
                  // Industry Type — same master the lead detail screen reads.
                  _LeadDropdown<LeadIndustry>(
                    label: 'Industry Type',
                    value: controller.selectedIndustryType,
                    items: controller.industryTypeOptions,
                    itemLabel: (e) => e.industryType ?? '',
                    isLoading: controller.isIndustryTypeLoading,
                    onChanged: controller.onIndustryTypeChanged,
                  ),
                  // Priority — shared indent/issue master, same list the
                  // Indent header screen shows.
                  _LeadDropdown<IndentDropdownOption>(
                    label: 'Priority',
                    value: controller.selectedPriority,
                    items: controller.priorityOptions,
                    itemLabel: (e) => e.label,
                    isLoading: controller.isPriorityLoading,
                    onChanged: controller.onPriorityChanged,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              //  Contact Details 
              _SectionCard(
                title: 'Contact Details',
                icon: Icons.contact_phone_outlined,
                iconColor: const Color(0xFF059669),
                children: [
                  _LeadTextField(
                    label: 'Mobile No.',
                    controller: controller.mobileNumberController,
                    focusNode: controller.mobileNoFocus,
                    keyboard: TextInputType.phone,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _LeadTextField(
                    label: 'Alternate Mobile No.',
                    controller: controller.alternateNumberController,
                    focusNode: controller.alternateNoFocus,
                    keyboard: TextInputType.phone,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _LeadTextField(
                    label: 'Phone No.',
                    controller: controller.phoneNumberController,
                    focusNode: controller.phoneFocus,
                    keyboard: TextInputType.phone,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _LeadTextField(
                    label: 'Email ID',
                    controller: controller.emailController,
                    focusNode: controller.emailIdFocus,
                    keyboard: TextInputType.emailAddress,
                  ),
                  _LeadTextField(
                    label: 'Website',
                    controller: controller.websiteController,
                    focusNode: controller.websiteFocus,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              //  Action buttons 
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Submit',
                      icon: Icons.check_circle_outline_rounded,
                      onTap: () => controller.addleadApi(),
                      style: _ButtonStyle.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'Edit/Search',
                      icon: Icons.manage_search_rounded,
                      onTap: () {},
                      style: _ButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'Reset',
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        controller.leadNumberController.clear();
                        controller.requirementController.clear();
                        controller.companyNameController.clear();
                        controller.ownerNameController.clear();
                        controller.contactPersonController.clear();
                        controller.mobileNumberController.clear();
                        controller.alternateNumberController.clear();
                        controller.emailController.clear();
                        controller.websiteController.clear();
                        controller.companyAddressController.clear();
                        controller.phoneNumberController.clear();
                        controller.businessNatureController.clear();
                        controller.clearSelectedDate();
                        controller.clearLeadEntryDropdowns();
                      },
                      style: _ButtonStyle.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
