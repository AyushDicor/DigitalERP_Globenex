// To parse this JSON data, do
//
//     final subGroupFiltredDataResponseModel = subGroupFiltredDataResponseModelFromJson(jsonString);

import 'dart:convert';

SubGroupFiltredDataResponseModel subGroupFiltredDataResponseModelFromJson(String str) =>
    SubGroupFiltredDataResponseModel.fromJson(json.decode(str));

String subGroupFiltredDataResponseModelToJson(SubGroupFiltredDataResponseModel data) =>
    json.encode(data.toJson());

class SubGroupFiltredDataResponseModel {
  bool? success;
  List<SubGroupFiltredData>? data;
  String? message;
  int? status;

  SubGroupFiltredDataResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory SubGroupFiltredDataResponseModel.fromJson(Map<String, dynamic> json) =>
      SubGroupFiltredDataResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<SubGroupFiltredData>.from(json["data"]!.map((x) => SubGroupFiltredData.fromJson(x))),
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

class SubGroupFiltredData {
  int? subcategoryid;
  String? subcategoryname;

  SubGroupFiltredData({
    this.subcategoryid,
    this.subcategoryname,
  });

  factory SubGroupFiltredData.fromJson(Map<String, dynamic> json) => SubGroupFiltredData(
        subcategoryid: json["subcategoryid"],
        subcategoryname: json["subcategoryname"],
      );

  Map<String, dynamic> toJson() => {
        "subcategoryid": subcategoryid,
        "subcategoryname": subcategoryname,
      };
}
