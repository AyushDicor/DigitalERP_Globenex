import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controller/lead_management_controller.dart';

class FollowUpsScreen extends StatefulWidget {
  final GetleadentryList lead;
  const FollowUpsScreen({super.key, required this.lead});

  @override
  State<FollowUpsScreen> createState() => _FollowUpsScreenState();
}

class _FollowUpsScreenState extends State<FollowUpsScreen> {
  final LeadViewController controller =
      Get.put(LeadViewController());

  @override
  void initState() {
    super.initState();
    // Fetch all follow-ups from the API when screen opens
    controller.gettingFollowUp(widget.lead.leadEntryId);
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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
    if (pickedDate != null) {
      final pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        controller.selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        controller.update();
      }
    }
  }

  Future<void> _addFollowup() async {
    if (controller.descController.text.trim().isEmpty ||
        controller.selectedDateTime == null) return;

    await controller.insertedLeadFollowUp(widget.lead.leadEntryId);
    await controller.gettingFollowUp(widget.lead.leadEntryId);

    controller.descController.clear();
    controller.selectedDateTime = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: GetBuilder<LeadViewController>(
        builder: (_) {
          final followups = controller.dataFollowups;

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
                          'Follow-ups - ${widget.lead.leadName}',
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: newTextPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : followups.isEmpty
                          ? Center(
                              child: Text(
                                'No follow-ups yet',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: newTextSecondary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: followups.length,
                              itemBuilder: (context, index) {
                                final f = followups[index];
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
                                                f.remarks ?? '',
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
                                                    '${f.followUpDate ?? ''}  ${f.followUpTime ?? ''}',
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
                                            await controller
                                                .deleteFollowUpsNotes(f.id);
                                            await controller.gettingFollowUp(
                                                widget.lead.leadEntryId);
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

                // Input bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: newBorderColor)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: newBlueLightColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.calendar_today_outlined,
                              color: newBlueColor, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller.descController,
                          decoration: InputDecoration(
                            hintText: controller.selectedDateTime == null
                                ? 'Select date & time first'
                                : 'Add follow-up description',
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 13, color: newTextHint),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _addFollowup,
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
