// import 'package:digitalerp/screen/base/base_controller.dart';
// import 'package:digitalerp/screen/ui/home/attendance/attendance_controller.dart';
// import 'package:digitalerp/screen/ui/home/executive_list/executive_attendance/executive_attendance_controller.dart';
// import 'package:digitalerp/utils/all_screens_dialog_box/executive_attendance_filter/executive_attendance_filter_view.dart';
// import 'package:digitalerp/utils/app_assets.dart';
// import 'package:digitalerp/utils/app_constant_new.dart';
// import 'package:digitalerp/utils/custom_clipper.dart';
// import 'package:digitalerp/utils/dottedline.dart';
// import 'package:digitalerp/utils/my_app_bar_new.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// //  Design tokens 
// const Color _kCard = Colors.white;
// const Color _kText = Color(0xFF1A1A2E);
// const Color _kSub = Color(0xFF888888);
// const Color _kBorder = Color(0xFFE8E8E8);
//
// class ExecutiveAttendanceView extends StatelessWidget {
//   const ExecutiveAttendanceView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ExecutiveAttendanceController>(
//       init: ExecutiveAttendanceController(Get.arguments),
//       builder: (controller) => Scaffold(
//         backgroundColor: const Color(0xFFF5F6FA),
//         body: SafeArea(
//           child: Column(
//             children: [
//               //  App Bar 
//               _appBar(controller),
//
//               //  Content 
//               Expanded(
//                 child: controller.isBusy
//                     ? const Center(
//                         child: CircularProgressIndicator(color: purpleColor))
//                     : (controller.attendanceSummaryData?.isNotEmpty ?? false)
//                         ? _body(controller)
//                         : Center(
//                             child: Text('No Data found',
//                                 style: GoogleFonts.dmSans(color: _kSub))),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   //  App bar with title + filter icon 
//   Widget _appBar(ExecutiveAttendanceController controller) {
//     return Container(
//       color: _kCard,
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () => controller.backTap(),
//             icon: const Icon(Icons.arrow_back_ios_new, color: _kText, size: 22),
//           ),
//           Expanded(
//             child: Text(
//               'Executive Attendance',
//               style: GoogleFonts.dmSans(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: _kText,
//               ),
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.only(right: 12),
//             decoration: BoxDecoration(
//               color: purpleLightest,
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.filter_list_sharp,
//                   color: purpleColor, size: 20),
//               onPressed: () => Get.dialog(ExecutiveAttendanceFilterView()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _body(ExecutiveAttendanceController controller) {
//     final summary = controller.attendanceSummaryData![0];
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           //  Attendance header + date 
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(controller.executiveName,
//                 style: GoogleFonts.dmSans(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   color: _kText,
//                 ),
//               ),
//               // Date chip (shows month from summary)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: _kCard,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: _kBorder),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       summary.month ?? 'N/A',
//                       style: GoogleFonts.dmSans(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: _kText,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Icon(Icons.calendar_today_outlined,
//                         color: purpleColor, size: 18),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           //  Stats grid (3 rows × 2 cols) 
//           _statsGrid(controller),
//           const SizedBox(height: 20),
//
//           //  Attendance detail cards 
//           if (summary.details?.isNotEmpty ?? false)
//             ListView.builder(
//               padding: EdgeInsets.zero,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: summary.details!.length,
//               itemBuilder: (context, index) =>
//                   _attendanceCard(controller, index),
//             ),
//         ],
//       ),
//     );
//   }
//
//   //  2×3 stats grid 
//   Widget _statsGrid(ExecutiveAttendanceController controller) {
//     final item = controller.attendanceSummaryData?[0];
//
//     final stats = [
//       _StatItem(
//           label: 'Total Leave',
//           value: NumberFormatter.format(item?.totalLeave),
//           color: newBlueColor,
//           bg: newBlueLightColor,
//           onTap: null),
//       _StatItem(
//           label: 'Approved Leave',
//           value: NumberFormatter.format(item?.approveLeave),
//           color: newGreenColor,
//           bg: newGreenLightColor,
//           onTap: () => controller.tapOnApprovedLeave()),
//       _StatItem(
//           label: 'Remaining Leave',
//           value: NumberFormatter.format(item?.remainingTotalLeave),
//           color: newOrangeColor,
//           bg: newOrangeLightColor,
//           onTap: null),
//       _StatItem(
//           label: 'Rejected Leave',
//           value: NumberFormatter.format(item?.rejectLeave),
//           color: newRedColor,
//           bg: newRedLightColor,
//           onTap: () => controller.tapOnRejectedLeave()),
//       _StatItem(
//           label: 'Total Present',
//           value: NumberFormatter.format(item?.present),
//           color: newGreenColor,
//           bg: newGreenLightColor,
//           onTap: null),
//       _StatItem(
//           label: 'Total Absent',
//           value: NumberFormatter.format(item?.absent),
//           color: newRedColor,
//           bg: newRedLightColor,
//           onTap: null),
//     ];
//
//     return Column(
//       children: [
//         for (int r = 0; r < stats.length; r += 2)
//           Padding(
//             padding: EdgeInsets.only(bottom: r + 2 < stats.length ? 12 : 0),
//             child: Row(
//               children: [
//                 Expanded(child: _statTile(stats[r])),
//                 const SizedBox(width: 12),
//                 Expanded(child: _statTile(stats[r + 1])),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _statTile(_StatItem s) {
//     return GestureDetector(
//       onTap: s.onTap,
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: _kCard,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: s.bg,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 _fmt(s.value),
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: s.color,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 s.label,
//                 style: GoogleFonts.dmSans(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: _kText,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Pads numeric strings to 2 digits; passes non-numeric as-is
//   String _fmt(String v) {
//     final n = int.tryParse(v);
//     if (n == null) return v;
//     return n.toString().padLeft(2, '0');
//   }
//
//   //  Attendance detail card (Figma style) 
//   Widget _attendanceCard(ExecutiveAttendanceController controller, int index) {
//     final item = controller.attendanceSummaryData![0].details![index];
//     final bool isInProgress = item.outTime == null;
//
//     // Parse battery level for progress bar
//     final int battery = int.tryParse(item.batterylevel?.toString() ?? '0') ?? 0;
//
//     // Format date label  e.g. "Tue, Feb 10, 2026"
//     final String dateLabel = _formatDateLabel(item.date?.toString() ?? '');
//
//     // Status label
//     final String statusLabel = isInProgress ? 'In Progress' : 'Completed';
//     final Color statusBg =
//         isInProgress ? newOrangeLightColor : newGreenLightColor;
//     final Color statusFg = isInProgress ? newOrangeColor : newGreenColor;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           //  Card header: date + status 
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
//             child: Row(
//               children: [
//                 // Blue left accent bar
//                 Container(
//                   width: 4,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: purpleColor,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     dateLabel,
//                     style: GoogleFonts.dmSans(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: _kText,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: statusBg,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     statusLabel,
//                     style: GoogleFonts.dmSans(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: statusFg,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Divider(height: 1, color: _kBorder),
//
//           //  Check-in / Check-out row 
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
//             child: Row(
//               children: [
//                 // Check In
//                 Expanded(
//                   child: _checkInOutBlock(
//                     label: 'Check In',
//                     time: item.inTime ?? 'N/A',
//                   ),
//                 ),
//                 // Vertical divider
//                 Container(
//                   width: 1,
//                   height: 50,
//                   color: _kBorder,
//                   margin: const EdgeInsets.symmetric(horizontal: 8),
//                 ),
//                 // Check Out
//                 Expanded(
//                   child: _checkInOutBlock(
//                     label: 'Check Out',
//                     time: item.outTime ?? (isInProgress ? '–' : 'N/A'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           //  Progress bar 
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//             child: Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: LinearProgressIndicator(
//                     value: battery / 100,
//                     minHeight: 8,
//                     backgroundColor: _kBorder,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       battery > 50 ? newGreenColor : newOrangeColor,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Progress',
//                         style: GoogleFonts.dmSans(fontSize: 11, color: _kSub)),
//                     Text('$battery/100',
//                         style: GoogleFonts.dmSans(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: _kSub)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _checkInOutBlock({required String label, required String time}) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Icon(Icons.location_on_outlined, color: purpleColor, size: 20),
//         const SizedBox(width: 6),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label,
//                 style: GoogleFonts.dmSans(
//                     fontSize: 12, fontWeight: FontWeight.w600, color: _kText)),
//             Text(time, style: GoogleFonts.dmSans(fontSize: 11, color: _kSub)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   /// Formats "dd/MM/yyyy" → "Tue, Feb 10, 2026"
//   String _formatDateLabel(String raw) {
//     try {
//       final parts = raw.split('/');
//       if (parts.length == 3) {
//         final d = DateTime(
//           int.parse(parts[2]),
//           int.parse(parts[1]),
//           int.parse(parts[0]),
//         );
//         const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//         const months = [
//           'Jan',
//           'Feb',
//           'Mar',
//           'Apr',
//           'May',
//           'Jun',
//           'Jul',
//           'Aug',
//           'Sep',
//           'Oct',
//           'Nov',
//           'Dec'
//         ];
//         return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
//       }
//     } catch (_) {}
//     return raw;
//   }
// }
//
// class _StatItem {
//   final String label;
//   final String value;
//   final Color color;
//   final Color bg;
//   final VoidCallback? onTap;
//   const _StatItem({
//     required this.label,
//     required this.value,
//     required this.color,
//     required this.bg,
//     required this.onTap,
//   });
// }

import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/attendance/attendance_controller.dart';
import 'package:digitalerp/screen/ui/home/executive_list/executive_attendance/executive_attendance_controller.dart';
import 'package:digitalerp/utils/all_screens_dialog_box/executive_attendance_filter/executive_attendance_filter_view.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:digitalerp/utils/app_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// fl_chart and performance_tracker_widget imports removed along with the
// Revenue / Users Visits / Recent Orders / Performance sections.

//  Design tokens 
const Color _kCard = Colors.white;
const Color _kText = Color(0xFF1A1A2E);
const Color _kSub = Color(0xFF888888);
const Color _kBorder = Color(0xFFE8E8E8);
const Color _kSurface = Color(0xFFF5F6FA);

class ExecutiveAttendanceView extends StatelessWidget {
  const ExecutiveAttendanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExecutiveAttendanceController>(
      init: ExecutiveAttendanceController(Get.arguments),
      builder: (controller) => Scaffold(
        backgroundColor: _kSurface,
        body: SafeArea(
          child: Column(
            children: [
              _appBar(controller),
              Expanded(
                child: controller.isBusy
                    ? const Center(
                        child: CircularProgressIndicator(color: purpleColor))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //  1. Profile card
                            _profileCard(controller),
                            const SizedBox(height: 20),

                            // Revenue / Users Visits / Recent Orders /
                            // Performance sections and the Total Orders +
                            // Pending Visits stat chips were removed on
                            // request — this screen is attendance-only now.

                            // 2. Attendance section header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _sectionTitle('Attendance'),
                                _datechip(controller),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 3. Attendance stats grid
                            _statsGrid(controller),
                            const SizedBox(height: 20),

                            // 4. Attendance detail cards
                            if (controller.attendanceSummaryData?[0].details
                                    ?.isNotEmpty ??
                                false)
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller
                                    .attendanceSummaryData![0].details!.length,
                                itemBuilder: (context, index) =>
                                    _attendanceCard(controller, index),
                              ),
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

  //  App bar 
  Widget _appBar(ExecutiveAttendanceController controller) {
    return Container(
      color: _kCard,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => controller.backTap(),
            icon: const Icon(Icons.arrow_back_ios_new, color: _kText, size: 22),
          ),
          Expanded(
            child: Text(
              controller.executiveName,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: purpleLightest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list_sharp,
                  color: purpleColor, size: 20),
              onPressed: () => Get.dialog(ExecutiveAttendanceFilterView()),
            ),
          ),
        ],
      ),
    );
  }

  //  Profile card (mirrors DashboardView gradient card) 
  Widget _profileCard(ExecutiveAttendanceController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4361EE), Color(0xFF738EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ProfileImageView(
            size: 52,
            imageUrl: controller.executivePhoto,
            borderSize: 2,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.executiveName,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  controller.executiveDesignation,
                  style:
                      GoogleFonts.dmSans(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  Section title 
  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w800, color: _kText),
      );

  //  Date chip 
  Widget _datechip(ExecutiveAttendanceController controller) {
    final summary = controller.attendanceSummaryData?[0];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            summary?.month ?? 'N/A',
            style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: _kText),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.calendar_today_outlined,
              color: purpleColor, size: 18),
        ],
      ),
    );
  }

  //  Attendance stats grid (existing, unchanged) 
  Widget _statsGrid(ExecutiveAttendanceController controller) {
    final item = controller.attendanceSummaryData?[0];

    final stats = [
      _StatItem(
          label: 'Total Leave',
          value: NumberFormatter.format(item?.totalLeave),
          color: newBlueColor,
          bg: newBlueLightColor,
          onTap: null),
      _StatItem(
          label: 'Approved Leave',
          value: NumberFormatter.format(item?.approveLeave),
          color: newGreenColor,
          bg: newGreenLightColor,
          onTap: () => controller.tapOnApprovedLeave()),
      _StatItem(
          label: 'Remaining Leave',
          value: NumberFormatter.format(item?.remainingTotalLeave),
          color: newOrangeColor,
          bg: newOrangeLightColor,
          onTap: null),
      _StatItem(
          label: 'Rejected Leave',
          value: NumberFormatter.format(item?.rejectLeave),
          color: newRedColor,
          bg: newRedLightColor,
          onTap: () => controller.tapOnRejectedLeave()),
      _StatItem(
          label: 'Total Present',
          value: NumberFormatter.format(item?.present),
          color: newGreenColor,
          bg: newGreenLightColor,
          onTap: null),
      _StatItem(
          label: 'Total Absent',
          value: NumberFormatter.format(item?.absent),
          color: newRedColor,
          bg: newRedLightColor,
          onTap: null),
    ];

    return Column(
      children: [
        for (int r = 0; r < stats.length; r += 2)
          Padding(
            padding: EdgeInsets.only(bottom: r + 2 < stats.length ? 12 : 0),
            child: Row(
              children: [
                Expanded(child: _statTile(stats[r])),
                const SizedBox(width: 12),
                Expanded(child: _statTile(stats[r + 1])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _statTile(_StatItem s) {
    return GestureDetector(
      onTap: s.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: s.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                _fmt(s.value),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: s.color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s.label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(String v) {
    final n = int.tryParse(v);
    if (n == null) return v;
    return n.toString().padLeft(2, '0');
  }

  //  Attendance detail card (existing, unchanged) 
  Widget _attendanceCard(ExecutiveAttendanceController controller, int index) {
    final item = controller.attendanceSummaryData![0].details![index];
    final bool isInProgress = item.outTime == null;
    final int battery = int.tryParse(item.batterylevel?.toString() ?? '0') ?? 0;
    final String dateLabel = _formatDateLabel(item.date?.toString() ?? '');
    final String statusLabel = isInProgress ? 'In Progress' : 'Completed';
    final Color statusBg =
        isInProgress ? newOrangeLightColor : newGreenLightColor;
    final Color statusFg = isInProgress ? newOrangeColor : newGreenColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: purpleColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(dateLabel,
                      style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kText)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusLabel,
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusFg)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _kBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Expanded(
                    child: _checkInOutBlock(
                        label: 'Check In', time: item.inTime ?? 'N/A')),
                Container(
                    width: 1,
                    height: 50,
                    color: _kBorder,
                    margin: const EdgeInsets.symmetric(horizontal: 8)),
                Expanded(
                    child: _checkInOutBlock(
                        label: 'Check Out',
                        time: item.outTime ?? (isInProgress ? '–' : 'N/A'))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: battery / 100,
                    minHeight: 8,
                    backgroundColor: _kBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      battery > 50 ? newGreenColor : newOrangeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress',
                        style: GoogleFonts.dmSans(fontSize: 11, color: _kSub)),
                    Text('$battery/100',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _kSub)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkInOutBlock({required String label, required String time}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on_outlined, color: purpleColor, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _kText)),
            Text(time, style: GoogleFonts.dmSans(fontSize: 11, color: _kSub)),
          ],
        ),
      ],
    );
  }

  String _formatDateLabel(String raw) {
    try {
      final parts = raw.split('/');
      if (parts.length == 3) {
        final d = DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
      }
    } catch (_) {}
    return raw;
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final VoidCallback? onTap;
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    required this.onTap,
  });
}
