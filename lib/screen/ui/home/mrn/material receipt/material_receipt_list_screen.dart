// // // lib/screens/mrn/material_receipt_list_screen.dart
// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:provider/provider.dart';
// // import '../../constants/app_theme.dart';
// // import '../../providers/mrn_provider.dart';
// // import '../../models/mrn_models.dart';
// // import '../../widgets/common_widgets.dart';
// // import '../../config/app_router.dart';
// // import '../../utils/app_utils.dart';
// //
// // class MaterialReceiptListScreen extends StatefulWidget {
// //   const MaterialReceiptListScreen({super.key});
// //   @override
// //   State<MaterialReceiptListScreen> createState() =>
// //       _MaterialReceiptListScreenState();
// // }
// //
// // class _MaterialReceiptListScreenState
// //     extends State<MaterialReceiptListScreen> {
// //   final _scrollCtrl = ScrollController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _scrollCtrl.addListener(_onScroll);
// //     WidgetsBinding.instance.addPostFrameCallback(
// //             (_) => context.read<MRNProvider>().loadMRNs(refresh: true));
// //   }
// //
// //   void _onScroll() {
// //     if (_scrollCtrl.position.pixels >=
// //         _scrollCtrl.position.maxScrollExtent - 200) {
// //       context.read<MRNProvider>().loadMore();
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _scrollCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final p = context.watch<MRNProvider>();
// //
// //     final completedCount =
// //         p.mrns.where((m) => m.statusId == 3).length;
// //     final pendingCount =
// //         p.mrns.where((m) => m.statusId == 1 || m.statusId == 2).length;
// //     final cancelledCount =
// //         p.mrns.where((m) => m.statusId == 4).length;
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.background,
// //       appBar: AppBar(
// //         title: const Text('Material received at site'),
// //         actions: [
// //           if (p.hasActiveFilters)
// //             TextButton(
// //               onPressed: p.clearFilters,
// //               child: Text('Clear',
// //                   style: AppTextStyles.body
// //                       .copyWith(color: AppColors.error)),
// //             ),
// //           Container(
// //             margin: const EdgeInsets.only(right: 12),
// //             width:  40,
// //             height: 40,
// //             decoration: BoxDecoration(
// //               color:  AppColors.purpleLightest,
// //               borderRadius: BorderRadius.circular(18),
// //             ),
// //             child: IconButton(
// //               padding: EdgeInsets.zero,
// //               icon: const Icon(
// //                 Icons.filter_list_sharp,
// //                 size:  18,
// //                 color: AppColors.purple,
// //               ),
// //               onPressed: () =>
// //                   context.push('/material-receipt/filter'),
// //             ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed:       () => context.push(AppRoutes.addMrn()),
// //         backgroundColor: AppColors.purple,
// //         shape: const CircleBorder(
// //             side: BorderSide(color: AppColors.white, width: 2)),
// //         elevation: 4,
// //         child: const Icon(Icons.add, color: Colors.white, size: 32),
// //       ),
// //       body: p.loading && p.mrns.isEmpty
// //           ? const Center(
// //           child:
// //           CircularProgressIndicator(color: AppColors.purple))
// //           : p.error != null && p.mrns.isEmpty
// //           ? ErrorState(
// //           message: p.error,
// //           onRetry: () => p.loadMRNs(refresh: true))
// //           : RefreshIndicator(
// //         onRefresh: () => p.loadMRNs(refresh: true),
// //         color:     AppColors.purple,
// //         child: ListView(
// //           controller: _scrollCtrl,
// //           padding:
// //           const EdgeInsets.fromLTRB(16, 16, 16, 0),
// //           children: [
// //             //  Stat cards 
// //             Row(children: [
// //               _StatCard(
// //                 count: completedCount,
// //                 label: 'Completed\nReceipt',
// //                 color: AppColors.success,
// //               ),
// //               const SizedBox(width: 6),
// //               _StatCard(
// //                 count: pendingCount,
// //                 label: 'Pending\nReceipt',
// //                 color: AppColors.orange,
// //               ),
// //               const SizedBox(width: 6),
// //               _StatCard(
// //                 count: cancelledCount,
// //                 label: 'Cancelled\nReceipt',
// //                 color: AppColors.error,
// //               ),
// //             ]),
// //             const SizedBox(height: 24),
// //
// //             //  Section heading 
// //             Text('List',
// //                 style: AppTextStyles.h2.copyWith(
// //                     fontWeight: FontWeight.w800)),
// //             const SizedBox(height: 12),
// //
// //             //  Empty state 
// //             if (p.mrns.isEmpty)
// //               EmptyState(
// //                 icon:        Icons.receipt_long_outlined,
// //                 title:       'No Receipts Found',
// //                 subtitle:
// //                 'Material receipts will appear here.',
// //                 actionLabel: 'Create MRN',
// //                 onAction: () =>
// //                     context.push(AppRoutes.addMrn()),
// //               )
// //             else
// //               ...p.mrns.map((mrn) => _ReceiptCard(
// //                 mrn:   mrn,
// //                 onTap: () => context
// //                     .push('/material-receipt/${mrn.mrnId}'),
// //               )),
// //
// //             if (p.loadingMore)
// //               const Padding(
// //                 padding: EdgeInsets.all(16),
// //                 child: Center(
// //                     child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         color: AppColors.purple)),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // //  Stat Card 
// // class _StatCard extends StatelessWidget {
// //   final int    count;
// //   final String label;
// //   final Color  color;
// //   const _StatCard(
// //       {required this.count, required this.label, required this.color});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Expanded(
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color:        AppColors.white,
// //           borderRadius: BorderRadius.circular(18),
// //           border:       Border.all(color: AppColors.border),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Container(
// //               width:     40,
// //               height:    40,
// //               decoration: BoxDecoration(
// //                 color:        color.withValues(alpha: 0.12),
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               alignment: Alignment.center,
// //               child: Text(
// //                 count.toString().padLeft(2, '0'),
// //                 style: AppTextStyles.h2.copyWith(
// //                     color:      color,
// //                     fontWeight: FontWeight.bold),
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(label,
// //                 style: AppTextStyles.body.copyWith(
// //                     color:  AppColors.textPrimary,
// //                     height: 1.3)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // //  Receipt Card 
// // class _ReceiptCard extends StatelessWidget {
// //   final MRN          mrn;
// //   final VoidCallback onTap;
// //   const _ReceiptCard({super.key, required this.mrn, required this.onTap});
// //
// //   // Extract trailing number e.g. "MRN/2026/000008" → "008"
// //   String get _receiptNo {
// //     final match = RegExp(r'\d+$').firstMatch(mrn.mrnNumber);
// //     if (match != null) {
// //       return int.parse(match.group(0)!).toString().padLeft(3, '0');
// //     }
// //     return mrn.mrnNumber;
// //   }
// //
// //   Color get _statusColor {
// //     switch (mrn.statusId) {
// //       case 3:  return AppColors.success;
// //       case 4:  return AppColors.error;
// //       case 2:  return AppColors.orange;
// //       default: return AppColors.info;
// //     }
// //   }
// //
// //   String get _statusLabel {
// //     switch (mrn.statusId) {
// //       case 3:  return 'Completed';
// //       case 4:  return 'Cancelled';
// //       case 2:  return 'Pending';
// //       default: return mrn.status;
// //     }
// //   }
// //
// //   String _fmtDate(DateTime d) =>
// //       '${d.day.toString().padLeft(2, '0')}/'
// //           '${d.month.toString().padLeft(2, '0')}/${d.year}';
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 12),
// //         decoration: BoxDecoration(
// //           color:        AppColors.white,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(
// //             color: mrn.statusId == 2 || mrn.statusId == 1
// //                 ? AppColors.info.withValues(alpha: 0.45)
// //                 : AppColors.border,
// //             width: mrn.statusId == 2 || mrn.statusId == 1
// //                 ? 1.5
// //                 : 1.0,
// //           ),
// //         ),
// //         child: Padding(
// //           padding: const EdgeInsets.all(14),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               //  Row 1: Receipt No. + PDF 
// //               Row(children: [
// //                 RichText(
// //                   text: TextSpan(children: [
// //                     TextSpan(
// //                       text:  'Receipt No.:',
// //                       style: AppTextStyles.body.copyWith(
// //                           color: AppColors.textSecondary),
// //                     ),
// //                     TextSpan(
// //                       text:  _receiptNo,
// //                       style: AppTextStyles.h3.copyWith(
// //                           fontWeight: FontWeight.bold),
// //                     ),
// //                   ]),
// //                 ),
// //                 const Spacer(),
// //                 // PDF icon only — no edit/delete on this screen
// //                 Container(
// //                   width:  34,
// //                   height: 34,
// //                   decoration: BoxDecoration(
// //                     color:        AppColors.errorLight,
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: const Icon(Icons.picture_as_pdf_rounded,
// //                       color: AppColors.error, size: 18),
// //                 ),
// //               ]),
// //
// //               const SizedBox(height: 10),
// //               const Divider(height: 1),
// //               const SizedBox(height: 10),
// //
// //               //  Row 2: Party Name box | Site Name box 
// //               Row(children: [
// //                 Expanded(
// //                   child: _InfoBox(
// //                     label: 'Party Name',
// //                     value: mrn.supplierName?.isNotEmpty == true
// //                         ? mrn.supplierName!
// //                         : '—',
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: _InfoBox(
// //                     label: 'Site Name',
// //                     value: mrn.siteName?.isNotEmpty == true
// //                         ? mrn.siteName!
// //                         : mrn.warehouseName?.isNotEmpty == true
// //                         ? mrn.warehouseName!
// //                         : '—',
// //                   ),
// //                 ),
// //               ]),
// //               const SizedBox(height: 12),
// //
// //               //  Row 3: Job Type : XXX  |  Status badge 
// //               Row(children: [
// //                 RichText(
// //                   text: TextSpan(children: [
// //                     TextSpan(
// //                       text:  'Job Type : ',
// //                       style: AppTextStyles.body.copyWith(
// //                           fontWeight: FontWeight.w600),
// //                     ),
// //                     TextSpan(
// //                       text: mrn.warehouseName?.isNotEmpty == true
// //                           ? mrn.warehouseName!
// //                           : '—',
// //                       style: AppTextStyles.body,
// //                     ),
// //                   ]),
// //                 ),
// //                 const Spacer(),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                       horizontal: 14, vertical: 6),
// //                   decoration: BoxDecoration(
// //                     color:        _statusColor.withValues(alpha: 0.12),
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     _statusLabel,
// //                     style: AppTextStyles.label(
// //                         color:  _statusColor,
// //                         weight: FontWeight.w600),
// //                   ),
// //                 ),
// //               ]),
// //
// //               const SizedBox(height: 10),
// //               const Divider(height: 1),
// //               const SizedBox(height: 10),
// //
// //               //  Row 4: Date | Submitted By 
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(Icons.calendar_today_outlined, size: 14),
// //                       const SizedBox(width: 6),
// //                       Text("Date : ${_fmtDate(mrn.mrnDate)}"),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 6),
// //                   Text(
// //                     "Submitted By : ${mrn.createdByName}",
// //                     style: const TextStyle(color: Colors.grey),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // //  Info Box 
// // class _InfoBox extends StatelessWidget {
// //   final String label;
// //   final String value;
// //   const _InfoBox({required this.label, required this.value});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(
// //           horizontal: 12, vertical: 10),
// //       decoration: BoxDecoration(
// //         color:        AppColors.background,
// //         borderRadius: BorderRadius.circular(8),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(label,
// //               style: AppTextStyles.label(
// //                   color: AppColors.textSecondary)),
// //           const SizedBox(height: 2),
// //           Text(value,
// //               style: AppTextStyles.body
// //                   .copyWith(fontWeight: FontWeight.w600),
// //               maxLines:  1,
// //               overflow:  TextOverflow.ellipsis),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:digitalerp/screen/ui/home/mrn/material%20receipt/material_receipt_filter_screen.dart';
// import 'package:digitalerp/screen/ui/home/mrn/screens/add_mrn_screen.dart';
// import 'package:digitalerp/utils/app_constant_new.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class MaterialReceiptListScreen extends StatelessWidget {
//   const MaterialReceiptListScreen({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () =>Get.to(AddMRNScreen()),
//         backgroundColor: purpleColor,
//         shape:
//             const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
//         elevation: 4,
//         child: const Icon(Icons.add, size: 28, color: Colors.white),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             //  App Bar 
//             Container(
//               color: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Get.back(),
//                     child: const Icon(Icons.arrow_back_ios_new,
//                         color: newTextPrimary, size: 22),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Material received at site',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: newTextPrimary,
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => Get.to(MaterialFilterScreen()),
//                     child: Container(
//                       height: 40,
//                       width: 40,
//                       decoration: BoxDecoration(
//                         color: purpleLightest,
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                       child: const Icon(Icons.filter_list_sharp,
//                           color: purpleColor, size: 20),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             //  Body 
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Stat cards
//                     _statsRow(),
//                     const SizedBox(height: 24),
//
//                     // Section heading
//                     const Text(
//                       'List',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                         color: newTextPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Cards
//                     _receiptCard(
//                       id: '101',
//                       partyName: 'Ravi Traders',
//                       siteName: 'Central Warehouse',
//                       jobType: 'Construction',
//                       date: '27/01/2026',
//                       submittedBy: 'Arun Soni',
//                       status: 'Completed',
//                       statusId: 3,
//                     ),
//                     _receiptCard(
//                       id: '102',
//                       partyName: 'Ravi Traders',
//                       siteName: 'Central Warehouse',
//                       jobType: 'Construction',
//                       date: '27/01/2026',
//                       submittedBy: 'Arun Soni',
//                       status: 'Pending',
//                       statusId: 1,
//                     ),
//                     _receiptCard(
//                       id: '103',
//                       partyName: 'Ravi Traders',
//                       siteName: 'Central Warehouse',
//                       jobType: 'Construction',
//                       date: '27/01/2026',
//                       submittedBy: 'Arun Soni',
//                       status: 'Cancelled',
//                       statusId: 4,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //  Stat row 
//   Widget _statsRow() {
//     return Row(
//       children: [
//         _statCard(
//             '16', 'Completed\nReceipt', newGreenColor, newGreenLightColor),
//         const SizedBox(width: 10),
//         _statCard(
//             '03', 'Pending\nReceipt', newOrangeColor, newOrangeLightColor),
//         const SizedBox(width: 10),
//         _statCard('02', 'Cancelled\nReceipt', newRedColor, newRedLightColor),
//       ],
//     );
//   }
//
//   Widget _statCard(String value, String label, Color color, Color bgColor) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: newBorderColor),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: newTextPrimary,
//                 height: 1.4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //  Receipt card 
//   Widget _receiptCard({
//     required String id,
//     required String partyName,
//     required String siteName,
//     required String jobType,
//     required String date,
//     required String submittedBy,
//     required String status,
//     required int statusId,
//   }) {
//     final Color statusColor = statusId == 3
//         ? newGreenColor
//         : statusId == 4
//             ? newRedColor
//             : newOrangeColor;
//
//     final Color statusBg = statusId == 3
//         ? newGreenLightColor
//         : statusId == 4
//             ? newRedLightColor
//             : newOrangeLightColor;
//
//     final Color borderColor = (statusId == 1 || statusId == 2)
//         ? newBlueColor.withValues(alpha: 0.35)
//         : newBorderColor;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           //  Header: Receipt No. + PDF icon 
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
//             child: Row(
//               children: [
//                 Text(
//                   'Receipt No.: ',
//                   style: TextStyle(
//                       fontSize: 13,
//                       color: newTextSecondary,
//                       fontWeight: FontWeight.w400),
//                 ),
//                 Text(
//                   id,
//                   style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: newTextPrimary),
//                 ),
//                 const Spacer(),
//                 // ← Custom PDF icon image
//                 Image.asset(
//                   'assets/iconsnew/pdfIcon.png',
//                   width: 14,
//                   height: 16,
//                 ),
//               ],
//             ),
//           ),
//
//           const Divider(height: 1, color: Color(0xFFEFF2F7)),
//
//           //  Party Name + Site Name info boxes 
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
//             child: Row(
//               children: [
//                 _infoBox('Party Name', partyName),
//                 const SizedBox(width: 10),
//                 _infoBox('Site Name', siteName),
//               ],
//             ),
//           ),
//
//           //  Job Type + Status badge 
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
//             child: Row(
//               children: [
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       const TextSpan(
//                         text: 'Job Type : ',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: newTextPrimary,
//                         ),
//                       ),
//                       TextSpan(
//                         text: jobType,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: newTextSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: statusBg,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: statusColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 10),
//           const Divider(height: 1, color: Color(0xFFEFF2F7)),
//
//           //  Date + Submitted By — FIXED overflow 
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.calendar_today_outlined,
//                         size: 14, color: newTextSecondary),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Date : $date',
//                       style: const TextStyle(
//                           fontSize: 13, color: newTextSecondary),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Submitted By : $submittedBy',
//                   style: const TextStyle(fontSize: 13, color: newTextSecondary),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _infoBox(String label, String value) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         decoration: BoxDecoration(
//           color: newBlueLightColor,
//           borderRadius: BorderRadius.circular(8),
//           border: Border(
//             left: BorderSide(color: newBlueColor, width: 3),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontSize: 11,
//                     color: newTextSecondary,
//                     fontWeight: FontWeight.w400)),
//             const SizedBox(height: 2),
//             Text(
//               value,
//               style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: newTextPrimary),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
