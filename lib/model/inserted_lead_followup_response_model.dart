// To parse this JSON data, do
//
//     final insertedLeadNotesResponseModel = insertedLeadNotesResponseModelFromJson(jsonString);

import 'dart:convert';

InsertedLeadNotesResponseModel insertedLeadNotesResponseModelFromJson(String str) =>
    InsertedLeadNotesResponseModel.fromJson(json.decode(str));

String insertedLeadNotesResponseModelToJson(InsertedLeadNotesResponseModel data) =>
    json.encode(data.toJson());

class InsertedLeadNotesResponseModel {
  bool? success;
  dynamic data;
  String? message;
  int? status;

  InsertedLeadNotesResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory InsertedLeadNotesResponseModel.fromJson(Map<String, dynamic> json) =>
      InsertedLeadNotesResponseModel(
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
