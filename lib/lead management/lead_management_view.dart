// // import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
// // import 'package:digitalerp/lead%20management/lead_entry_view.dart';
// // import 'package:digitalerp/lead%20management/lead_filtter_view.dart';
// // import 'package:digitalerp/lead%20management/lead_followup_details_view.dart';
// // import 'package:digitalerp/lead%20management/lead_followup_history.dart';
// // import 'package:digitalerp/screen/base/base_controller.dart';
// // import 'package:digitalerp/screen/ui/home/order/select_brand/select_brand_view.dart';
// // import 'package:digitalerp/utils/app_assets.dart';
// // import 'package:digitalerp/utils/app_constant.dart';
// // import 'package:digitalerp/utils/my_app_bar_new.dart';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:get/get_core/src/get_main.dart';
// // import 'package:get/get_navigation/get_navigation.dart';
// // import 'package:get/get_state_manager/get_state_manager.dart';
// //
// // class LeadManagementView extends StatefulWidget {
// //   const LeadManagementView({Key? key}) : super(key: key);
// //
// //   @override
// //   State<LeadManagementView> createState() => _LeadManagementViewState();
// // }
// //
// // class _LeadManagementViewState extends State<LeadManagementView> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return GetBuilder<LeadManagementController>(
// //         init: LeadManagementController(),
// //         builder: (controller){
// //       return Scaffold(
// //         body: Center(
// //             child: Stack(
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
// //                           title: 'Lead Management',
// //                           onFilterTap: (){
// //                             Get.to(LeadFilterScreen());
// //                           },
// //                           // onDrawerTap: () => controller.openDrawer(context),
// //                           onBackTap: () =>Get.back(),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   Positioned(
// //                     top: Get.height * 0.138,
// //                     left: 25,
// //                     right: 0,
// //                     bottom: 0,
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       mainAxisAlignment: MainAxisAlignment.start,
// //                       children: [
// //                         Padding(
// //                           padding: EdgeInsets.only(top: 15),
// //                           child: Text('Add Lead',style: TextStyle().bold,),
// //                         ),
// //                         SizedBox(width: Get.width * 0.500,),
// //                         Container(
// //                             height: 35,
// //                             width: 30,
// //                             decoration: BoxDecoration(
// //                                 shape:BoxShape.circle,
// //                                 gradient: customGradient(topColor: orangeColor, bottomColor: red2Color)
// //                             ),
// //                             child:InkWell(
// //                               onTap: (){
// //                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>LeadEntryView()));
// //                               },
// //                               child: Icon(Icons.add,color: Colors.white,),
// //                             )
// //                         ),
// //
// //                       ],
// //                     ),
// //                   ),
// //                   Positioned(
// //                       right: 0,
// //                       left: 0,
// //                       bottom: 0,
// //                       top: Get.height * 0.200,
// //                       child:  SingleChildScrollView(
// //                         child: Column(children: [
// //                           ListView.builder(
// //                               shrinkWrap: true,
// //                               padding: EdgeInsets.zero,
// //                               physics: const NeverScrollableScrollPhysics(),
// //                               itemCount:5,
// //                               itemBuilder: (context, index) => LeadCard()
// //                           ),
// //                         ]),
// //                       )
// //
// //                   ),
// //
// //                 ]
// //             )
// //         ),
// //       );
// //     });
// //
// //   }
// //   LeadCard() {
// //     return Padding(
// //       padding: const EdgeInsets.all(5.0),
// //       child: Card(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         color: Colors.white,
// //         child: InkWell(
// //           onTap: () => Get.to(LeadFollowupDetailsView()),
// //           child: Container(
// //             width: Get.width,
// //             // height: Get.height * 0.270,
// //             decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(10),
// //                 color: Colors.white,
// //                 boxShadow: const [
// //                   BoxShadow(
// //                       color: Colors.black12, blurRadius: 3, offset: Offset(0, 3))
// //                 ]),
// //             padding: const EdgeInsets.only(top: 20, left: 7, right: 20),
// //             child: Column(
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text("Lead No.",
// //                             style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.deepOrange.shade400)),
// //                         Text(
// //                               'N/A',
// //                           style: TextStyle().xstyle
// //                         ),
// //                         const SizedBox(
// //                           height: 10,
// //                         ),
// //                         Row(
// //                           children: [
// //                             Text(
// //                               "Edit",
// //                               style: const TextStyle().newstyle,
// //                             ),
// //                             SizedBox(width: Get.width * 0.030,),
// //                             InkWell(
// //                               onTap: (){},
// //                               child: Image.asset(AppAssets.editIcon,color: Colors.deepOrange.shade400,scale: 4,),
// //                             )
// //                           ],
// //                         ),
// //                         const SizedBox(
// //                           height: 12,
// //                         ),
// //                         Text(
// //                           "Contact Person",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                               'N/A',
// //                           style: const TextStyle().xstyle,
// //                         ),
// //                         const SizedBox(
// //                           height: 7,
// //                         ),
// //                         Text(
// //                           "Next Followp date",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                               'N/A',
// //                           style:  const TextStyle().xstyle,
// //                         ),
// //                         SizedBox(height: 7,),
// //                         Text(
// //                           "Status",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                           'N/A',
// //                           style:  const TextStyle().xstyle,
// //                         ),
// //                         SizedBox(height: 7,),
// //                         Text(
// //                           "Specificatiion",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                           'N/A',
// //                           style:  const TextStyle().xstyle,
// //                         ),
// //                         SizedBox(height: 7,),
// //                         Row(
// //                           children: [
// //                             Text(
// //                               "Followp",
// //                               style: const TextStyle().newstyle,
// //                             ),
// //                             SizedBox(width: Get.width * 0.020,),
// //                             InkWell(
// //                               child: Icon(Icons.supervised_user_circle,color: Colors.deepOrange.shade400,),
// //                             )
// //                           ],
// //                         ),
// //                         Text(
// //                           'N/A',
// //                           style:  const TextStyle().xstyle,
// //                         ),
// //                         SizedBox(height: 7,),
// //                         Text(
// //                           "Print",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Padding(
// //                           padding:  EdgeInsets.only(top: 5),
// //                           child: InkWell(
// //                             onTap: () {
// //                             },
// //                             child: Image(
// //                               image: const AssetImage('assets/images/pdf.png'),
// //                               height: Get.height * 0.0370,
// //                             ),
// //                           ),
// //                         ),
// //
// //
// //                       ],
// //                     ),
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //
// //                       children: [
// //                         Text("Lead Date",
// //                             style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.deepOrange.shade400)),
// //                         Text(
// //                             'N/A',
// //                             style: const TextStyle().xstyle),
// //                         const SizedBox(
// //                           height: 7,
// //                         ),
// //                         Text(
// //                           "Company",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                               'N/A',
// //                           overflow: TextOverflow.visible,
// //                           softWrap: false,
// //                           maxLines: 2,
// //                           style: const TextStyle().xstyle,
// //                         ),
// //                         const SizedBox(
// //                           height: 7,
// //                         ),
// //                         Text(
// //                           "Mobile No.",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                               'N/A',
// //                           style: const TextStyle().xstyle,
// //                         ),
// //                         const SizedBox(
// //                           height: 7,
// //                         ),
// //                         Text(
// //                           "Followp Entry date",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                               'N/A',
// //                           style: const TextStyle().xstyle,
// //                         ),
// //                         const SizedBox(
// //                           height: 7,
// //                         ),
// //                         Text(
// //                           "Handler",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                           'N/A',
// //                           style: const TextStyle().xstyle,
// //                         ),
// //                         const SizedBox(
// //                           height: 7,
// //                         ),
// //                         Row(
// //                           children: [
// //                             Text(
// //                               "Followp Histroy",
// //                               style: const TextStyle().newstyle,
// //                             ),
// //                             SizedBox(width: Get.width * 0.010,),
// //                            InkWell(
// //                              onTap: ()=> Get.to(LeadFolloupHistory()),
// //                              child:Icon(Icons.history,color: Colors.deepOrange.shade400,),)
// //                           ],
// //                         ),
// //                         Text(
// //                           'N/A',
// //                           style: const TextStyle().xstyle,
// //                         ),
// //                         const SizedBox(
// //                           height: 7,
// //                         ),
// //                         Text(
// //                           "Quotation",
// //                           style: const TextStyle().newstyle,
// //                         ),
// //                         Text(
// //                           'N/A',
// //                           style: const TextStyle().xstyle,
// //                         ),
// //                         const SizedBox(
// //                           height: 15,
// //                         ),
// //                        Container(
// //                          height: 38,
// //                          // width: 120,
// //                          decoration: ShapeDecoration(
// //                            shape: const StadiumBorder(),
// //                            gradient: customGradient(topColor: orangeColor, bottomColor: red2Color),
// //                          ),
// //                          child: MaterialButton(
// //                            onPressed: (){
// //                              Get.to(SelectBrandView());
// //                            },
// //                            shape: const StadiumBorder(),
// //                            child: Row(
// //                              children: [
// //                                CircleAvatar(child: Icon(Icons.add,color: Colors.orange,),backgroundColor: Colors.white,radius: 12,),
// //                                SizedBox(width:5,),
// //                                Text(
// //                                 'Add Item',
// //                                  style:  TextStyle(fontSize: 15,color: Colors.white),
// //                                ),
// //                              ],
// //                            ),
// //                          ),
// //                        )
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Padding(
// //                       padding: const EdgeInsets.only(
// //                         left: 255,
// //                         top: 10,
// //                       ),
// //
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
// import 'package:digitalerp/lead%20management/lead_entry_view.dart';
// import 'package:digitalerp/lead%20management/lead_followup_details_view.dart';
// import 'package:digitalerp/lead%20management/lead_followup_history.dart';
// import 'package:digitalerp/lead%20management/lead_filtter_view.dart';
// import 'package:digitalerp/screen/base/base_controller.dart';
// import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filter_controller.dart';
// import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/documentname_responce.dart';
// import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/status_list_responce.dart';
// import 'package:digitalerp/screen/ui/home/mrn/widgets/app_theme.dart';
// import 'package:digitalerp/screen/ui/home/order/select_brand/select_brand_view.dart';
// import 'package:digitalerp/utils/app_constant_new.dart';
//
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// //  Design tokens 
// const Color _kBg = Color(0xFFF5F6FA);
// const Color _kWhite = Colors.white;
// const Color _kBlue = purpleColor;
// final Color _kBlueBg = purpleLightest;
// const Color _kBorder = Color(0xFFE2E8F0);
// const Color _kTextPrimary = Color(0xFF0F172A);
// const Color _kTextSub = Color(0xFF64748B);
// const Color _kDivider = Color(0xFFEFF2F7);
// const Color _kGreen = Color(0xFF10B981);
// const Color _kGreenBg = Color(0xFFD1FAE5);
// const Color _kOrange = Color(0xFFF59E0B);
// const Color _kOrangeBg = Color(0xFFFEF3C7);
//
// //  Shared helpers 
// Widget _appBar(String title, {VoidCallback? onFilter}) {
//   return Container(
//     color: _kWhite,
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     child: Row(children: [
//       GestureDetector(
//         onTap: () => Get.back(),
//         child: const Icon(Icons.arrow_back_ios, color: _kTextPrimary, size: 22),
//       ),
//       const SizedBox(width: 12),
//       Expanded(
//         child: Text(title,
//             style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: _kTextPrimary)),
//       ),
//       if (onFilter != null)
//         GestureDetector(
//           onTap: onFilter,
//           child: Container(
//             height: 40,
//             width: 40,
//             decoration: BoxDecoration(
//                 color: AppColors.purpleLightest, borderRadius: BorderRadius.circular(18)),
//             child: const Icon(Icons.filter_list_sharp, color: purpleColor, size: 20),
//           ),
//         ),
//     ]),
//   );
// }
//
//
// Widget _sectionLabel(String label) => Padding(
//   padding: const EdgeInsets.only(bottom: 8),
//   child: Text(label,
//       style: const TextStyle(
//           fontSize: 14, fontWeight: FontWeight.w600, color: _kTextPrimary)),
// );
//
//
//
// class LeadManagementView extends StatefulWidget {
//   const LeadManagementView({Key? key}) : super(key: key);
//   @override
//   State<LeadManagementView> createState() => _LeadManagementViewState();
// }
//
// class _LeadManagementViewState extends State<LeadManagementView> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<LeadManagementController>(
//       init: LeadManagementController(),
//       builder: (controller) => Scaffold(
//         backgroundColor: const Color(0xFFF5F6FA),
//         body: SafeArea(
//           child: Stack(
//             children: [
//               Column(
//               children: [
//                 _appBar(
//                   'Lead Management',
//                   onFilter: () => Get.to(LeadFilterScreen()),
//                 ),
//
//                 Expanded(
//                   child: controller.isBusy
//                       ? showLoader(color: _kBlue)
//                       : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//                     itemCount: 5, // replace with controller.leadList.length
//                     itemBuilder: (context, index) =>
//                         _LeadCard(controller: controller),
//                   ),
//
//                 ),
//
//               ],
//             ),
//               Positioned(
//                 right: 20,
//                 bottom: 28,
//                 child: FloatingActionButton(
//                   onPressed: () => Get.to(const LeadEntryView()),
//                   backgroundColor: purpleColor,
//                   shape:
//                   const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
//                   elevation: 4,
//                   child: const Icon(Icons.add,
//                       color: Colors.white, size: 32),
//                 ),
//               ),
//             ],
//           ),
//
//         ),
//       ),
//     );
//   }
// }
//
// //  Lead Card 
// class _LeadCard extends StatelessWidget {
//   final LeadManagementController controller;
//   const _LeadCard({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Get.to(const LeadFollowupDetailsView()),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         decoration: BoxDecoration(
//           color: _kWhite,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: _kBorder),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.04),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2))
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             //  Header: Lead No. + Lead Date + Edit 
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
//               child: Row(children: [
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('Lead No.',
//                       style: TextStyle(fontSize: 11, color: _kTextSub)),
//                   const SizedBox(height: 2),
//                   const Text('N/A',
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           color: _kTextPrimary)),
//                 ]),
//                 const SizedBox(width: 16),
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('Lead Date',
//                       style: TextStyle(fontSize: 11, color: _kTextSub)),
//                   const SizedBox(height: 2),
//                   const Text('N/A',
//                       style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: _kTextPrimary)),
//                 ]),
//                 const Spacer(),
//                 // Edit icon
//                 GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                     width: 32,
//                     height: 32,
//                     decoration: BoxDecoration(
//                         color: _kBlueBg,
//                         borderRadius: BorderRadius.circular(8)),
//                     child: const Icon(Icons.edit_outlined,
//                         color: _kBlue, size: 16),
//                   ),
//                 ),
//               ]),
//             ),
//
//             const Divider(height: 1, color: _kDivider),
//
//             //  Info boxes: Company | Contact Person 
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
//               child: Row(children: [
//                 _infoBox('Company', 'N/A'),
//                 const SizedBox(width: 10),
//                 _infoBox('Contact Person', 'N/A'),
//               ]),
//             ),
//
//             //  Mini fields: Mobile | Status | Handler 
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
//               child: Row(children: [
//                 _miniField('Mobile No.', 'N/A'),
//                 _vDivider(),
//                 _miniField('Status', 'N/A'),
//                 _vDivider(),
//                 _miniField('Handler', 'N/A'),
//               ]),
//             ),
//
//             const SizedBox(height: 10),
//             const Divider(height: 1, color: _kDivider),
//
//             //  Footer: Next Followup | Specification | Actions 
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(children: [
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     const Text('Next Followup',
//                         style: TextStyle(fontSize: 11, color: _kTextSub)),
//                     const Text('N/A',
//                         style: TextStyle(fontSize: 12, color: _kTextPrimary)),
//                   ]),
//                   const SizedBox(width: 20),
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     const Text('Specification',
//                         style: TextStyle(fontSize: 11, color: _kTextSub)),
//                     const Text('N/A',
//                         style: TextStyle(fontSize: 12, color: _kTextPrimary)),
//                   ]),
//                   const Spacer(),
//                   // Followup icon
//                   GestureDetector(
//                     onTap: () => Get.to(const LeadFollowupDetailsView()),
//                     child: Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                           color: _kGreenBg,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: const Icon(Icons.person_add_outlined,
//                           color: _kGreen, size: 16),
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   // History icon
//                   GestureDetector(
//                     onTap: () => Get.to(const LeadFolloupHistory()),
//                     child: Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                           color: _kOrangeBg,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: const Icon(Icons.history, color: _kOrange, size: 16),
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   // PDF icon
//                   Image.asset('assets/iconsnew/pdfIcon.png',
//                       width: 28, height: 28),
//                   const SizedBox(width: 6),
//                   // Add Item button
//                   GestureDetector(
//                     onTap: () => Get.to(SelectBrandView()),
//                     child: Container(
//                       padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                       decoration: BoxDecoration(
//                           color: _kBlueBg,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: const Row(children: [
//                         Icon(Icons.add, color: _kBlue, size: 14),
//                         SizedBox(width: 4),
//                         Text('Add Item',
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: _kBlue)),
//                       ]),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _infoBox(String label, String value) => Expanded(
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: _kBlueBg,
//         borderRadius: BorderRadius.circular(8),
//         border: const Border(left: BorderSide(color: _kBlue, width: 3)),
//       ),
//       child:
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(label, style: const TextStyle(fontSize: 11, color: _kTextSub)),
//         const SizedBox(height: 2),
//         Text(value,
//             style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: _kTextPrimary),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis),
//       ]),
//     ),
//   );
//
//   Widget _miniField(String label, String value) => Expanded(
//     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(label, style: const TextStyle(fontSize: 10, color: _kTextSub)),
//       const SizedBox(height: 2),
//       Text(value,
//           style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: _kTextPrimary),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis),
//     ]),
//   );
//
//   Widget _vDivider() => Container(
//       width: 1,
//       height: 32,
//       color: _kBorder,
//       margin: const EdgeInsets.symmetric(horizontal: 8));
// }



import 'package:digitalerp/lead%20management/lead%20management%20controller/lead_management_controller.dart';
import 'package:digitalerp/lead%20management/lead_entry_view.dart';
import 'package:digitalerp/lead%20management/lead_filtter_view.dart';
import 'package:digitalerp/lead%20management/lead_followup_details_view.dart';
import 'package:digitalerp/lead%20management/lead_followup_history.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/order/select_brand/select_brand_view.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/call_logs_screen.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/create_quote_screen.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/lead_managment_screen.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/notes_screen.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/view_lead_screen.dart'
    show LeadDetailsScreen;
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

//  Design tokens 
const Color _kPrimary       = purpleColor;
final Color _kPrimaryLight  = purpleLightest;
const Color _kBg            = Color(0xFFF6F7FB);
const Color _kSurface       = Colors.white;
const Color _kBorder        = Color(0xFFE4E7F0);
const Color _kDivider       = Color(0xFFEFF2F7);
const Color _kTextPrimary   = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kCardShadow    = Color(0x0A000000);
const Color _kGreen         = newGreenColor;
const Color _kGreenLight    = newGreenLightColor;
const Color _kOrange        = newOrangeColor;
const Color _kOrangeLight   = newOrangeLightColor;
const Color _kAccent        = Color(0xFF5B5FC7);
const Color _kAccentLight   = Color(0xFFF0F3FF);

class LeadManagementView extends StatefulWidget {
  const LeadManagementView({Key? key}) : super(key: key);
  @override
  State<LeadManagementView> createState() => _LeadManagementViewState();
}

class _LeadManagementViewState extends State<LeadManagementView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadManagementController>(
      init: LeadManagementController(),
      builder: (controller) => Scaffold(
        backgroundColor: _kBg,

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
              //     color: _kBg,
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(color: _kBorder)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _kTextPrimary, size: 18),
            ),
          ),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Lead Management',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary)),
            Text('Manage and track your leads',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: _kTextSecondary)),
          ]),
          actions: [
            GestureDetector(
              onTap: () => Get.to(LeadFilterScreen()),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: _kAccentLight,
                    borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.filter_list_rounded,
                    color: _kAccent, size: 20),
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(const LeadEntryView()),
          backgroundColor: _kPrimary,
          elevation: 3,
          shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 2.5)),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),

        body: controller.isBusy
            ? Center(
            child: CircularProgressIndicator(
                color: _kPrimary, strokeWidth: 2.5))
            : controller.filteredLeadList.isEmpty
            ? _emptyState(controller.isLeadFilterActive)
            : RefreshIndicator(
          color: _kPrimary,
          onRefresh: () async => controller.getLeadList(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.filteredLeadList.length,
            itemBuilder: (ctx, i) =>
                _LeadCard(item: controller.filteredLeadList[i]),
          ),
        ),
      ),
    );
  }

  Widget _emptyState([bool filterActive = false]) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
              color: _kAccentLight,
              borderRadius: BorderRadius.circular(36)),
          child: const Icon(Icons.leaderboard_outlined,
              size: 34, color: _kAccent),
        ),
        const SizedBox(height: 16),
        const Text('No Leads Found',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary)),
        const SizedBox(height: 6),
        Text(
            filterActive
                ? 'No leads match the current filter.'
                : 'Tap + to add a new lead',
            style: const TextStyle(fontSize: 13, color: _kTextSecondary)),
      ]),
    );
  }
}

//  Lead Card 
class _LeadCard extends StatelessWidget {
  /// Deliberately TYPED, not `dynamic`. This card previously used `dynamic`
  /// and read invented field names (leadnumber / contactperson / handler /
  /// nextfollowupdate) that don't exist on the model. That compiled fine and
  /// only avoided crashing because the lead list was hardcoded empty — the
  /// moment real data arrived it would have thrown NoSuchMethodError.
  /// Typing it means the compiler catches any wrong field name.
  final GetleadentryList? item;
  const _LeadCard({required this.item});

  /// Actions sheet: Call / WhatsApp / Follow-ups / Notes / Call Logs / Quote /
  /// View Details. These all existed in the Balaji build but had no entry point
  /// here — the card only ever opened the follow-up form.
  void _showLeadActions(BuildContext context) {
    final lead = item;
    if (lead == null) return;
    final mobile = (lead.mobileNo ?? '').trim();

    void close() => Navigator.pop(context);

    void warnNoMobile() => ShowMessage.showSnackBar(
        'No mobile number', 'This lead has no mobile number saved.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 14),
            Text(
              (lead.leadName.isNotEmpty) ? lead.leadName : (lead.companyName ?? 'Lead'),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (mobile.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(mobile,
                    style: const TextStyle(
                        fontSize: 12, color: _kTextSecondary)),
              ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _sheetAction(Icons.visibility_outlined, _kPrimary,
                    _kAccentLight, 'View Details', () {
                  close();
                  Get.to(() => LeadDetailsScreen(
                        onUpdate: () {},
                        id: lead.leadEntryId?.toString(),
                      ));
                }),
                _sheetAction(Icons.call_outlined, _kGreen, _kGreenLight, 'Call',
                    () async {
                  close();
                  if (mobile.isEmpty) return warnNoMobile();
                  await launchUrl(Uri(scheme: 'tel', path: mobile));
                }),
                _sheetAction(Icons.chat, const Color(0xFF25D366),
                    _kGreenLight, 'WhatsApp', () async {
                  close();
                  if (mobile.isEmpty) return warnNoMobile();
                  await launchUrl(Uri.parse('https://wa.me/$mobile'),
                      mode: LaunchMode.externalApplication);
                }),
                _sheetAction(Icons.event_note_outlined, _kOrange,
                    _kOrangeLight, 'Follow-ups', () {
                  close();
                  Get.to(() =>
                      LeadRemarksScreen(lead: lead, type: 'Followup'));
                }),
                _sheetAction(Icons.sticky_note_2_outlined, _kAccent,
                    _kAccentLight, 'Notes', () {
                  close();
                  Get.to(() => LeadRemarksScreen(lead: lead, type: 'Notes'));
                }),
                _sheetAction(Icons.phone_callback_outlined, _kPrimary,
                    _kPrimaryLight, 'Call Logs', () {
                  close();
                  Get.to(() => CallLogsScreen(lead: lead));
                }),
                _sheetAction(Icons.request_quote_outlined, _kOrange,
                    _kOrangeLight, 'Quote', () {
                  close();
                  Get.to(() => CreateQuoteScreen(lead: lead));
                }),
                _sheetAction(Icons.history_rounded, _kAccent, _kAccentLight,
                    'History', () {
                  close();
                  Get.to(const LeadFolloupHistory());
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetAction(IconData icon, Color color, Color bg, String label,
          VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: _kTextSecondary),
                maxLines: 2),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(const LeadFollowupDetailsView()),
      onLongPress: () => _showLeadActions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
          boxShadow: const [
            BoxShadow(
                color: _kCardShadow,
                blurRadius: 10,
                offset: Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          //  Header: Lead No + Date + Edit 
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(children: [
              // Lead No badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _kPrimaryLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Text('Lead No. ',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _kPrimary)),
                  Text(item?.leadEntryId.toString() ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _kPrimary)),
                ]),
              ),
              const SizedBox(width: 10),
              // Date
              Expanded(
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: _kTextSecondary),
                  const SizedBox(width: 4),
                  Text(item?.leadDate ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _kTextSecondary)),
                ]),
              ),
              // Edit — was a no-op; opens the lead in the edit form.
              // The edit screen re-fetches the full record by id, because this
              // list row only carries six fields. Refresh on return so an
              // edited lead doesn't keep showing its old values here.
              GestureDetector(
                onTap: () =>
                    Get.to(() => LeadManagementScreen(editLead: item))?.then((_) {
                  if (Get.isRegistered<LeadManagementController>()) {
                    Get.find<LeadManagementController>().getLeadList();
                  }
                }),
                // Labelled, not a bare icon — a pencil square on its own left
                // users guessing what the button does.
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: _kAccentLight,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined, color: _kAccent, size: 14),
                    SizedBox(width: 5),
                    Text('Edit',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kAccent)),
                  ]),
                ),
              ),
            ]),
          ),

          const Divider(height: 1, color: _kDivider),

          //  Company + Contact Person 
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(children: [
              _bracketBox('Company', item?.companyName ?? 'N/A'),
              const SizedBox(width: 10),
              // leadName is the lead/contact person on this endpoint; it can be
              // returned blank, so fall back rather than showing an empty box.
              _bracketBox('Contact Person',
                  (item?.leadName.isNotEmpty ?? false) ? item!.leadName : 'N/A'),
            ]),
          ),

          //  Mobile | Status | Handler 
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(children: [
              _miniField(Icons.phone_outlined, 'Mobile',
                  item?.mobileNo ?? 'N/A'),
              _vDivider(),
              // Was 'Status' → the lead-list model has no status field at all.
              // Source is real data this endpoint can return.
              _miniField(Icons.flag_outlined, 'Source',
                  item?.sourceName ?? 'N/A'),
              _vDivider(),
              // Was 'Handler' → no such field exists. Ageing (days since the
              // lead was raised) IS returned by the endpoint.
              _miniField(Icons.person_outline_rounded, 'Ageing',
                  item?.ageing ?? 'N/A'),
            ]),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: _kDivider),

          //  Footer: next followup, spec, action icons 
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
            // Last Contact now sits on its own line, and the actions get a
            // full-width row underneath. Previously four unlabelled icon
            // squares competed with the text for horizontal space, so they
            // were both cramped and unreadable.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  // Was 'Next Followup' → no such field on the lead-list
                  // model. lastCommunicationDate is the real equivalent.
                  const Text('Last Contact',
                      style:
                          TextStyle(fontSize: 10, color: _kTextSecondary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item?.lastCommunicationDate ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary)),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _labelledAction(
                        Icons.person_add_alt_1_outlined,
                        'Follow-up',
                        _kGreen,
                        _kGreenLight,
                        () => Get.to(const LeadFollowupDetailsView())),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _labelledAction(
                        Icons.history_rounded,
                        'History',
                        _kOrange,
                        _kOrangeLight,
                        () => Get.to(const LeadFolloupHistory())),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _labelledAction(
                        Icons.add_rounded,
                        'Add Item',
                        _kAccent,
                        _kAccentLight,
                        () => Get.to(SelectBrandView())),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    // Was a dead PDF button (onTap did nothing). Now the entry
                    // point to Call / WhatsApp / Notes / Quote / Details.
                    child: _labelledAction(
                        Icons.more_horiz_rounded,
                        'More',
                        _kPrimary,
                        _kPrimaryLight,
                        () => _showLeadActions(context)),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _bracketBox(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: _kAccentLight,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8)),
        border: Border(
            left: BorderSide(color: _kAccent, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: _kTextSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    ),
  );

  Widget _miniField(IconData icon, String label, String value) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 11, color: _kTextSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: _kTextSecondary)),
      ]),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    ]),
  );

  Widget _vDivider() => Container(
      width: 1,
      height: 32,
      color: _kBorder,
      margin: const EdgeInsets.symmetric(horizontal: 8));

  /// Card action with its name under the icon.
  ///
  /// Replaces the old bare `_iconBtn` squares — a person-plus, a clock and a
  /// "…" gave no clue what they did, and the only labelled one was Add Item.
  Widget _labelledAction(IconData icon, String label, Color color, Color bg,
          VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
}