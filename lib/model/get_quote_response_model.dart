// To parse this JSON data, do
//
//     final getAddQuoteResponseModel = getAddQuoteResponseModelFromJson(jsonString);

import 'dart:convert';

GetAddQuoteResponseModel getAddQuoteResponseModelFromJson(String str) =>
    GetAddQuoteResponseModel.fromJson(json.decode(str));

String getAddQuoteResponseModelToJson(GetAddQuoteResponseModel data) => json.encode(data.toJson());

class GetAddQuoteResponseModel {
  bool? success;
  Datas? data;
  String? message;
  int? status;

  GetAddQuoteResponseModel({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory GetAddQuoteResponseModel.fromJson(Map<String, dynamic> json) => GetAddQuoteResponseModel(
        success: json["success"],
        data: json["data"] == null ? null : Datas.fromJson(json["data"]),
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
        "status": status,
      };
}

class Datas {
  String? leadName;
  List<GetQuote>? leadItems;

  Datas({
    this.leadName,
    this.leadItems,
  });

  factory Datas.fromJson(Map<String, dynamic> json) => Datas(
        leadName: json["LeadName"],
        leadItems: json["LeadItems"] == null
            ? []
            : List<GetQuote>.from(json["LeadItems"]!.map((x) => GetQuote.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "LeadName": leadName,
        "LeadItems": leadItems == null ? [] : List<dynamic>.from(leadItems!.map((x) => x.toJson())),
      };
}

class GetQuote {
  int? itemId;
  String? itemName;
  int? quantity;
  dynamic salesPrice;
  dynamic amount;
  dynamic vatPercent;

  GetQuote({
    this.itemId,
    this.itemName,
    this.quantity,
    this.salesPrice,
    this.amount,
    this.vatPercent,
  });

  factory GetQuote.fromJson(Map<String, dynamic> json) => GetQuote(
        itemId: json["ItemId"],
        itemName: json["ItemName"],
        quantity: json["Quantity"],
        salesPrice: json["SalesPrice"],
        amount: json["Amount"],
        vatPercent: json["VatPercent"],
      );

  Map<String, dynamic> toJson() => {
        "ItemId": itemId,
        "ItemName": itemName,
        "Quantity": quantity,
        "SalesPrice": salesPrice,
        "Amount": amount,
        "VatPercent": vatPercent,
      };
}
