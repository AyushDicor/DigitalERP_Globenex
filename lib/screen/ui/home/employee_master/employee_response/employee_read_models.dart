// ─────────────────────────────────────────────────────────────────────────────
// employee_read_models.dart
// Read models for employeeonboardinglist / employeeonboarddetail.
//
// Key spellings confirmed 2026-08-26 against the live endpoints. Note the two
// read APIs disagree with each other and with the save: the list returns
// `employeename`, the detail returns `name`, and the save takes `name`. Reads
// go through [pick], which tries all of them, so neither side can break the
// other. The record id is `partyid` everywhere.
// ─────────────────────────────────────────────────────────────────────────────

/// First non-empty value among [keys].
String pick(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
  }
  return '';
}

/// One row in the employee list.
class EmployeeListItem {
  final String id;
  final String employeeCode;
  final String name;
  final String designation;
  final String department;
  final String site;
  final String vendor;
  final String phone;
  final String photoUrl;
  final String dateOfJoining;

  const EmployeeListItem({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.designation,
    required this.department,
    required this.site,
    required this.vendor,
    required this.phone,
    required this.photoUrl,
    required this.dateOfJoining,
  });

  factory EmployeeListItem.fromJson(Map<String, dynamic> j) => EmployeeListItem(
        id: pick(j, ['partyid', 'id', 'Id', 'employeeid', 'onboardingid']),
        employeeCode:
            pick(j, ['employeecode', 'EmployeeCode', 'empcode', 'code']),
        name: pick(j, ['employeename', 'EmployeeName', 'name', 'Name']),
        designation: pick(j, ['designation', 'Designation', 'designnation']),
        department: pick(j, ['department', 'Department', 'departmentname']),
        site: pick(j, ['sitename', 'SiteName', 'site']),
        vendor: pick(j, ['vendorname', 'VendorName', 'vendor', 'partyname']),
        phone: pick(j, [
          'personalphoneno',
          'PersonalPhoneNo',
          'phoneno',
          'mobileno',
          'phone'
        ]),
        // Only a full URL is renderable — a bare file name is not.
        photoUrl:
            pick(j, ['employeephoto', 'EmployeePhoto', 'photo', 'photourl']),
        dateOfJoining:
            pick(j, ['dateofjoining', 'DateOfJoining', 'doj', 'joiningdate']),
      );

  bool get hasPhoto => photoUrl.startsWith('http');

  /// Initials for the avatar when there is no usable photo URL.
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    String head(String s) => s.substring(0, 1).toUpperCase();
    if (parts.length == 1) return head(parts.first);
    return head(parts.first) + head(parts.last);
  }

  /// Everything the list search box matches against.
  String get searchBlob =>
      '$name $employeeCode $designation $department $site $vendor $phone'
          .toLowerCase();
}

/// A titled block of label/value rows on the detail screen.
class EmployeeDetailSection {
  final String title;
  final List<MapEntry<String, String>> rows;
  const EmployeeDetailSection(this.title, this.rows);
}

/// The full record behind the read-only detail screen.
///
/// Held as ordered label/value sections rather than a fixed field list, so a
/// key the API does not send is simply left out instead of rendering blank.
class EmployeeDetail {
  final String id;
  final String employeeCode;
  final String name;
  final String designation;
  final String photoUrl;

  /// Kept as plain fields as well as inside [sections], because the ID card
  /// needs them individually rather than as display rows.
  final String department;
  final String vendor;
  final String site;
  final String phone;

  final List<EmployeeDetailSection> sections;
  final List<MapEntry<String, String>> attachments;

  const EmployeeDetail({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.designation,
    required this.photoUrl,
    required this.department,
    required this.vendor,
    required this.site,
    required this.phone,
    required this.sections,
    required this.attachments,
  });

  factory EmployeeDetail.fromJson(Map<String, dynamic> j) {
    /// Each spec row is [label, ...candidate keys].
    List<MapEntry<String, String>> rows(List<List<String>> spec) => [
          for (final row in spec)
            if (pick(j, row.sublist(1)).isNotEmpty)
              MapEntry(row.first, pick(j, row.sublist(1))),
        ];

    final files = <MapEntry<String, String>>[];
    void addFile(String label, List<String> keys) {
      final v = pick(j, keys);
      // Only full URLs are openable; a bare file name would 404.
      if (v.startsWith('http')) files.add(MapEntry(label, v));
    }

    addFile('Aadhar Card', ['aadharfileurl', 'aadharcardfile', 'aadharfile']);
    addFile('PAN Card', ['panfileurl', 'pancardfile', 'panfile']);

    return EmployeeDetail(
      id: pick(j, ['partyid', 'id', 'Id', 'employeeid', 'onboardingid']),
      employeeCode: pick(j, ['partycode', 'empid', 'employeecode', 'empcode']),
      name: pick(j, ['employeename', 'EmployeeName', 'name']),
      designation: pick(j, ['designation', 'Designation', 'designnation']),
      photoUrl:
          pick(j, ['photourl', 'employeephoto', 'EmployeePhoto', 'photo']),
      department: pick(j, ['department', 'Department', 'departmentname']),
      vendor: pick(j, ['vendorname', 'VendorName', 'vendor', 'partyname']),
      site: pick(j, ['sitename', 'SiteName', 'site']),
      phone: pick(j, ['mobile', 'mobileno', 'personalphoneno', 'phoneno']),
      attachments: files,
      sections: [
        EmployeeDetailSection(
            'Vendor & Site',
            rows([
              ['Vendor Name', 'vendorname', 'VendorName', 'vendor', 'partyname'],
              ['Site Name', 'sitename', 'SiteName', 'site'],
            ])),
        EmployeeDetailSection(
            'General Details',
            rows([
              ['Gender', 'gender', 'Gender', 'gendername'],
              ['Department', 'department', 'Department', 'departmentname'],
              ['Designation', 'designation', 'Designation', 'designnation'],
              ['PF No', 'pfno', 'PfNo', 'PFNo'],
              ['ESI No', 'esino', 'EsiNo', 'ESINo'],
              ['Personal Phone', 'mobile', 'mobileno', 'personalphoneno', 'phoneno'],
              ['Date of Joining', 'dateofjoining', 'doj', 'joiningdate'],
              ['Date of Birth', 'dateofbirth', 'dob', 'birthdate'],
            ])),
        EmployeeDetailSection(
            'Salary & Work',
            rows([
              ['Salary Type', 'salarytype', 'SalaryType'],
              ['Week Off', 'weekoff', 'WeekOff'],
              ['OT Applicable', 'otapplicable', 'OtApplicable'],
              ['Work Hours', 'workhourstype', 'WorkHoursType', 'workhours'],
              ['Shift', 'shiftname', 'ShiftName', 'shift'],
              ['Daily Working Hours', 'dailyworkinghours', 'workinghours'],
            ])),
        EmployeeDetailSection(
            'Document Details',
            rows([
              ['Aadhar Card No', 'aadharcardno', 'AadharCardNo', 'aadharno'],
              ['PAN Card No', 'pancardno', 'PanCardNo', 'panno'],
            ])),
        EmployeeDetailSection(
            'Address Details',
            rows([
              ['Full Address', 'fulladdress', 'FullAddress', 'address'],
              ['State', 'statename', 'StateName', 'state'],
              ['City', 'cityname', 'CityName', 'city'],
              ['Pincode', 'pincode', 'Pincode', 'pinno'],
            ])),
      ].where((s) => s.rows.isNotEmpty).toList(),
    );
  }

  bool get hasPhoto => photoUrl.startsWith('http');
}

/// Pulls the row list out of whatever envelope the API uses — `data`, a nested
/// `data.data`, `list`, or a bare top-level array.
List<Map<String, dynamic>> extractRows(dynamic body) {
  dynamic node = body;
  if (node is Map) {
    node = node['data'] ?? node['Data'] ?? node['list'] ?? node['result'];
    if (node is Map) {
      node = node['data'] ?? node['list'] ?? node['rows'] ?? node['items'];
    }
  }
  if (node is List) {
    return node.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
  return const [];
}

/// Pulls a single record out of the same range of envelopes.
Map<String, dynamic>? extractRecord(dynamic body) {
  dynamic node = body;
  if (node is Map) {
    final inner = node['data'] ?? node['Data'] ?? node['result'];
    if (inner is Map) {
      final deeper = inner['data'];
      if (deeper is Map) return deeper.cast<String, dynamic>();
      return inner.cast<String, dynamic>();
    }
    if (inner is List && inner.isNotEmpty && inner.first is Map) {
      return (inner.first as Map).cast<String, dynamic>();
    }
    if (inner == null) return node.cast<String, dynamic>();
  }
  if (node is List && node.isNotEmpty && node.first is Map) {
    return (node.first as Map).cast<String, dynamic>();
  }
  return null;
}

/// Everything api/employeeidcard hands back for one employee's ID card.
///
/// This endpoint is the card's source of truth: it carries the company name
/// and logo (which live nowhere else in the app's session) plus a server-built
/// `qrdata` string, so the app never has to invent the QR payload itself.
class EmployeeCardInfo {
  final String partyId;
  final String companyName;
  final String companyLogoUrl;
  final String employeeName;
  final String photoUrl;
  final String empId;
  final String designation;
  final String siteName;
  final String phone;
  final String qrData;

  const EmployeeCardInfo({
    required this.partyId,
    required this.companyName,
    required this.companyLogoUrl,
    required this.employeeName,
    required this.photoUrl,
    required this.empId,
    required this.designation,
    required this.siteName,
    required this.phone,
    required this.qrData,
  });

  factory EmployeeCardInfo.fromJson(Map<String, dynamic> j) => EmployeeCardInfo(
        partyId: pick(j, ['partyid', 'id']),
        companyName: pick(j, ['companyname', 'CompanyName']),
        companyLogoUrl: pick(j, ['companylogourl', 'CompanyLogoUrl']),
        employeeName: pick(j, ['employeename', 'name', 'EmployeeName']),
        photoUrl: pick(j, ['photourl', 'photo', 'PhotoUrl']),
        empId: pick(j, ['empid', 'partycode', 'employeecode']),
        designation: pick(j, ['designation', 'Designation']),
        siteName: pick(j, ['sitename', 'SiteName', 'site']),
        phone: pick(j, ['phone', 'mobile', 'mobileno']),
        qrData: pick(j, ['qrdata', 'QrData', 'qr']),
      );
}
