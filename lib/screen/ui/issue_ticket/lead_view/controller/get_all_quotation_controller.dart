// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:digitalerp/model/get_all_quotation_model.dart';
// import 'package:digitalerp/model/getleadentry_response_model.dart';
// import 'package:digitalerp/repo/lead_management_repo.dart';
// import 'package:digitalerp/screen/ui/home/home_controller.dart';
// import 'package:get/get.dart';
//
// class GetAllQuotationController extends GetxController {
//   HomeController homeController = Get.find<HomeController>();
//
//   // Make lead reactive if needed
//   Rxn<GetleadentryList> lead = Rxn<GetleadentryList>();
//
//   // Make quotations reactive
//   Rxn<GetAllQuotation> getAllQuotation = Rxn<GetAllQuotation>();
//
//   // Make loading reactive
//   RxBool isLoading = false.obs;
//   // Rxn<GetleadentryList> lead = Rxn<GetleadentryList>();
//   // Rxn<GetAllQuotation> getAllQuotation = Rxn<GetAllQuotation>();
//   // RxBool isLoading = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     getArgument();
//   }
//
//   void getArgument() {
//     lead.value = Get.arguments;
//     if (lead.value != null) {
//       log('leadEntryId => ${lead.value?.leadEntryId}');
//       getAllList();
//     } else {
//       log('❌ Lead argument is null!');
//     }
//   }
//
//   Future<void> getAllList() async {
//     try {
//       isLoading.value = true;
//
//       log('homeController.currentUserData?.userid=================>>>>>${homeController.currentUserData?.userid}');
//       final requestData = {
//         "userid": homeController.currentUserData?.userid,
//         "yearid": homeController.currentUserData?.yearId.toString() ?? '',
//         "leadid": lead.value?.leadEntryId ?? 0,
//         "compid": homeController.currentUserData?.compId,
//         "branchid": homeController.currentUserData?.branchId,
//       };
//
//       log('requestData for getAddQuotes =================>>>>> $requestData');
//
//       final result = await LeadManagementRepo.getAllQuotationMethod(requestData);
//
//       if (result.statusCode == 200) {
//         getAllQuotation.value = GetAllQuotation.fromJson(result.data);
//         log('getQuote=================>>>>>${jsonEncode(getAllQuotation.value)}');
//       } else {
//         log("getAddQuotes error: ${result.message}");
//       }
//     } catch (e, s) {
//       log("Error in getAddQuotes: $e", stackTrace: s);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> getAllLists({int? leadId}) async {
//     try {
//       isLoading.value = true;
//
//       log('homeController.currentUserData?.userid=================>>>>>${homeController.currentUserData?.userid}');
//       final requestData = {
//         "userid": homeController.currentUserData?.userid,
//         "yearid": homeController.currentUserData?.yearId.toString() ?? '',
//         "leadid": leadId ?? 0,
//         "compid": homeController.currentUserData?.compId,
//         "branchid": homeController.currentUserData?.branchId,
//       };
//
//       log('requestData for getAddQuotess =================>>>>> $requestData');
//
//       final result = await LeadManagementRepo.getAllQuotationMethod(requestData);
//
//       if (result.statusCode == 200) {
//         getAllQuotation.value = GetAllQuotation.fromJson(result.data);
//         log('getQuote=================>>>>>${jsonEncode(getAllQuotation.value)}');
//       } else {
//         log("getAddQuotes error: ${result.message}");
//       }
//     } catch (e, s) {
//       log("Error in getAddQuotes: $e", stackTrace: s);
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'package:digitalerp/model/call_logs_showing_onlead_response_model.dart';
import 'package:digitalerp/model/get_all_quotation_model.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/repo/lead_management_repo.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GetAllQuotationController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();

  Rxn<GetleadentryList> lead = Rxn<GetleadentryList>();
  Rxn<GetAllQuotation> getAllQuotation = Rxn<GetAllQuotation>();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getArgument();
  }

  void getArgument() {
    lead.value = Get.arguments;
    if (lead.value != null) {
      log('leadEntryId => ${lead.value?.leadEntryId}');
      getAllList();
    } else {
      log(' Lead argument is null!');
    }
  }

  Future<void> getAllList() async {
    try {
      isLoading.value = true;

      final requestData = {
        "userid": homeController.currentUserData?.userid,
        "yearid": homeController.currentUserData?.yearId.toString() ?? '',
        "leadid": lead.value?.leadEntryId ?? 0,
        "compid": homeController.currentUserData?.compId,
        "branchid": homeController.currentUserData?.branchId,
      };

      log('requestData for getAddQuotes => $requestData');

      final result = await LeadManagementRepo.getAllQuotationMethod(requestData);

      if (result.statusCode == 200) {
        getAllQuotation.value = GetAllQuotation.fromJson(result.data);
        log('getQuote => ${jsonEncode(getAllQuotation.value)}');
      } else {
        log("getAddQuotes error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in getAddQuotes: $e", stackTrace: s);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllLists({int? leadId}) async {
    try {
      isLoading.value = true;

      log('homeController.currentUserData?.userid=================>>>>>${homeController.currentUserData?.userid}');
      final requestData = {
        "userid": homeController.currentUserData?.userid,
        "yearid": homeController.currentUserData?.yearId.toString() ?? '',
        "leadid": leadId ?? 0,
        "compid": homeController.currentUserData?.compId,
        "branchid": homeController.currentUserData?.branchId,
      };

      log('requestData for getAddQuotess =================>>>>> $requestData');

      final result = await LeadManagementRepo.getAllQuotationMethod(requestData);

      if (result.statusCode == 200) {
        getAllQuotation.value = GetAllQuotation.fromJson(result.data);
        log('getQuote=================>>>>>${jsonEncode(getAllQuotation.value)}');
      } else {
        log("getAddQuotes error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in getAddQuotes: $e", stackTrace: s);
    } finally {
      isLoading.value = false;
    }
  }

  CallLogsDataResponseModel? callLogsDataResponseModel;

  List<FetchCallLogsList> getAllCallLogsData = [];
  Future<void> getCallLogsFromApi({
    int? leadId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      isLoading.value = true;

      final now = DateTime.now();
      final defaultFrom = fromDate ?? now.subtract(const Duration(days: 30));
      final defaultTo = toDate ?? now;

      final dateFormat = DateFormat('yyyy-MM-dd');

      final requestData = {
        "userId": homeController.currentUserData?.userid,
        // Was sending yearId here — the company filter was receiving "9"
        // instead of the real compid, so this could never match a call log.
        "compid": homeController.currentUserData?.compId.toString() ?? '',
        "fromDate": dateFormat.format(defaultFrom),
        "toDate": dateFormat.format(defaultTo),
        "leadid": leadId ?? 0,
      };

      log('requestData for getCallLogsFromApi => $requestData');

      final result = await LeadManagementRepo.getCallLogsFromApo(requestData);

      if (result.statusCode == 200) {
        callLogsDataResponseModel = CallLogsDataResponseModel.fromJson(result.data);
        getAllCallLogsData = callLogsDataResponseModel?.data?.toList() ?? [];
        log("Fetched ${getAllCallLogsData.length} call logs");
      } else {
        log("getCallLogsFromApi error: ${result.message}");
      }
    } catch (e, s) {
      log("Error in getCallLogsFromApi: $e", stackTrace: s);
    } finally {
      isLoading.value = false;
    }
  }
}
