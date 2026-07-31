// To parse this JSON data, do
//
//     final currentSoftwareResponseModel = currentSoftwareResponseModelFromJson(jsonString);

import 'dart:convert';

CurrentSoftwareResponseModel currentSoftwareResponseModelFromJson(String str) =>
    CurrentSoftwareResponseModel.fromJson(json.decode(str));

String currentSoftwareResponseModelToJson(CurrentSoftwareResponseModel data) => json.encode(data.toJson());

class CurrentSoftwareResponseModel {
  bool success;
  List<CurrantSoftware> data;
  String message;
  int status;

  CurrentSoftwareResponseModel({
    required this.success,
    required this.data,
    required this.message,
    required this.status,
  });

  CurrentSoftwareResponseModel copyWith({bool? success, List<CurrantSoftware>? data, String? message, int? status}) =>
      CurrentSoftwareResponseModel(
        success: success ?? this.success,
        data: data ?? this.data,
        message: message ?? this.message,
        status: status ?? this.status,
      );

  factory CurrentSoftwareResponseModel.fromJson(Map<String, dynamic> json) => CurrentSoftwareResponseModel(
    success: json["success"],
    data: List<CurrantSoftware>.from(json["data"].map((x) => CurrantSoftware.fromJson(x))),
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

class CurrantSoftware {
  String decisionTimeline;
  int decisionTimelineid;

  CurrantSoftware({required this.decisionTimeline, required this.decisionTimelineid});

  CurrantSoftware copyWith({String? decisionTimeline, int? decisionTimelineid}) => CurrantSoftware(
    decisionTimeline: decisionTimeline ?? this.decisionTimeline,
    decisionTimelineid: decisionTimelineid ?? this.decisionTimelineid,
  );

  factory CurrantSoftware.fromJson(Map<String, dynamic> json) =>
      CurrantSoftware(decisionTimeline: json["DecisionTimeline"], decisionTimelineid: json["DecisionTimelineid"]);

  Map<String, dynamic> toJson() => {"DecisionTimeline": decisionTimeline, "DecisionTimelineid": decisionTimelineid};
}
