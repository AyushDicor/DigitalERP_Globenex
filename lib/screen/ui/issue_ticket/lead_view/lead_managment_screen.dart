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
      // The lead LIST endpoint (getleadentry/getleadentry) returns only six
      // fields — LeadEntryId, LeadName, CompanyName, MobileNo, LeadDate,
      // Ageing. Opening this form straight from a list card therefore left
      // email, website, address, remarks, business/industry type and source
      // all blank, because those values simply were not in the object handed
      // over. Fetch the full record by id first; fall back to whatever was
      // passed only if that call fails.
      GetleadentryList lead = widget.editLead!;
      await controller.getLeadEntryDetailFromId(lead.leadEntryId);
      final full = controller.getLeadDetailFromIdResponseModel?.data;
      if (full != null) {
        lead = controller.fromApiToLeadModel(full);
      } else {
        log('Edit Lead: detail fetch failed for ${lead.leadEntryId}, '
            'falling back to the list row');
      }
      loadLeadData(lead);
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
    // The API returns a full timestamp ("2026-08-04T00:00:00"), which rendered
    // raw in the box. Normalise to the same yyyy-MM-dd the date picker writes
    // and getAgeing() parses, so all three agree.
    controller.leadDateController.text = _dateOnly(lead.leadDate);
    controller.lastCommDateController.text =
        _dateOnly(lead.lastCommunicationDate);
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
      // Every field on this screen is pre-filled from the lead, and `hintText`
      // is hidden as soon as a field has a value — so the form rendered as a
      // column of values with nothing saying what any of them were. A label
      // pinned above the box stays visible whether the field is filled or not.
      labelText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade700, fontSize: 12.5, fontWeight: FontWeight.w600),
      floatingLabelStyle: GoogleFonts.poppins(
          color: purpleColor, fontSize: 13, fontWeight: FontWeight.w600),
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

  /// One titled card per group of fields.
  ///
  /// The screen used to be a single 20-padded white box holding ~15 unlabelled
  /// inputs in one column, which read as an undifferentiated wall. Cards match
  /// the Lead Entry screen's layout so both halves of the module look alike.
  Widget sectionCard(
      String title, IconData icon, Color accent, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: newTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  /// Read-only row for a value the user cannot edit (Ageing).
  Widget readOnlyRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  color: purpleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Strips the time off an API date so the field shows "2026-08-04" rather
  /// than "2026-08-04T00:00:00". Returns '' for null/unparseable input.
  String _dateOnly(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return raw.trim();
    return DateFormat('yyyy-MM-dd').format(parsed);
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

        final bool isEdit = widget.editLead != null;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF5F6FA),
          // A real app bar: title, the record being edited, and a back button.
          // The old header was a plain white Row inside the scroll view, so it
          // scrolled away and offered no way back.
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: const Color(0xFFE8EAF0),
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            // Boxed chevron, matching the Lead Management list app bar. The
            // Material default back arrow looked nothing like the rest of the
            // module.
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8EAF0))),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: newTextPrimary, size: 16),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isEdit ? "Edit Lead" : "New Lead",
                  style: GoogleFonts.poppins(
                      color: newTextPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  isEdit
                      ? (widget.editLead?.companyName ??
                          widget.editLead?.leadName ??
                          'Update lead details')
                      : 'Create a new lead record',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
            actions: [
              // Same 38x38 boxed action button the list screen uses for its
              // filter, so both app bars in the module read as one design.
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LeadListScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.list_alt_rounded,
                      color: Color(0xFF5B5FC7), size: 20),
                ),
              ),
            ],
          ),
          // The save button used to sit at the bottom of a very long scroll,
          // so it was only reachable after scrolling past every field.
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [purpleColor, blueColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (isEdit) {
                      controller.updateLeadEntry(widget.editLead!.leadEntryId);
                    } else {
                      controller.saveLeadEntry(context);
                    }
                  }
                },
                icon: const Icon(Icons.save, color: Colors.white, size: 20),
                label: Text(
                  isEdit ? "Update Lead" : "Save Lead",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionCard('Contact Details', Icons.person_outline,
                                const Color(0xFF2563EB), [

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

                            ]),

                            sectionCard('Source & Address',
                                Icons.location_on_outlined,
                                const Color(0xFF7C3AED), [

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

                            ]),

                            sectionCard('Dates',
                                Icons.calendar_month_outlined,
                                const Color(0xFF059669), [

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
                            // Ageing is derived, not editable — rendered as a
                            // read-only row so it reads differently from the
                            // inputs around it.
                            readOnlyRow('Ageing', getAgeing(),
                                Icons.hourglass_bottom_rounded),

                            ]),

                            sectionCard('Classification',
                                Icons.category_outlined,
                                const Color(0xFFEA580C), [

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

                            ]),

                            sectionCard('Requirement & Products',
                                Icons.notes_outlined,
                                const Color(0xFF0891B2), [

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

                            ]),
                            // The Save/Update button now lives in the sticky
                            // bottomNavigationBar instead of down here.
                          ],
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
                // Same fix as inputDecoration(): this field is pre-filled, so a
                // hint-only label was never visible.
                labelText: "Company Name",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600),
                floatingLabelStyle: GoogleFonts.poppins(
                    color: purpleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
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
