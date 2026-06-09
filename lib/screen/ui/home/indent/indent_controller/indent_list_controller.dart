// ─────────────────────────────────────────────────────────────────────────────
// indent_list_controller.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:digitalerp/screen/base/base_controller.dart';
import '../../grn/grn_filter/grn_filter_sheet.dart';
import '../../home_controller.dart';
import '../indent_response/indent_model.dart';

class IndentListController extends AppBaseController {
  final HomeController homeController = Get.find<HomeController>();

  // ── Filter ─────────────────────────────────────────────────────────────────
  MrnGrnFilter activeFilter = const MrnGrnFilter();
  bool get hasActiveFilter => activeFilter.isActive;

  // ── State ──────────────────────────────────────────────────────────────────
  bool isLoadingList = false;
  List<IndentListItem> indentItems = [];

  List<IndentListItem> get filteredItems {
    List<IndentListItem> items = searchQuery.trim().isEmpty
        ? List.from(indentItems)
        : indentItems
        .where((i) =>
    i.indentNo.toLowerCase().contains(searchQuery.toLowerCase())   ||
        i.requestBy.toLowerCase().contains(searchQuery.toLowerCase())  ||
        i.siteName.toLowerCase().contains(searchQuery.toLowerCase())   ||
        i.department.toLowerCase().contains(searchQuery.toLowerCase()) ||
        i.jobType.toLowerCase().contains(searchQuery.toLowerCase())    ||
        i.status.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return activeFilter.applyMrn(
      items,
      partyName: (e) => e.requestBy,
      siteName:  (e) => e.siteName,
      jobType:   (e) => e.jobType,
      totalAmt:  (e) => e.totalItems.toDouble(),
    );
  }

  String searchQuery = '';

  // ── Date controllers ───────────────────────────────────────────────────────
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl   = TextEditingController();

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _isFetching = false;  // ← reset on init
    final today = DateTime.now();
    final from  = today.subtract(const Duration(days: 30));
    fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(from);
    toDateCtrl.text   = DateFormat('yyyy-MM-dd').format(today);
    fetchIndentList();
  }

  @override
  void onClose() {
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    super.onClose();
  }

  // ── Filter helpers ─────────────────────────────────────────────────────────
  void applyFilter(MrnGrnFilter f) { activeFilter = f; update(['indentList']);; }
  void resetFilter()               { activeFilter = const MrnGrnFilter(); update(['indentList']);; }
  void onSearch(String q)          { searchQuery = q; update(['indentList']);; }

  // ── Fetch ──────────────────────────────────────────────────────────────────
  bool _isFetching = false;

  Future<void> fetchIndentList() async {
    if (_isFetching) return;
    _isFetching = true;
    isLoadingList = true;
    indentItems = [];
    searchQuery = '';
    // ❌ remove update(['indentList']); here — don't trigger rebuild before await

    try {
      final body = {
        'compid':   homeController.currentUserData?.compId   ?? 0,
        'branchid': homeController.currentUserData?.branchId ?? 0,
        'userid':   homeController.currentUserData?.userid   ?? 0,
        'fromdate': fromDateCtrl.text,
        'todate':   toDateCtrl.text,
        'siteid':   0,
      };

      final res = await api.getIndentList(body);
      if (res.success == true || res.status == 200) {
        indentItems = res.data;
      } else {
        ShowMessage.showSnackBar('Indent List', res.message ?? 'Failed to load');
      }
    } catch (e) {
      if (kDebugMode) print('IndentList exception: $e');
      ShowMessage.showSnackBar('Error', '$e');
    } finally {
      isLoadingList = false;
      _isFetching = false;
      update(['indentList']);; // ✅ only ONE update at the very end
    }
  }

  // ── Date pickers ───────────────────────────────────────────────────────────
  Future<void> pickFromDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.tryParse(fromDateCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      update(['indentList']);;
    }
  }

  Future<void> pickToDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.tryParse(toDateCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      toDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      update(['indentList']);;
    }
  }

  // ── Pull-to-refresh ────────────────────────────────────────────────────────
  Future<void> refresh() => fetchIndentList();
}