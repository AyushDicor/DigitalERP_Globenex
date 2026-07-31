// To parse this JSON data, do
//
//     final decisionTimelineResponseModel = decisionTimelineResponseModelFromJson(jsonString);

import 'dart:convert';

DecisionTimelineResponseModel decisionTimelineResponseModelFromJson(String str) => DecisionTimelineResponseModel.fromJson(json.decode(str));

String decisionTimelineResponseModelToJson(DecisionTimelineResponseModel data) => json.encode(data.toJson());

class DecisionTimelineResponseModel {
  bool success;
  List<DecisionTimelineList> data;
  String message;
  int status;

  DecisionTimelineResponseModel({
    required this.success,
    required this.data,
    required this.message,
    required this.status,
  });

  DecisionTimelineResponseModel copyWith({
    bool? success,
    List<DecisionTimelineList>? data,
    String? message,
    int? status,
  }) =>
      DecisionTimelineResponseModel(
        success: success ?? this.success,
        data: data ?? this.data,
        message: message ?? this.message,
        status: status ?? this.status,
      );

  factory DecisionTimelineResponseModel.fromJson(Map<String, dynamic> json) => DecisionTimelineResponseModel(
    success: json["success"],
    data: List<DecisionTimelineList>.from(json["data"].map((x) => DecisionTimelineList.fromJson(x))),
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

class DecisionTimelineList {
  String decisionTimeline;
  int decisionTimelineid;

  DecisionTimelineList({
    required this.decisionTimeline,
    required this.decisionTimelineid,
  });

  DecisionTimelineList copyWith({
    String? decisionTimeline,
    int? decisionTimelineid,
  }) =>
      DecisionTimelineList(
        decisionTimeline: decisionTimeline ?? this.decisionTimeline,
        decisionTimelineid: decisionTimelineid ?? this.decisionTimelineid,
      );

  factory DecisionTimelineList.fromJson(Map<String, dynamic> json) => DecisionTimelineList(
    decisionTimeline: json["DecisionTimeline"],
    decisionTimelineid: json["DecisionTimelineid"],
  );

  Map<String, dynamic> toJson() => {
    "DecisionTimeline": decisionTimeline,
    "DecisionTimelineid": decisionTimelineid,
  };
}
