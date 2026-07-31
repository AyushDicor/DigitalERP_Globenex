import 'dart:convert';

GetAllQuotation getAllQuotationFromJson(String str) => GetAllQuotation.fromJson(json.decode(str));

String getAllQuotationToJson(GetAllQuotation data) => json.encode(data.toJson());

class GetAllQuotation {
  bool? success;
  List<Datum>? data;
  String? message;
  int? status;

  GetAllQuotation({this.success, this.data, this.message, this.status});

  factory GetAllQuotation.fromJson(Map<String, dynamic> json) => GetAllQuotation(
        success: json["success"] ?? false,
        data: json["data"] != null ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x ?? {}))) : [],
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.map((x) => x.toJson()).toList(),
        "message": message,
        "status": status,
      };
}

class Datum {
  int? id;
  String? quotationNo;
  DateTime? quotationDate;
  String? companyName;
  String? mobileNo;
  String? emailId;
  String? url;
  String? message;
  int? status;

  Datum({
    this.id,
    this.quotationNo,
    this.quotationDate,
    this.companyName,
    this.mobileNo,
    this.emailId,
    this.url,
    this.message,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["Id"],
        quotationNo: json["QuotationNo"],
        quotationDate: json["QuotationDate"] != null ? DateTime.tryParse(json["QuotationDate"]) : null,
        companyName: json["CompanyName"],
        mobileNo: json["MobileNo"],
        emailId: json["EmailId"],
        url: json["URL"],
        message: json["Message"],
        status: json["Status"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "QuotationNo": quotationNo,
        "QuotationDate": quotationDate?.toIso8601String(),
        "CompanyName": companyName,
        "MobileNo": mobileNo,
        "EmailId": emailId,
        "URL": url,
        "Message": message,
        "Status": status,
      };
}
