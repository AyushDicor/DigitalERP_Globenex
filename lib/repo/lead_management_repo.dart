import 'dart:developer';

import 'package:digitalerp/model/response_model.dart';
import 'package:digitalerp/repo/base_api_helper.dart';

import 'base_url.dart';

class LeadManagementRepo {
  static Future<ResponseItem> businessTypeMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.businessTypeUrl;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "businessTypeMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> industryTypeMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.industryTypeUrl;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "industryTypeMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> interestedTypeMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.interestedTypeUrl;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "interestedTypeMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> tagProductsTypeMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.tagProductTypeUrl;
      log('requestUrlforTagProducts=================>>>>>${requestUrl}');

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "interestedTypeMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> mainGroup(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.mainGroup;
      log('requestUrlforTagProducts=================>>>>>${requestUrl}');

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "interestedTypeMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> subGroup(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.subGroup;
      log('requestUrlforTagProducts=================>>>>>${requestUrl}');

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "interestedTypeMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> saveLeadEntryMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.saveLeadEntry;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "saveLeadEntryMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> interestedInMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.interestedInApi;
      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "interestedInMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> currentSoftwareMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.currentSoftwareApi;
      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "currentSoftwareMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> decisionTimelineMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.decisionTimelineApi;
      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "currentSoftwareMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> getLeadEntryMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.getleadentryApi;
      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "getleadentryMethod Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> getLeadEntryMethodFromId(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.getLeadDetailFromId;
      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
          status: false, message: "getLeadEntryMethodFromId Repo : An error occurred: ${e.toString()}");
    }
  }

  ///15-09

  static Future<ResponseItem> deleteLeads(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.deleteLeadMethod;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(status: false, message: "deleteLeads Repo : An error occurred: ${e.toString()}");
    }
  }

  static Future<ResponseItem> insertLeadNotesAndFollowUp(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.insertLeadNotesAndFollowUpMethod;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "insertLeadNotesAndFollowUp Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> getNotesAndFollowupMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.getNotesAndFollowupMethod;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "getNotesAndFollowupMethod Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> deleteNotes(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.deleteNotesMethod;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "deleteNotesMethod Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> updateLeadEntry(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.updateLeadEntry;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "updateLeadEntry Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> insertLeadQuoteMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.insertQuote;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "insertLeadQuote Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> getQuoteMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.getQuestionAgainLeads;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "getQuoteMethod Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> getAllQuotationMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.getQuote;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "getAllQuoteMethod Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> getCallLogsFromApo(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.getCallLogs;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "getCallLogsFromApo Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> leadSourcesMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.leadSources;

      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);

      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "leadSourcesMethod Repo : An error occurred: ${e.toString()}",
      );
    }
  }

  static Future<ResponseItem> agentPartyMethod(Map<String, dynamic> requestData) async {
    try {
      String requestUrl = AppUrls.baseUrl + MethodName.agentParty;
      ResponseItem result = await BaseApiHelper.postRequest(requestUrl, requestData);
      return result;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: "agentPartyMethod Repo : An error occurred: ${e.toString()}",
      );
    }
  }
}
