// ── additional_charge_model.dart ──────────────────────────────────────────────
// Model for a single additional charge row (Freight, CGST, Discount, etc.)
// Mirrors the web ERP's "Other Details" table.

import 'package:flutter/foundation.dart';

enum ChargeNature { plus, less }

enum ChargeCalcType { fixed, percentage }

class AdditionalChargeHead {
  final String id;
  final String label;

  const AdditionalChargeHead({required this.id, required this.label});

  factory AdditionalChargeHead.fromJson(Map<String, dynamic> json) =>
      AdditionalChargeHead(
        id: json['headid']?.toString() ?? json['id']?.toString() ?? '',
        label: json['headname']?.toString() ?? json['label']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'headid': id, 'headname': label};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AdditionalChargeHead && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A single row in the Additional Charges table.
class AdditionalCharge {
  /// Unique local ID (timestamp-based) — not sent to API.
  final String localId;

  /// The selected charge head (e.g. Freight Inward, CGST @ 2.5%).
  AdditionalChargeHead? head;

  /// Plus (+) or Less (−).
  ChargeNature nature;

  /// Fixed amount OR percentage.
  ChargeCalcType calcType;

  /// The raw value entered by the user (either an amount or a %).
  double value;

  /// The localId of the charge this row's % is calculated on.
  /// null → use item subtotal as base.
  String? dependsOnLocalId;

  /// Resolved label shown in the Depends On column.
  String? dependsOnLabel;

  /// ── Computed ──────────────────────────────────────────────────────────────
  /// Filled in by [AdditionalChargesController._recalculate].
  double calculatedAmount = 0.0;

  AdditionalCharge({
    required this.localId,
    this.head,
    this.nature = ChargeNature.plus,
    this.calcType = ChargeCalcType.fixed,
    this.value = 0.0,
    this.dependsOnLocalId,
    this.dependsOnLabel,
  });

  /// Deep copy used when editing.
  AdditionalCharge copyWith({
    AdditionalChargeHead? head,
    ChargeNature? nature,
    ChargeCalcType? calcType,
    double? value,
    String? dependsOnLocalId,
    String? dependsOnLabel,
  }) =>
      AdditionalCharge(
        localId: localId,
        head: head ?? this.head,
        nature: nature ?? this.nature,
        calcType: calcType ?? this.calcType,
        value: value ?? this.value,
        dependsOnLocalId: dependsOnLocalId ?? this.dependsOnLocalId,
        dependsOnLabel: dependsOnLabel ?? this.dependsOnLabel,
      );

  /// Serialise for API payload.
  Map<String, dynamic> toApiJson() => {
    'headid': int.tryParse(head?.id ?? '0') ?? 0,
    'headname': head?.label ?? '',
    'nature': nature == ChargeNature.plus ? '+' : '-',
    'calctype': calcType == ChargeCalcType.fixed ? 'fixed' : 'percentage',
    'value': value,
    'amount': calculatedAmount,
    'dependsid': dependsOnLocalId ?? '0',
  };
}