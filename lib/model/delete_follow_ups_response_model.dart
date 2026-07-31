// To parse this JSON data, do
//
//     final deleteGetFollowUpsResponseModel = deleteGetFollowUpsResponseModelFromJson(jsonString);

import 'dart:convert';

DeleteGetFollowUpsResponseModel deleteGetFollowUpsResponseModelFromJson(String str) =>
    DeleteGetFollowUpsResponseModel.fromJson(json.decode(str));

String deleteGetFollowUpsResponseModelToJson(DeleteGetFollowUpsResponseModel data) =>
    json.encode(data.toJson());

class DeleteGetFollowUpsResponseModel {
  bool? success;
  dynamic data;
  String? message;
  int? status;

  DeleteGetFollowUpsResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory DeleteGetFollowUpsResponseModel.fromJson(Map<String, dynamic> json) =>
      DeleteGetFollowUpsResponseModel(
        success: json["success"],
        data: json["data"],
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data,
        "message": message,
        "status": status,
      };
}
