import 'dart:convert';
import 'package:digitalerp/model/get_lead_detail_from_id_response_model.dart';

GetleadentryResponseModel getleadentryResponseModelFromJson(String str) =>
    GetleadentryResponseModel.fromJson(json.decode(str));

String getleadentryResponseModelToJson(GetleadentryResponseModel data) => json.encode(data.toJson());

class GetleadentryResponseModel {
  bool success;
  List<GetleadentryList> data;
  String message;
  int status;

  GetleadentryResponseModel({
    required this.success,
    required this.data,
    required this.message,
    required this.status,
  });

  factory GetleadentryResponseModel.fromJson(Map<String, dynamic> json) => GetleadentryResponseModel(
        success: json["success"] ?? false,
        data: (json["data"] as List<dynamic>?)?.map((x) => GetleadentryList.fromJson(x)).toList() ?? [],
        message: json["message"] ?? '',
        status: json["status"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "status": status,
      };
}

class GetleadentryList {
  int leadEntryId;
  String leadName;
  String companyName;
  String mobileNo;
  String? alternateMobile;
  String? email;
  String? website;
  String? lastCommunicationDate;
  String? requirement;
  int? businessTypeId;
  String? businessType;
  int? industryTypeId;
  String? industryType;
  int? sourceId;
  String? sourceName;
  int? interestedInId;
  String? interestedIn;
  int? currentSoftwareId;
  String? currentSoftware;
  int? decisionTimeId;
  String? decisionTime;
  String leadDate;
  String ageing;
  String? address;
  List<LeadItem> leadItems;

  GetleadentryList({
    required this.leadEntryId,
    required this.leadName,
    required this.companyName,
    required this.mobileNo,
    this.alternateMobile,
    this.email,
    this.website,
    this.lastCommunicationDate,
    this.requirement,
    this.businessTypeId,
    this.businessType,
    this.industryTypeId,
    this.industryType,
    this.sourceId,
    this.sourceName,
    this.interestedInId,
    this.interestedIn,
    this.currentSoftwareId,
    this.currentSoftware,
    this.decisionTimeId,
    this.decisionTime,
    required this.leadDate,
    required this.address,
    required this.ageing,
    this.leadItems = const [],
  });

  factory GetleadentryList.fromJson(Map<String, dynamic> json) => GetleadentryList(
        leadEntryId: json["LeadEntryId"] ?? 0,
        leadName: json["LeadName"] ?? '',
        companyName: json["CompanyName"] ?? '',
        mobileNo: json["MobileNo"] ?? '',
        alternateMobile: json["AlternateMobile"],
        email: json["Email"],
        website: json["Website"],
        lastCommunicationDate: json["LastCommunicationDate"],
        requirement: json["Requirement"],
        businessTypeId: json["BusinessTypeId"],
        businessType: json["BusinessType"],
        industryTypeId: json["IndustryTypeId"],
        industryType: json["IndustryType"],
        sourceId: json["sourceid"],
        sourceName: json["source"], // ✅ maps to name
        interestedInId: json["InterestedInId"],
        interestedIn: json["InterestedIn"],
        currentSoftwareId: json["CurrentSoftwareId"],
        currentSoftware: json["CurrentSoftware"],
        decisionTimeId: json["DecisionTimeId"],
        decisionTime: json["DecisionTime"],
        leadDate: json["LeadDate"] ?? '',
        address: json["address"],
        ageing: json["Ageing"] ?? '',
        leadItems: (json["LeadItems"] as List<dynamic>?)?.map((x) => LeadItem.fromJson(x)).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        "LeadEntryId": leadEntryId,
        "LeadName": leadName,
        "CompanyName": companyName,
        "MobileNo": mobileNo,
        "AlternateMobile": alternateMobile,
        "Email": email,
        "Website": website,
        "address": address,
        "LastCommunicationDate": lastCommunicationDate,
        "Requirement": requirement,
        "BusinessTypeId": businessTypeId,
        "BusinessType": businessType,
        "IndustryTypeId": industryTypeId,
        "IndustryType": industryType,
        "sourceid": sourceId,
        "source": sourceName, // ✅ maps back correctly
        "InterestedInId": interestedInId,
        "InterestedIn": interestedIn,
        "CurrentSoftwareId": currentSoftwareId,
        "CurrentSoftware": currentSoftware,
        "DecisionTimeId": decisionTimeId,
        "DecisionTime": decisionTime,
        "LeadDate": leadDate,
        "Ageing": ageing,
        "LeadItems": leadItems.map((x) => x.toJson()).toList(),
      };
}
