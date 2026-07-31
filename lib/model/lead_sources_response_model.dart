// To parse this JSON data, do
//
//     final leadSourcesResponseModel = leadSourcesResponseModelFromJson(jsonString);

import 'dart:convert';

LeadSourcesResponseModel leadSourcesResponseModelFromJson(String str) =>
    LeadSourcesResponseModel.fromJson(json.decode(str));

String leadSourcesResponseModelToJson(LeadSourcesResponseModel data) => json.encode(data.toJson());

class LeadSourcesResponseModel {
  bool? success;
  List<LeadSourcesData>? data;
  String? message;
  int? status;

  LeadSourcesResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory LeadSourcesResponseModel.fromJson(Map<String, dynamic> json) => LeadSourcesResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<LeadSourcesData>.from(json["data"]!.map((x) => LeadSourcesData.fromJson(x))),
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

class LeadSourcesData {
  int? sourceid;
  String? sourcename;

  LeadSourcesData({
    this.sourceid,
    this.sourcename,
  });

  factory LeadSourcesData.fromJson(Map<String, dynamic> json) => LeadSourcesData(
        sourceid: json["sourceid"],
        sourcename: json["sourcename"],
      );

  Map<String, dynamic> toJson() => {
        "sourceid": sourceid,
        "sourcename": sourcename,
      };
}
