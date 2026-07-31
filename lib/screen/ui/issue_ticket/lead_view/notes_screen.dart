import 'dart:convert';
import 'dart:developer';

import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'controller/lead_management_controller.dart';

class LeadRemarksScreen extends StatefulWidget {
  final GetleadentryList lead;
  final String type;

  const LeadRemarksScreen({
    super.key,
    required this.lead,
    required this.type,
  });

  @override
  State<LeadRemarksScreen> createState() => _LeadRemarksScreenState();
}

class _LeadRemarksScreenState extends State<LeadRemarksScreen> {
  final LeadViewController controller =
      Get.put(LeadViewController());

  @override
  void initState() {
    super.initState();
    controller.getRemarks(widget.lead.leadEntryId, widget.type);
  }

  Future<void> _add() async {
    final text = controller.descController.text.trim();

    if (text.isEmpty) {
      Get.snackbar(
        'Empty Remark',
        'Please enter a remark before sending.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    controller.selectedDateTime ??= DateTime.now();

    await controller.insertRemark(widget.lead.leadEntryId, widget.type);
    await controller.getRemarks(widget.lead.leadEntryId, widget.type);

    controller.descController.clear();
    controller.selectedDateTime = null;
  }

  String formatted = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: GetBuilder<LeadViewController>(
        builder: (_) {
          final items = controller.remarksList;
          return SafeArea(
            child: Column(
              children: [
                // App bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back_ios_new,
                            color: newTextPrimary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${widget.type} - ${widget.lead.leadName}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: newTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // List of remarks
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                          ? Center(
                              child: Text(
                                'No ${widget.type.toLowerCase()} yet',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: newTextSecondary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              itemBuilder: (_, i) {
                                final r = items[i];
                                log('r=================>>>>>${jsonEncode(r)}');
                                final rawDate = r.followUpDate ?? '';
                                final rawTime = r.followUpTime ?? '';
                                if (rawDate.isNotEmpty &&
                                    rawTime.isNotEmpty) {
                                  try {
                                    // Combine date & time into a single string
                                    final dateTimeString =
                                        '${rawDate.split(' ').first} $rawTime';

                                    // Parse into DateTime
                                    final dateTime = DateTime.parse(
                                        DateFormat('M/d/yyyy HH:mm:ss')
                                            .parse(dateTimeString)
                                            .toIso8601String());

                                    formatted =
                                        '${DateFormat('M/d/yyyy').format(dateTime)}  ${DateFormat('h:mm a').format(dateTime)}';
                                  } catch (e) {
                                    // fallback if parsing fails
                                    formatted = '$rawDate  $rawTime';
                                  }
                                }
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: newBorderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: newBlueColor,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                r.remarks ?? '',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color: newTextPrimary),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      size: 12,
                                                      color:
                                                          newTextSecondary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    formatted,
                                                    style:
                                                        GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            color:
                                                                newTextSecondary),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await controller.deleteRemark(
                                                r.id, widget.type);
                                            await controller.getRemarks(
                                                widget.lead.leadEntryId,
                                                widget.type);
                                          },
                                          child: Container(
                                            padding:
                                                const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: newRedLightColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                                Icons.delete_outline,
                                                color: newRedColor,
                                                size: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),

                // Input section
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: newBorderColor)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${DateFormat('yyyy/MM/dd').format(DateTime.now())}\n${DateFormat('h:mm a').format(DateTime.now())}",
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: newTextSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller.descController,
                          decoration: InputDecoration(
                            hintText: controller.selectedDateTime == null
                                ? 'Select date & time first'
                                : 'Add ${widget.type.toLowerCase()}',
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 13, color: newTextHint),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _add,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: purpleColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.send,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
