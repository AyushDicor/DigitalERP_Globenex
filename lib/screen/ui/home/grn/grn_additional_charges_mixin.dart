// ── grn_additional_charges_mixin.dart ────────────────────────────────────────
// Drop this mixin onto GrnController to add full Additional Charges logic.
//
// USAGE — in grn_controller.dart:
//   class GrnController extends AppBaseController
//       with GrnAdditionalChargesMixin {
//
// Then call `_fetchAllDropdowns()` to include `fetchChargeHeads()`.

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../../utils/show_message.dart';

// ignore: depend_on_referenced_packages
import 'package:digitalerp/utils/app_constant_new.dart';

import 'grn_controller/additional_charge_model.dart';

mixin GrnAdditionalChargesMixin on GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  List<AdditionalChargeHead> chargeHeadList = [];
  bool isLoadingChargeHeads = false;

  List<AdditionalCharge> additionalCharges = [];

  // ── Derived totals (set by _recalculateCharges) ────────────────────────────
  double additionalChargesTotal = 0.0; // net (+/-)
  double additionalChargesGross = 0.0; // sum of + rows
  double additionalChargesDeduct = 0.0; // sum of - rows

  // ── These must be provided by the host controller ─────────────────────────
  /// Item subtotal (sum of item amounts before GST).
  double get subtotal;

  /// Grand total before additional charges.
  double get grandTotal;

  // ── Fetch charge heads from API ────────────────────────────────────────────
  /// Call this in `_fetchAllDropdowns`.
  Future<void> fetchChargeHeads() async {
    isLoadingChargeHeads = true;
    update();
    try {
      // ------------------------------------------------------------------
      // Replace the body map / api call with your real endpoint.
      // The endpoint should return a list like:
      //   [{"headid": 248274, "headname": "FREIGHT INWARD"}, ...]
      //
      // Example using the same GrnDropdownList pattern:
      //   final res = await api.getGrnDropdownList(
      //       _GrnDropdownBody('chargehead'));
      //
      // For now we fall back to a sensible default list so the UI works
      // immediately even if the endpoint isn't wired yet.
      // ------------------------------------------------------------------

      // ── Fallback / default heads (mirrors common ERP setups) ──────────
      chargeHeadList = [
        const AdditionalChargeHead(id: '1', label: 'Freight Inward'),
        const AdditionalChargeHead(id: '2', label: 'Packing & Forwarding'),
        const AdditionalChargeHead(id: '3', label: 'Insurance'),
        const AdditionalChargeHead(id: '4', label: 'Loading / Unloading'),
        const AdditionalChargeHead(id: '5', label: 'CGST @ 2.5% INPUT'),
        const AdditionalChargeHead(id: '6', label: 'SGST @ 2.5% INPUT'),
        const AdditionalChargeHead(id: '7', label: 'IGST @ 18% INPUT'),
        const AdditionalChargeHead(id: '8', label: 'IGST @ 5% INPUT'),
        const AdditionalChargeHead(id: '9', label: 'DISCOUNT'),
        const AdditionalChargeHead(id: '10', label: 'Round Off'),
        const AdditionalChargeHead(id: '11', label: 'Handling Charges'),
        const AdditionalChargeHead(id: '12', label: 'TDS Deduction'),
      ];

      // ── Uncomment once API is ready ────────────────────────────────────
      // final res = await api.getGrnDropdownList(_GrnDropdownBody('chargehead'));
      // if ((res.status == 200 || res.success == true) && res.data != null) {
      //   chargeHeadList = (res.data as List)
      //       .map((e) => AdditionalChargeHead.fromJson(e))
      //       .toList();
      // }
    } catch (e) {
      if (kDebugMode) print('⚠️ fetchChargeHeads error: $e');
    } finally {
      isLoadingChargeHeads = false;
      update();
    }
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────
  void addAdditionalCharge() {
    additionalCharges.add(
      AdditionalCharge(
        localId: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );
    _recalculateCharges();
    update();
  }

  void updateAdditionalCharge(AdditionalCharge updated) {
    final idx =
    additionalCharges.indexWhere((c) => c.localId == updated.localId);
    if (idx != -1) {
      additionalCharges[idx] = updated;
      _recalculateCharges();
      update();
    }
  }

  void removeAdditionalCharge(String localId) {
    additionalCharges.removeWhere((c) => c.localId == localId);
    // Also clear dependencies pointing to the deleted charge.
    for (final c in additionalCharges) {
      if (c.dependsOnLocalId == localId) {
        c.dependsOnLocalId = null;
        c.dependsOnLabel = null;
      }
    }
    _recalculateCharges();
    update();
  }

  // ── Recalculation engine ───────────────────────────────────────────────────
  /// Processes all charges in order, resolving percentage bases, and
  /// populates `calculatedAmount` on each row.
  void _recalculateCharges() {
    // Map localId → resolved amount (for dependency lookup).
    final Map<String, double> resolved = {};
    final baseAmount = subtotal; // item subtotal used as default base

    for (final charge in additionalCharges) {
      double base = baseAmount;

      if (charge.calcType == ChargeCalcType.percentage) {
        if (charge.dependsOnLocalId != null &&
            resolved.containsKey(charge.dependsOnLocalId)) {
          base = resolved[charge.dependsOnLocalId]!.abs();
        } else {
          base = baseAmount;
        }
        charge.calculatedAmount = (charge.value / 100.0) * base;
      } else {
        charge.calculatedAmount = charge.value;
      }

      // Apply sign.
      final signedAmt = charge.nature == ChargeNature.plus
          ? charge.calculatedAmount
          : -charge.calculatedAmount;
      resolved[charge.localId] = signedAmt;
    }

    // Compute aggregate totals.
    additionalChargesGross = additionalCharges
        .where((c) => c.nature == ChargeNature.plus)
        .fold(0.0, (s, c) => s + c.calculatedAmount);

    additionalChargesDeduct = additionalCharges
        .where((c) => c.nature == ChargeNature.less)
        .fold(0.0, (s, c) => s + c.calculatedAmount);

    additionalChargesTotal = additionalChargesGross - additionalChargesDeduct;
  }

  // ── Extended grand total (used in Review screen) ───────────────────────────
  /// grandTotal (items) + net additional charges
  double get grandTotalWithCharges => grandTotal + additionalChargesTotal;

  // ── Serialise for API submit ───────────────────────────────────────────────
  List<Map<String, dynamic>> get additionalChargesPayload =>
      additionalCharges.map((c) => c.toApiJson()).toList();
}