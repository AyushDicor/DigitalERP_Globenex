// To parse this JSON data, do
//
//     final leadIndustryResponseModel = leadIndustryResponseModelFromJson(jsonString);

import 'dart:convert';

LeadIndustryResponseModel leadIndustryResponseModelFromJson(String str) =>
    LeadIndustryResponseModel.fromJson(json.decode(str));

String leadIndustryResponseModelToJson(LeadIndustryResponseModel data) => json.encode(data.toJson());

class LeadIndustryResponseModel {
  bool? success;
  List<LeadIndustry>? data;
  String? message;
  int? status;

  LeadIndustryResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory LeadIndustryResponseModel.fromJson(Map<String, dynamic> json) => LeadIndustryResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<LeadIndustry>.from(json["data"]!.map((x) => LeadIndustry.fromJson(x))),
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

class LeadIndustry {
  String? industryType;
  int? industryTypeid;

  LeadIndustry({
    this.industryType,
    this.industryTypeid,
  });

  factory LeadIndustry.fromJson(Map<String, dynamic> json) => LeadIndustry(
        industryType: json["IndustryType"],
        industryTypeid: json["IndustryTypeid"],
      );

  Map<String, dynamic> toJson() => {
        "IndustryType": industryType,
        "IndustryTypeid": industryTypeid,
      };
}
