// To parse this JSON data, do
//
//     final callLogsDataResponseModel = callLogsDataResponseModelFromJson(jsonString);

import 'dart:convert';

CallLogsDataResponseModel callLogsDataResponseModelFromJson(String str) =>
    CallLogsDataResponseModel.fromJson(json.decode(str));

String callLogsDataResponseModelToJson(CallLogsDataResponseModel data) => json.encode(data.toJson());

class CallLogsDataResponseModel {
  bool? success;
  List<FetchCallLogsList>? data;
  String? message;
  int? status;

  CallLogsDataResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory CallLogsDataResponseModel.fromJson(Map<String, dynamic> json) => CallLogsDataResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<FetchCallLogsList>.from(json["data"]!.map((x) => FetchCallLogsList.fromJson(x))),
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

class FetchCallLogsList {
  String? phoneNumber;
  DateTime? callDateTime;
  String? duration;
  String? callType;

  FetchCallLogsList({
    this.phoneNumber,
    this.callDateTime,
    this.duration,
    this.callType,
  });

  factory FetchCallLogsList.fromJson(Map<String, dynamic> json) => FetchCallLogsList(
        phoneNumber: json["PhoneNumber"],
        callDateTime: json["CallDateTime"] == null ? null : DateTime.parse(json["CallDateTime"]),
        duration: json["Duration"],
        callType: json["CallType"],
      );

  Map<String, dynamic> toJson() => {
        "PhoneNumber": phoneNumber,
        "CallDateTime": callDateTime?.toIso8601String(),
        "Duration": duration,
        "CallType": callType,
      };
}
