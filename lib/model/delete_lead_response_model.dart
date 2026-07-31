// To parse this JSON data, do
//
//     final deleteLeadResponseModel = deleteLeadResponseModelFromJson(jsonString);

import 'dart:convert';

DeleteLeadResponseModel deleteLeadResponseModelFromJson(String str) =>
    DeleteLeadResponseModel.fromJson(json.decode(str));

String deleteLeadResponseModelToJson(DeleteLeadResponseModel data) => json.encode(data.toJson());

class DeleteLeadResponseModel {
  bool? success;
  dynamic data;
  String? message;
  int? status;

  DeleteLeadResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory DeleteLeadResponseModel.fromJson(Map<String, dynamic> json) => DeleteLeadResponseModel(
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
