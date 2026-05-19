import 'package:flutter/foundation.dart';

class MrnQcListRequest {
  final String fromdate;
  final String todate;
  final int compid;
  final int branchid;
  final int userid;
  final int partyid;
  final int siteid;
  final int jobtypeid;
  final String filtertype;


  MrnQcListRequest({
    required this.fromdate,
    required this.todate,
    required this.compid,
    required this.branchid,
    required this.userid,
    this.partyid = 0,
    this.siteid = 0,
    this.jobtypeid = 0,
    required this.filtertype,
  });

  Map<String, dynamic> toJson() => {
    'fromdate': fromdate,
    'todate': todate,
    'compid': compid,
    'branchid': branchid,
    'userid': userid,
    'partyid': partyid,
    'siteid': siteid,
    'jobtypeid': jobtypeid,
    'filtertype': filtertype,
  };
}

// class MrnQcListResponse {
//   final bool? success;
//   final int? status;
//   final String? message;
//   final List<MrnQcListItem> data;
//
//   MrnQcListResponse({this.success, this.status, this.message, this.data = const []});
//
//   factory MrnQcListResponse.fromJson(Map<String, dynamic> json) {
//     final raw = json['data'];
//     final items = raw is String ? _parseHtmlTable(raw) : <MrnQcListItem>[];
//     return MrnQcListResponse(
//       success: json['success'],
//       status:  json['status'],
//       message: json['message'],
//       data:    items,
//     );
//   }
//
//   // ── Parse the HTML table string into a list of MrnQcListItem ─────────────
//   static List<MrnQcListItem> _parseHtmlTable(String html) {
//     final items = <MrnQcListItem>[];
//     // Extract all <tr> rows inside <tbody>
//     final tbodyMatch = RegExp(r'<tbody>(.*?)</tbody>', dotAll: true).firstMatch(html);
//     if (tbodyMatch == null) return items;
//
//     final rows = RegExp(r'<tr>(.*?)</tr>', dotAll: true)
//         .allMatches(tbodyMatch.group(1)!)
//         .toList();
//
//     for (final row in rows) {
//       final cells = RegExp(r'<td>(.*?)</td>', dotAll: true)
//           .allMatches(row.group(1)!)
//           .map((m) => m.group(1)!.trim())
//           .toList();
//
//       // Order: ID, Mrnno, BillNo, Mrndate, PartyName, SiteName, JobType, TotalQty, TotalAmt
//       if (cells.length >= 9) {
//         items.add(MrnQcListItem(
//           id:        int.tryParse(cells[0]) ?? 0,
//           MrnNo:     cells[1],
//           billNo:    cells[2],
//           MrnDate:   cells[3],
//           partyName: cells[4],
//           siteName:  cells[5],
//           jobType:   cells[6],
//           totalQty:  double.tryParse(cells[7]) ?? 0,
//           totalAmt:  double.tryParse(cells[8]) ?? 0,
//         ));
//       }
//     }
//     return items;
//   }
// }
//─────────────────────Mrn List ───────────────────────────────────────────────

class MrnQcListRawRow {
  final int id; // always extract ID for tap-to-edit
  final Map<String, dynamic> data; // all columns as-is from API

  MrnQcListRawRow({required this.id, required this.data});
}

class MrnQcListResponse {
  final bool? success;
  final int? status;
  final String? message;
  final List<MrnQcListItem> data; // parsed items (for edit navigation)
  final List<MrnQcListRawRow> rawRows; // dynamic rows for table display
  final List<String> columns; // column headers in order
  final String rawHtml;

  MrnQcListResponse({
    this.success,
    this.status,
    this.message,
    this.data = const [],
    this.rawRows = const [],
    this.columns = const [],
    this.rawHtml = '',
  });

  factory MrnQcListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<MrnQcListItem> items = [];
    List<MrnQcListRawRow> rawRows = [];
    List<String> columns = [];
    String html = '';

    if (rawData is List && rawData.isNotEmpty) {
      final firstRow = rawData.first as Map<String, dynamic>;
      columns = firstRow.keys.toList();

      for (final row in rawData) {
        final map = row as Map<String, dynamic>;

        // ✅ Handle double ID (335787.0) correctly
        final rawId = map['ID'] ?? map['id'] ?? map['stockid'] ?? 0;
        final int id;
        if (rawId is double) {
          id = rawId.toInt();
        } else if (rawId is int) {
          id = rawId;
        } else {
          id = int.tryParse(rawId.toString().split('.')[0]) ?? 0;
        }

        rawRows.add(MrnQcListRawRow(id: id, data: map));
        items.add(MrnQcListItem.fromJson(map));
      }
    } else if (rawData is String && rawData.isNotEmpty) {
      html = rawData;
      items = MrnQcListResponse._parseHtmlTable(rawData);
    }

    return MrnQcListResponse(
      status: json['status'],
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: items,
      rawRows: rawRows,
      columns: columns,
      rawHtml: html,
    );
  }

  static List<MrnQcListItem> _parseHtmlTable(String html) {
    final List<MrnQcListItem> result = [];
    try {
      final tbodyMatch =
      RegExp(r'<tbody>(.*?)</tbody>', dotAll: true).firstMatch(html);
      if (tbodyMatch == null) return result;
      final rowMatches = RegExp(r'<tr>(.*?)</tr>', dotAll: true)
          .allMatches(tbodyMatch.group(1)!);
      for (final row in rowMatches) {
        final cells = RegExp(r'<td>(.*?)</td>', dotAll: true)
            .allMatches(row.group(1)!)
            .map((m) => m.group(1)?.trim() ?? '')
            .toList();
        if (cells.length < 9) continue;
        result.add(MrnQcListItem(
          id: int.tryParse(cells[0]) ?? 0,
          MrnNo: cells[1],
          billNo: cells[2],
          MrnDate: cells[3],
          partyName: cells[4],
          siteName: cells[5],
          jobType: cells[6],
          totalQty: double.tryParse(cells[7]) ?? 0,
          totalAmt: double.tryParse(cells[8]) ?? 0,
        ));
      }
    } catch (_) {}
    return result;
  }

}

class MrnQcListItem {
  final int id;
  final String MrnNo;
  final String billNo;
  final String MrnDate;
  final String partyName;
  final String siteName;
  final String jobType;
  final double totalQty;
  final double totalAmt;
  final String withRateUrl;
  final String withoutRateUrl;

  MrnQcListItem({
    required this.id,
    required this.MrnNo,
    required this.billNo,
    required this.MrnDate,
    required this.partyName,
    required this.siteName,
    required this.jobType,
    required this.totalQty,
    required this.totalAmt,
    this.withRateUrl = '',
    this.withoutRateUrl = '',
  });

  // ✅ Add this
  factory MrnQcListItem.fromJson(Map<String, dynamic> json) {
    // ✅ DEBUG — print all keys to find the correct Mrn No field name
    if (kDebugMode) print('📋 MrnQcListItem raw keys: ${json.keys.toList()}');
    if (kDebugMode) print('📋 MrnQcListItem raw data: $json');

    return MrnQcListItem(
      id: _parseId(json['ID'] ?? json['id'] ?? json['stockid']),
      MrnNo: json['Mrnno']?.toString() ??
          json['Mrnno']?.toString() ??
          json['MrnNo']?.toString() ??
          json['MRNNo']?.toString() ??
          json['mrnno']?.toString() ??
          json['Mrnno']?.toString() ??
          json['MrnNo']?.toString() ??
          '',
      billNo: json['BillNo']?.toString() ?? json['billno']?.toString() ?? '',
      MrnDate: json['Mrndate']?.toString() ?? json['Mrndate']?.toString() ?? '',
      partyName: json['PartyName']?.toString() ?? json['partyname']?.toString() ?? '',
      siteName: json['SiteName']?.toString() ?? json['sitename']?.toString() ?? '',
      jobType: json['JobType']?.toString() ?? json['jobtype']?.toString() ?? '',
      totalQty: _parseDouble(json['TotalQty'] ?? json['totalqty']),
      totalAmt: _parseDouble(json['TotalAmt'] ?? json['totalamt']),
      withRateUrl: json['withrateurl']?.toString() ?? '',
      withoutRateUrl: json['withOUTrateurl']?.toString() ?? '',
    );
  }

// ✅ Handles int, double (335787.0), and string ("335787")
  static int _parseId(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt(); // ✅ 335787.0 → 335787
    final str = v.toString().split('.')[0]; // ✅ "335787.0" → "335787"
    return int.tryParse(str) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}