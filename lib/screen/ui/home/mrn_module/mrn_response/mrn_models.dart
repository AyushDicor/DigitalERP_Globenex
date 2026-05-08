//  MRN Models 

enum MrnSourceType { purchaseOrder, indent, directPurchase, barcodeScan }

enum MrnDocType { invoice, indent, deliveryChallan, inspection, other }

class MrnPOItem {
  final String poNumber;
  final String date;
  final String itemCategory;
  final double amount;
  final String status; // Open, Partial, Closed
  bool isSelected;

  MrnPOItem({
    required this.poNumber,
    required this.date,
    required this.itemCategory,
    required this.amount,
    required this.status,
    this.isSelected = false,
  });
}

class MrnItemLine {
  final String itemId;
  final String itemName;
  final String itemCode;
  final double poQty;
  final double receivedQty;
  final double rate;
  final String unit;
  final String source; // 'PO' | 'Scan' | 'Direct'
  double receiveNowQty;

  MrnItemLine({
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.poQty,
    required this.receivedQty,
    required this.rate,
    required this.unit,
    required this.source,
    required this.receiveNowQty,
  });

  double get lineTotal => receiveNowQty * rate;
}

class MrnScannedItem {
  final String barcode;
  final String itemName;
  final String itemCode;
  final double rate;
  final bool isUnknown;
  double qty;

  MrnScannedItem({
    required this.barcode,
    required this.itemName,
    required this.itemCode,
    required this.rate,
    required this.isUnknown,
    this.qty = 1,
  });
}

class MrnDocument {
  final String id;
  final String fileName;
  final String filePath;
  final String fileType; // 'pdf' | 'image'
  final String fileSize;
  final MrnDocType docType;
  final String source; // 'camera' | 'gallery' | 'file'
  final DateTime uploadedAt;

  MrnDocument({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.docType,
    required this.source,
    required this.uploadedAt,
  });
}

class MrnSubmitResponse {
  final int? status;
  final String? message;
  final String? mrnNumber;

  MrnSubmitResponse({this.status, this.message, this.mrnNumber});

  factory MrnSubmitResponse.fromJson(Map<String, dynamic> json) {
    return MrnSubmitResponse(
      status: json['status'],
      message: json['message'],
      mrnNumber: json['mrnno'],
    );
  }
}
