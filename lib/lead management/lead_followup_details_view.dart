// import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
// import 'package:digitalerp/screen/base/base_controller.dart';
// import 'package:digitalerp/utils/app_assets.dart';
// import 'package:digitalerp/utils/app_constant.dart';
// import 'package:digitalerp/utils/date_widget.dart';
// import 'package:digitalerp/utils/my_app_bar_new.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// class LeadFollowupDetailsView extends StatefulWidget {
//   const LeadFollowupDetailsView({Key? key}) : super(key: key);
//
//   @override
//   State<LeadFollowupDetailsView> createState() => _LeadFollowupDetailsViewState();
// }
//
// class _LeadFollowupDetailsViewState extends State<LeadFollowupDetailsView> {
//   @override
//   Widget build(BuildContext context) {
//     print('ReBuild');
//     return GetBuilder<LeadManagementController>(
//       init: LeadManagementController(),
//         builder: (controller){
//       return Scaffold(
//           resizeToAvoidBottomInset: false,
//           body:Center(
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage('assets/images/dashboard_bg.png'),
//                         fit: BoxFit.fill,
//                       ),
//                     ),
//                     child: SafeArea(
//                       child: MyAppBar(
//                         title: 'Followup Detail',
//                         onBackTap: () => Get.back(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   right: 0,
//                   left: 0,
//                   bottom: 0,
//                   top: Get.height * 0.135,
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.only(
//                         bottom: (MediaQuery.of(context).viewInsets.bottom > 0) ? 200 : 0, left: 20, right: 20),
//                     child: Column(
//                       children: [
//                         _adddetails(controller),
//                         SizedBox(height: Get.height * 0.02),
//                       Obx((){
//                     return CheckboxListTile(
//                       title: Text('Next Follow up Detail',style: TextStyle(fontWeight: FontWeight.bold),),
//                       autofocus: false,
//                       activeColor: Colors.green,
//                       checkColor: Colors.white,
//                       selected:controller.isCheck.value,
//                       value:controller.isCheck.value,
//                       onChanged: (val) {
//                         controller.onChangeValue(val);
//                       },
//                     );
//                   }),
//                       Obx((){
//                         return   controller.isCheck.value == true
//                             ? _checkFollowup(controller)
//                             : Text('');
//                       }),
//                         // SizedBox(height: Get.height * 0.02),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             submitButton(controller),
//                             resetButton(controller),
//
//                           ],
//                         ),
//                         SizedBox(height: Get.height * 0.09),
//
//
//
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//       );
//     }
//     );
//   }
//   Widget _adddetails(LeadManagementController controller){
//     return Column(
//       children: [
//           Container(
//           height:Get.height * 0.150,
//           width: Get.width * 0.900,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   grBottomColor.withValues(alpha:0.2),
//                   grTopColor.withValues(alpha:0.2)
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: TextFormField(
//             controller: controller.addressController,
//             textInputAction: TextInputAction.done,
//             focusNode: controller.addressFocus,
//             // onChanged: (value) {
//             //   controller.onSearchTextChanged(value);
//             // },
//             style: TextStyle().newstyle.copyWith(
//               color: Colors.black,
//             ),
//             decoration: InputDecoration().textFieldStylenew(hintText: 'Address')
//           ),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         Container(
//           height:Get.height * 0.100,
//           width: Get.width * 0.900,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 grBottomColor.withValues(alpha:0.2),
//                 grTopColor.withValues(alpha:0.2)
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: TextFormField(
//             controller: controller.specificationController,
//               textInputAction: TextInputAction.done,
//               focusNode: controller.specificationFocus,
//               // onChanged: (value) {
//               //   controller.onSearchTextChanged(value);
//               // },
//               style: TextStyle().newstyle.copyWith(
//                 color: Colors.black,
//               ),
//               decoration: InputDecoration().textFieldStylenew(hintText: 'Specification')
//           ),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         Container(
//           height: Get.height * 0.0600,
//           width: Get.width * 0.900,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: dropdownBoxColor,
//             gradient: LinearGradient(
//               colors: [
//                 grBottomColor.withValues(alpha:0.2),
//                 grTopColor.withValues(alpha:0.2)
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: _dateView(context, controller),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         DropdownButtonHideUnderline(
//           child: DropdownButton2(
//             buttonHeight:Get.height * 0.0600,
//             buttonWidth:  Get.width * 0.900,
//             buttonPadding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
//               "Status",
//               style: const TextStyle().newstyle.copyWith(
//                 // fontSize: 15,
//                 // fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//               // overflow: TextOverflow.ellipsis,
//             ),
//             // value: controller.selectedDocument,
//             icon: Image.asset(
//               AppAssets.dropdownIcon,
//               width: 15,
//               height: 15,
//             ), items: [],
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
//
//           ),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         DropdownButtonHideUnderline(
//           child: DropdownButton2(
//             buttonHeight:Get.height * 0.0600,
//             buttonWidth:  Get.width * 0.900,
//             buttonPadding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
//               "Handler Name",
//               style: const TextStyle().newstyle.copyWith(
//                 // fontSize: 15,
//                 // fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//               // overflow: TextOverflow.ellipsis,
//             ),
//             // value: controller.selectedDocument,
//             icon: Image.asset(
//               AppAssets.dropdownIcon,
//               width: 15,
//               height: 15,
//             ), items: [],
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
//
//           ),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         Container(
//           height:Get.height * 0.150,
//           width: Get.width * 0.900,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 grBottomColor.withValues(alpha:0.2),
//                 grTopColor.withValues(alpha:0.2)
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: TextFormField(
//             controller: controller.remarksController,
//               textInputAction: TextInputAction.done,
//               focusNode: controller.remarkFocus,
//               // onChanged: (value) {
//               //   controller.onSearchTextChanged(value);
//               // },
//               style: TextStyle().newstyle.copyWith(
//                 color: Colors.black,
//               ),
//               decoration: InputDecoration().textFieldStylenew(hintText: 'Remarks')
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _checkFollowup(LeadManagementController controller){
//     return Column(
//       children: [
//         SizedBox(height: Get.height * 0.0100,),
//        AppDateWidgetNew(value:controller.selectDate2 , onSelectDate: controller.setSelectedDate2),
//         SizedBox(height: Get.height * 0.0100,),
//         Container(
//           height:Get.height * 0.0600,
//           width: Get.width * 0.900,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 grBottomColor.withValues(alpha:0.2),
//                 grTopColor.withValues(alpha:0.2)
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: TextFormField(
//             controller: controller.followupTimeController,
//               textInputAction: TextInputAction.done,
//               focusNode: controller.followupTimeFocus,
//               // onChanged: (value) {
//               //   controller.onSearchTextChanged(value);
//               // },
//               style: TextStyle().newstyle.copyWith(
//                 color: Colors.black,
//               ),
//               decoration: InputDecoration().textFieldStylenew(hintText: 'Follow up Time')
//           ),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         DropdownButtonHideUnderline(
//           child: DropdownButton2(
//             buttonHeight:Get.height * 0.0600,
//             buttonWidth:  Get.width * 0.900,
//             buttonPadding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
//               "Purpose",
//               style: const TextStyle().newstyle.copyWith(
//                 // fontSize: 15,
//                 // fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//               // overflow: TextOverflow.ellipsis,
//             ),
//             // value: controller.selectedDocument,
//             icon: Image.asset(
//               AppAssets.dropdownIcon,
//               width: 15,
//               height: 15,
//             ), items: [],
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
//
//           ),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         DropdownButtonHideUnderline(
//           child: DropdownButton2(
//             buttonHeight:Get.height * 0.0600,
//             buttonWidth:  Get.width * 0.900,
//             buttonPadding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
//               "Executive",
//               style: const TextStyle().newstyle.copyWith(
//                 // fontSize: 15,
//                 // fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//               // overflow: TextOverflow.ellipsis,
//             ),
//             // value: controller.selectedDocument,
//             icon: Image.asset(
//               AppAssets.dropdownIcon,
//               width: 15,
//               height: 15,
//             ), items: [],
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
//
//           ),
//         ),
//         SizedBox(height: Get.height * 0.0100,),
//         Container(
//           height:Get.height * 0.150,
//           width: Get.width * 0.900,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 grBottomColor.withValues(alpha:0.2),
//                 grTopColor.withValues(alpha:0.2)
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: TextFormField(
//             controller: controller.remarkFollowController,
//               textInputAction: TextInputAction.done,
//               focusNode: controller.remarkFollowupFocus,
//               // onChanged: (value) {
//               //   controller.onSearchTextChanged(value);
//               // },
//               style: TextStyle().newstyle.copyWith(
//                 color: Colors.black,
//               ),
//               decoration: InputDecoration().textFieldStylenew(hintText: 'Remarks')
//           ),
//         ),
//         SizedBox(height: Get.height * 0.10,),
//       ],
//     );
//   }
//   Widget submitButton(LeadManagementController controller) {
//     return  Container(
//       height: 38,
//       // width: 120,
//       decoration: ShapeDecoration(
//         shape: const StadiumBorder(),
//         gradient: customGradient(topColor: orangeColor, bottomColor: red2Color),
//       ),
//       child: MaterialButton(
//         onPressed: ()=> controller.followupDetailsApi(),
//         shape: const StadiumBorder(),
//         child: Row(
//           children: [
//             SizedBox(width:5,),
//             Text(
//               'Submit',
//               style:  TextStyle(fontSize: 15,color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget resetButton(LeadManagementController controller) {
//     return  Container(
//       height: 38,
//       // width: 120,
//       decoration: ShapeDecoration(
//         shape: const StadiumBorder(),
//         gradient: customGradient(topColor: orangeColor, bottomColor: red2Color),
//       ),
//       child: MaterialButton(
//         onPressed: (){
//           controller.addressController.clear();
//           controller.specificationController.clear();
//           controller.remarksController.clear();
//           controller.followupTimeController.clear();
//           controller.clearSelected();
//           controller.clearSelected2();
//           // controller.remarkFollowController.clear();
//         },
//         shape: const StadiumBorder(),
//         child: Row(
//           children: [
//             SizedBox(width:5,),
//             Text(
//               'Reset',
//               style:  TextStyle(fontSize: 15,color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _dateView(BuildContext context, LeadManagementController ctrl) {
//     DropdownButtonHideUnderline(
//       child: DropdownButton2(
//         dropdownDecoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           color: dropdownBoxColor,
//         ),
//         dropdownMaxHeight: 200,
//         buttonDecoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: dropdownBoxColor,
//           gradient: LinearGradient(
//             colors: [
//               grBottomColor.withValues(alpha:0.2),
//               grTopColor.withValues(alpha:0.2)
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         isExpanded: true,
//         // value: controller.selectedDocument,
//         items: [],
//         // items: controller.filterDocumentData.map(
//         //       (items) {
//         //     return DropdownMenuItem(
//         //       value: items,
//         //       child: Text(
//         //         items.documentname ?? '',
//         //       ),
//         //     );
//         //   },
//         // ).toList(),
//         // onChanged: (newValue){
//         //   controller.onChangedDocumentDataValue(newValue);
//         //   controller.update();
//         // },
//       ),
//     );
//     return InkWell(
//       onTap: () async {
//         DateTime? pickedDate = await showDatePicker(
//             context: context,
//             initialDate: DateTime.now(),
//             firstDate: AppConst.calenderFirstDate ??
//                 DateTime(DateTime.now().year, 1, 1),
//             //DateTime.now() - not to allow to choose before today.
//             lastDate: AppConst.calenderLastDate ??
//                 DateTime(DateTime.now().year, 12, 31));
//
//         if (pickedDate != null) {
//           String formattedDate =
//           DateFormat(AppString.ddMMyyyy).format(pickedDate);
//           ctrl.setSelectedDatef(formattedDate);
//         } else {
//           if (kDebugMode) {
//             print('Date is not selected');
//           }
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(height: 15),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//
//               Text(ctrl.selectDatef.toString(), style: const TextStyle().xstyle.copyWith(
//                   fontSize: 16
//               )),
//               SizedBox(width: Get.width * 0.37,),
//               Image.asset(
//                 AppAssets.calendarIcon,
//                 width: 18,
//                 height: 18,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }

import 'package:digitalerp/utils/lead_app_bar.dart';
import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
import 'package:digitalerp/model/followup_option_response_model.dart';
import 'package:digitalerp/response/executive_list_response.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filter_controller.dart';
import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/documentname_responce.dart';
import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/status_list_responce.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
import 'package:digitalerp/screen/ui/home/order/select_brand/select_brand_view.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
// date_widget removed — the Next Follow up Entry Date now uses this screen's
// own _styledDateField instead of the legacy AppDateWidgetNew.
import 'package:digitalerp/utils/show_message.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

//  Design tokens 
const Color _kBg = Color(0xFFF5F6FA);
const Color _kWhite = Colors.white;
const Color _kBlue = purpleColor;
final Color _kBlueBg = purpleLightest;
const Color _kBorder = Color(0xFFE2E8F0);
const Color _kTextPrimary = Color(0xFF0F172A);
const Color _kTextSub = Color(0xFF64748B);
const Color _kTextHint = Color(0xFF94A3B8);

const Color _kGreen = newGreenColor;

//  Shared helpers 
/// Delegates to the module-wide [LeadAppBar] so this screen stops rendering a
/// 20pt title with a bare back arrow while the rest of the module uses a 17pt
/// title with a boxed chevron.
Widget _appBar(String title,
    {String? subtitle, VoidCallback? onFilter, VoidCallback? onAdd}) {
  return LeadAppBar(
    title: title,
    subtitle: subtitle,
    actions: [
      if (onAdd != null) leadAppBarAction(Icons.add_rounded, onAdd),
      if (onFilter != null)
        leadAppBarAction(Icons.filter_list_rounded, onFilter),
    ],
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

Widget _textField({
  required TextEditingController controller,
  required FocusNode focusNode,
  required String hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) =>
    Container(
      decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        keyboardType:
        maxLines > 1 ? TextInputType.multiline : keyboardType,
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        style: const TextStyle(fontSize: 14, color: _kTextPrimary),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: _kTextHint, fontSize: 14),
        ),
      ),
    );

Widget _dropdownShell({required String hint, List<DropdownMenuItem>? items}) =>
    _styledDropdown(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          buttonHeight: 50,
          buttonPadding: const EdgeInsets.symmetric(horizontal: 14),
          dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18), color: _kWhite),
          dropdownMaxHeight: 200,
          buttonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.transparent),
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(fontSize: 14, color: _kTextHint)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: _kTextSub, size: 22),
          items: items ?? [],
          onChanged: null,
        ),
      ),
    );

/// A real, working dropdown in the same shell as [_dropdownShell].
///
/// [_dropdownShell] hardcodes `items: []` AND `onChanged: null`, so it can
/// never open — it only looks like a dropdown. This one is backed by data.
Widget _dataDropdown<T>({
  required String hint,
  required T? value,
  required List<T> items,
  required String Function(T) itemLabel,
  required ValueChanged<T?> onChanged,
  bool isLoading = false,
  String emptyHint = '',
}) {
  final bool disabled = isLoading || items.isEmpty;
  return _styledDropdown(
    child: DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        buttonHeight: 50,
        buttonPadding: const EdgeInsets.symmetric(horizontal: 14),
        dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18), color: _kWhite),
        dropdownMaxHeight: 300,
        buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.transparent),
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
                    ? 'Loading $hint…'
                    : (items.isEmpty && emptyHint.isNotEmpty
                        ? emptyHint
                        : hint),
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
                    style:
                        const TextStyle(fontSize: 14, color: _kTextPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: disabled ? null : onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: _kTextSub, size: 22),
      ),
    ),
  );
}

// NOTE: these two used `CircleBorder`, which forces a circular outline while
// the button still lays out at full row width — so the label rendered outside
// the circle ("Submit" spilling past its edge). Full-width rounded rectangles
// are what the rest of the app uses.
Widget _solidButton(String label, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kBlue,
          foregroundColor: _kWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );

Widget _outlineButton(String label, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _kBlue,
          side: const BorderSide(color: _kBorder, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );

class LeadFollowupDetailsView extends StatefulWidget {
  const LeadFollowupDetailsView({Key? key}) : super(key: key);
  @override
  State<LeadFollowupDetailsView> createState() =>
      _LeadFollowupDetailsViewState();
}

class _LeadFollowupDetailsViewState extends State<LeadFollowupDetailsView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadManagementController>(
      init: LeadManagementController(),
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _appBar('Followup Detail'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom > 0 ? 200 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address
                      _sectionLabel('Address'),
                      _textField(
                          controller: controller.addressController,
                          focusNode: controller.addressFocus,
                          hint: 'Address',
                          maxLines: 3),
                      const SizedBox(height: 14),

                      // Specification
                      _sectionLabel('Specification'),
                      _textField(
                          controller: controller.specificationController,
                          focusNode: controller.specificationFocus,
                          hint: 'Specification',
                          maxLines: 2),
                      const SizedBox(height: 14),

                      // Date
                      _sectionLabel('Date'),
                      _datePickerField(context, controller),
                      const SizedBox(height: 14),

                      // Status — master being built by the backend team; the
                      // dropdown stays disabled until the endpoint exists.
                      _sectionLabel('Status'),
                      _dataDropdown<FollowupOption>(
                        hint: 'Status',
                        value: controller.selectedStatus,
                        items: controller.statusOptions,
                        itemLabel: (e) => e.name,
                        isLoading: controller.isStatusLoading,
                        emptyHint: 'Status list not available yet',
                        onChanged: controller.onFollowupStatusChanged,
                      ),
                      const SizedBox(height: 14),

                      // Handler Name — company executive list
                      _sectionLabel('Handler Name'),
                      _dataDropdown<ExecutiveList>(
                        hint: 'Handler Name',
                        value: controller.selectedHandler,
                        items: controller.executiveOptions,
                        itemLabel: (e) => e.executivename ?? '',
                        isLoading: controller.isExecutiveLoading,
                        onChanged: controller.onHandlerChanged,
                      ),
                      const SizedBox(height: 14),

                      // Remarks
                      _sectionLabel('Remarks'),
                      _textField(
                          controller: controller.remarksController,
                          focusNode: controller.remarkFocus,
                          hint: 'Remarks',
                          maxLines: 3),
                      const SizedBox(height: 16),

                      // Next followup checkbox
                      Container(
                        decoration: BoxDecoration(
                            color: _kWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _kBorder)),
                        child: Obx(() => CheckboxListTile(
                              title: const Text('Next Follow up Detail',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _kTextPrimary)),
                              value: controller.isCheck.value,
                              onChanged: controller.onChangeValue,
                              activeColor: _kGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            )),
                      ),

                      // Conditional next followup section
                      Obx(() => controller.isCheck.value
                          ? _nextFollowupSection(controller, context)
                          : const SizedBox()),

                      const SizedBox(height: 24),

                      // Buttons
                      Row(children: [
                        Expanded(
                            child: _solidButton('Submit',
                                () => controller.followupDetailsApi())),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _outlineButton('Reset', () {
                          controller.addressController.clear();
                          controller.specificationController.clear();
                          controller.remarksController.clear();
                          controller.followupTimeController.clear();
                          controller.clearSelected();
                          controller.clearSelected2();
                          controller.clearFollowupDropdowns();
                        })),
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePickerField(BuildContext context, LeadManagementController ctrl) {
    return _styledDateField(
        context, ctrl.selectDatef.toString(), ctrl.setSelectedDatef);
  }

  /// Extracted so the "Next Follow up Details" Entry Date can reuse it. That
  /// field previously used the shared `AppDateWidgetNew`, whose legacy
  /// gradient styling clashed with every other plain bordered field on this
  /// screen.
  Widget _styledDateField(
      BuildContext context, String value, ValueChanged<String> onPicked) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: AppConst.calenderFirstDate ?? DateTime(2000),
          lastDate: AppConst.calenderLastDate ?? DateTime(2050),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: _kBlue, onPrimary: Colors.white),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onPicked(DateFormat(AppString.ddMMyyyy).format(picked));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder)),
        child: Row(children: [
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, color: _kTextPrimary)),
          ),
          const Icon(Icons.calendar_today_outlined, size: 16, color: _kTextSub),
        ]),
      ),
    );
  }

  Widget _nextFollowupSection(
      LeadManagementController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _kBlueBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBlue.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Next Follow up Details',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary)),
        const SizedBox(height: 14),
        _styledDateField(
            context, controller.selectDate2.toString(), controller.setSelectedDate2),
        const SizedBox(height: 14),
        _sectionLabel('Follow up Time'),
        _textField(
            controller: controller.followupTimeController,
            focusNode: controller.followupTimeFocus,
            hint: 'Follow up Time'),
        const SizedBox(height: 14),
        _sectionLabel('Purpose'),
        _dataDropdown<FollowupOption>(
          hint: 'Purpose',
          value: controller.selectedPurpose,
          items: controller.purposeOptions,
          itemLabel: (e) => e.name,
          isLoading: controller.isPurposeLoading,
          emptyHint: 'Purpose list not available yet',
          onChanged: controller.onFollowupPurposeChanged,
        ),
        const SizedBox(height: 14),
        _sectionLabel('Executive'),
        _dataDropdown<ExecutiveList>(
          hint: 'Executive',
          value: controller.selectedExecutive,
          items: controller.executiveOptions,
          itemLabel: (e) => e.executivename ?? '',
          isLoading: controller.isExecutiveLoading,
          onChanged: controller.onExecutiveChanged,
        ),
        const SizedBox(height: 14),
        _sectionLabel('Remarks'),
        _textField(
            controller: controller.remarkFollowController,
            focusNode: controller.remarkFollowupFocus,
            hint: 'Remarks',
            maxLines: 3),
      ]),
    );
  }
}
