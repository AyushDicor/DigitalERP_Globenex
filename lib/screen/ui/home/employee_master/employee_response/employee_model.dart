// ─────────────────────────────────────────────────────────────────────────────
// employee_model.dart
// Models for the Employee Master module.
// ─────────────────────────────────────────────────────────────────────────────

/// Generic {id, label} pair every dropdown on this screen is normalised into,
/// so the UI does not care whether an option came from the designation API,
/// the shared indent dropdown, the state list, or a hardcoded list.
class EmpOption {
  final String id;
  final String label;

  const EmpOption({required this.id, required this.label});

  /// Tolerant of the several key spellings the existing endpoints use.
  factory EmpOption.fromJson(Map<String, dynamic> j) => EmpOption(
        id: (j['id'] ??
                j['Id'] ??
                j['stateid'] ??
                j['cityid'] ??
                j['designnationid'] ??
                '')
            .toString(),
        label: (j['label'] ??
                j['Label'] ??
                j['name'] ??
                j['Name'] ??
                j['statename'] ??
                j['cityname'] ??
                j['designnation'] ??
                '')
            .toString(),
      );

  @override
  bool operator ==(Object other) => other is EmpOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The payload the Save button posts.
///
/// Key names below are this app's best guess at the ERP's column names, taken
/// from the web Employee Master form. The backend team has not shipped the
/// endpoint yet — when they do, only the keys in [toJson] should need to move.
class EmployeeMasterPayload {
  // Company scope
  final int compId;
  final int branchId;
  final int userId;

  // Scope — chosen before anything else on the form
  final String vendorId;
  final String vendorName;
  final String siteId;
  final String siteName;

  // General details
  final String employeePhoto; // uploaded file name / url
  final String employeeName;
  final String genderId;
  final String genderName;
  final String departmentId;
  final String departmentName;
  final String pfNo;
  final String esiNo;
  final String designationId;
  final String designationName;
  final String personalPhoneNo;
  final String dateOfJoining; // dd/MM/yyyy
  final String dateOfBirth; // dd/MM/yyyy

  // Salary + work terms
  final String salaryType;
  final String weekOff;
  final String otApplicable;
  final String workHoursMode; // Default / Manual
  final String shiftId;
  final String shiftName;
  final String dailyWorkingHours;

  // Document details
  final String aadharCardNo;
  final String aadharCardFile;
  final String panCardNo;
  final String panCardFile;

  // Address details
  final String fullAddress;
  final String stateId;
  final String stateName;
  final String cityId;
  final String cityName;
  final String pincode;

  const EmployeeMasterPayload({
    required this.compId,
    required this.branchId,
    required this.userId,
    required this.vendorId,
    required this.vendorName,
    required this.siteId,
    required this.siteName,
    required this.employeePhoto,
    required this.employeeName,
    required this.genderId,
    required this.genderName,
    required this.departmentId,
    required this.departmentName,
    required this.pfNo,
    required this.esiNo,
    required this.designationId,
    required this.designationName,
    required this.personalPhoneNo,
    required this.dateOfJoining,
    required this.dateOfBirth,
    required this.salaryType,
    required this.weekOff,
    required this.otApplicable,
    required this.workHoursMode,
    required this.shiftId,
    required this.shiftName,
    required this.dailyWorkingHours,
    required this.aadharCardNo,
    required this.aadharCardFile,
    required this.panCardNo,
    required this.panCardFile,
    required this.fullAddress,
    required this.stateId,
    required this.stateName,
    required this.cityId,
    required this.cityName,
    required this.pincode,
  });

  /// Field names below are the ERP's own, confirmed 2026-08-26 by probing
  /// api/employeeonboarding and reading back api/employeeonboarddetail. They
  /// are NOT guesses any more, and several differ from the obvious spelling —
  /// `name` (not employeename), `mobile`, `joiningdate`, `dob`, `aadharno`,
  /// `panno`, `address`, `workinghours`. A wrong key here is silently dropped
  /// by the server, so do not "tidy" these.
  ///
  /// The server requires `name`, `stateid`, and at least one of
  /// `aadharno` / `panno`.
  Map<String, dynamic> toJson() => {
        'compid': compId,
        'branchid': branchId,
        'userid': userId,

        // Scope
        'vendorid': vendorId,
        'vendorname': vendorName,
        'siteid': siteId,
        'sitename': siteName,

        // General
        'name': employeeName,
        'genderid': genderId,
        'gender': genderName,
        'departmentid': departmentId,
        'designationid': designationId,
        'designation': designationName,
        'pfno': pfNo,
        'esino': esiNo,
        'mobile': personalPhoneNo,
        'joiningdate': dateOfJoining,
        'dob': dateOfBirth,

        // Salary + work terms
        'salarytype': salaryType,
        'weekoff': weekOff,
        'otapplicable': otApplicable,
        'shiftid': shiftId,
        'workinghours': dailyWorkingHours,

        // Documents — the numbers. The scans themselves go up as multipart
        // file parts named photo / aadharfile / panfile, not as text.
        'aadharno': aadharCardNo,
        'panno': panCardNo,

        // Address
        'address': fullAddress,
        'stateid': stateId,
        'statename': stateName,
        'cityid': cityId,
        'cityname': cityName,
        'pincode': pincode,
      };
}
