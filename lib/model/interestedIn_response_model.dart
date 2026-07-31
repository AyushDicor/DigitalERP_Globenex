// To parse this JSON data, do
//
//     final interestedInResponseModel = interestedInResponseModelFromJson(jsonString);

import 'dart:convert';

InterestedInResponseModel interestedInResponseModelFromJson(String str) =>
    InterestedInResponseModel.fromJson(json.decode(str));

String interestedInResponseModelToJson(InterestedInResponseModel data) => json.encode(data.toJson());

class InterestedInResponseModel {
  bool success;
  List<InterestedInList> data;
  String message;
  int status;

  InterestedInResponseModel({required this.success, required this.data, required this.message, required this.status});

  InterestedInResponseModel copyWith({bool? success, List<InterestedInList>? data, String? message, int? status}) =>
      InterestedInResponseModel(
        success: success ?? this.success,
        data: data ?? this.data,
        message: message ?? this.message,
        status: status ?? this.status,
      );

  factory InterestedInResponseModel.fromJson(Map<String, dynamic> json) => InterestedInResponseModel(
    success: json["success"],
    data: List<InterestedInList>.from(json["data"].map((x) => InterestedInList.fromJson(x))),
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

class InterestedInList {
  String currentSoftware;
  int currentSoftwareid;

  InterestedInList({required this.currentSoftware, required this.currentSoftwareid});

  InterestedInList copyWith({String? currentSoftware, int? currentSoftwareid}) => InterestedInList(
    currentSoftware: currentSoftware ?? this.currentSoftware,
    currentSoftwareid: currentSoftwareid ?? this.currentSoftwareid,
  );

  factory InterestedInList.fromJson(Map<String, dynamic> json) =>
      InterestedInList(currentSoftware: json["CurrentSoftware"], currentSoftwareid: json["CurrentSoftwareid"]);

  Map<String, dynamic> toJson() => {"CurrentSoftware": currentSoftware, "CurrentSoftwareid": currentSoftwareid};
}
