// To parse this JSON data, do
//
//     final tagProductsResponseModel = tagProductsResponseModelFromJson(jsonString);

// import 'dart:convert';
//
// TagProductsResponseModel tagProductsResponseModelFromJson(String str) =>
//     TagProductsResponseModel.fromJson(json.decode(str));
//
// String tagProductsResponseModelToJson(TagProductsResponseModel data) => json.encode(data.toJson());
//
// class TagProductsResponseModel {
//   bool? success;
//   List<TagProducts>? data;
//   String? message;
//   int? status;
//
//   TagProductsResponseModel({
//     this.success,
//     this.data,
//     this.message,
//     this.status,
//   });
//
//   factory TagProductsResponseModel.fromJson(Map<String, dynamic> json) => TagProductsResponseModel(
//         success: json["success"],
//         data: json["data"] == null
//             ? []
//             : List<TagProducts>.from(json["data"]!.map((x) => TagProducts.fromJson(x))),
//         message: json["message"],
//         status: json["status"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
//         "message": message,
//         "status": status,
//       };
// }
//
// class TagProducts {
//   String? itemCode;
//   int? itemid;
//   String? itemName;
//   String? imagepath;
//   String? mrp;
//
//   int quantity;
//
//   TagProducts({
//     this.itemCode,
//     this.itemid,
//     this.itemName,
//     this.imagepath,
//     this.mrp,
//     this.quantity = 0,
//   });
//
//   factory TagProducts.fromJson(Map<String, dynamic> json) => TagProducts(
//         itemCode: json["ItemCode"],
//         itemid: json["itemid"] is int
//             ? json["itemid"]
//             : (json["itemid"] is double
//                 ? (json["itemid"] as double).toInt()
//                 : int.tryParse(json["itemid"].toString()) ?? 0),
//         itemName: json["ItemName"],
//         imagepath: json["imagepath"],
//         quantity: json["quantity"] is int
//             ? json["quantity"]
//             : (json["quantity"] is double
//                 ? (json["quantity"] as double).toInt()
//                 : int.tryParse(json["quantity"].toString()) ?? 0),
//         mrp: json["MRP"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "ItemCode": itemCode,
//         "itemid": itemid,
//         "ItemName": itemName,
//         "quantity": quantity,
//         "imagepath": imagepath,
//         "MRP": mrp,
//       };
// }
//
// // To parse this JSON data, do
// //
// //     final tagProductsResponseModel = tagProductsResponseModelFromJson(jsonString);

import 'dart:convert';

TagProductsResponseModel tagProductsResponseModelFromJson(String str) =>
    TagProductsResponseModel.fromJson(json.decode(str));

String tagProductsResponseModelToJson(TagProductsResponseModel data) => json.encode(data.toJson());

class TagProductsResponseModel {
  bool? success;
  List<TagProducts>? data;
  String? message;
  int? status;

  TagProductsResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory TagProductsResponseModel.fromJson(Map<String, dynamic> json) => TagProductsResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<TagProducts>.from(json["data"]!.map((x) => TagProducts.fromJson(x))),
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

class TagProducts {
  int? itemid;
  String? itemname;
  String? itemcode;
  String? itemdescription;
  String? itemimage;
  String? unit;
  dynamic rate;
  int? requiredpoint;
  int? quantity;
  int? unitid;

  TagProducts({
    this.itemid,
    this.itemname,
    this.itemcode,
    this.itemdescription,
    this.itemimage,
    this.unit,
    this.rate,
    this.requiredpoint,
    this.quantity,
    this.unitid,
  });

  factory TagProducts.fromJson(Map<String, dynamic> json) => TagProducts(
        itemid: _toInt(json["itemid"]),
        itemname: json["itemname"],
        itemcode: json["itemcode"],
        itemdescription: json["itemdescription"],
        itemimage: json["itemimage"],
        unit: json["unit"],
        rate: _toInt(json["rate"]),
        requiredpoint: _toInt(json["requiredpoint"]),
        quantity: _toInt(json["quantity"]),
        unitid: _toInt(json["unitid"]),
      );

  Map<String, dynamic> toJson() => {
        "itemid": itemid,
        "itemname": itemname,
        "itemcode": itemcode,
        "itemdescription": itemdescription,
        "itemimage": itemimage,
        "unit": unit,
        "rate": rate,
        "requiredpoint": requiredpoint,
        "quantity": quantity,
        "unitid": unitid,
      };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
