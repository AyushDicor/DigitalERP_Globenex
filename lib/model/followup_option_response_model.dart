// Shared model for the two follow-up masters the backend team is building:
// FollowupStatus/FollowupStatusdropdown and FollowupPurpose/FollowupPurposedropdown.
//
// The exact key casing is not fixed yet, so parsing is deliberately tolerant —
// it accepts statusid/StatusId/purposeid/PurposeId/id/Id for the value and
// status/statusname/purpose/purposename/name (any casing) for the label. That
// way the dropdowns work whichever spelling the endpoints ship with, instead of
// silently rendering blank rows.

class FollowupOptionResponse {
  bool? success;
  List<FollowupOption>? data;
  String? message;
  int? status;

  FollowupOptionResponse({
    this.success,
    this.data,
    this.message,
    this.status,
  });

  factory FollowupOptionResponse.fromJson(Map<String, dynamic> json) =>
      FollowupOptionResponse(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<FollowupOption>.from((json["data"] as List)
                .map((x) => FollowupOption.fromJson(x as Map<String, dynamic>))),
        message: json["message"]?.toString(),
        status: int.tryParse(json["status"]?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "status": status,
      };
}

class FollowupOption {
  final int id;
  final String name;

  const FollowupOption({required this.id, required this.name});

  static dynamic _pick(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      if (j[k] != null) return j[k];
    }
    return null;
  }

  factory FollowupOption.fromJson(Map<String, dynamic> json) => FollowupOption(
        // The shipped endpoints use FollowupStatusid / FollowupPurposeid —
        // listed first; the rest are kept as fallbacks.
        id: int.tryParse(_pick(json, [
                  'FollowupStatusid',
                  'FollowupStatusId',
                  'followupstatusid',
                  'FollowupPurposeid',
                  'FollowupPurposeId',
                  'followuppurposeid',
                  'statusid',
                  'StatusId',
                  'Statusid',
                  'purposeid',
                  'PurposeId',
                  'Purposeid',
                  'id',
                  'Id',
                ])?.toString() ??
                '') ??
            0,
        name: _pick(json, [
              'FollowupStatus',
              'followupstatus',
              'FollowupPurpose',
              'followuppurpose',
              'status',
              'Status',
              'statusname',
              'StatusName',
              'purpose',
              'Purpose',
              'purposename',
              'PurposeName',
              'name',
              'Name',
            ])?.toString() ??
            '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  // Compared by id so a dropdown can match a restored selection against a
  // freshly fetched list.
  @override
  bool operator ==(Object other) => other is FollowupOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
