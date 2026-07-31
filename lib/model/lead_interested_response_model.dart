// To parse this JSON data, do
//
//     final interestedResponseModel = interestedResponseModelFromJson(jsonString);

import 'dart:convert';

InterestedResponseModel interestedResponseModelFromJson(String str) =>
    InterestedResponseModel.fromJson(json.decode(str));

String interestedResponseModelToJson(InterestedResponseModel data) => json.encode(data.toJson());

class InterestedResponseModel {
  bool? success;
  List<InterestedData>? data;
  String? message;
  int? status;

  InterestedResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory InterestedResponseModel.fromJson(Map<String, dynamic> json) => InterestedResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<InterestedData>.from(json["data"]!.map((x) => InterestedData.fromJson(x))),
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

class InterestedData {
  String? currentSoftware;
  int? currentSoftwareid;

  InterestedData({
    this.currentSoftware,
    this.currentSoftwareid,
  });

  factory InterestedData.fromJson(Map<String, dynamic> json) => InterestedData(
        currentSoftware: json["CurrentSoftware"],
        currentSoftwareid: json["CurrentSoftwareid"],
      );

  Map<String, dynamic> toJson() => {
        "CurrentSoftware": currentSoftware,
        "CurrentSoftwareid": currentSoftwareid,
      };
}
