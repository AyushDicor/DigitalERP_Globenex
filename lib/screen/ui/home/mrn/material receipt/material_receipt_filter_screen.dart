// // // lib/screens/mrn/material_receipt_filter_screen.dart
// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:provider/provider.dart';
// // import '../../constants/app_theme.dart';
// // import '../../providers/mrn_provider.dart';
// //
// // class MaterialReceiptFilterScreen extends StatefulWidget {
// //   const MaterialReceiptFilterScreen({super.key});
// //   @override
// //   State<MaterialReceiptFilterScreen> createState() =>
// //       _MaterialReceiptFilterScreenState();
// // }
// //
// // class _MaterialReceiptFilterScreenState
// //     extends State<MaterialReceiptFilterScreen> {
// //   DateTime? _fromDate = DateTime(2026, 1, 20);
// //   DateTime? _toDate = DateTime(2026, 1, 27);
// //   int? _partyId;
// //   int? _siteId;
// //   int? _jobTypeId;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback(
// //             (_) => context.read<MRNProvider>().loadDropdowns());
// //   }
// //
// //   Future<void> _pickDate(bool isFrom) async {
// //     final initial =
// //     isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: initial,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //       builder: (ctx, child) => Theme(
// //         data: Theme.of(ctx).copyWith(
// //             colorScheme: const ColorScheme.light(primary: AppColors.purple)),
// //         child: child!,
// //       ),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         if (isFrom)
// //           _fromDate = picked;
// //         else
// //           _toDate = picked;
// //       });
// //     }
// //   }
// //
// //   String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
// //       '${d.month.toString().padLeft(2, '0')}/${d.year}';
// //
// //   void _apply() {
// //     context.read<MRNProvider>().setFilters(
// //       partyId: _partyId,
// //       siteId: _siteId,
// //       jobTypeId: _jobTypeId,
// //       fromDate: _fromDate,
// //       toDate: _toDate,
// //     );
// //     context.pop();
// //   }
// //
// //   void _reset() {
// //     setState(() {
// //       _fromDate = null;
// //       _toDate = null;
// //       _partyId = null;
// //       _siteId = null;
// //       _jobTypeId = null;
// //     });
// //     context.read<MRNProvider>().clearFilters();
// //     context.pop();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final p = context.watch<MRNProvider>();
// //     final parties = p.parties;
// //     final sites = p.sites;
// //     final jobTypes = p.jobTypes;
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.background,
// //       appBar: PreferredSize(
// //         preferredSize: const Size.fromHeight(60),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             boxShadow: [
// //               BoxShadow(
// //                 color: AppColors.borderDark,
// //                 blurRadius: 12,
// //                 offset: const Offset(0, 3),
// //               ),
// //             ],
// //           ),
// //           child: SafeArea(
// //             bottom: false,
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 4),
// //               child: Row(
// //                 children: [
// //                   IconButton(
// //                     icon:
// //                     const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
// //                     color: AppColors.textPrimary,
// //                     onPressed: () => context.pop(),
// //                   ),
// //                   Expanded(
// //                     child: Text(
// //                       'Filter',
// //                       style: AppTextStyles.h2
// //                           .copyWith(fontSize: 22, fontWeight: FontWeight.w800),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
// //               child: Column(
// //                 children: [
// //                   //  Date range 
// //                   Row(children: [
// //                     Expanded(
// //                       child: _DateBox(
// //                         label: _fromDate != null
// //                             ? _fmtDate(_fromDate!)
// //                             : 'From Date',
// //                         onTap: () => _pickDate(true),
// //                       ),
// //                     ),
// //                     Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 10),
// //                       child: Text('to',
// //                           style: AppTextStyles.body
// //                               .copyWith(color: AppColors.textSecondary)),
// //                     ),
// //                     Expanded(
// //                       child: _DateBox(
// //                         label: _toDate != null ? _fmtDate(_toDate!) : 'To Date',
// //                         onTap: () => _pickDate(false),
// //                       ),
// //                     ),
// //                   ]),
// //                   const SizedBox(height: 16),
// //
// //                   //  Party Name 
// //                   _FilterDropdown<int>(
// //                     label: 'Party Name',
// //                     value: _partyId,
// //                     items: parties
// //                         .map((p) => DropdownMenuItem<int>(
// //                       value: p['PartyID'] as int,
// //                       child: Text(p['PartyName']?.toString() ?? '',
// //                           style: AppTextStyles.body),
// //                     ))
// //                         .toList(),
// //                     onChanged: parties.isEmpty
// //                         ? null
// //                         : (v) => setState(() => _partyId = v),
// //                   ),
// //                   const SizedBox(height: 16),
// //
// //                   //  Site Name 
// //                   _FilterDropdown<int>(
// //                     label: 'Site Name',
// //                     value: _siteId,
// //                     items: sites
// //                         .map((s) => DropdownMenuItem<int>(
// //                       value: s['SiteID'] as int,
// //                       child: Text(s['SiteName']?.toString() ?? '',
// //                           style: AppTextStyles.body),
// //                     ))
// //                         .toList(),
// //                     onChanged: sites.isEmpty
// //                         ? null
// //                         : (v) => setState(() => _siteId = v),
// //                   ),
// //                   const SizedBox(height: 16),
// //
// //                   //  Job Type 
// //                   _FilterDropdown<int>(
// //                     label: 'Job Type',
// //                     value: _jobTypeId,
// //                     items: jobTypes
// //                         .map((j) => DropdownMenuItem<int>(
// //                       value: j['JobTypeID'] as int,
// //                       child: Text(j['JobTypeName']?.toString() ?? '',
// //                           style: AppTextStyles.body),
// //                     ))
// //                         .toList(),
// //                     onChanged: jobTypes.isEmpty
// //                         ? null
// //                         : (v) => setState(() => _jobTypeId = v),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //
// //           //  Bottom buttons 
// //           Container(
// //             padding: EdgeInsets.only(
// //               left: 20,
// //               right: 20,
// //               top: 16,
// //               bottom: MediaQuery.of(context).padding.bottom + 16,
// //             ),
// //             decoration: const BoxDecoration(
// //               color: AppColors.surface,
// //               border: Border(top: BorderSide(color: AppColors.border)),
// //             ),
// //             child: Row(children: [
// //               Expanded(
// //                 child: OutlinedButton(
// //                   onPressed: _reset,
// //                   style: OutlinedButton.styleFrom(
// //                     foregroundColor: AppColors.purple,
// //                     minimumSize: const Size(double.infinity, 52),
// //                     side: const BorderSide(color: AppColors.purple),
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(18)),
// //                   ),
// //                   child: Text('Reset',
// //                       style: AppTextStyles.button(color: AppColors.purple)),
// //                 ),
// //               ),
// //               const SizedBox(width: 14),
// //               Expanded(
// //                 child: ElevatedButton(
// //                   onPressed: _apply,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.primaryBlue,
// //                     foregroundColor: Colors.white,
// //                     minimumSize: const Size(double.infinity, 52),
// //                     elevation: 0,
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(18)),
// //                   ),
// //                   child: Text('Apply',
// //                       style: AppTextStyles.button(color: Colors.white)),
// //                 ),
// //               ),
// //             ]),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // //  Date Box 
// // class _DateBox extends StatelessWidget {
// //   final String label;
// //   final VoidCallback onTap;
// //   const _DateBox({required this.label, required this.onTap});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
// //         decoration: BoxDecoration(
// //           color: AppColors.white,
// //           borderRadius: BorderRadius.circular(18),
// //           boxShadow: [
// //             BoxShadow(
// //               color: const Color(0x12000000),
// //               blurRadius: 8,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Row(children: [
// //           Expanded(
// //             child: Text(label,
// //                 style: AppTextStyles.bodyMedium.copyWith(fontSize: 15)),
// //           ),
// //           const Icon(Icons.calendar_today_outlined,
// //               size: 18, color: AppColors.textSecondary),
// //         ]),
// //       ),
// //     );
// //   }
// // }
// //
// // //  Filter Dropdown 
// // class _FilterDropdown<T> extends StatelessWidget {
// //   final String label;
// //   final T? value;
// //   final List<DropdownMenuItem<T>> items;
// //   final ValueChanged<T?>? onChanged;
// //
// //   const _FilterDropdown({
// //     required this.label,
// //     required this.value,
// //     required this.items,
// //     required this.onChanged,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: AppColors.white,
// //         borderRadius: BorderRadius.circular(18),
// //         boxShadow: [
// //           BoxShadow(
// //             color: const Color(0x12000000),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: DropdownButtonHideUnderline(
// //         child: DropdownButton<T>(
// //           value: value,
// //           isExpanded: true,
// //           hint: Text(label,
// //               style: AppTextStyles.body
// //                   .copyWith(fontSize: 16, color: AppColors.textPrimary)),
// //           icon: const Icon(Icons.keyboard_arrow_down_rounded,
// //               size: 26, color: AppColors.textSecondary),
// //           items: items.isEmpty ? [] : items,
// //           onChanged: onChanged,
// //           style: AppTextStyles.body.copyWith(fontSize: 15),
// //           disabledHint: Text(label,
// //               style: AppTextStyles.body
// //                   .copyWith(fontSize: 15, color: AppColors.textPrimary)),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// class MaterialFilterScreen extends StatelessWidget {
//   const MaterialFilterScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FA),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _appBar(context),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20),
//
//                     // 🔹 Date Range
//                     Row(
//                       children: [
//                         Expanded(child: _dateBox("20/01/2026")),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           child: Text("to"),
//                         ),
//                         Expanded(child: _dateBox("27/01/2026")),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     _dropdownBox("Party Name"),
//                     const SizedBox(height: 14),
//
//                     _dropdownBox("Site Name"),
//                     const SizedBox(height: 14),
//
//                     _dropdownBox("Job Type"),
//
//                     const Spacer(),
//
//                     // 🔹 Bottom Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _outlineButton("Reset"),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _filledButton("Apply"),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
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
//   // 🔹 AppBar
//   Widget _appBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: const Icon(Icons.arrow_back_ios_new, size: 20),
//           ),
//           const SizedBox(width: 10),
//           const Text(
//             "Filter",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🔹 Date Box
//   Widget _dateBox(String date) {
//     return Container(
//       height: 56,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 8,
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           Text(
//             date,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const Spacer(),
//           const Icon(Icons.calendar_today, size: 18),
//         ],
//       ),
//     );
//   }
//
//   // 🔹 Dropdown Box
//   Widget _dropdownBox(String title) {
//     return Container(
//       height: 56,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 8,
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 14),
//           ),
//           const Spacer(),
//           Container(
//             height: 30,
//             width: 30,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF0F1F5),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.keyboard_arrow_down),
//           )
//         ],
//       ),
//     );
//   }
//
//   // 🔹 Buttons
//   Widget _outlineButton(String text) {
//     return Container(
//       height: 55,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         border: Border.all(color: const Color(0xFF4F6EF7)),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Color(0xFF4F6EF7),
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Widget _filledButton(String text) {
//     return Container(
//       height: 55,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: const Color(0xFF4F6EF7),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }