import 'package:digitalerp/utils/lead_app_bar.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/controller/get_all_quotation_controller.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CallLogsScreen extends StatefulWidget {
  final GetleadentryList lead;

  const CallLogsScreen({super.key, required this.lead});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  final getAllQuotationController = Get.put(GetAllQuotationController());
  final TextEditingController _searchController = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;
  List filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialLogs(); // load last 30 days on first open
  }

  Future<void> _fetchInitialLogs() async {
    await getAllQuotationController.getCallLogsFromApi(
        leadId: widget.lead.leadEntryId);
    setState(() {
      filteredLogs = getAllQuotationController.getAllCallLogsData;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: fromDate ?? now.subtract(const Duration(days: 30)),
        end: toDate ?? now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: newBlueColor,
              onPrimary: Colors.white,
              onSurface: newTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      fromDate = picked.start;
      toDate = picked.end;

      await getAllQuotationController.getCallLogsFromApi(
        leadId: widget.lead.leadEntryId,
        fromDate: fromDate,
        toDate: toDate,
      );

      setState(() {
        filteredLogs = getAllQuotationController.getAllCallLogsData;
      });
    }
  }

  void _filterSearch(String query) {
    final allLogs = getAllQuotationController.getAllCallLogsData;
    setState(() {
      filteredLogs = allLogs.where((log) {
        final phone = log.phoneNumber?.toLowerCase() ?? '';
        final type = log.callType?.toLowerCase() ?? '';
        return phone.contains(query.toLowerCase()) ||
            type.contains(query.toLowerCase());
      }).toList();
    });
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  String _formatDuration(String? duration) {
    if (duration == null) return "0 sec";
    final parts = duration.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final s = int.parse(parts[2]);
    final d = Duration(hours: h, minutes: m, seconds: s);
    if (d.inMinutes > 0) return "${d.inMinutes} min";
    return "${d.inSeconds} sec";
  }

  Widget _getCallIcon(String type) {
    Color color;
    Color bg;
    IconData icon;
    switch (type.toLowerCase()) {
      case 'incoming':
        icon = Icons.call_received;
        color = newGreenColor;
        bg = newGreenLightColor;
        break;
      case 'outgoing':
        icon = Icons.call_made;
        color = newBlueColor;
        bg = newBlueLightColor;
        break;
      case 'missed':
        icon = Icons.call_missed;
        color = newRedColor;
        bg = newRedLightColor;
        break;
      default:
        icon = Icons.call;
        color = newTextSecondary;
        bg = newSurfaceColor;
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List> grouped = {};
    for (var log in filteredLogs) {
      final callTime = log.callDateTime ?? DateTime.now();
      final label = _getDayLabel(callTime);
      grouped.putIfAbsent(label, () => []).add(log);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            LeadAppBar(
              title: 'Call Logs',
              subtitle: widget.lead.leadName,
              actions: [
                leadAppBarAction(Icons.date_range_rounded, _pickDateRange),
              ],
            ),
            Expanded(
              child: Obx(
                () => getAllQuotationController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: newBorderColor),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.search,
                                      color: newTextHint, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: _filterSearch,
                                      decoration: InputDecoration(
                                        hintText: 'Search by number or type',
                                        hintStyle: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: newTextHint),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (fromDate != null && toDate != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                "Showing: ${DateFormat('dd MMM').format(fromDate!)} → ${DateFormat('dd MMM yyyy').format(toDate!)}",
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: newTextSecondary),
                              ),
                            ),
                          Expanded(
                            child: filteredLogs.isEmpty
                                ? Center(
                                    child: Text(
                                      "No call logs found",
                                      style: GoogleFonts.poppins(
                                          color: newTextSecondary),
                                    ),
                                  )
                                : ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    children:
                                        grouped.entries.map((entry) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8),
                                            child: Text(
                                              entry.key,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: newTextPrimary,
                                              ),
                                            ),
                                          ),
                                          ...entry.value.map((log) {
                                            final callTime =
                                                log.callDateTime ??
                                                    DateTime.now();

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        14),
                                                border: Border.all(
                                                    color: newBorderColor),
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      newBlueLightColor,
                                                  child: Icon(Icons.call,
                                                      color: newBlueColor,
                                                      size: 20),
                                                ),
                                                title: Text(
                                                  log.phoneNumber ??
                                                      'Unknown',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          newTextPrimary),
                                                ),
                                                subtitle: Text(
                                                  "${DateFormat('hh:mm a').format(callTime)} · ${_formatDuration(log.duration)}",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color:
                                                          newTextSecondary),
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final uri = Uri(
                                                            scheme: 'tel',
                                                            path: log
                                                                .phoneNumber);
                                                        if (await canLaunchUrl(
                                                            uri)) {
                                                          await launchUrl(
                                                              uri);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              newGreenLightColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8),
                                                        ),
                                                        child: Icon(
                                                            Icons.phone,
                                                            color:
                                                                newGreenColor,
                                                            size: 16),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    _getCallIcon(
                                                        log.callType ?? ''),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
