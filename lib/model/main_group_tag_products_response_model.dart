import 'dart:convert';

MainGroupResponseModel mainGroupResponseModelFromJson(String str) =>
    MainGroupResponseModel.fromJson(json.decode(str));

String mainGroupResponseModelToJson(MainGroupResponseModel data) => json.encode(data.toJson());

class MainGroupResponseModel {
  bool? success;
  List<MainGroup>? data;
  String? message;
  int? status;

  MainGroupResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory MainGroupResponseModel.fromJson(Map<String, dynamic> json) => MainGroupResponseModel(
        success: json["success"],
        data:
            json["data"] == null ? [] : List<MainGroup>.from(json["data"]!.map((x) => MainGroup.fromJson(x))),
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

class MainGroup {
  int? categoryid;
  String? categoryname;

  MainGroup({
    this.categoryid,
    this.categoryname,
  });

  factory MainGroup.fromJson(Map<String, dynamic> json) => MainGroup(
        categoryid: json["categoryid"],
        categoryname: json["categoryname"],
      );

  Map<String, dynamic> toJson() => {
        "categoryid": categoryid,
        "categoryname": categoryname,
      };
}
