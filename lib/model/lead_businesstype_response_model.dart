// To parse this JSON data, do
//
//     final leadBusinessResponseModel = leadBusinessResponseModelFromJson(jsonString);

import 'dart:convert';

LeadBusinessResponseModel leadBusinessResponseModelFromJson(String str) =>
    LeadBusinessResponseModel.fromJson(json.decode(str));

String leadBusinessResponseModelToJson(LeadBusinessResponseModel data) => json.encode(data.toJson());

class LeadBusinessResponseModel {
  bool? success;
  List<LeadBusinessList>? data;
  String? message;
  int? status;

  LeadBusinessResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory LeadBusinessResponseModel.fromJson(Map<String, dynamic> json) => LeadBusinessResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<LeadBusinessList>.from(json["data"]!.map((x) => LeadBusinessList.fromJson(x))),
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "status": status,
      };
}

class LeadBusinessList {
  String? businessType;
  int? businessTypeid;

  LeadBusinessList({
    this.businessType,
    this.businessTypeid,
  });

  factory LeadBusinessList.fromJson(Map<String, dynamic> json) => LeadBusinessList(
        businessType: json["BusinessType"],
        businessTypeid: json["BusinessTypeid"],
      );

  Map<String, dynamic> toJson() => {
        "BusinessType": businessType,
        "BusinessTypeid": businessTypeid,
      };
}
