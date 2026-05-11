// MRN Models

enum MrnSourceType { purchaseOrder, indent, directPurchase, barcodeScan, grn }
enum MrnDocType { invoice, indent, deliveryChallan, inspection, other }
enum MrnAttachmentType { bill, challan }

class MrnDropdownResponse {
  final int? status;
  final bool? success;
  final String? message;
  final List<MrnDropdownOption>? data;

  MrnDropdownResponse({this.status, this.success, this.message, this.data});

  factory MrnDropdownResponse.fromJson(Map<String, dynamic> json) {
    return MrnDropdownResponse(
      status:  json['status'],
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)
          ?.map((e) => MrnDropdownOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── PO header item ─────────────────────────────────────────────────────────────
class MrnPOItem {
  final String poNumber;
  final String date;
  final String itemCategory;
  final double amount;
  final String status;
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

// ── Full item line ─────────────────────────────────────────────────────────────
class MrnItemLine {
  final String itemId;
  final String itemName;
  final String itemCode;
  final String unit;
  final String source; // 'PO' | 'Direct' | 'GRN'
  final String orderNo;

  // Backend-populated for PO; user-entered for Direct
  final double poQty;
  final double previouslyReceivedQty;
  final double rate;
  final double discountPercent; // % — used for PO
  final double discountAmount;  // flat ₹ — used for Direct
  final double gstPercent;

  // Editable by user
  double receiveNowQty;
  String? selectedGodownId;
  String remarks;

  // UI state
  bool isExpanded;

  MrnItemLine({
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.unit,
    required this.source,
    this.orderNo = '',
    required this.poQty,
    this.previouslyReceivedQty = 0,
    required this.rate,
    this.discountPercent = 0,
    this.discountAmount = 0,  // ← new field, defaults to 0
    this.gstPercent = 18,
    required this.receiveNowQty,
    this.selectedGodownId,
    this.remarks = '',
    this.isExpanded = false,
  });

  // ── Computed ───────────────────────────────────────────────────────────────
  double get maxReceivable =>
      (poQty - previouslyReceivedQty).clamp(0, double.infinity);

  double get _discAmt => source == 'Direct'
      ? discountAmount
      : receiveNowQty * rate * discountPercent / 100;

  double get amount => (receiveNowQty * rate) - _discAmt;
  double get gstAmount => amount * gstPercent / 100;
  double get totalAmount => amount + gstAmount;
  double get lineTotal => totalAmount;
}

// ── Scanned item ───────────────────────────────────────────────────────────────
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

// ── Attachment document ────────────────────────────────────────────────────────
class MrnDocument {
  final String id;
  final String fileName;
  final String filePath;
  final String fileType;
  final String fileSize;
  final MrnAttachmentType attachmentType;
  final String source;
  final DateTime uploadedAt;

  MrnDocument({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.attachmentType,
    required this.source,
    required this.uploadedAt,
  });
}

// ── Generic API-driven dropdown option ────────────────────────────────────────
class MrnDropdownOption {
  final String id;
  final String label;

  MrnDropdownOption({required this.id, required this.label});

  factory MrnDropdownOption.fromJson(Map<String, dynamic> json) {
    return MrnDropdownOption(
      id: json['id']?.toString() ?? '',
      label: json['name'] ?? json['label'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MrnDropdownOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ── Submit response ────────────────────────────────────────────────────────────
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
class MrnAddress {
  final String label;  // 'Shipping' or 'Billing'
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;

  const MrnAddress({
    required this.label,
    this.line1 = '',
    this.line2 = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
  });

  String get formatted {
    final parts = [line1, line2, city, state, pincode]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  bool get isEmpty => formatted.isEmpty;

  factory MrnAddress.fromJson(Map<String, dynamic> json) => MrnAddress(
    label:   json['label']   ?? '',
    line1:   json['line1']   ?? json['address1'] ?? '',
    line2:   json['line2']   ?? json['address2'] ?? '',
    city:    json['city']    ?? '',
    state:   json['state']   ?? '',
    pincode: json['pincode'] ?? json['pin'] ?? '',
  );
}