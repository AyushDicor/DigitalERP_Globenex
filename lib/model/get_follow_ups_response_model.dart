// To parse this JSON data, do
//
//     final getFollowUpsResponseModel = getFollowUpsResponseModelFromJson(jsonString);

import 'dart:convert';

GetFollowUpsResponseModel getFollowUpsResponseModelFromJson(String str) =>
    GetFollowUpsResponseModel.fromJson(json.decode(str));

String getFollowUpsResponseModelToJson(GetFollowUpsResponseModel data) => json.encode(data.toJson());

class GetFollowUpsResponseModel {
  bool? success;
  List<FollowUps>? data;
  String? message;
  int? status;

  GetFollowUpsResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory GetFollowUpsResponseModel.fromJson(Map<String, dynamic> json) => GetFollowUpsResponseModel(
        success: json["success"],
        data:
            json["data"] == null ? [] : List<FollowUps>.from(json["data"]!.map((x) => FollowUps.fromJson(x))),
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

class FollowUps {
  int? id;
  String? remarks;
  String? followUpDate;
  String? followUpTime;

  FollowUps({
    this.id,
    this.remarks,
    this.followUpDate,
    this.followUpTime,
  });

  factory FollowUps.fromJson(Map<String, dynamic> json) => FollowUps(
        id: json["id"],
        remarks: json["Remarks"],
        followUpDate: json["FollowUp_date"],
        followUpTime: json["FollowUp_time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Remarks": remarks,
        "FollowUp_date": followUpDate,
        "FollowUp_time": followUpTime,
      };
}
