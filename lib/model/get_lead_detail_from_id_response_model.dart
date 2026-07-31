// To parse this JSON data, do
//
//     final getLeadDetailFromIdResponseModel = getLeadDetailFromIdResponseModelFromJson(jsonString);

import 'dart:convert';

GetLeadDetailFromIdResponseModel getLeadDetailFromIdResponseModelFromJson(String str) =>
    GetLeadDetailFromIdResponseModel.fromJson(json.decode(str));

String getLeadDetailFromIdResponseModelToJson(GetLeadDetailFromIdResponseModel data) =>
    json.encode(data.toJson());

class GetLeadDetailFromIdResponseModel {
  bool? success;
  Data? data;
  String? message;
  int? status;

  GetLeadDetailFromIdResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory GetLeadDetailFromIdResponseModel.fromJson(Map<String, dynamic> json) =>
      GetLeadDetailFromIdResponseModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
        "status": status,
      };
}

class Data {
  int? leadEntryId;
  String? leadName;
  String? companyName;
  String? mobileNo;
  String? alternateMobile;
  String? email;
  String? website;
  DateTime? leadDate;
  DateTime? lastCommunicationDate;
  String? ageing;
  int? businessTypeId;
  String? businessType;
  int? industryTypeId;
  String? industryType;
  String? service;
  String? requirement;
  int? interestedInId;
  String? interestedIn;
  int? currentSoftwareId;
  String? currentSoftware;
  int? decisionTimeId;
  String? decisionTime;
  int? compId;
  int? branchId;
  int? userId;
  dynamic yearId;
  int? sourceid;
  String? source;
  String? address;
  List<LeadItem>? leadItems;

  Data({
    this.leadEntryId,
    this.leadName,
    this.companyName,
    this.mobileNo,
    this.alternateMobile,
    this.email,
    this.website,
    this.leadDate,
    this.lastCommunicationDate,
    this.ageing,
    this.businessTypeId,
    this.businessType,
    this.industryTypeId,
    this.industryType,
    this.service,
    this.requirement,
    this.interestedInId,
    this.interestedIn,
    this.currentSoftwareId,
    this.currentSoftware,
    this.decisionTimeId,
    this.decisionTime,
    this.compId,
    this.branchId,
    this.userId,
    this.yearId,
    this.sourceid,
    this.source,
    this.address,
    this.leadItems,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        leadEntryId: json["LeadEntryId"],
        leadName: json["LeadName"],
        companyName: json["CompanyName"],
        mobileNo: json["MobileNo"],
        alternateMobile: json["AlternateMobile"],
        email: json["Email"],
        website: json["Website"],
        leadDate: json["LeadDate"] == null ? null : DateTime.parse(json["LeadDate"]),
        lastCommunicationDate:
            json["LastCommunicationDate"] == null ? null : DateTime.parse(json["LastCommunicationDate"]),
        ageing: json["Ageing"],
        businessTypeId: json["BusinessTypeId"],
        businessType: json["BusinessType"],
        industryTypeId: json["IndustryTypeId"],
        industryType: json["IndustryType"],
        service: json["Service"],
        requirement: json["Requirement"],
        interestedInId: json["InterestedInId"],
        interestedIn: json["InterestedIn"],
        currentSoftwareId: json["CurrentSoftwareId"],
        currentSoftware: json["CurrentSoftware"],
        decisionTimeId: json["DecisionTimeId"],
        decisionTime: json["DecisionTime"],
        compId: json["CompId"],
        branchId: json["BranchId"],
        userId: json["UserId"],
        yearId: json["YearId"],
        sourceid: json["sourceid"],
        source: json["source"],
        address: json["address"],
        leadItems: json["LeadItems"] == null
            ? []
            : List<LeadItem>.from(json["LeadItems"]!.map((x) => LeadItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "LeadEntryId": leadEntryId,
        "LeadName": leadName,
        "CompanyName": companyName,
        "MobileNo": mobileNo,
        "AlternateMobile": alternateMobile,
        "Email": email,
        "Website": website,
        "LeadDate": leadDate?.toIso8601String(),
        "LastCommunicationDate": lastCommunicationDate?.toIso8601String(),
        "Ageing": ageing,
        "BusinessTypeId": businessTypeId,
        "BusinessType": businessType,
        "IndustryTypeId": industryTypeId,
        "IndustryType": industryType,
        "Service": service,
        "Requirement": requirement,
        "InterestedInId": interestedInId,
        "InterestedIn": interestedIn,
        "CurrentSoftwareId": currentSoftwareId,
        "CurrentSoftware": currentSoftware,
        "DecisionTimeId": decisionTimeId,
        "DecisionTime": decisionTime,
        "CompId": compId,
        "BranchId": branchId,
        "UserId": userId,
        "YearId": yearId,
        "sourceid": sourceid,
        "source": source,
        "address": address,
        "LeadItems": leadItems == null ? [] : List<dynamic>.from(leadItems!.map((x) => x.toJson())),
      };
}

class LeadItem {
  int? itemId;
  String? itemName;
  int? quantity;
  dynamic salesPrice;

  LeadItem({
    this.itemId,
    this.itemName,
    this.quantity,
    this.salesPrice,
  });

  factory LeadItem.fromJson(Map<String, dynamic> json) => LeadItem(
        itemId: json["ItemId"],
        itemName: json["ItemName"],
        quantity: json["Quantity"],
        salesPrice: json["SalesPrice"],
      );

  Map<String, dynamic> toJson() => {
        "ItemId": itemId,
        "ItemName": itemName,
        "Quantity": quantity,
        "SalesPrice": salesPrice,
      };
}
