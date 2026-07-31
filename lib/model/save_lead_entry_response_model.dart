// To parse this JSON data, do
//
//     final saveLeadEntryResponseModel = saveLeadEntryResponseModelFromJson(jsonString);

import 'dart:convert';

SaveLeadEntryResponseModel saveLeadEntryResponseModelFromJson(String str) =>
    SaveLeadEntryResponseModel.fromJson(json.decode(str));

String saveLeadEntryResponseModelToJson(SaveLeadEntryResponseModel data) => json.encode(data.toJson());

class SaveLeadEntryResponseModel {
  bool? success;
  dynamic data;
  String? message;
  int? status;

  SaveLeadEntryResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory SaveLeadEntryResponseModel.fromJson(Map<String, dynamic> json) => SaveLeadEntryResponseModel(
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
