import 'dart:convert';

// MRN Models

enum MrnSourceType { purchaseOrder, directPurchase }

enum MrnDocType { invoice, indent, deliveryChallan, inspection, other }

enum MrnAttachmentType { bill, challan }

// ── MRN Dropdown API response ──────────────────────────────────────────────────
class MrnDropdownResponse {
  final int? status;
  final bool? success;
  final String? message;
  final List<MrnDropdownOption>? data;

  MrnDropdownResponse({this.status, this.success, this.message, this.data});

  factory MrnDropdownResponse.fromJson(Map<String, dynamic> json) {
    return MrnDropdownResponse(
      status: json['status'],
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)
          ?.map((e) => MrnDropdownOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Pending PO API — request body ─────────────────────────────────────────────
class GetPendingPoRequest {
  final int compid;
  final int branchid;
  final int userid;
  final int partyid;
  final int siteid;
  final String orderid;
  final int stockid;

  GetPendingPoRequest({
    required this.compid,
    required this.branchid,
    required this.userid,
    this.partyid = 0,
    this.siteid = 0,
    this.orderid = '',
    this.stockid = 0,
  });

  Map<String, dynamic> toJson() => {
        'compid': compid,
        'branchid': branchid,
        'userid': userid,
        'partyid': partyid,
        'siteid': siteid,
        'orderid': orderid,
        'stockid': stockid,
      };

  String toJsonString() => jsonEncode(toJson());
}

// ── Pending PO API — response wrapper ─────────────────────────────────────────
class GetPendingPoResponse {
  final bool? success;
  final List<PendingPoItem>? data;
  final String? message;
  final int? status;

  GetPendingPoResponse({this.success, this.data, this.message, this.status});

  factory GetPendingPoResponse.fromJson(Map<String, dynamic> json) {
    return GetPendingPoResponse(
      success: json['success'],
      message: json['message'],
      status: json['status'],
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .map((v) => PendingPoItem.fromJson(v as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

GetPendingPoResponse getPendingPoResponseFromJson(String str) =>
    GetPendingPoResponse.fromJson(jsonDecode(str));

// ── Single PO row (used in both PO list AND item list) ─────────────────────────
/// When [stockid] == 0  → this is a PO header row
/// When [stockid]  > 0  → this is an item line row (same endpoint, different data)
class PendingPoItem {
  // ── From getpendingpo API (stockid = 0) ───────────────────────────────────
  final int orderid; // e.g. 27658 — pass this as orderid in process call
  final String orderno; // e.g. "GP09/0030/PO/26-27" — display PO number
  final String orderdate; // e.g. "09-05-2026"
  final String partyname; // e.g. "GOLDLINE SECURITY SYSTEMS"
  final int totalqty; // total items ordered
  final double totalamount; // subtotal before GST
  final double grandtotal; // total including GST

  // ── Item line fields — populated when stockid > 0 (process call) ─────────
  // TODO: update these once you get the item API response shape
  final String itemname;
  final String itemcode;
  final String unit;
  final double orderedqty;
  final double receivedqty;
  final double rate;
  final double discountpercent;
  final double gstpercent;
  final int stockid;

  // UI state
  bool isSelected;

  PendingPoItem({
    required this.orderid,
    this.orderno = '',
    this.orderdate = '',
    this.partyname = '',
    this.totalqty = 0,
    this.totalamount = 0,
    this.grandtotal = 0,
    // item fields
    this.itemname = '',
    this.itemcode = '',
    this.unit = 'Nos',
    this.orderedqty = 0,
    this.receivedqty = 0,
    this.rate = 0,
    this.discountpercent = 0,
    this.gstpercent = 18,
    this.stockid = 0,
    this.isSelected = false,
  });

  factory PendingPoItem.fromJson(Map<String, dynamic> json) {
    return PendingPoItem(
      // PO header fields
      orderid: _i(json['orderid']),
      orderno: json['orderno']?.toString() ?? '',
      orderdate: json['orderdate']?.toString() ?? '',
      partyname: json['partyname']?.toString() ?? '',
      totalqty: _i(json['totalqty']),
      totalamount: _d(json['totalamount']),
      grandtotal: _d(json['grandtotal']),
      // Item line fields — covering common naming variants
      itemname: json['itemname']?.toString() ??
          json['item_name']?.toString() ??
          json['name']?.toString() ??
          '',
      itemcode: json['itemcode']?.toString() ??
          json['item_code']?.toString() ??
          json['code']?.toString() ??
          '',
      unit: json['unit']?.toString() ?? json['unitname']?.toString() ?? 'Nos',
      orderedqty: _d(json['orderedqty'] ??
          json['orderqty'] ??
          json['qty'] ??
          json['poqty']),
      receivedqty: _d(json['receivedqty'] ??
          json['recqty'] ??
          json['prevreceivedqty'] ??
          0),
      rate: _d(json['rate'] ?? json['unitrate'] ?? json['price']),
      discountpercent:
          _d(json['discountpercent'] ?? json['discount'] ?? json['disc'] ?? 0),
      gstpercent: _d(json['gstpercent'] ??
          json['gst'] ??
          json['gstrate'] ??
          json['tax'] ??
          18),
      stockid: _i(json['stockid'] ?? json['stock_id'] ?? 0),
    );
  }

  /// Converts an item-response row to [MrnItemLine].
  /// Call this after processSelectedPO() returns item rows.
  MrnItemLine toItemLine({required String poNumber}) {
    return MrnItemLine(
      itemId: itemcode.isNotEmpty ? itemcode : orderid.toString(),
      itemName: itemname,
      itemCode: itemcode,
      unit: unit,
      source: 'PO',
      orderNo: poNumber,
      poQty: orderedqty,
      previouslyReceivedQty: receivedqty,
      rate: rate,
      discountPercent: discountpercent,
      gstPercent: gstpercent,
      receiveNowQty: (orderedqty - receivedqty).clamp(0, double.infinity),
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

// ── PO header item (kept for any legacy usage) ─────────────────────────────────
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
  final String source;
  final String orderNo;
  final double poQty;
  final double previouslyReceivedQty;
  final double rate;
  final double discountPercent;
  final double discountAmount;
  final double gstPercent;

  // ✅ Add these fields
  final int unitId;
  final int transId;
  final int uniqueId;
  final int makeId;
  final String make;
  final String batchNo;

  double receiveNowQty;
  String? selectedGodownId;
  String remarks;
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
    this.discountAmount = 0,
    this.gstPercent = 18,
    required this.receiveNowQty,
    this.selectedGodownId,
    this.remarks = '',
    this.isExpanded = false,
    // ✅ Add with defaults so existing Direct/PO usages don't break
    this.unitId = 0,
    this.transId = 0,
    this.uniqueId = 0,
    this.makeId = 0,
    this.make = '',
    this.batchNo = '',
  });

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
  final bool? success;   // ✅ add this
  final String? message;
  final String? mrnNumber;

  MrnSubmitResponse({
    this.status,
    this.success,         // ✅ add this
    this.message,
    this.mrnNumber,
  });

  factory MrnSubmitResponse.fromJson(Map<String, dynamic> json) {
    return MrnSubmitResponse(
      status:    json['status'],
      success:   json['success'],   // ✅ add this
      message:   json['message'],
      mrnNumber: json['mrnno'],
    );
  }
}

// ── Address ────────────────────────────────────────────────────────────────────
class MrnAddress {
  final String label;
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
        label: json['label'] ?? '',
        line1: json['line1'] ?? json['address1'] ?? '',
        line2: json['line2'] ?? json['address2'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        pincode: json['pincode'] ?? json['pin'] ?? '',
      );
}


// ── Process PO request body ────────────────────────────────────────────────
class ProcessPendingPoRequest {
  final int type;
  final int compid;
  final int branchid;
  final int userid;
  final int partyid;
  final int siteid;
  final String orderid;
  final int stockid;

  ProcessPendingPoRequest({
    this.type = 1,
    required this.compid,
    required this.branchid,
    required this.userid,
    this.partyid = 0,
    this.siteid = 0,
    required this.orderid,
    this.stockid = 0,
  });

  Map<String, dynamic> toJson() => {
    'type':     type,
    'compid':   compid,
    'branchid': branchid,
    'userid':   userid,
    'partyid':  partyid,
    'siteid':   siteid,
    'orderid':  orderid,
    'stockid':  stockid,
  };
}

// ── Process PO response item ───────────────────────────────────────────────
class ProcessPoItem {
  final int orderid;
  final String orderno;
  final int itemid;
  final String itemname;
  final double mrp;
  final double rate;
  final double quantity;   // ordered qty
  final double amount;
  final double gstpercent;
  final double taxamt;
  final double discountpercent;
  final double discountamount;
  final int unitid;
  final String unitname;
  final String specification;
  final int makeid;
  final String make;
  final int godownid;
  final String godownname;
  final String batchno;
  final int transid;
  final double remqty;     // remaining/balance qty — use as maxReceivable
  final double totalamount;
  final int uniqueid;

  ProcessPoItem({
    required this.orderid,
    this.orderno = '',
    required this.itemid,
    this.itemname = '',
    this.mrp = 0,
    this.rate = 0,
    this.quantity = 0,
    this.amount = 0,
    this.gstpercent = 0,
    this.taxamt = 0,
    this.discountpercent = 0,
    this.discountamount = 0,
    this.unitid = 0,
    this.unitname = 'Nos',
    this.specification = '',
    this.makeid = 0,
    this.make = '',
    this.godownid = 0,
    this.godownname = '',
    this.batchno = '',
    this.transid = 0,
    this.remqty = 0,
    this.totalamount = 0,
    this.uniqueid = 0,
  });

  factory ProcessPoItem.fromJson(Map<String, dynamic> json) {
    return ProcessPoItem(
      orderid:         _i(json['orderid']),
      orderno:         json['orderno']?.toString() ?? '',
      itemid:          _i(json['itemid']),
      itemname:        json['itemname']?.toString() ?? '',
      mrp:             _d(json['mrp']),
      rate:            _d(json['rate']),
      quantity:        _d(json['quantity']),
      amount:          _d(json['amount']),
      gstpercent:      _d(json['gstpercent']),
      taxamt:          _d(json['taxamt']),
      discountpercent: _d(json['discountpercent']),
      discountamount:  _d(json['discountamount']),
      unitid:          _i(json['unitid']),
      unitname:        json['unitname']?.toString() ?? 'Nos',
      specification:   json['specification']?.toString() ?? '',
      makeid:          _i(json['makeid']),
      make:            json['make']?.toString() ?? '',
      godownid:        _i(json['godownid']),
      godownname:      json['godownname']?.toString() ?? '',
      batchno:         json['batchno']?.toString() ?? '',
      transid:         _i(json['transid']),
      remqty:          _d(json['remqty']),
      totalamount:     _d(json['totalamount']),
      uniqueid:        _i(json['uniqueid']),
    );
  }

  // ── Convert to MrnItemLine ─────────────────────────────────────────────
  MrnItemLine toItemLine({required String poNumber}) {
    // poQty = quantity (ordered)
    // previouslyReceivedQty = quantity - remqty (already received)
    // receiveNowQty = remqty (balance left to receive)
    final alreadyReceived = (quantity - remqty).clamp(0.0, double.infinity);
    return MrnItemLine(
      itemId:                itemid.toString(),
      itemName:              itemname,
      itemCode:              itemid.toString(),
      unit:                  unitname,
      source:                'PO',
      orderNo:               poNumber,
      poQty:                 quantity,
      previouslyReceivedQty: alreadyReceived,
      rate:                  rate,
      discountPercent:       discountpercent,
      gstPercent:            gstpercent,
      receiveNowQty:         remqty,   // default to full balance
      selectedGodownId:      godownid > 0 ? godownid.toString() : null,
      remarks:               specification,
      unitId:    unitid,
      transId:   transid,
      uniqueId:  uniqueid,
      makeId:    makeid,
      make:      make,
      batchNo:   batchno,
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

// ── Process PO response wrapper ────────────────────────────────────────────
class ProcessPendingPoResponse {
  final bool? success;
  final List<ProcessPoItem>? data;
  final String? message;
  final int? status;

  ProcessPendingPoResponse({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory ProcessPendingPoResponse.fromJson(Map<String, dynamic> json) {
    return ProcessPendingPoResponse(
      success: json['success'],
      message: json['message'],
      status:  json['status'],
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
          .map((e) => ProcessPoItem.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],
    );
  }
}