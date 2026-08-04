// Response of `leadexistingclientdetail` — the prefill used when a lead is
// raised against a company that is already a client.
//
// Request takes `partyid` (NOT clientid — that returns "Client detail Not
// Available"). Verified live on two parties; the shape is stable.
//
// Note there is no free-text address field: location comes as
// country/state/city/area ids + names, which map onto the form's dropdowns.

class LeadExistingClientResponse {
  bool? success;
  LeadExistingClient? data;
  String? message;
  int? status;

  LeadExistingClientResponse({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory LeadExistingClientResponse.fromJson(Map<String, dynamic> json) =>
      LeadExistingClientResponse(
        success: json["success"],
        data: json["data"] == null
            ? null
            : LeadExistingClient.fromJson(
                json["data"] as Map<String, dynamic>),
        message: json["message"]?.toString(),
        status: int.tryParse(json["status"]?.toString() ?? ''),
      );
}

class LeadExistingClient {
  final int? partyid;
  final String? partyname;
  final String? emailid;
  final String? mobileno;
  final int? countryid;
  final String? countryname;
  final int? stateid;
  final String? statename;
  final int? cityid;
  final String? cityname;
  final int? areaid;
  final String? areaname;
  final int? businesstypeid;
  final String? businesstype;
  final List<ClientContact> contactlist;

  const LeadExistingClient({
    this.partyid,
    this.partyname,
    this.emailid,
    this.mobileno,
    this.countryid,
    this.countryname,
    this.stateid,
    this.statename,
    this.cityid,
    this.cityname,
    this.areaid,
    this.areaname,
    this.businesstypeid,
    this.businesstype,
    this.contactlist = const [],
  });

  static int? _toInt(dynamic v) =>
      v == null ? null : int.tryParse(v.toString());

  factory LeadExistingClient.fromJson(Map<String, dynamic> json) =>
      LeadExistingClient(
        partyid: _toInt(json["partyid"]),
        partyname: json["partyname"]?.toString(),
        emailid: json["emailid"]?.toString(),
        mobileno: json["mobileno"]?.toString(),
        countryid: _toInt(json["countryid"]),
        countryname: json["countryname"]?.toString(),
        stateid: _toInt(json["stateid"]),
        statename: json["statename"]?.toString(),
        cityid: _toInt(json["cityid"]),
        cityname: json["cityname"]?.toString(),
        areaid: _toInt(json["areaid"]),
        areaname: json["areaname"]?.toString(),
        businesstypeid: _toInt(json["businesstypeid"]),
        businesstype: json["businesstype"]?.toString(),
        contactlist: json["contactlist"] == null
            ? const []
            : List<ClientContact>.from((json["contactlist"] as List)
                .map((e) => ClientContact.fromJson(e as Map<String, dynamic>))),
      );
}

class ClientContact {
  final int? contactid;
  final String? contactperson;
  final String? mobileno;
  final String? emailid;

  const ClientContact({
    this.contactid,
    this.contactperson,
    this.mobileno,
    this.emailid,
  });

  factory ClientContact.fromJson(Map<String, dynamic> json) => ClientContact(
        contactid: int.tryParse(json["contactid"]?.toString() ?? ''),
        contactperson: json["contactperson"]?.toString(),
        mobileno: json["mobileno"]?.toString(),
        emailid: json["emailid"]?.toString(),
      );

  // Compared by id so a dropdown can still match its selection after the
  // contact list is re-fetched and rebuilt.
  @override
  bool operator ==(Object other) =>
      other is ClientContact && other.contactid == contactid;

  @override
  int get hashCode => contactid.hashCode;
}
