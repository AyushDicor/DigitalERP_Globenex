// // To parse this JSON data, do
// //
// //     final leadInsertQuoteResponseModel = leadInsertQuoteResponseModelFromJson(jsonString);
//
// import 'dart:convert';
//
// LeadInsertQuoteResponseModel leadInsertQuoteResponseModelFromJson(String str) =>
//     LeadInsertQuoteResponseModel.fromJson(json.decode(str));
//
// String leadInsertQuoteResponseModelToJson(LeadInsertQuoteResponseModel data) => json.encode(data.toJson());
//
// class LeadInsertQuoteResponseModel {
//   bool? success;
//   dynamic data;
//   String? message;
//   int? status;
//
//   LeadInsertQuoteResponseModel({
//     this.success,
//     this.data,
//     this.message,
//     this.status,
//   });
//
//   factory LeadInsertQuoteResponseModel.fromJson(Map<String, dynamic> json) => LeadInsertQuoteResponseModel(
//         success: json["success"],
//         data: json["data"],
//         message: json["message"],
//         status: json["status"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data,
//         "message": message,
//         "status": status,
//       };
// }
// To parse this JSON data, do
//
//     final leadInsertQuoteResponseModel = leadInsertQuoteResponseModelFromJson(jsonString);

import 'dart:convert';

LeadInsertQuoteResponseModel leadInsertQuoteResponseModelFromJson(String str) =>
    LeadInsertQuoteResponseModel.fromJson(json.decode(str));

String leadInsertQuoteResponseModelToJson(LeadInsertQuoteResponseModel data) => json.encode(data.toJson());

class LeadInsertQuoteResponseModel {
  bool success;
  List<Datum> data;
  String message;
  int status;

  LeadInsertQuoteResponseModel({
    required this.success,
    required this.data,
    required this.message,
    required this.status,
  });

  factory LeadInsertQuoteResponseModel.fromJson(Map<String, dynamic> json) => LeadInsertQuoteResponseModel(
        success: json["success"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "status": status,
      };
}

class Datum {
  String url;
  String message;
  int status;

  Datum({
    required this.url,
    required this.message,
    required this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        url: json["url"],
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "message": message,
        "status": status,
      };
}
