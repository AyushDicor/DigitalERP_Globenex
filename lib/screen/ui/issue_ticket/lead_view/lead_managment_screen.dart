import 'dart:convert';
import 'dart:developer';

import 'package:digitalerp/model/current_software_lead_reponse_model.dart';
import 'package:digitalerp/model/decision_timeline_response_model.dart';
import 'package:digitalerp/model/get_lead_detail_from_id_response_model.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/model/lead_businesstype_response_model.dart';
import 'package:digitalerp/model/lead_industry_response_model.dart';
import 'package:digitalerp/model/lead_interested_response_model.dart';
import 'package:digitalerp/model/lead_sources_response_model.dart';
import 'package:digitalerp/model/lead_tag_products_response_model.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
// This app's app_constant.dart also declares the new* tokens — hide them here
// so the app_constant_new versions win, as the screen intends.
import 'package:digitalerp/utils/app_constant.dart'
    hide newTextPrimary, newBlueColor, newBlueLightColor;
import 'package:digitalerp/utils/app_constant_new.dart'
    show newTextPrimary, newBlueColor, newBlueLightColor;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'controller/lead_management_controller.dart';
import 'tag_products_screen.dart';
import 'view_lead_screen.dart';

class LeadManagementScreen extends StatefulWidget {
  final GetleadentryList? editLead;

  const LeadManagementScreen({super.key, this.editLead});

  @override
  State<LeadManagementScreen> createState() => _LeadManagementScreenState();
}

class _LeadManagementScreenState extends State<LeadManagementScreen> {
  final LeadViewController controller =
      Get.put(LeadViewController());
  HomeController homeController = Get.find<HomeController>();
  final formKey = GlobalKey<FormState>();

  bool isLoading = true; // track API loading

  @override
  void initState() {
    super.initState();
    controller.clearLeadData();
    loadApiData();
  }

  Future<void> loadApiData() async {
    await Future.wait([
      controller.businessTypeList(),
      controller.leadIndustryTypeList(),
      controller.leadInterestedTypeList(),
      controller.interestedInApiMethod(),
      controller.currentSoftwareApiMethod(),
      controller.decisionTimelineApiMethod(),
      controller.leadSources(),
      controller.fetchAgentPartyList(),
    ]);

    if (widget.editLead != null) {
      loadLeadData(widget.editLead!);
    } else {
      controller.clearLeadData();
    }

    setState(() {
      isLoading = false;
    });
  }

  void loadLeadData(GetleadentryList lead) {
    log('lead for soureces=================>>>>>${jsonEncode(lead)}');
    controller.nameController.text = lead.leadName ?? "";
    controller.companyController.text = lead.companyName ?? "";
    controller.mobileController.text = lead.mobileNo ?? "";
    controller.altContactController.text = lead.alternateMobile ?? "";
    controller.emailController.text = lead.email ?? "";
    controller.websiteController.text = lead.website ?? "";
    controller.leadDateController.text = lead.leadDate ?? "";
    controller.lastCommDateController.text = lead.lastCommunicationDate ?? "";
    controller.remarksController.text = lead.requirement ?? "";
    controller.addressController.text = lead.address ?? "";

    // Business Type
    final business = controller.leadBusinessData.firstWhere(
      (e) => e.businessTypeid == lead.businessTypeId,
      orElse: () => LeadBusinessList(businessTypeid: 0, businessType: ''),
    );
    controller.businessType = business.businessType;
    controller.selectedBusinessTypeId = lead.businessTypeId;

    // Industry Type
    final industry = controller.leadIndustryListData.firstWhere(
      (e) => e.industryTypeid == lead.industryTypeId,
      orElse: () => LeadIndustry(industryTypeid: 0, industryType: ''),
    );
    controller.industryType = industry.industryType;
    controller.selectedIndustryTypeId = lead.industryTypeId;

    // Interested In
    final interested = controller.interestedDataList.firstWhere(
      (e) => e.currentSoftwareid == lead.interestedInId,
      orElse: () => InterestedData(currentSoftwareid: 0, currentSoftware: ''),
    );
    controller.interestedIn = interested.currentSoftware;
    controller.interestedTypeId = lead.interestedInId;

    final sources = controller.leadSourcesList.firstWhere(
      (e) => e.sourceid == lead.sourceId,
      orElse: () => LeadSourcesData(sourceid: 0, sourcename: ''),
    );
    controller.sourcesType = sources.sourcename;
    controller.sourcesId = lead.sourceId;

    // Current Software
    final software = controller.currantSoftwareList.firstWhere(
      (e) => e.decisionTimelineid == lead.currentSoftwareId,
      orElse: () =>
          CurrantSoftware(decisionTimelineid: 0, decisionTimeline: ''),
    );
    controller.selectCurrentSoftwareName = software.decisionTimeline;
    controller.selectCurrentSoftwareId = lead.currentSoftwareId;

    // Decision Timeline
    final timeline = controller.decisionTimelineList.firstWhere(
      (e) => e.decisionTimelineid == lead.decisionTimeId,
      orElse: () =>
          DecisionTimelineList(decisionTimelineid: 0, decisionTimeline: ''),
    );
    controller.selectDecisionTimelineName = timeline.decisionTimeline;
    controller.selectDecisionTimelineId = lead.decisionTimeId;

    // Lead Items
    if (lead.leadItems.isNotEmpty) {
      controller.previouslySelectedItems = lead.leadItems
          .map((e) => TagProducts(
                itemid: e.itemId,
                itemname: e.itemName,
                quantity: int.parse(e.quantity.toString()) ?? 0,
                rate: e.salesPrice,
              ))
          .toList();

      controller.tagProducts.text = controller.previouslySelectedItems
          .map((e) => '${e.itemname} x${e.quantity} @₹${e.rate}')
          .join(', ');
    }

    controller.update();
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: purpleColor),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: whiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: purpleColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: GoogleFonts.poppins(
          color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
    );
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return "$fieldName is required";
    return null;
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final scaffoldKeys = GlobalKey<ScaffoldState>();

  // Example validator
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter mobile number';
    } else if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
        return "Enter valid email";
      }
    }
    return null;
  }

  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  String getAgeing() {
    if (controller.leadDateController.text.isEmpty) return "-";
    try {
      final leadDate =
          DateFormat('yyyy-MM-dd').parse(controller.leadDateController.text);
      controller.days = DateTime.now().difference(leadDate).inDays;
      return "${controller.days} days";
    } catch (_) {
      return "-";
    }
  }

  @override
  void dispose() {
    super.dispose();
    // clearLeadData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadViewController>(
      builder: (ctrl) {
        if (isLoading) {
          return Scaffold(
            key: scaffoldKeys,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Build dropdown lists and ensure selected values exist
        final businessItems = {
          if (ctrl.businessType != null && ctrl.businessType!.isNotEmpty)
            ctrl.businessType!,
          ...ctrl.leadBusinessData.map((e) => e.businessType ?? ''),
        }.toSet().toList();
        final sourcesItems = {
          if (ctrl.sourcesType != null && ctrl.sourcesType!.isNotEmpty)
            ctrl.sourcesType!,
          ...ctrl.leadSourcesList.map((e) => e.sourcename ?? ''),
        }.toSet().toList();

        if (ctrl.businessType != null &&
            ctrl.businessType!.isNotEmpty &&
            !businessItems.contains(ctrl.businessType)) {
          businessItems.insert(0, ctrl.businessType!);
        }

        final industryItems = [
          ...ctrl.leadIndustryListData.map((e) => e.industryType ?? ''),
        ];

        if (ctrl.industryType != null &&
            ctrl.industryType!.isNotEmpty &&
            !industryItems.contains(ctrl.industryType)) {
          industryItems.insert(0, ctrl.industryType!);
        }

        final interestedItems = [
          ...ctrl.interestedDataList
              .map((e) => e.currentSoftware)
              .whereType<String>(), // remove nulls
        ];

        if (ctrl.interestedIn != null &&
            ctrl.interestedIn!.isNotEmpty &&
            !interestedItems.contains(ctrl.interestedIn)) {
          interestedItems.insert(0, ctrl.interestedIn!);
        }

        final currentSoftwareList = [
          ...ctrl.currantSoftwareList.map((e) => e.decisionTimeline ?? ''),
        ];
        if (ctrl.selectCurrentSoftwareName != null &&
            ctrl.selectCurrentSoftwareName!.isNotEmpty &&
            !currentSoftwareList.contains(ctrl.selectCurrentSoftwareName)) {
          currentSoftwareList.insert(0, ctrl.selectCurrentSoftwareName!);
        }

        final decisionTimelineList = [
          ...ctrl.decisionTimelineList.map((e) => e.decisionTimeline ?? ''),
        ];
        if (ctrl.selectDecisionTimelineName != null &&
            ctrl.selectDecisionTimelineName!.isNotEmpty &&
            !decisionTimelineList.contains(ctrl.selectDecisionTimelineName)) {
          decisionTimelineList.insert(0, ctrl.selectDecisionTimelineName!);
        }
        final selectedBusinessValue = businessItems.contains(ctrl.businessType)
            ? ctrl.businessType
            : null;
        final selectedSourcesValue =
            sourcesItems.contains(ctrl.sourcesType) ? ctrl.sourcesType : null;

        log('selectedSourcesValue=================>>>>>${selectedSourcesValue}');

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.assignment_outlined,
                            color: newTextPrimary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          widget.editLead != null
                              ? "Edit Lead"
                              : "Lead Management",
                          style: GoogleFonts.poppins(
                              color: newTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LeadListScreen()));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: newBlueLightColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.list_alt,
                                color: newBlueColor, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextField(ctrl.nameController,
                                "Lead Name - contact person", Icons.person,
                                validator: (v) =>
                                    validateRequired(v, "Lead Name")),
                            _CompanyAutocomplete(controller: ctrl),
                            buildTextField(ctrl.mobileController,
                                "Mobile Number", Icons.phone,
                                type: TextInputType.phone,
                                validator: validateMobile),
                            buildTextField(
                                ctrl.altContactController,
                                "Alternate Contact (optional)",
                                Icons.phone_android,
                                type: TextInputType.phone),

                            buildDropdown(
                              "Sources",
                              sourcesItems,
                              selectedSourcesValue,
                              Icons.source_sharp,
                              (val) {
                                ctrl.sourcesType = val ?? '';
                                final selectedObj =
                                    ctrl.leadSourcesList.firstWhere(
                                  (e) => e.sourcename == ctrl.sourcesType,
                                  orElse: () => LeadSourcesData(
                                      sourceid: 0, sourcename: ''),
                                );
                                ctrl.sourcesId = selectedObj.sourceid;
                                log('sourcesId=================>>>>>${ctrl.sourcesId}');
                                ctrl.update();
                              },
                            ),

                            buildTextField(
                              ctrl.addressController,
                              "Address",
                              Icons.home,
                              validator: (v) => validateRequired(v, "Address"),
                            ),

                            const SizedBox(height: 0),

                            GestureDetector(
                              onTap: ctrl.isFetchingLocation
                                  ? null
                                  : () async {
                                      await ctrl.fetchCurrentLocation();
                                    },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ctrl.isFetchingLocation
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Icon(Icons.my_location,
                                            color: purpleColor, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      ctrl.isFetchingLocation
                                          ? "Fetching location..."
                                          : "Fetch Current Location",
                                      style: TextStyle(
                                        color: ctrl.isFetchingLocation
                                            ? Colors.grey
                                            : purpleColor,
                                        fontWeight: FontWeight.w600,
                                        decoration: ctrl.isFetchingLocation
                                            ? null
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            buildTextField(ctrl.emailController,
                                "Email Address", Icons.email,
                                validator: validateEmail),
                            buildTextField(ctrl.websiteController, "Website",
                                Icons.language),
                            GestureDetector(
                              onTap: () => pickDate(ctrl.leadDateController),
                              child: AbsorbPointer(
                                  child: buildTextField(ctrl.leadDateController,
                                      "Lead Date", Icons.calendar_today)),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  pickDate(ctrl.lastCommDateController),
                              child: AbsorbPointer(
                                  child: buildTextField(
                                      ctrl.lastCommDateController,
                                      "Last Comm. Date",
                                      Icons.date_range)),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Ageing",
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey.shade700,
                                          fontSize: 14)),
                                  Text(getAgeing(),
                                      style: GoogleFonts.poppins(
                                          color: purpleColor, fontSize: 14)),
                                ],
                              ),
                            ),

                            // Dropdowns
                            buildDropdown(
                              "Business Type",
                              businessItems,
                              selectedBusinessValue, // use safe value
                              Icons.store,
                              (val) {
                                ctrl.businessType = val ?? '';
                                final selectedObj =
                                    ctrl.leadBusinessData.firstWhere(
                                  (e) => e.businessType == ctrl.businessType,
                                  orElse: () => LeadBusinessList(
                                      businessTypeid: 0, businessType: ''),
                                );
                                ctrl.selectedBusinessTypeId =
                                    selectedObj.businessTypeid;
                                ctrl.update();
                              },
                            ),

                            buildDropdown(
                              "Industry Type",
                              industryItems,
                              industryItems.contains(ctrl.industryType)
                                  ? ctrl.industryType
                                  : null,
                              Icons.work,
                              (val) {
                                ctrl.industryType = val ?? '';
                                final selectedObj =
                                    ctrl.leadIndustryListData.firstWhere(
                                  (e) => e.industryType == ctrl.industryType,
                                  orElse: () => LeadIndustry(
                                      industryTypeid: 0, industryType: ''),
                                );
                                ctrl.selectedIndustryTypeId =
                                    selectedObj.industryTypeid;
                                ctrl.update();
                              },
                            ),

                            buildTextField(
                                ctrl.productsController,
                                "Products / Services They Offer",
                                Icons.list_alt,
                                validator: (v) =>
                                    validateRequired(v, "Products / Services")),
                            buildTextField(
                                ctrl.remarksController,
                                "Requirement Description / Remarks",
                                Icons.description,
                                maxLines: 2,
                                validator: (v) =>
                                    validateRequired(v, "Remarks")),

                            homeController.currentUserData!.compId == 24
                                ? Column(
                                    children: [
                                      buildDropdown(
                                        "Interested In",
                                        interestedItems,
                                        interestedItems
                                                .contains(ctrl.interestedIn)
                                            ? ctrl.interestedIn
                                            : null,
                                        Icons.store,
                                        (val) {
                                          ctrl.interestedIn = val ?? '';
                                          final selectedObj = ctrl
                                              .interestedDataList
                                              .firstWhere(
                                            (e) =>
                                                e.currentSoftware ==
                                                ctrl.interestedIn,
                                            orElse: () => InterestedData(
                                                currentSoftwareid: 0,
                                                currentSoftware: ''),
                                          );
                                          ctrl.interestedTypeId =
                                              selectedObj.currentSoftwareid;
                                          ctrl.update();
                                        },
                                      ),
                                      buildDropdown(
                                        "Current Software (if any)",
                                        currentSoftwareList,
                                        ctrl.selectCurrentSoftwareName,
                                        Icons.computer,
                                        (val) {
                                          ctrl.selectCurrentSoftwareName =
                                              val ?? '';
                                          final selectedObj = ctrl
                                              .currantSoftwareList
                                              .firstWhere(
                                            (e) =>
                                                e.decisionTimeline ==
                                                ctrl.selectCurrentSoftwareName,
                                            orElse: () => CurrantSoftware(
                                                decisionTimelineid: 0,
                                                decisionTimeline: ''),
                                          );
                                          ctrl.selectCurrentSoftwareId =
                                              selectedObj.decisionTimelineid;
                                          ctrl.update();
                                        },
                                      ),
                                      buildDropdown(
                                        "Decision Timeline",
                                        decisionTimelineList,
                                        ctrl.selectDecisionTimelineName,
                                        Icons.timer,
                                        (val) {
                                          ctrl.selectDecisionTimelineName =
                                              val ?? '';
                                          final selectedObj = ctrl
                                              .decisionTimelineList
                                              .firstWhere(
                                            (e) =>
                                                e.decisionTimeline ==
                                                ctrl.selectDecisionTimelineName,
                                            orElse: () => DecisionTimelineList(
                                                decisionTimelineid: 0,
                                                decisionTimeline: ''),
                                          );
                                          ctrl.selectDecisionTimelineId =
                                              selectedObj.decisionTimelineid;
                                          ctrl.update();
                                        },
                                      ),
                                    ],
                                  )
                                : SizedBox(),

                            // Tag Products
                            GestureDetector(
                              onTap: () async {
                                final result =
                                    await Navigator.push<List<TagProducts>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemGridFilterScreen(
                                      preselectedItems: List<TagProducts>.from(
                                          ctrl.previouslySelectedItems),
                                    ),
                                  ),
                                );

                                if (result != null) {
                                  ctrl.previouslySelectedItems = result;
                                  ctrl.tagProducts.text = result.map((e) {
                                    final qty = e.quantity ?? 0;
                                    final price = e.rate ?? 0;
                                    return '${e.itemname} x$qty @₹$price';
                                  }).join(', ');
                                  ctrl.update();
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ctrl.tagProducts.text.isEmpty
                                            ? "Tag Products"
                                            : ctrl.tagProducts.text,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: ctrl.tagProducts.text.isEmpty
                                              ? Colors.grey.shade500
                                              : purpleColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        color: purpleColor, size: 16),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [purpleColor, blueColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    if (widget.editLead != null) {
                                      controller.updateLeadEntry(
                                          widget.editLead!.leadEntryId);
                                    } else {
                                      controller.saveLeadEntry(context);
                                    }
                                  }
                                },
                                icon:
                                    const Icon(Icons.save, color: Colors.white),
                                label: Text(
                                  widget.editLead != null
                                      ? "Update Lead"
                                      : "Save Lead",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        inputFormatters: [
          if (type == TextInputType.phone) ...[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ],
        validator: validator,
        decoration: inputDecoration(hint, icon),
      ),
    );
  }

// Example validator
//   String? validateMobile(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter mobile number';
//     } else if (value.length != 10) {
//       return 'Mobile number must be 10 digits';
//     }
//     return null;
//   }

  Widget buildDropdown(
    String hint,
    List<String> items,
    String? value,
    IconData icon,
    Function(String?) onChanged,
  ) {
    // Ensure duplicates are removed
    final uniqueItems = items.toSet().toList();

    // Only set value if it actually exists in the list
    final validValue =
        (value != null && uniqueItems.contains(value)) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: validValue,
        decoration: inputDecoration(hint, icon),
        icon: const Icon(Icons.arrow_drop_down, color: purpleColor),
        items: uniqueItems
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null || v.isEmpty ? "Select $hint" : null,
      ),
    );
  }
}

class _CompanyAutocomplete extends StatelessWidget {
  final LeadViewController controller;
  const _CompanyAutocomplete({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final suggestions = controller.partySuggestions;
      final isLoading = controller.isPartyLoading.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller.companyController,
              onChanged: controller.onCompanyNameChanged,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Company Name is required"
                  : null,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.business, color: purpleColor),
                hintText: "Company Name",
                hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: purpleColor),
                        ),
                      )
                    : controller.companyController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: Colors.grey),
                            onPressed: () {
                              controller.companyController.clear();
                              controller.partySuggestions.clear();
                              controller.selectedParty = null;
                            },
                          )
                        : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: purpleColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            if (suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final party = suggestions[index];
                    final query =
                        controller.companyController.text.toLowerCase();
                    final name = party.partyName ?? '';
                    final start = name.toLowerCase().indexOf(query);

                    return InkWell(
                      onTap: () => controller.onPartySelected(party),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: purpleColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.business,
                                  size: 16, color: purpleColor),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: start >= 0
                                  ? RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black87),
                                        children: [
                                          TextSpan(
                                              text: name.substring(0, start)),
                                          TextSpan(
                                            text: name.substring(
                                                start, start + query.length),
                                            style: GoogleFonts.poppins(
                                              color: purpleColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(
                                              text: name.substring(
                                                  start + query.length)),
                                        ],
                                      ),
                                    )
                                  : Text(name,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13, color: Colors.black87)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}
