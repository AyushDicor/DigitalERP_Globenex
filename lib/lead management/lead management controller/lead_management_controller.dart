// import 'dart:convert';
// import 'package:digitalerp/screen/base/base_controller.dart';
// import 'package:digitalerp/screen/ui/home/home_controller.dart';
// import 'package:digitalerp/utils/app_constant.dart';
// import 'package:digitalerp/utils/show_message.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// class LeadManagementController extends AppBaseController {
//   HomeController homeController = Get.find<HomeController>();
//
//   //  Lead list (used by LeadManagementView) 
//   // Replace `dynamic` with your actual LeadData model once the API is wired up
//   List<dynamic> leadList = [];
//
//   //  Text controllers 
//   /// Lead entry
//   final TextEditingController leadNumberController = TextEditingController();
//   final TextEditingController requirementController = TextEditingController();
//   final TextEditingController companyNameController = TextEditingController();
//   final TextEditingController ownerNameController = TextEditingController();
//   final TextEditingController contactPersonController = TextEditingController();
//   final TextEditingController mobileNumberController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController alternateNumberController = TextEditingController();
//   final TextEditingController websiteController = TextEditingController();
//   final TextEditingController companyAddressController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();
//   final TextEditingController businessNatureController = TextEditingController();
//
//   /// Followup details
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController specificationController = TextEditingController();
//   final TextEditingController remarksController = TextEditingController();
//   final TextEditingController followupTimeController = TextEditingController();
//   final TextEditingController remarkFollowController = TextEditingController();
//
//   //  Focus nodes 
//   /// Lead entry
//   final FocusNode leadNoFocus = FocusNode();
//   final FocusNode requirementFocus = FocusNode();
//   final FocusNode companyNameFocus = FocusNode();
//   final FocusNode ownerNameFocus = FocusNode();
//   final FocusNode contactPersonFocus = FocusNode();
//   final FocusNode mobileNoFocus = FocusNode();
//   final FocusNode alternateNoFocus = FocusNode();
//   final FocusNode emailIdFocus = FocusNode();
//   final FocusNode websiteFocus = FocusNode();
//   final FocusNode companyAddresFocus = FocusNode();
//   final FocusNode phoneFocus = FocusNode();
//   final FocusNode businessFocus = FocusNode();
//
//   /// Followup details
//   final FocusNode addressFocus = FocusNode();
//   final FocusNode specificationFocus = FocusNode();
//   final FocusNode remarkFocus = FocusNode();
//   final FocusNode followupTimeFocus = FocusNode();
//   final FocusNode remarkFollowupFocus = FocusNode();
//
//   //  Observable 
//   RxBool isCheck = false.obs;
//
//   void onChangeValue(var value) {
//     isCheck.value = value;
//   }
//
//   //  Date fields 
//   String selectDate = 'Lead Date';
//   void setSelectedDate(String value) {
//     selectDate = value;
//     update();
//   }
//
//   void clearSelectedDate() {
//     selectDate = 'Lead Date';
//     update();
//   }
//
//   String selectDatef = 'Entry Date';
//   void setSelectedDatef(String value) {
//     selectDatef = value;
//     update();
//   }
//
//   void clearSelected() {
//     selectDatef = 'Entry Date';
//     update();
//   }
//
//   String selectDate2 = 'Entry Date';
//   void setSelectedDate2(String value) {
//     selectDate2 = value;
//     update();
//   }
//
//   void clearSelected2() {
//     selectDate2 = 'Entry Date';
//     update();
//   }
//
//   //  Validation 
//
//   bool _isLeadValidate() {
//     if (leadNumberController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt.tr, AppString.pleaseEnterLeadNo.tr);
//       return false;
//     }
//     if (requirementController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterRequirementSpecification.tr);
//       return false;
//     }
//     if (companyNameController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterCompanyName.tr);
//       return false;
//     }
//     if (ownerNameController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterOwnerName.tr);
//       return false;
//     }
//     if (contactPersonController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterContactPersonTxt.tr);
//       return false;
//     }
//     if (mobileNumberController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterMobileTxt.tr);
//       return false;
//     }
//     if (mobileNumberController.text.trim().length != 10) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterValidMobileTxt.tr);
//       return false;
//     }
//     if (alternateNumberController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterAlternateMobileNo.tr);
//       return false;
//     }
//     // ✅ FIX: was checking mobileNumber twice — now checks alternateNumber length
//     if (alternateNumberController.text.trim().length != 10) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr,
//           AppString.pleaseEnterValidMobileTxt.tr);
//       return false;
//     }
//     if (emailController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterEmailIdTxt.tr);
//       return false;
//     }
//     if (websiteController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterWebsite.tr);
//       return false;
//     }
//     if (companyAddressController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterCompanyAddress.tr);
//       return false;
//     }
//     if (phoneNumberController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterPhoneNo.tr);
//       return false;
//     }
//     if (businessNatureController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterBusinessNature.tr);
//       return false;
//     }
//     return true;
//   }
//
//   // ✅ FIX: Removed unreachable code that came after `return true` inside
//   // the nested block — the original had dead validation checks after that.
//   bool _isFollowupValidate() {
//     if (addressController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterAddress);
//       return false;
//     }
//     if (selectDatef == 'Entry Date') {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, 'Please Select Entry Date');
//       return false;
//     }
//     if (specificationController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(AppString.requiredFieldTxt,
//           AppString.pleaseEnterRequirementSpecification);
//       return false;
//     }
//     if (remarksController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterRemark);
//       return false;
//     }
//     if (followupTimeController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterFollowupTime);
//       return false;
//     }
//     if (remarkFollowController.text.trim().isEmpty) {
//       ShowMessage.showSnackBar(
//           AppString.requiredFieldTxt, AppString.pleaseEnterRemark);
//       return false;
//     }
//     return true;
//   }
//
//   //  API calls 
//
//   void addleadApi() async {
//     unfocus();
//     setBusy(true);
//     if (_isLeadValidate()) {
//       try {
//         // TODO: populate body with actual field values
//         final Map<String, String> body = {};
//         final res = await api.addCompanyJson(json.encode(body));
//         if (res.status == 200) {
//           backTap();
//           ShowMessage.showSnackBar(
//               'Success', res.message.toString());
//         } else {
//           ShowMessage.showSnackBar(
//               'Error', res.message.toString());
//         }
//       } catch (e) {
//         ShowMessage.showSnackBar('Error', '$e');
//       } finally {
//         setBusy(false);
//       }
//     } else {
//       setBusy(false);
//     }
//   }
//
//   void followupDetailsApi() async {
//     unfocus();
//     setBusy(true);
//     if (_isFollowupValidate()) {
//       try {
//         // TODO: populate body with actual field values
//         final Map<String, String> body = {};
//         final res = await api.addCompanyJson(json.encode(body));
//         if (res.status == 200) {
//           backTap();
//           ShowMessage.showSnackBar(
//               'Success', res.message.toString());
//         } else {
//           ShowMessage.showSnackBar(
//               'Error', res.message.toString());
//         }
//       } catch (e) {
//         ShowMessage.showSnackBar('Error', '$e');
//       } finally {
//         setBusy(false);
//       }
//     } else {
//       setBusy(false);
//     }
//   }
//
//   //  Dispose 
//
//   @override
//   void onClose() {
//     // Lead entry controllers
//     leadNumberController.dispose();
//     requirementController.dispose();
//     companyNameController.dispose();
//     ownerNameController.dispose();
//     contactPersonController.dispose();
//     mobileNumberController.dispose();
//     emailController.dispose();
//     alternateNumberController.dispose();
//     websiteController.dispose();
//     companyAddressController.dispose();
//     phoneNumberController.dispose();
//     businessNatureController.dispose();
//     // Followup controllers
//     addressController.dispose();
//     specificationController.dispose();
//     remarksController.dispose();
//     followupTimeController.dispose();
//     remarkFollowController.dispose();
//     super.onClose();
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:digitalerp/contactsview/Designation_dropdown_responce.dart';
import 'package:digitalerp/model/followup_option_response_model.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/model/lead_businesstype_response_model.dart';
import 'package:digitalerp/model/lead_existing_client_response_model.dart';
import 'package:digitalerp/model/lead_industry_response_model.dart';
import 'package:digitalerp/model/lead_sources_response_model.dart';
import 'package:digitalerp/repo/lead_management_repo.dart';
import 'package:digitalerp/response/area_data_response.dart';
import 'package:digitalerp/response/city_data_response.dart';
import 'package:digitalerp/response/executive_list_response.dart';
import 'package:digitalerp/response/state_data_response.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/approval/approval_filtter/approval_filtter_responce/client_list_responce.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
import 'package:digitalerp/screen/ui/home/indent/indent_response/indent_model.dart';
import 'package:digitalerp/services/api_service/request_keys.dart';
import 'package:digitalerp/utils/app_constant.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LeadManagementController extends AppBaseController {
  HomeController homeController = Get.find<HomeController>();

  //  Lead list
  List<GetleadentryList> leadList = [];

  // ─────────────────────────────────────────────────────────────────────
  //  Lead entry dropdowns: State → City → Area (cascading) and Source.
  //  Previously these were `_DropdownRow` widgets in the view — a grey box
  //  with a chevron and no data, no state and no tap handler.
  // ─────────────────────────────────────────────────────────────────────
  List<StateDataList> stateList = [];
  List<CityDataList> cityList = [];
  List<AreaDataList> areaList = [];
  List<LeadSourcesData> sourceList = [];

  StateDataList? selectedState;
  CityDataList? selectedCity;
  AreaDataList? selectedArea;
  LeadSourcesData? selectedSource;

  bool isStateLoading = false;
  bool isCityLoading = false;
  bool isAreaLoading = false;

  // ─────────────────────────────────────────────────────────────────────
  //  Business Type — replaces the free-text "Business Nature" field.
  //
  //  Same master the lead DETAIL screen uses (BusinessType/BusinessTypedropdown),
  //  so the value picked here is one the detail screen can render back. Unlike
  //  state/city/area this one really is stored: Leadedit/getlead returns
  //  BusinessTypeId + BusinessType.
  // ─────────────────────────────────────────────────────────────────────
  List<LeadBusinessList> businessTypeOptions = [];
  LeadBusinessList? selectedBusinessType;
  bool isBusinessTypeLoading = false;

  // ─────────────────────────────────────────────────────────────────────
  //  Industry Type — same master as the lead detail screen
  //  (IndustryType/IndustryTypedropdown). Stored: Leadedit/getlead returns
  //  IndustryTypeId + IndustryType.
  // ─────────────────────────────────────────────────────────────────────
  List<LeadIndustry> industryTypeOptions = [];
  LeadIndustry? selectedIndustryType;
  bool isIndustryTypeLoading = false;

  // ─────────────────────────────────────────────────────────────────────
  //  Priority — sourced from the shared indent/issue dropdown master
  //  (POST indentandissuedropdown, type "Priority"), the same one the Indent
  //  header screen uses. There is no lead-specific Priority master.
  // ─────────────────────────────────────────────────────────────────────
  List<IndentDropdownOption> priorityOptions = [];
  IndentDropdownOption? selectedPriority;
  bool isPriorityLoading = false;

  // ─────────────────────────────────────────────────────────────────────
  //  Lead Type — a fixed two-value list, no API. There is no Lead Type
  //  master on the server (all candidate paths 404) and only these two
  //  values are in use.
  // ─────────────────────────────────────────────────────────────────────
  final List<String> leadTypeOptions = const ['Existing Client', 'Direct'];
  String? selectedLeadType;

  // ─────────────────────────────────────────────────────────────────────
  //  Designation — was a decorative `_DropdownRow`. The master always
  //  existed (designationlist/desinationdropdown, note the real "desination"
  //  typo in the path and the "designnation" double-n in the keys); what was
  //  missing was somewhere to store it. leadentrywithstatecity now takes
  //  DesignationId + Designation — verified round-tripping on a test lead.
  // ─────────────────────────────────────────────────────────────────────
  List<DesignationData> designationOptions = [];
  DesignationData? selectedDesignation;
  bool isDesignationLoading = false;

  /// Country is stored on the lead (`countryid`) but has no master endpoint —
  /// every path probed returns 404 and every record on this account is India.
  /// Sent as a constant until the backend ships a country list.
  static const int kDefaultCountryId = 1000;
  static const String kDefaultCountryName = 'India';

  // ─────────────────────────────────────────────────────────────────────
  //  Company Name — picker over the client master used by the Approval
  //  filter (Allclientlistfilter/clientdrpdon, 274 rows on this account).
  //
  //  It is a PICKER, not a closed dropdown: a lead is often a company that
  //  is not a client yet, so a name typed in the search box can still be
  //  used as-is. `companyNameController` stays the source of truth for
  //  validation and for the save body; `selectedClient` is set only when
  //  the name came from the master.
  // ─────────────────────────────────────────────────────────────────────
  List<ClientListData> clientOptions = [];
  ClientListData? selectedClient;
  bool isClientLoading = false;

  // ─────────────────────────────────────────────────────────────────────
  //  Follow-up detail: Handler Name and Executive.
  //
  //  Both were `_dropdownShell` placeholders — hardcoded `items: []` AND
  //  `onChanged: null`, so neither could ever open. Both now list the
  //  company's executives from ExecutiveReportPerson/ExecutiveReportPersonList,
  //  the same master the Approval hub and the visit screens use.
  //
  //  NOTE: the follow-up record has no handler or executive column yet —
  //  insertleadfollowup/leadfollowup accepts only remarks + entrydate/entrytime
  //  — so a pick shows correctly but is not persisted.
  // ─────────────────────────────────────────────────────────────────────
  List<ExecutiveList> executiveOptions = [];
  ExecutiveList? selectedHandler;
  ExecutiveList? selectedExecutive;
  bool isExecutiveLoading = false;

  // ─────────────────────────────────────────────────────────────────────
  //  Follow-up detail: Status and Purpose.
  //
  //  Both masters are being built by the backend team. Until they deploy,
  //  the endpoints 404 and these lists stay empty, which leaves the dropdown
  //  disabled showing "not available yet" — no error, no crash. Nothing here
  //  needs changing when they go live; the values simply appear.
  // ─────────────────────────────────────────────────────────────────────
  List<FollowupOption> statusOptions = [];
  FollowupOption? selectedStatus;
  bool isStatusLoading = false;

  List<FollowupOption> purposeOptions = [];
  FollowupOption? selectedPurpose;
  bool isPurposeLoading = false;

  @override
  void onInit() {
    super.onInit();
    getLeadList(); // ✅ FIX: fetch leads on init so the list is never null/empty
    getStateList();
    getSourceList();
    getBusinessTypeList();
    getIndustryTypeList();
    getDesignationList();
    getPriorityList();
    getClientList();
    getExecutiveList();
    getFollowupStatusList();
    getFollowupPurposeList();
  }

  //  State / City / Area

  Future<void> getStateList() async {
    isStateLoading = true;
    update();
    try {
      Map<String, String> body = {
        RequestKeys.compId: homeController.currentUserData?.compId.toString() ?? '',
      };
      var res = await api.getStateData(body);
      if (res.status == 200) stateList = res.data ?? [];
    } catch (e) {
      log('getStateList error: $e');
    } finally {
      isStateLoading = false;
      update();
    }
  }

  Future<void> onStateChanged(StateDataList? value) async {
    selectedState = value;
    // Changing State invalidates the City and Area beneath it.
    selectedCity = null;
    selectedArea = null;
    cityList = [];
    areaList = [];
    update();
    if (value?.stateid == null) return;
    await getCityList(value!.stateid.toString());
  }

  Future<void> getCityList(String stateId) async {
    isCityLoading = true;
    update();
    try {
      Map<String, String> body = {
        RequestKeys.compId: homeController.currentUserData?.compId.toString() ?? '',
        RequestKeys.stateId: stateId,
      };
      var res = await api.getCityData(body);
      // No `.first` auto-select here — that pattern crashes on a state with no
      // cities and silently applies a value the user never chose.
      if (res.status == 200) cityList = res.data ?? [];
    } catch (e) {
      log('getCityList error: $e');
    } finally {
      isCityLoading = false;
      update();
    }
  }

  Future<void> onCityChanged(CityDataList? value) async {
    selectedCity = value;
    selectedArea = null;
    areaList = [];
    update();
    if (value?.cityid == null) return;
    await getAreaList(value!.cityid.toString());
  }

  Future<void> getAreaList(String cityId) async {
    isAreaLoading = true;
    update();
    try {
      Map<String, String> body = {
        RequestKeys.compId: homeController.currentUserData?.compId.toString() ?? '',
        RequestKeys.cityId: cityId,
      };
      var res = await api.getAreaData(body);
      if (res.status == 200) areaList = res.data ?? [];
    } catch (e) {
      log('getAreaList error: $e');
    } finally {
      isAreaLoading = false;
      update();
    }
  }

  void onAreaChanged(AreaDataList? value) {
    selectedArea = value;
    update();
  }

  //  Source

  Future<void> getSourceList() async {
    try {
      final requestData = {
        "compid": homeController.currentUserData?.compId.toString() ?? '',
      };
      final result = await LeadManagementRepo.leadSourcesMethod(requestData);
      if (result.statusCode == 200 && result.data != null) {
        sourceList = LeadSourcesResponseModel.fromJson(result.data).data ?? [];
      }
    } catch (e) {
      log('getSourceList error: $e');
    }
    update();
  }

  void onSourceChanged(LeadSourcesData? value) {
    selectedSource = value;
    update();
  }

  //  Business Type

  Future<void> getBusinessTypeList() async {
    isBusinessTypeLoading = true;
    update();
    try {
      final requestData = {
        "compid": homeController.currentUserData?.compId.toString() ?? '',
      };
      final result = await LeadManagementRepo.businessTypeMethod(requestData);
      if (result.statusCode == 200 && result.data != null) {
        businessTypeOptions =
            LeadBusinessResponseModel.fromJson(result.data).data ?? [];
      }
    } catch (e) {
      log('getBusinessTypeList error: $e');
    } finally {
      isBusinessTypeLoading = false;
      update();
    }
  }

  void onBusinessTypeChanged(LeadBusinessList? value) {
    selectedBusinessType = value;
    update();
  }

  //  Industry Type

  Future<void> getIndustryTypeList() async {
    isIndustryTypeLoading = true;
    update();
    try {
      final requestData = {
        "compid": homeController.currentUserData?.compId.toString() ?? '',
      };
      final result = await LeadManagementRepo.industryTypeMethod(requestData);
      if (result.statusCode == 200 && result.data != null) {
        industryTypeOptions =
            LeadIndustryResponseModel.fromJson(result.data).data ?? [];
      }
    } catch (e) {
      log('getIndustryTypeList error: $e');
    } finally {
      isIndustryTypeLoading = false;
      update();
    }
  }

  void onIndustryTypeChanged(LeadIndustry? value) {
    selectedIndustryType = value;
    update();
  }

  //  Designation

  Future<void> getDesignationList() async {
    isDesignationLoading = true;
    update();
    try {
      Map<String, String> body = {
        RequestKeys.userId:
            homeController.currentUserData?.userid.toString() ?? '',
        RequestKeys.compId:
            homeController.currentUserData?.compId.toString() ?? '',
        RequestKeys.partyId: '0',
      };
      var res = await api.getSDesignationDropdown(body);
      if (res.status == 200) designationOptions = res.data ?? [];
    } catch (e) {
      log('getDesignationList error: $e');
    } finally {
      isDesignationLoading = false;
      update();
    }
  }

  void onDesignationChanged(DesignationData? value) {
    selectedDesignation = value;
    update();
  }

  //  Priority

  Future<void> getPriorityList() async {
    isPriorityLoading = true;
    update();
    try {
      final res = await api.getIndentDropdownList({
        'type': 'Priority',
        'compid': homeController.currentUserData?.compId ?? 0,
        'branchid': homeController.currentUserData?.branchId ?? 0,
        'userid': homeController.currentUserData?.userid ?? 0,
        'siteid': 0,
        'partyid': 0,
        'dependentid': 0,
      });
      if ((res.success == true || res.status == 200) && res.data.isNotEmpty) {
        priorityOptions = res.data;
      }
    } catch (e) {
      log('getPriorityList error: $e');
    } finally {
      isPriorityLoading = false;
      update();
    }
  }

  void onPriorityChanged(IndentDropdownOption? value) {
    selectedPriority = value;
    update();
  }

  //  Lead Type (static)

  void onLeadTypeChanged(String? value) {
    selectedLeadType = value;
    update();
  }

  //  Company Name / client master

  Future<void> getClientList() async {
    isClientLoading = true;
    update();
    try {
      Map<String, String> body = {
        RequestKeys.userId:
            homeController.currentUserData?.userid.toString() ?? '',
        RequestKeys.compId:
            homeController.currentUserData?.compId.toString() ?? '',
        RequestKeys.branchId:
            homeController.currentUserData?.branchId.toString() ?? '',
      };
      var res = await api.getClientData(body);
      if (res.status == 200) clientOptions = res.data ?? [];
    } catch (e) {
      log('getClientList error: $e');
    } finally {
      isClientLoading = false;
      update();
    }
  }

  /// Contacts belonging to the picked client. When this is non-empty the
  /// Contact Person field becomes a dropdown of these people instead of a
  /// free-text box; choosing one fills their mobile and email too.
  List<ClientContact> clientContacts = [];
  ClientContact? selectedContact;
  bool isClientDetailLoading = false;

  /// Company picked from the client master — keeps the id alongside the name
  /// and pulls the rest of the company's details so the user doesn't retype
  /// what the ERP already knows.
  void onClientChanged(ClientListData? value) {
    selectedClient = value;
    companyNameController.text = value?.clientname ?? '';
    clientContacts = [];
    selectedContact = null;
    contactPersonController.clear();
    update();
    if (value?.clientid != null) {
      applyExistingClient(value!.clientid!.toInt());
    }
  }

  /// Company typed by hand because it is not a client yet — no id to keep,
  /// and nothing to prefill.
  void setCompanyNameManually(String value) {
    selectedClient = null;
    clientContacts = [];
    selectedContact = null;
    companyNameController.text = value.trim();
    update();
  }

  /// Pulls the client's stored details and fills the form from them.
  ///
  /// `leadexistingclientdetail` returns mobile, email, business type and the
  /// country/state/city/area ids, plus the company's contact people. Only
  /// fields the client actually has values for are overwritten — a blank on
  /// the server never wipes something the user already typed.
  Future<void> applyExistingClient(int partyId) async {
    isClientDetailLoading = true;
    update();
    try {
      final result = await LeadManagementRepo.leadExistingClientDetailMethod({
        "compid": homeController.currentUserData?.compId.toString() ?? '',
        "branchid": homeController.currentUserData?.branchId.toString() ?? '',
        "userid": homeController.currentUserData?.userid.toString() ?? '',
        "partyid": partyId,
      });

      if (result.statusCode != 200 || result.data == null) {
        log('applyExistingClient: no detail for party $partyId');
        return;
      }

      final detail = LeadExistingClientResponse.fromJson(result.data).data;
      if (detail == null) return;

      if ((detail.partyname ?? '').isNotEmpty) {
        companyNameController.text = detail.partyname!;
      }
      if ((detail.mobileno ?? '').isNotEmpty) {
        mobileNumberController.text = detail.mobileno!;
      }
      if ((detail.emailid ?? '').isNotEmpty) {
        emailController.text = detail.emailid!;
      }

      // Business Type — match by id against the already-loaded master.
      if (detail.businesstypeid != null) {
        final match = _firstOrNull(businessTypeOptions,
            (e) => e.businessTypeid == detail.businesstypeid);
        if (match != null) selectedBusinessType = match;
      }

      clientContacts = detail.contactlist;
      update();

      await _applyClientLocation(detail);
    } catch (e) {
      log('applyExistingClient error: $e');
    } finally {
      isClientDetailLoading = false;
      update();
    }
  }

  /// Walks the State → City → Area cascade for a prefilled client.
  ///
  /// Each level has to be fetched before the next can be matched, so this
  /// awaits the loaders rather than firing them and hoping.
  Future<void> _applyClientLocation(LeadExistingClient detail) async {
    if (detail.stateid == null) return;

    final state = _firstOrNull(stateList, (e) => e.stateid == detail.stateid);
    if (state == null) return;

    selectedState = state;
    selectedCity = null;
    selectedArea = null;
    cityList = [];
    areaList = [];
    update();

    await getCityList(detail.stateid.toString());
    final city = _firstOrNull(cityList, (e) => e.cityid == detail.cityid);
    if (city == null) {
      update();
      return;
    }
    selectedCity = city;
    update();

    await getAreaList(detail.cityid.toString());
    final area = _firstOrNull(areaList, (e) => e.areaid == detail.areaid);
    if (area != null) selectedArea = area;
    update();
  }

  /// Local stand-in for firstWhereOrNull — `firstWhere` without an `orElse`
  /// throws StateError on no match, which has already caused crashes here.
  T? _firstOrNull<T>(List<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Contact person chosen from the client's own contact list.
  ///
  /// Also fills that person's mobile and email — the whole point of the
  /// prefill is that the user shouldn't retype what the ERP already holds.
  /// A contact with no mobile/email on file leaves those fields alone rather
  /// than blanking whatever is already there.
  void onContactPersonChanged(ClientContact? contact) {
    selectedContact = contact;
    if (contact == null) {
      update();
      return;
    }
    contactPersonController.text = contact.contactperson ?? '';
    if ((contact.mobileno ?? '').isNotEmpty) {
      mobileNumberController.text = contact.mobileno!;
    }
    if ((contact.emailid ?? '').isNotEmpty) {
      emailController.text = contact.emailid!;
    }
    update();
  }

  //  Executives — feeds both Handler Name and Executive on the follow-up screen

  Future<void> getExecutiveList() async {
    isExecutiveLoading = true;
    update();
    try {
      Map<String, String> body = {
        RequestKeys.compId:
            homeController.currentUserData?.compId.toString() ?? '',
        RequestKeys.branchId:
            homeController.currentUserData?.branchId.toString() ?? '',
        RequestKeys.userId:
            homeController.currentUserData?.userid.toString() ?? '',
      };
      var res = await api.getExecutiveListData(body);
      if (res.status == 200) executiveOptions = res.data ?? [];
    } catch (e) {
      log('getExecutiveList error: $e');
    } finally {
      isExecutiveLoading = false;
      update();
    }
  }

  void onHandlerChanged(ExecutiveList? value) {
    selectedHandler = value;
    update();
  }

  void onExecutiveChanged(ExecutiveList? value) {
    selectedExecutive = value;
    update();
  }

  //  Follow-up Status / Purpose masters

  Future<void> getFollowupStatusList() async {
    isStatusLoading = true;
    update();
    try {
      final requestData = {
        "compid": homeController.currentUserData?.compId.toString() ?? '',
      };
      final result = await LeadManagementRepo.followupStatusMethod(requestData);
      if (result.statusCode == 200 && result.data != null) {
        statusOptions = FollowupOptionResponse.fromJson(result.data).data ?? [];
      } else {
        // 404 while the endpoint is still being built — leave the list empty
        // so the dropdown renders disabled instead of showing an error.
        log('followup status master not available yet: ${result.message}');
      }
    } catch (e) {
      log('getFollowupStatusList error: $e');
    } finally {
      isStatusLoading = false;
      update();
    }
  }

  Future<void> getFollowupPurposeList() async {
    isPurposeLoading = true;
    update();
    try {
      final requestData = {
        "compid": homeController.currentUserData?.compId.toString() ?? '',
      };
      final result = await LeadManagementRepo.followupPurposeMethod(requestData);
      if (result.statusCode == 200 && result.data != null) {
        purposeOptions = FollowupOptionResponse.fromJson(result.data).data ?? [];
      } else {
        log('followup purpose master not available yet: ${result.message}');
      }
    } catch (e) {
      log('getFollowupPurposeList error: $e');
    } finally {
      isPurposeLoading = false;
      update();
    }
  }

  void onFollowupStatusChanged(FollowupOption? value) {
    selectedStatus = value;
    update();
  }

  void onFollowupPurposeChanged(FollowupOption? value) {
    selectedPurpose = value;
    update();
  }

  void clearFollowupDropdowns() {
    selectedHandler = null;
    selectedExecutive = null;
    selectedStatus = null;
    selectedPurpose = null;
    update();
  }

  // ─────────────────────────────────────────────────────────────────────
  //  Lead LIST filter (client-side).
  //
  //  getleadentry/getleadentry accepts no filter parameters and returns only
  //  6 fields per lead — LeadEntryId, LeadName, CompanyName, MobileNo,
  //  LeadDate, Ageing. So those are the only things that can be filtered on.
  //  "Lead Type", "Status" and "Handler" are not in the list payload at all,
  //  which is why those dropdowns could never have worked.
  // ─────────────────────────────────────────────────────────────────────
  String? filterCompany;
  String? filterContact;
  DateTime? filterFromDate;
  DateTime? filterToDate;

  /// Distinct company names present in the loaded leads.
  List<String> get filterCompanyOptions {
    final s = leadList
        .map((e) => e.companyName.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return s;
  }

  /// Distinct contact names present in the loaded leads.
  List<String> get filterContactOptions {
    final s = leadList
        .map((e) => e.leadName.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return s;
  }

  bool get isLeadFilterActive =>
      filterCompany != null ||
      filterContact != null ||
      filterFromDate != null ||
      filterToDate != null;

  /// LeadDate arrives as dd-MM-yyyy.
  DateTime? _parseLeadDate(String raw) {
    final p = raw.split('-');
    if (p.length != 3) return null;
    return DateTime.tryParse('${p[2]}-${p[1]}-${p[0]}');
  }

  List<GetleadentryList> get filteredLeadList {
    return leadList.where((e) {
      if (filterCompany != null && e.companyName.trim() != filterCompany) {
        return false;
      }
      if (filterContact != null && e.leadName.trim() != filterContact) {
        return false;
      }
      if (filterFromDate != null || filterToDate != null) {
        final d = _parseLeadDate(e.leadDate);
        if (d == null) return false;
        if (filterFromDate != null && d.isBefore(filterFromDate!)) return false;
        if (filterToDate != null) {
          final end = DateTime(filterToDate!.year, filterToDate!.month,
              filterToDate!.day, 23, 59, 59);
          if (d.isAfter(end)) return false;
        }
      }
      return true;
    }).toList();
  }

  void setLeadFilterCompany(String? v) { filterCompany = v; update(); }
  void setLeadFilterContact(String? v) { filterContact = v; update(); }
  void setLeadFilterFromDate(DateTime? v) { filterFromDate = v; update(); }
  void setLeadFilterToDate(DateTime? v) { filterToDate = v; update(); }

  void resetLeadFilter() {
    filterCompany = null;
    filterContact = null;
    filterFromDate = null;
    filterToDate = null;
    update();
  }

  void clearLeadEntryDropdowns() {
    selectedState = null;
    selectedCity = null;
    selectedArea = null;
    selectedSource = null;
    selectedBusinessType = null;
    selectedIndustryType = null;
    selectedPriority = null;
    selectedLeadType = null;
    selectedClient = null;
    cityList = [];
    areaList = [];
    update();
  }

  /// Fetch the lead list from the existing getleadentry endpoint.
  ///
  /// This used to be a placeholder that unconditionally set `leadList = []`,
  /// so the Lead Management list was permanently empty even though the data
  /// existed. `getleadentry/getleadentry` was already declared in base_url.dart
  /// but never called from anywhere — no new backend work was needed.
  void getLeadList() async {
    setBusy(true);
    try {
      final requestData = {
        "userId": homeController.currentUserData?.userid.toString() ?? '',
        "compId": homeController.currentUserData?.compId.toString() ?? '',
        "branchid": homeController.currentUserData?.branchId.toString() ?? '',
      };
      final result = await LeadManagementRepo.getLeadEntryMethod(requestData);
      if (result.statusCode == 200 && result.data != null) {
        final model = GetleadentryResponseModel.fromJson(result.data);
        leadList = model.data.toList();
      } else {
        leadList = [];
      }
    } catch (e) {
      ShowMessage.showSnackBar('Error', '$e');
    } finally {
      setBusy(false);
    }
  }

  //  Text controllers 
  /// Lead entry
  final TextEditingController leadNumberController = TextEditingController();
  final TextEditingController requirementController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController alternateNumberController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController companyAddressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController businessNatureController = TextEditingController();

  /// Followup details
  final TextEditingController addressController = TextEditingController();
  final TextEditingController specificationController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController followupTimeController = TextEditingController();
  final TextEditingController remarkFollowController = TextEditingController();

  //  Focus nodes 
  final FocusNode leadNoFocus = FocusNode();
  final FocusNode requirementFocus = FocusNode();
  final FocusNode companyNameFocus = FocusNode();
  final FocusNode ownerNameFocus = FocusNode();
  final FocusNode contactPersonFocus = FocusNode();
  final FocusNode mobileNoFocus = FocusNode();
  final FocusNode alternateNoFocus = FocusNode();
  final FocusNode emailIdFocus = FocusNode();
  final FocusNode websiteFocus = FocusNode();
  final FocusNode companyAddresFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode businessFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode specificationFocus = FocusNode();
  final FocusNode remarkFocus = FocusNode();
  final FocusNode followupTimeFocus = FocusNode();
  final FocusNode remarkFollowupFocus = FocusNode();

  //  Observables 
  RxBool isCheck = false.obs;

  void onChangeValue(var value) {
    isCheck.value = value;
  }

  //  Date fields 
  String selectDate = 'Lead Date';
  void setSelectedDate(String value) { selectDate = value; update(); }
  void clearSelectedDate() { selectDate = 'Lead Date'; update(); }

  String selectDatef = 'Entry Date';
  void setSelectedDatef(String value) { selectDatef = value; update(); }
  void clearSelected() { selectDatef = 'Entry Date'; update(); }

  String selectDate2 = 'Entry Date';
  void setSelectedDate2(String value) { selectDate2 = value; update(); }
  void clearSelected2() { selectDate2 = 'Entry Date'; update(); }

  //  Validation 
  bool _isLeadValidate() {
    if (leadNumberController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterLeadNo.tr);
      return false;
    }
    if (requirementController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterRequirementSpecification.tr);
      return false;
    }
    if (companyNameController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterCompanyName.tr);
      return false;
    }
    if (ownerNameController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterOwnerName.tr);
      return false;
    }
    if (contactPersonController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterContactPersonTxt.tr);
      return false;
    }
    if (mobileNumberController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterMobileTxt.tr);
      return false;
    }
    if (mobileNumberController.text.trim().length != 10) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterValidMobileTxt.tr);
      return false;
    }
    if (alternateNumberController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterAlternateMobileNo.tr);
      return false;
    }
    // ✅ FIX: was checking mobileNumber length twice — now correctly checks alternateNumber
    if (alternateNumberController.text.trim().length != 10) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt.tr, AppString.pleaseEnterValidMobileTxt.tr);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterEmailIdTxt.tr);
      return false;
    }
    if (websiteController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterWebsite.tr);
      return false;
    }
    if (companyAddressController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterCompanyAddress.tr);
      return false;
    }
    if (phoneNumberController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterPhoneNo.tr);
      return false;
    }
    // Business Nature was a free-text field and was mandatory; Business Type
    // replaces it and stays mandatory. Priority and Lead Type are left
    // optional — the lead record has no column for either yet.
    if (selectedBusinessType == null) {
      ShowMessage.showSnackBar(
          AppString.requiredFieldTxt, 'Please select Business Type');
      return false;
    }
    return true;
  }

  bool _isFollowupValidate() {
    if (addressController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterAddress);
      return false;
    }
    if (selectDatef == 'Entry Date') {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, 'Please Select Entry Date');
      return false;
    }
    if (specificationController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterRequirementSpecification);
      return false;
    }
    if (remarksController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterRemark);
      return false;
    }
    if (followupTimeController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterFollowupTime);
      return false;
    }
    if (remarkFollowController.text.trim().isEmpty) {
      ShowMessage.showSnackBar(AppString.requiredFieldTxt, AppString.pleaseEnterRemark);
      return false;
    }
    return true;
  }

  //  API calls
  /// Save a new lead.
  ///
  /// This used to post an EMPTY body to `addCompanyJson` with a
  /// "TODO: populate body with actual field values" comment — so nothing the
  /// user typed was ever saved.
  ///
  /// Now posts to `leadentrywithstatecity`. Key names mirror what
  /// `Leadeditwithstatecity` returns — confirmed 2026-08-04 by saving a
  /// throwaway lead and reading every field back before deleting it.
  /// The one field with nowhere to go is Phone No.
  void addleadApi() async {
    unfocus();
    setBusy(true);
    if (_isLeadValidate()) {
      try {
        final String leadDate = (selectDate == 'Lead Date') ? '' : selectDate;
        final Map<String, dynamic> body = {
          "leadName": contactPersonController.text.trim(),
          "companyName": companyNameController.text.trim(),
          // Set only when the company came from the client master; a lead for
          // a company that is not a client yet sends 0.
          "companyid": selectedClient?.clientid ?? 0,
          "OwnerName": ownerNameController.text.trim(),
          "mobileNo": mobileNumberController.text.trim(),
          "alternateMobile": alternateNumberController.text.trim(),
          // Phone No. is the one form field with no column on the lead record
          // — sent, but not returned by any read endpoint.
          "phoneNo": phoneNumberController.text.trim(),
          "email": emailController.text.trim(),
          "website": websiteController.text.trim(),
          "address": companyAddressController.text.trim(),
          // Business Type replaces the old free-text "businessNature". These
          // two keys are the ones the lead detail reads back, and the same
          // ones the ported lead edit form posts.
          "businessTypeId": selectedBusinessType?.businessTypeid ?? 0,
          "businessType": selectedBusinessType?.businessType ?? '',
          "industryTypeId": selectedIndustryType?.industryTypeid ?? 0,
          "industryType": selectedIndustryType?.industryType ?? '',
          "requirement": requirementController.text.trim(),
          "leadDate": leadDate,
          "sourceid": selectedSource?.sourceid ?? 0,
          "source": selectedSource?.sourcename ?? '',
          // Everything below is stored by leadentrywithstatecity. The old
          // leadentry/saveleadentry silently dropped all of it.
          "Priority": selectedPriority?.label ?? '',
          "leadtype": selectedLeadType ?? '',
          "DesignationId": selectedDesignation?.designnationid ?? 0,
          "Designation": selectedDesignation?.designnation ?? '',
          // No country master exists — see kDefaultCountryId.
          "countryid": kDefaultCountryId,
          "countryname": kDefaultCountryName,
          "stateid": selectedState?.stateid ?? 0,
          "statename": selectedState?.statename ?? '',
          "cityid": selectedCity?.cityid ?? 0,
          "cityname": selectedCity?.cityname ?? '',
          "areaid": selectedArea?.areaid ?? 0,
          "areaname": selectedArea?.areaname ?? '',
          "compId": homeController.currentUserData?.compId,
          "branchId": homeController.currentUserData?.branchId,
          "userId": homeController.currentUserData?.userid,
          "yearId": homeController.currentUserData?.yearId,
        };
        log('addleadApi body => ${json.encode(body)}');
        final res =
            await LeadManagementRepo.saveLeadEntryWithStateCityMethod(body);
        if (res.statusCode == 200 && (res.data?["success"] == true)) {
          backTap();
          // ✅ Refresh the list after a successful add
          getLeadList();
          ShowMessage.showSnackBar('Success', res.data?["message"]?.toString() ?? 'Lead saved');
        } else {
          ShowMessage.showSnackBar(
              'Could not save lead', res.data?["message"]?.toString() ?? res.message.toString());
        }
      } catch (e) {
        ShowMessage.showSnackBar('Error', '$e');
      } finally {
        setBusy(false);
      }
    } else {
      setBusy(false);
    }
  }

  void followupDetailsApi() async {
    unfocus();
    setBusy(true);
    if (_isFollowupValidate()) {
      try {
        // TODO: populate body with actual field values
        final Map<String, String> body = {};
        final res = await api.addCompanyJson(json.encode(body));
        if (res.status == 200) {
          backTap();
          ShowMessage.showSnackBar('Success', res.message.toString());
        } else {
          ShowMessage.showSnackBar('Error', res.message.toString());
        }
      } catch (e) {
        ShowMessage.showSnackBar('Error', '$e');
      } finally {
        setBusy(false);
      }
    } else {
      setBusy(false);
    }
  }

  //  Dispose 
  @override
  void onClose() {
    leadNumberController.dispose();
    requirementController.dispose();
    companyNameController.dispose();
    ownerNameController.dispose();
    contactPersonController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    alternateNumberController.dispose();
    websiteController.dispose();
    companyAddressController.dispose();
    phoneNumberController.dispose();
    businessNatureController.dispose();
    addressController.dispose();
    specificationController.dispose();
    remarksController.dispose();
    followupTimeController.dispose();
    remarkFollowController.dispose();
    super.onClose();
  }
}