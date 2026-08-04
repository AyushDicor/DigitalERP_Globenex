import 'dart:convert';
import 'dart:developer';

import 'package:digitalerp/model/current_software_lead_reponse_model.dart';
import 'package:digitalerp/model/decision_timeline_response_model.dart';
import 'package:digitalerp/model/delete_follow_ups_response_model.dart';
import 'package:digitalerp/model/delete_lead_response_model.dart';
import 'package:digitalerp/model/get_follow_ups_response_model.dart';
import 'package:digitalerp/model/get_lead_detail_from_id_response_model.dart';
import 'package:digitalerp/model/get_quote_response_model.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/model/inserted_lead_followup_response_model.dart';
import 'package:digitalerp/model/interestedIn_response_model.dart';
import 'package:digitalerp/model/lead_businesstype_response_model.dart';
import 'package:digitalerp/model/lead_industry_response_model.dart';
import 'package:digitalerp/model/lead_insert_quote_response_model.dart';
import 'package:digitalerp/model/lead_interested_response_model.dart';
import 'package:digitalerp/model/lead_sources_response_model.dart';
import 'package:digitalerp/model/lead_tag_products_response_model.dart';
import 'package:digitalerp/model/main_group_tag_products_response_model.dart';
import 'package:digitalerp/model/save_lead_entry_response_model.dart';
import 'package:digitalerp/model/select_currency_response_model.dart';
import 'package:digitalerp/model/sub_group_filtred_data_response_model.dart';
import 'package:digitalerp/repo/lead_management_repo.dart';
import 'package:digitalerp/repo/reimbursement_repo.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/view_lead_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../lead model/agent_party_response_model.dart';

class LeadViewController extends GetxController {
  String? selectedType;

  HomeController homeController = Get.find<HomeController>();
  final TextEditingController descController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  String selectedCurrency = "INR";
  int? selectedInrId;

  /// Currency list for the Create Quote screen.
  /// In Balaji this lived on ReimbursementController; this app has no
  /// reimbursement module, so the list is loaded here instead of dragging that
  /// whole module across. Same endpoint either way.
  List<CurrencyList> currencyDataList = [];

  Future<void> pickCurrencyData() async {
    try {
      final requestData = {
        "compid": homeController.currentUserData?.compId.toString() ?? '',
      };
      final result = await ReimbursementRepo.currencyDropDownList(requestData);
      if (result.statusCode == 200) {
        currencyDataList =
            CurrencyResponseModel.fromJson(result.data).data?.toList() ?? [];
      } else {
        log("pickCurrencyData error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in pickCurrencyData: $e", stackTrace: s);
    }
    update();
  }
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController additionalChargesController = TextEditingController();
  final TextEditingController additionalRemarksController = TextEditingController();
  final TextEditingController addTermsAndCondition = TextEditingController();
  final TextEditingController bodyTextController = TextEditingController(
    text: "Dear Customer,\nThank you for your interest. Please find the quote below.",
  );

  List<AgentPartyData> _allParties = [];
  RxList<AgentPartyData> partySuggestions = <AgentPartyData>[].obs;
  RxBool isPartyLoading = false.obs;
  AgentPartyData? selectedParty;

  LeadInsertQuoteResponseModel? leadInsertQuoteResponseModel;
  GetAddQuoteResponseModel? getAddQuoteResponseModel;

  List<GetQuote> getQuote = [];

  double get subTotal => getQuote.fold(0, (sum, item) => sum + (item.amount ?? 0) * (item.quantity ?? 0));
  Future<void> insertLeadQuote({int? leadId, int? totalAmount}) async {
    try {
      isLoading = true;

      final requestData = {
        "quotationdesc": descriptionController.text,
        "quotationtext": bodyTextController.text,
        "currencyid": selectedInrId == null ? 64 : selectedInrId,
        "currency": selectedCurrency,
        "quotationDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "expiryDate": expiryDateController.text,
        "additionalcharge": additionalChargesController.text,
        "remarksforadditionalcharges": additionalRemarksController.text,
        "totalamt": totalAmount,
        "leadid": leadId,
        "compid": homeController.currentUserData?.compId,
        "branchid": homeController.currentUserData?.branchId,
        "userid": homeController.currentUserData?.userid,
        "yearid": homeController.currentUserData?.yearId,
        "leadItems": getQuote
            .map((item) => {
                  "itemId": item.itemId,
                  "itemName": item.itemName,
                  "quantity": item.quantity,
                  "SalesPrice": item.amount,
                })
            .toList(),
      };

      log('requestData for insertLeadQuote =================>>>>> $requestData');

      final result = await LeadManagementRepo.insertLeadQuoteMethod(requestData);
      log('result for insertLeadQuote =================>>>>>${jsonEncode(result)}');

      log('Status Code: ${result.statusCode}');
      log('Message: ${result.message ?? 'No message'}');

      if (result.data != null) {
        final prettyJson = const JsonEncoder.withIndent('  ').convert(result.data);
        log('Data:\n$prettyJson');
      } else {
        log('Data is null');
      }

      if (result.statusCode == 200) {
        leadInsertQuoteResponseModel = LeadInsertQuoteResponseModel.fromJson(result.data);
        log('leadInsertQuoteResponseModel===========url======>>>>>${leadInsertQuoteResponseModel?.data.first.url}');
        Get.snackbar("Success", "Quote Insert SuccessFully..");
        update();
      } else {
        log("deleteFollowUpsNotes error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in deleteFollowUpsNotes: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchAgentPartyList() async {
    isPartyLoading.value = true;
    try {
      final requestData = {
        'compid':   homeController.currentUserData?.compId?.toString()   ?? '',
        'userid':   homeController.currentUserData?.userid?.toString()   ?? '',
        'branchid': homeController.currentUserData?.branchId?.toString() ?? '',
      };
      log('fetchAgentPartyList requestData =====>>>>> $requestData');
      final result = await LeadManagementRepo.agentPartyMethod(requestData);
      if (result.statusCode == 200 && result.data != null) {
        final model = AgentPartyResponseModel.fromJson(result.data);
        _allParties = model.data ?? [];
        log('agentParty loaded: ${_allParties.length} parties');
      } else {
        log('fetchAgentPartyList error: ${result.message}');
      }
    } catch (e, s) {
      log('fetchAgentPartyList catch: $e', stackTrace: s);
    } finally {
      isPartyLoading.value = false;
    }
  }

  void onCompanyNameChanged(String query) {
    selectedParty = null;
    if (query.trim().isEmpty) {
      partySuggestions.clear();
      return;
    }
    final q = query.toLowerCase();
    partySuggestions.value = _allParties
        .where((p) => (p.partyName ?? '').toLowerCase().contains(q))
        .take(8)
        .toList();
  }

  void onPartySelected(AgentPartyData party) {
    selectedParty = party;
    companyController.text = party.partyName ?? '';
    partySuggestions.clear();
    update();
  }




  Future<void> getAddQuotes({int? leadId}) async {
    try {
      isLoading = true;

      final requestData = {
        "leadId": leadId,
        "compid": homeController.currentUserData?.compId,
        "branchid": homeController.currentUserData?.branchId,
      };

      log('requestData for getAddQuotes =================>>>>> $requestData');

      final result = await LeadManagementRepo.getQuoteMethod(requestData);

      if (result.statusCode == 200) {
        getAddQuoteResponseModel = GetAddQuoteResponseModel.fromJson(result.data);
        getQuote = getAddQuoteResponseModel?.data?.leadItems?.toList() ?? [];
        log('getQuote=================>>>>>${jsonEncode(getQuote)}');
        update();
      } else {
        log("getAddQuotes error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in getAddQuotes: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  GetleadentryList fromApiToLeadModel(Data data) {
    return GetleadentryList(
      leadEntryId: int.parse(data.leadEntryId.toString()),
      leadName: data.leadName.toString(),
      companyName: data.companyName.toString(),
      mobileNo: data.mobileNo.toString(),
      alternateMobile: data.alternateMobile,
      email: data.email,
      website: data.website,
      lastCommunicationDate: data.lastCommunicationDate.toString(),
      requirement: data.requirement,
      businessTypeId: data.businessTypeId,
      sourceId: data.sourceid,
      sourceName: data.source,
      businessType: data.businessType,
      industryTypeId: data.industryTypeId,
      industryType: data.industryType,
      interestedInId: data.interestedInId,
      interestedIn: data.interestedIn,
      currentSoftwareId: data.currentSoftwareId,
      currentSoftware: data.currentSoftware,
      decisionTimeId: data.decisionTimeId,
      decisionTime: data.decisionTime,
      leadDate: data.leadDate.toString(),
      ageing: data.ageing.toString(),
      // `data.leadItems!` — a bang on a nullable list. A lead saved with no
      // tagged products would have thrown here and blanked the edit form.
      leadItems: (data.leadItems ?? [])
          .map((e) => LeadItem(
                itemId: e.itemId,
                itemName: e.itemName,
                quantity: e.quantity,
                salesPrice: e.salesPrice,
              ))
          .toList(),
      address: data.address,
    );
  }

  void loadLeadData(GetleadentryList lead) {
    nameController.text = lead.leadName ?? "";
    companyController.text = lead.companyName ?? "";
    mobileController.text = lead.mobileNo ?? "";
    altContactController.text = lead.alternateMobile ?? "";
    emailController.text = lead.email ?? "";
    websiteController.text = lead.website ?? "";
    leadDateController.text = lead.leadDate ?? "";
    lastCommDateController.text = lead.lastCommunicationDate ?? "";
    remarksController.text = lead.requirement ?? "";
    addressController.text = lead.address ?? "";

    businessType = lead.businessType;
    sourcesType = lead.businessType;
    selectedBusinessTypeId = lead.businessTypeId;
    industryType = lead.industryType;
    selectedIndustryTypeId = lead.industryTypeId;
    interestedIn = lead.interestedIn;
    interestedTypeId = lead.interestedInId;
    selectCurrentSoftwareName = lead.currentSoftware;
    selectCurrentSoftwareId = lead.currentSoftwareId;
    selectDecisionTimelineName = lead.decisionTime;
    selectDecisionTimelineId = lead.decisionTimeId;

    if (lead.leadItems.isNotEmpty) {
      previouslySelectedItems = lead.leadItems
          .map((e) => TagProducts(
                itemid: e.itemId,
                itemname: e.itemName,
                quantity: int.parse(e.quantity.toString()),
                rate: e.salesPrice,
              ))
          .toList();

      tagProducts.text =
          previouslySelectedItems.map((e) => '${e.itemname} x${e.quantity} @₹${e.rate}').join(', ');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final mobileController = TextEditingController();
  final altContactController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final productsController = TextEditingController();
  final tagProducts = TextEditingController();
  final remarksController = TextEditingController();

  final leadDateController = TextEditingController();
  final lastCommDateController = TextEditingController();

  bool isLoading = false;
  LeadBusinessResponseModel? leadBusinessResponseModel;
  LeadSourcesResponseModel? leadSourcesResponseModel;
  List<LeadBusinessList> leadBusinessData = [];
  List<LeadSourcesData> leadSourcesList = [];

  String? businessType;
  String? sourcesType;
  int? selectedBusinessTypeId;
  int? sourcesId;
  int? days;

  bool isFetchingLocation = false;
  Future<void> fetchCurrentLocation() async {
    try {
      isFetchingLocation = true;

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission Denied', 'Please enable location access');
        isFetchingLocation = false;
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String formattedAddress =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        addressController.text = formattedAddress;
      }

      isFetchingLocation = false;
    } catch (e) {
      isFetchingLocation = false;
      Get.snackbar('Error', 'Failed to fetch location: $e');
    }
  }

  ///businessType
  Future<void> businessTypeList() async {
    try {
      isLoading = true;

      final requestData = {"compid": homeController.currentUserData!.compId.toString()};
      // final requestData = {"compid": "24"};

      log('requestData For businessTypeList =================>>>>> $requestData');

      final result = await LeadManagementRepo.businessTypeMethod(requestData);

      if (result.statusCode == 200) {
        leadBusinessResponseModel = LeadBusinessResponseModel.fromJson(result.data);
        leadBusinessData = leadBusinessResponseModel?.data?.toList() ?? [];

        log('businessTypeList =================>>>>> ${jsonEncode(leadBusinessData)}');
      } else {
        log("businessTypeList error: ${result.message}");
      }
      update();
    } catch (e, s) {
      log("Error in businessTypeList: $e", stackTrace: s);
    } finally {
      isLoading = false;
    }
    update();
  }

  /// industry Type

  LeadIndustryResponseModel? leadIndustryResponseModel;
  List<LeadIndustry> leadIndustryListData = [];

  String? industryType;
  int? selectedIndustryTypeId;

  Future<void> leadIndustryTypeList() async {
    try {
      isLoading = true;

      final requestData = {"compid": homeController.currentUserData!.compId.toString()};
      // final requestData = {"compid": "24"};

      log('requestData For leadIndustryTypeList =================>>>>> $requestData');

      final result = await LeadManagementRepo.industryTypeMethod(requestData);

      if (result.statusCode == 200) {
        leadIndustryResponseModel = LeadIndustryResponseModel.fromJson(result.data);
        leadIndustryListData = leadIndustryResponseModel?.data?.toList() ?? [];

        log('leadIndustryListData =================>>>>> ${jsonEncode(leadIndustryListData)}');
      } else {
        log("leadIndustryListData error: ${result.message}");
      }
      update();
    } catch (e, s) {
      log("Error in leadIndustryListData: $e", stackTrace: s);
    } finally {
      isLoading = false;
    }
    update();
  }

  /// interested fun.

  InterestedResponseModel? interestedResponseModel;
  List<InterestedData> interestedDataList = [];
  String? interestedIn;
  int? interestedTypeId;

  Future<void> leadInterestedTypeList() async {
    try {
      isLoading = true;

      final requestData = {"compid": homeController.currentUserData!.compId.toString()};
      // final requestData = {"compid": "24"};

      log('requestData For leadInterestedTypeList =================>>>>> $requestData');

      final result = await LeadManagementRepo.interestedTypeMethod(requestData);

      if (result.statusCode == 200) {
        interestedResponseModel = InterestedResponseModel.fromJson(result.data);
        interestedDataList = interestedResponseModel?.data?.toList() ?? [];

        log('interestedDataList =================>>>>> ${jsonEncode(interestedDataList)}');
      } else {
        log("interestedDataList error: ${result.message}");
      }
      update();
    } catch (e, s) {
      log("Error in interestedDataList: $e", stackTrace: s);
    } finally {
      isLoading = false;
    }
    update();
  }

  /// Tag Products

  TagProductsResponseModel? tagProductsResponseModel;
  List<TagProducts> tagProductsList = [];

  Future<void> leadTagProductsTypeList({
    String? categoryId,
    String? subCategoryId,
    String? brandId,
    String rateFrom = "0",
    String rateTo = "0",
    String itemName = "",
  }) async {
    try {
      isLoading = true;

      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString(),
        "categoryid": categoryId ?? "",
        "subcategoryid": subCategoryId ?? "",
        "brandid": brandId ?? "",
        "ratefrom": rateFrom,
        "rateto": rateTo,
        "itemname": itemName,
      };

      log('Request Data (leadTagProductsTypeList): $requestData');

      final result = await LeadManagementRepo.tagProductsTypeMethod(requestData);

      if (result.statusCode == 200) {
        tagProductsResponseModel = TagProductsResponseModel.fromJson(result.data);
        tagProductsList = tagProductsResponseModel?.data?.toList() ?? [];

        log('tagProductsList loaded: ${jsonEncode(tagProductsList)}');
      } else {
        log("️tagProductsList error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in leadTagProductsTypeList: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  MainGroupResponseModel? mainGroupResponseModel;

  List<MainGroup> mainGroup = [];

  Future<void> mainGroupTagProductsList() async {
    try {
      isLoading = true;

      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString()
      };

      log('requestData For mainGroupTagProductsList =================>>>>> $requestData');

      final result = await LeadManagementRepo.mainGroup(requestData);

      if (result.statusCode == 200) {
        mainGroupResponseModel = MainGroupResponseModel.fromJson(result.data);
        mainGroup = mainGroupResponseModel?.data?.toList() ?? [];
        update();
        log('mainGroup =================>>>>> ${jsonEncode(mainGroup)}');
      } else {
        log("mainGroup error: ${result.message}");
      }
      update();
    } catch (e, s) {
      log("Error in mainGroup: $e", stackTrace: s);
    } finally {
      isLoading = false;
    }
    update();
  }

  SubGroupFiltredDataResponseModel? subGroupFiltredDataResponseModel;

  List<SubGroupFiltredData> subGroupData = [];
  Map<int, List<SubGroupFiltredData>> subGroupsMap = {};
  Future<void> subGroupTagProductsList({int? id}) async {
    if (id == null) return;
    try {
      isLoading = true;
      update();

      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString(),
        "categoryid": id
      };

      log('requestData For subGroupTagProductsList =================>>>>> $requestData');

      final result = await LeadManagementRepo.subGroup(requestData);

      if (result.statusCode == 200) {
        final responseModel = SubGroupFiltredDataResponseModel.fromJson(result.data);
        subGroupsMap[id] = responseModel.data?.toList() ?? [];
        log('Subgroups for main group $id loaded: ${subGroupsMap[id]?.length}');
      } else {
        log("subGroupTagProductsList error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in subGroupTagProductsList: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// save Lead entry
  SaveLeadEntryResponseModel? saveLeadEntryResponseModel;
  List<TagProducts> previouslySelectedItems = [];

  Future<void> saveLeadEntry(context) async {
    try {
      isLoading = true;
      update();

      final List<Map<String, dynamic>> leadItems = previouslySelectedItems
          .map((item) => {
                'itemId': item.itemid,
                'itemName': item.itemname,
                'quantity': item.quantity,
                'salesPrice': item.rate,
              })
          .toList();

      final requestData = {
        "leadname": nameController.text,
        "companyName": companyController.text,
        "mobileNo": mobileController.text,
        "alternateMobile": altContactController.text,
        "email": emailController.text,
        "website": websiteController.text,
        "leadDate": leadDateController.text,
        "lastCommunicationDate": lastCommDateController.text,
        "ageing": days,
        "businessTypeId": selectedBusinessTypeId ?? 0,
        "businessType": businessType ?? '',
        "industryTypeId": selectedIndustryTypeId ?? 0,
        "industryType": industryType ?? '',
        "service": productsController.text,
        "requirement": remarksController.text,
        "interestedInId": homeController.currentUserData!.compId == 24 ? 0 : (interestedTypeId ?? 0),
        "interestedIn": homeController.currentUserData!.compId == 24
            ? '0'
            : ((interestedIn == null || interestedIn!.isEmpty) ? '0' : interestedIn),
        "currentSoftwareId":
            homeController.currentUserData!.compId == 24 ? 0 : (selectCurrentSoftwareId ?? 0),
        "currentSoftware": homeController.currentUserData!.compId == 24
            ? '0'
            : ((selectCurrentSoftwareName == null || selectCurrentSoftwareName!.isEmpty)
                ? '0'
                : selectCurrentSoftwareName),
        "decisionTimeId": homeController.currentUserData!.compId == 24 ? 0 : (selectDecisionTimelineId ?? 0),
        "decisionTime": homeController.currentUserData!.compId == 24
            ? '0'
            : ((selectDecisionTimelineName == null || selectDecisionTimelineName!.isEmpty)
                ? '0'
                : selectDecisionTimelineName),

        // "interestedInId": homeController.currentUserData!.compId == 24 ? 0 : interestedTypeId ?? 0,
        // "interestedIn": homeController.currentUserData!.compId == 24 ? 0 : interestedIn ?? '0',
        // "currentSoftwareId": homeController.currentUserData!.compId == 24 ? 0 : selectCurrentSoftwareId ?? 0,
        // "currentSoftware":
        //     homeController.currentUserData!.compId == 24 ? 0 : selectCurrentSoftwareName ?? '0',
        // "decisionTimeId": homeController.currentUserData!.compId == 24 ? 0 : selectDecisionTimelineId ?? 0,
        // "decisionTime": homeController.currentUserData!.compId == 24 ? 0 : selectDecisionTimelineName ?? '0',
        "compId": homeController.currentUserData?.compId,
        "branchId": homeController.currentUserData?.branchId,
        "userId": homeController.currentUserData?.userid,
        "yearId": homeController.currentUserData?.yearId,
        "leadItems": leadItems,
        "sourceid": sourcesId,
        "address": addressController.text
      };

      log('RequestData for add Lead: $requestData');

      final result = await LeadManagementRepo.saveLeadEntryMethod(requestData);

      if (result.statusCode == 200) {
        saveLeadEntryResponseModel = SaveLeadEntryResponseModel.fromJson(result.data);
        Get.snackbar("Success", saveLeadEntryResponseModel?.message ?? "Lead Saved Successfully");
        Get.to(LeadListScreen());
        nameController.clear();
        companyController.clear();
        mobileController.clear();
        altContactController.clear();
        emailController.clear();
        websiteController.clear();
        leadDateController.clear();
        lastCommDateController.clear();
        productsController.clear();
        remarksController.clear();
        tagProducts.clear();

        // Clear dropdown selections
        businessType = '';
        selectedBusinessTypeId = 0;
        industryType = '';
        selectedIndustryTypeId = 0;
        interestedIn = '';
        interestedTypeId = 0;
        selectCurrentSoftwareName = '';
        selectCurrentSoftwareId = 0;
        selectDecisionTimelineName = '';
        selectDecisionTimelineId = 0;

        // Clear previously selected items
        previouslySelectedItems = [];

        update();
      } else {
        Get.snackbar("Error", result.message ?? "Failed to save lead");
      }
    } catch (e, s) {
      log("Error in saveLeadEntry: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  //// s.code

  InterestedInResponseModel? interestedInResponseModel;
  CurrentSoftwareResponseModel? currentSoftwareResponseModel;
  DecisionTimelineResponseModel? decisionTimelineResponseModel;

  List<InterestedInList> interestedInList = [];
  List<CurrantSoftware> currantSoftwareList = [];
  List<DecisionTimelineList> decisionTimelineList = [];

  Future<void> interestedInApiMethod() async {
    try {
      isLoading = true;
      // final requestData = {"compid": "24"};
      final requestData = {"compid": homeController.currentUserData!.compId.toString()};
      final result = await LeadManagementRepo.interestedInMethod(requestData);

      if (result.statusCode == 200) {
        interestedInResponseModel = InterestedInResponseModel.fromJson(result.data);
        interestedInList = (interestedInResponseModel?.data ?? []).toList();
        // log('interestedInList  :::::::::::::  ${jsonEncode(interestedInList)}');
        update();
      } else {
        log("interestedInList error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in interestedInList: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> decisionTimelineApiMethod() async {
    try {
      isLoading = true;
      // final requestData = {"compid": "24"};
      final requestData = {"compid": homeController.currentUserData!.compId.toString()};
      final result = await LeadManagementRepo.decisionTimelineMethod(requestData);

      if (result.statusCode == 200) {
        decisionTimelineResponseModel = DecisionTimelineResponseModel.fromJson(result.data);
        decisionTimelineList = (decisionTimelineResponseModel?.data ?? []).toList();
        // log('decisionTimelineList  :::::::::::::  ${jsonEncode(decisionTimelineList)}');
        update();
      } else {
        log("decisionTimelineList error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in decisionTimelineList: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  int? selectCurrentSoftwareId;
  String? selectCurrentSoftwareName;
  int? selectDecisionTimelineId;
  String? selectDecisionTimelineName;

  Future<void> currentSoftwareApiMethod() async {
    try {
      isLoading = true;
      // final requestData = {"compid": "24"};
      final requestData = {"compid": homeController.currentUserData!.compId.toString()};
      log('requestData for currantsoftware=================>>>>>${requestData}');
      final result = await LeadManagementRepo.currentSoftwareMethod(requestData);

      if (result.statusCode == 200) {
        currentSoftwareResponseModel = CurrentSoftwareResponseModel.fromJson(result.data);
        currantSoftwareList = (currentSoftwareResponseModel?.data ?? []).toList();
        // log('currantSoftwareList  :::::::::::::  ${jsonEncode(currantSoftwareList)}');
        update();
      } else {
        log("currantSoftwareList error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in currantSoftwareList: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  List<GetleadentryList> getleadentryList = [];

  GetleadentryResponseModel? getleadentryResponseModel;

  Future<void> getLeadEntryApiMethod() async {
    try {
      isLoading = true;
      final requestData = {
        "userId": homeController.currentUserData!.userid.toString(),
        "compId": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString()
      };
      log('requestData getLeadEntryApiMethod =================>>>>>${requestData}');
      final result = await LeadManagementRepo.getLeadEntryMethod(requestData);
      log('==================== API RESPONSE ====================');
      if (result.data != null) {
        final prettyJson = const JsonEncoder.withIndent('  ').convert(result.data);
        log('Data:\n$prettyJson');
      } else {
        log('Data is null');
      }
      if (result.statusCode == 200 && result.data != null) {
        if (result.data != null) {
          getleadentryResponseModel = GetleadentryResponseModel.fromJson(result.data);
          getleadentryList = (getleadentryResponseModel?.data ?? []).toList();
          log('getleadentryList  :::::::::::::  ${jsonEncode(getleadentryList)}');
        }
        update();
      } else {
        log("getleadentryList error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in getleadentryList: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  GetLeadDetailFromIdResponseModel? getLeadDetailFromIdResponseModel;

  /// 15-09

  Future<void> getLeadEntryDetailFromId(int? id) async {
    try {
      isLoading = true;
      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString(),
        "leadId": id
      };
      log('requestData for getLeadEntryDetailFromId =================>>>>>${requestData}');
      final result = await LeadManagementRepo.getLeadEntryMethodFromId(requestData);

      if (result.statusCode == 200) {
        getLeadDetailFromIdResponseModel = GetLeadDetailFromIdResponseModel.fromJson(result.data);
        log('getLeadEntryDetailFromId  :::::::::::::  ${jsonEncode(getLeadDetailFromIdResponseModel)}');
        update();
      } else {
        log("getLeadEntryDetailFromId error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in getLeadEntryDetailFromId: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  ///delete Lead
  DeleteLeadResponseModel? deleteLeadResponseModel;

  Future<void> deleteLeadFun(int? id) async {
    if (id == null) return;
    try {
      isLoading = true;
      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString(),
        "leadId": id,
        // ✅ FIX: this sent compId as the userid, so every delete was
        // attributed to the company id instead of the signed-in user.
        "userid": homeController.currentUserData!.userid.toString()
      };
      log('requestData for deleteLeadFun =================>>>>>${requestData}');
      final result = await LeadManagementRepo.deleteLeads(requestData);

      deleteLeadResponseModel = result.data == null
          ? null
          : DeleteLeadResponseModel.fromJson(result.data);
      log('deleteLeadFun  :::::::::::::  ${jsonEncode(deleteLeadResponseModel)}');

      // ✅ FIX: this only checked the HTTP status. This server answers a failed
      // delete with HTTP 200 and "status": 500 in the body, so a refused delete
      // navigated away as though it had worked and the lead was still there.
      final bool deleted = result.statusCode == 200 &&
          (deleteLeadResponseModel?.success == true ||
              deleteLeadResponseModel?.status == 200);

      if (deleted) {
        Get.snackbar('Deleted',
            deleteLeadResponseModel?.message ?? 'Lead deleted successfully.');
        // ✅ FIX: was Get.to(...), which pushed ANOTHER list screen on top of
        // the stack every time. Go back to the existing list and refresh it.
        Get.back(result: true);
        getLeadEntryApiMethod();
      } else {
        Get.snackbar('Could not delete',
            deleteLeadResponseModel?.message ?? result.message.toString());
        log("deleteLeadFun error: ${result.message}");
      }
      update();
    } catch (e, s) {
      log("Error in deleteLeadFun: $e", stackTrace: s);
      Get.snackbar('Could not delete', '$e');
    } finally {
      isLoading = false;
      update();
    }
  }

  InsertedLeadNotesResponseModel? insertedLeadNotesResponseModel;
  DateTime? selectedDateTime;

  Future<void> updateLeadEntry(int? leadId) async {
    try {
      isLoading = true;
      update();

      // Prepare lead items
      final List<Map<String, dynamic>> leadItems = previouslySelectedItems
          .map((item) => {
                'itemId': item.itemid,
                'itemName': item.itemname,
                'quantity': item.quantity,
                'salesPrice': item.rate,
              })
          .toList();

      final requestData = {
        "leadEntryId": leadId,
        "leadname": nameController.text,
        "companyName": companyController.text,
        "mobileNo": mobileController.text,
        "alternateMobile": altContactController.text,
        "email": emailController.text,
        "website": websiteController.text,
        "leadDate": leadDateController.text,
        "lastCommunicationDate": lastCommDateController.text,
        "ageing": days,
        "businessTypeId": selectedBusinessTypeId,
        "businessType": businessType,
        "industryTypeId": selectedIndustryTypeId,
        "industryType": industryType,
        "service": productsController.text,
        "requirement": remarksController.text,
        "interestedInId": homeController.currentUserData!.compId == 24 ? 0 : interestedTypeId ?? 0,
        "interestedIn": (interestedIn == null || interestedIn!.isEmpty) ? '0' : interestedIn,

        "currentSoftwareId": homeController.currentUserData!.compId == 24 ? 0 : selectCurrentSoftwareId ?? 0,
        "currentSoftware": (selectCurrentSoftwareName == null || selectCurrentSoftwareName!.isEmpty)
            ? '0'
            : selectCurrentSoftwareName,
        "decisionTimeId": homeController.currentUserData!.compId == 24 ? 0 : selectDecisionTimelineId ?? 0,
        "decisionTime": (selectDecisionTimelineName == null || selectDecisionTimelineName!.isEmpty)
            ? '0'
            : selectDecisionTimelineName,

        // "interestedInId": interestedTypeId,
        // "interestedIn": interestedIn,
        // "currentSoftwareId": selectCurrentSoftwareId,
        // "currentSoftware": selectCurrentSoftwareName,
        // "decisionTimeId": selectDecisionTimelineId,
        // "decisionTime": selectDecisionTimelineName,
        "compId": homeController.currentUserData?.compId,
        "branchId": homeController.currentUserData?.branchId,
        "userId": homeController.currentUserData?.userid,
        "yearId": homeController.currentUserData?.yearId,
        "leadItems": leadItems,
        "sourceid": sourcesId,
        "address": addressController.text,
      };

      log('Request Data for updateLeadEntry =================>>>>> $requestData');

      final result = await LeadManagementRepo.updateLeadEntry(requestData);

      if (result.statusCode == 200) {
        log('Lead updated successfully: ${jsonEncode(result)}');
        Get.snackbar("Success", "Lead updated successfully");
        Get.to(const LeadListScreen());
        getLeadEntryApiMethod();
        clearLeadData();
      } else {
        log('Error updating lead: ${result.message}');
        Get.snackbar("Error", result.message ?? "Failed to update lead");
      }
    } catch (e, s) {
      log("Error in updateLeadEntry: $e", stackTrace: s);
      Get.snackbar("Error", "An error occurred while updating lead");
    } finally {
      isLoading = false;
      update();
    }
  }

  void clearLeadData() {
    nameController.clear();
    companyController.clear();
    mobileController.clear();
    altContactController.clear();
    emailController.clear();
    websiteController.clear();
    leadDateController.clear();
    productsController.clear();
    lastCommDateController.clear();
    remarksController.clear();
    tagProducts.clear();
    addressController.clear();

    // Reset dropdowns and selected IDs
    businessType = '';
    selectedBusinessTypeId = null;

    industryType = '';
    selectedIndustryTypeId = null;

    interestedIn = '';
    interestedTypeId = null;

    selectCurrentSoftwareName = '';
    selectCurrentSoftwareId = null;

    selectDecisionTimelineName = '';
    selectDecisionTimelineId = null;
    sourcesId = null;
    sourcesType = "";
    previouslySelectedItems = [];
    previouslySelectedItems = [];
    selectedParty = null;
    partySuggestions.clear();
  }

  GetFollowUpsResponseModel? followUpsResponseModel;
  List<FollowUps> dataFollowups = [];

  Future<void> gettingFollowUp(int? id) async {
    try {
      isLoading = true;

      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "leadId": id,
        "type": "Followup"
      };

      log('requestData for insertedLeadFollowUp =================>>>>> $requestData');

      final result = await LeadManagementRepo.getNotesAndFollowupMethod(requestData);

      if (result.statusCode == 200) {
        followUpsResponseModel = GetFollowUpsResponseModel.fromJson(result.data);
        dataFollowups = followUpsResponseModel?.data?.toList() ?? [];
        log('dataFollowups ::::::::::::: ${jsonEncode(dataFollowups)}');
        update();
      } else {
        log("dataFollowups error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in dataFollowups: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> insertedLeadFollowUp(int? id) async {
    try {
      isLoading = true;

      if (selectedDateTime == null) {
        log('No date/time selected');
        return;
      }

      final String entryDate = DateFormat('yyyy-MM-dd').format(selectedDateTime!);
      final String entryTime = DateFormat('HH:mm:ss').format(selectedDateTime!);

      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString(),
        "leadId": id,
        "userid": homeController.currentUserData!.compId.toString(),
        "entrydate": entryDate,
        "entrytime": entryTime,
        "remarks": descController.text,
        "type": "Followup",
      };

      log('requestData for insertedLeadFollowUp =================>>>>> $requestData');

      final result = await LeadManagementRepo.insertLeadNotesAndFollowUp(requestData);

      if (result.statusCode == 200) {
        insertedLeadNotesResponseModel = InsertedLeadNotesResponseModel.fromJson(result.data);
        log('insertedLeadFollowUp ::::::::::::: ${jsonEncode(insertedLeadNotesResponseModel)}');
        update();
      } else {
        log("insertedLeadFollowUp error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in insertedLeadFollowUp: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  DeleteGetFollowUpsResponseModel? deleteGetFollowUpsResponseModel;

  Future<void> deleteFollowUpsNotes(int? id) async {
    try {
      isLoading = true;

      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "Id": id,
        "type": "Followup"
      };

      log('requestData for deleteFollowUpsNotes =================>>>>> $requestData');

      final result = await LeadManagementRepo.deleteNotes(requestData);

      if (result.statusCode == 200) {
        deleteGetFollowUpsResponseModel = DeleteGetFollowUpsResponseModel.fromJson(result.data);
        Get.snackbar(
            "Success", deleteGetFollowUpsResponseModel?.message ?? "Delete FollowUps SuccessFully..");
        update();
      } else {
        log("deleteFollowUpsNotes error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in deleteFollowUpsNotes: $e", stackTrace: s);
    } finally {
      isLoading = false;
      update();
    }
  }

  List<FollowUps> remarksList = [];

  Future<void> getRemarks(int? leadId, String type) async {
    try {
      isLoading = true;
      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "leadId": leadId,
        "type": type,
      };
      final result = await LeadManagementRepo.getNotesAndFollowupMethod(requestData);
      if (result.statusCode == 200) {
        followUpsResponseModel = GetFollowUpsResponseModel.fromJson(result.data);
        remarksList = followUpsResponseModel?.data ?? [];
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> insertRemark(int? leadId, String type) async {
    try {
      isLoading = true;

      // Date/time only matters for follow-up
      final date = DateFormat('yyyy-MM-dd').format(type == 'Followup' ? selectedDateTime! : DateTime.now());
      final time = DateFormat('HH:mm:ss').format(type == 'Followup' ? selectedDateTime! : DateTime.now());

      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "branchid": homeController.currentUserData!.branchId.toString(),
        "leadId": leadId,
        "userid": homeController.currentUserData!.compId.toString(),
        "entrydate": date,
        "entrytime": time,
        "remarks": descController.text,
        "type": type, // <── dynamic
      };
      await LeadManagementRepo.insertLeadNotesAndFollowUp(requestData);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteRemark(int? id, String type) async {
    try {
      isLoading = true;
      final requestData = {
        "compid": homeController.currentUserData!.compId.toString(),
        "Id": id,
        "type": type,
      };
      await LeadManagementRepo.deleteNotes(requestData);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Lead Management sources

  Future<void> leadSources() async {
    try {
      isLoading = true;

      final requestData = {"compid": homeController.currentUserData!.compId.toString()};

      log('requestData For leadSources =================>>>>> $requestData');

      final result = await LeadManagementRepo.leadSourcesMethod(requestData);

      if (result.statusCode == 200) {
        leadSourcesResponseModel = LeadSourcesResponseModel.fromJson(result.data);
        leadSourcesList = leadSourcesResponseModel?.data?.toList() ?? [];

        log('leadSources =================>>>>> ${jsonEncode(leadSourcesList)}');
      } else {
        log("leadSources error: ${result.message}");
      }
      update();
    } catch (e, s) {
      log("Error in leadSources: $e", stackTrace: s);
    } finally {
      isLoading = false;
    }
    update();
  }
}
