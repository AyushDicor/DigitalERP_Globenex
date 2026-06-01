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
  // Replace MrnGrnFilter with your indent filter class if you have one,
  // or reuse MrnGrnFilter if indent shares the same filter sheet.
  MrnGrnFilter activeFilter = const MrnGrnFilter();
  bool get hasActiveFilter => activeFilter.isActive;

  // ── State ──────────────────────────────────────────────────────────────────
  bool isLoadingList = false;
  List<IndentListItem> indentItems = [];

  List<IndentListItem> get filteredItems {
    List<IndentListItem> items = searchQuery.trim().isEmpty
        ? List.from(indentItems)
        : indentItems.where((i) =>
    i.indentNo.toLowerCase().contains(searchQuery.toLowerCase())   ||
        i.requestBy.toLowerCase().contains(searchQuery.toLowerCase())  ||
        i.siteName.toLowerCase().contains(searchQuery.toLowerCase())   ||
        i.department.toLowerCase().contains(searchQuery.toLowerCase()))
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
  void applyFilter(MrnGrnFilter f) { activeFilter = f; update(); }
  void resetFilter()               { activeFilter = const MrnGrnFilter(); update(); }

  void onSearch(String q) {
    searchQuery = q;
    update();
  }


  // ── Fetch ──────────────────────────────────────────────────────────────────
  bool _isFetching = false;   // ← add this field

  Future<void> fetchIndentList() async {
    if (_isFetching) return;
    _isFetching = true;

    isLoadingList = true;
    indentItems = [];
    searchQuery = '';
    update();

    try {
      // ── TEMPORARY MOCK: remove once API is ready ──────────────────────
      await Future.delayed(const Duration(seconds: 1));
      indentItems = [
        const IndentListItem(
          id:         1,
          indentNo:   'IND-2024-001',
          indentDate: '2024-05-01',
          requestBy:  'GAURAV DWIVEDI',
          siteName:   'Site A',
          department: 'IT',
          jobType:    'Internal',
          priority:   'High',
          status:     'Draft',
          totalItems: 5,
        ),
        const IndentListItem(
          id:         2,
          indentNo:   'IND-2024-002',
          indentDate: '2024-05-10',
          requestBy:  'Neha Gautam',
          siteName:   'Site B',
          department: 'HR',
          jobType:    'External',
          priority:   'Medium',
          status:     'Approved',
          totalItems: 3,
        ),
        const IndentListItem(
          id:         3,
          indentNo:   'IND-2024-003',
          indentDate: '2024-05-15',
          requestBy:  'SHIVANI DWIVEDI',
          siteName:   'Site C',
          department: 'Admin',
          jobType:    'Internal',
          priority:   'Low',
          status:     'Pending',
          totalItems: 8,
        ),
      ];
      // ── END MOCK ──────────────────────────────────────────────────────

      // ── REAL API: uncomment this block when API is ready ──────────────
      // final body = {
      //   'compid':   homeController.currentUserData?.compId   ?? 0,
      //   'branchid': homeController.currentUserData?.branchId ?? 0,
      //   'userid':   homeController.currentUserData?.userid   ?? 0,
      //   'fromdate': fromDateCtrl.text,
      //   'todate':   toDateCtrl.text,
      // };
      // final res = await api.getIndentList(body);
      // if (res.status == 200 || res.success == true) {
      //   indentItems = res.data;
      // } else {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     ShowMessage.showSnackBar('Indent List', res.message ?? 'Failed to load');
      //   });
      // }
      // ─────────────────────────────────────────────────────────────────

    } catch (e) {
      if (kDebugMode) print('IndentList exception: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Error', '$e');
      });
    } finally {
      isLoadingList = false;
      _isFetching = false;
      update();
    }
  }

  // Future<void> fetchIndentList() async {
  //   if (_isFetching) return;  // ← guard against re-entry
  //   _isFetching = true;
  //
  //   isLoadingList = true;
  //   indentItems = [];
  //   searchQuery = '';
  //   update();
  //
  //   try {
  //     final body = {
  //       'compid':   homeController.currentUserData?.compId   ?? 0,
  //       'branchid': homeController.currentUserData?.branchId ?? 0,
  //       'userid':   homeController.currentUserData?.userid   ?? 0,
  //       'fromdate': fromDateCtrl.text,
  //       'todate':   toDateCtrl.text,
  //     };
  //     final res = await api.getIndentList(body);
  //     if (res.status == 200 || res.success == true) {
  //       indentItems = res.data;
  //     } else {
  //       // ← defer snackbar until after the current frame is done
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         ShowMessage.showSnackBar('Indent List', res.message ?? 'Failed to load');
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('IndentList exception: $e');
  //     // ← defer here too
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ShowMessage.showSnackBar('Error', '$e');
  //     });
  //   } finally {
  //     isLoadingList = false;
  //     _isFetching = false;   // ← always release the guard
  //     update();
  //   }
  // }

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
      update();
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
      update();
    }
  }

  // ── Pull-to-refresh ────────────────────────────────────────────────────────
  Future<void> refresh() => fetchIndentList();
}