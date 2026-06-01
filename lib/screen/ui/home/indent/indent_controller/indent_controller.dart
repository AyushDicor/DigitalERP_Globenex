// ─────────────────────────────────────────────────────────────────────────────
// indent_controller.dart
// GetX controller for the multi-step Indent entry screen.
// Step 0 → Header   Step 1 → Items   Step 2 → Review & Submit
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/utils/show_message.dart';
import '../../home_controller.dart';
import '../indent_response/indent_model.dart';
import '../indent_screens/indent_list_screen.dart';
import 'indent_list_controller.dart';

class IndentController extends AppBaseController {
  final HomeController _home = Get.find<HomeController>();

  // ── Step tracking ──────────────────────────────────────────────────────────
  int currentStep = 0;
  final PageController pageController = PageController();

  // ── Edit mode ──────────────────────────────────────────────────────────────
  bool isEditMode = false;
  int? editIndentId;

  // ── Step 0: Header ─────────────────────────────────────────────────────────

  // Indent number / date
  String indentNumber = '';
  final TextEditingController indentDateCtrl = TextEditingController();
  final TextEditingController indentDisplayNoCtrl = TextEditingController();

  // Request By
  final TextEditingController requestByCtrl = TextEditingController();

  // Department
  List<IndentDropdownOption> departmentList = [];
  IndentDropdownOption? selectedDepartment;
  bool isLoadingDepartment = false;

  // Job Type
  List<IndentDropdownOption> jobTypeList = [];
  IndentDropdownOption? selectedJobType;
  bool isLoadingJobType = false;

  // Site
  List<IndentDropdownOption> siteList = [];
  IndentDropdownOption? selectedSite;
  bool isLoadingSite = false;

  // Godown
  List<IndentDropdownOption> godownList = [];
  IndentDropdownOption? selectedGodown;
  bool isLoadingGodown = false;

  // Priority
  final List<String> priorityOptions = ['Low', 'Medium', 'High', 'Urgent'];
  String selectedPriority = 'Medium';

  // Work Order
  List<IndentDropdownOption> workOrderList = [];
  IndentDropdownOption? selectedWorkOrder;
  bool isLoadingWorkOrder = false;

  // Site Incharge
  final TextEditingController siteInchargeCtrl = TextEditingController();

  // Remarks
  final TextEditingController remarksCtrl = TextEditingController();

  // ── Step 1: Items ──────────────────────────────────────────────────────────
  List<IndentItemLine> itemLines = [];

  // Direct item add dropdowns
  List<IndentDropdownOption> itemList = [];
  bool isLoadingItems = false;

  List<IndentDropdownOption> unitList = [];
  bool isLoadingUnits = false;

  // ── Step 2: Review ─────────────────────────────────────────────────────────
  final TextEditingController reviewRemarksCtrl = TextEditingController();

  // ── Financials ─────────────────────────────────────────────────────────────
  double get totalQty => itemLines.fold(0, (s, i) => s + i.indentQty);
  double get totalAmount => itemLines.fold(0, (s, i) => s + i.amount);

  // ── Init / Dispose ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    indentDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    indentNumber = _generateIndentNumber();
    indentDisplayNoCtrl.text = indentNumber;
    _setLoggedInUser();
    _fetchAllDropdowns();

    final args = Get.arguments;
    if (args is IndentListItem) {
      isEditMode = true;
      editIndentId = args.id;
      _prefillFromListItem(args);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    indentDateCtrl.dispose();
    indentDisplayNoCtrl.dispose();
    requestByCtrl.dispose();
    siteInchargeCtrl.dispose();
    remarksCtrl.dispose();
    reviewRemarksCtrl.dispose();
    super.onClose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void goToStep(int step) {
    if (step < 0 || step > 2) return;
    currentStep = step;
    pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    update();
  }

  void nextStep() => goToStep(currentStep + 1);
  void prevStep() => goToStep(currentStep - 1);

  // ── Header setters ─────────────────────────────────────────────────────────
  void setDepartment(IndentDropdownOption? v) {
    selectedDepartment = v;
    update();
  }

  void setJobType(IndentDropdownOption? v) {
    selectedJobType = v;
    update();
  }

  void setSite(IndentDropdownOption? v) {
    selectedSite = v;
    selectedGodown = null;
    godownList.clear();
    if (v != null) {
      fetchGodowns(siteId: int.tryParse(v.id) ?? 0);
      fetchWorkOrders(siteId: int.tryParse(v.id) ?? 0);
    }
    update();
  }

  void setGodown(IndentDropdownOption? v) {
    selectedGodown = v;
    update();
  }

  void setPriority(String v) {
    selectedPriority = v;
    update();
  }

  void setWorkOrder(IndentDropdownOption? v) {
    selectedWorkOrder = v;
    update();
  }

  // ── Item interactions ──────────────────────────────────────────────────────
  void setIndentQty(IndentItemLine item, double qty) {
    item.indentQty = qty < 0 ? 0 : qty;
    update();
  }

  void increaseQty(IndentItemLine item) {
    item.indentQty++;
    update();
  }

  void decreaseQty(IndentItemLine item) {
    if (item.indentQty > 1) {
      item.indentQty--;
      update();
    }
  }

  void setItemDescription(IndentItemLine item, String val) {
    item.itemDescription = val;
    update();
  }

  void removeItem(IndentItemLine item) {
    itemLines.remove(item);
    update();
  }

  void addItem({
    required String itemId,
    required String itemName,
    required String itemCode,
    required String unit,
    required String unitId,
    required double indentQty,
    required double rate,
    required double stockAtSite,
    required String itemDescription,
  }) {
    // Prevent duplicate
    if (itemLines.any((i) => i.itemId == itemId)) {
      ShowMessage.showSnackBar('Duplicate', 'Item "$itemName" already added');
      return;
    }
    itemLines.add(IndentItemLine(
      itemId: itemId,
      itemName: itemName,
      itemCode: itemCode,
      unit: unit,
      unitId: unitId,
      indentQty: indentQty,
      rate: rate,
      stockAtSite: stockAtSite,
      itemDescription: itemDescription,
    ));
    update();
  }

  void updateItemRate(IndentItemLine item, double rate) {
    item.rate = rate;
    update();
  }

  // ── Date pickers ───────────────────────────────────────────────────────────
  Future<void> pickIndentDate(BuildContext ctx) =>
      _pickDate(ctx, indentDateCtrl);

  Future<void> _pickDate(
      BuildContext ctx, TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (c, child) => Theme(
        data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1976D2))),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
      update();
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> submitIndent() async {
    // Validation
    if (selectedSite == null) {
      ShowMessage.showSnackBar('Validation', 'Please select a site');
      return;
    }
    if (itemLines.isEmpty) {
      ShowMessage.showSnackBar('Validation', 'Please add at least one item');
      return;
    }
    if (itemLines.any((i) => i.indentQty <= 0)) {
      ShowMessage.showSnackBar(
          'Validation', 'All items must have indent qty > 0');
      return;
    }

    setBusy(true);
    try {
      DateTime parseDate(String d) {
        try {
          return DateFormat('dd/MM/yyyy').parse(d);
        } catch (_) {
          return DateTime.now();
        }
      }

      final items = itemLines
          .map((i) => {
        'itemid': int.tryParse(i.itemId) ?? 0,
        'itemname': i.itemName,
        'unitid': int.tryParse(i.unitId) ?? 0,
        'unitname': i.unit,
        'indentqty': i.indentQty,
        'prqty': i.prQty,
        'delqty': i.delQty,
        'rate': i.rate,
        'amount': i.amount,
        'stockatsite': i.stockAtSite,
        'itemdescription': i.itemDescription,
        'transid': i.transId,
      })
          .toList();

      final body = {
        'indentid': isEditMode ? (editIndentId ?? 0) : 0,
        'indentno': indentNumber,
        'indentdate': parseDate(indentDateCtrl.text).toIso8601String(),
        'requestby': requestByCtrl.text.trim(),
        'siteid': int.tryParse(selectedSite?.id ?? '0') ?? 0,
        'sitename': selectedSite?.label ?? '',
        'departmentid':
        int.tryParse(selectedDepartment?.id ?? '0') ?? 0,
        'department': selectedDepartment?.label ?? '',
        'jobtypeid': int.tryParse(selectedJobType?.id ?? '0') ?? 0,
        'jobtype': selectedJobType?.label ?? '',
        'priority': selectedPriority,
        'godownid': int.tryParse(selectedGodown?.id ?? '0') ?? 0,
        'workorderid':
        int.tryParse(selectedWorkOrder?.id ?? '0') ?? 0,
        'siteincharge': siteInchargeCtrl.text.trim(),
        'remarks': remarksCtrl.text.trim(),
        'description': reviewRemarksCtrl.text.trim(),
        'compid': _home.currentUserData?.compId ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
        'userid': _home.currentUserData?.userid ?? 0,
        'indentitems': items,
      };

      if (kDebugMode) {
        const encoder = JsonEncoder.withIndent('  ');
        print('📦 INDENT SUBMIT PAYLOAD');
        print(encoder.convert(body));
      }

      final res = await api.saveIndent(body);
      if (res.status == 200 || res.success == true) {
        ShowMessage.showSnackBar(
            'Success', res.message ?? 'Indent saved successfully');
        if (Get.isRegistered<IndentListController>()) {
          Get.find<IndentListController>().fetchIndentList();
        }
        Get.off(() => const IndentListScreen());
      } else {
        ShowMessage.showSnackBar(
            'Error', res.message ?? 'Failed to save indent');
      }
    } catch (e) {
      ShowMessage.showSnackBar('Error', '$e');
    } finally {
      setBusy(false);
    }
  }

  // ── Pre-fill from list item (opens detail API) ─────────────────────────────
  void _prefillFromListItem(IndentListItem item) {
    indentNumber = item.indentNo;
    indentDisplayNoCtrl.text = item.indentNo;
    requestByCtrl.text = item.requestBy;
    try {
      final date = DateFormat('dd-MM-yyyy').parse(item.indentDate);
      indentDateCtrl.text = DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {}
    update();
    _fetchIndentDetail(item.id);
  }

  Future<void> _fetchIndentDetail(int indentId) async {
    setBusy(true);
    try {
      final body = {
        'indentid': indentId,
        'compid': _home.currentUserData?.compId ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
      };
      final res = await api.getIndentDetail(body);
      if ((res.status == 200 || res.success == true) && res.data != null) {
        _applyDetail(res.data!);
      } else {
        ShowMessage.showSnackBar(
            'Detail', res.message ?? 'Could not load indent details');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Indent detail error: $e');
    } finally {
      setBusy(false);
    }
  }

  void _applyDetail(IndentDetailData d) {
    requestByCtrl.text = d.requestby;
    siteInchargeCtrl.text = d.siteIncharge;
    remarksCtrl.text = d.remarks;
    if (d.priority.isNotEmpty) selectedPriority = d.priority;

    _setDateCtrl(indentDateCtrl, d.indentdate);

    if (d.siteid > 0) {
      selectedSite =
          siteList.firstWhereOrNull((s) => s.id == d.siteid.toString()) ??
              IndentDropdownOption(id: d.siteid.toString(), label: d.sitename);
      fetchGodowns(siteId: d.siteid);
      fetchWorkOrders(siteId: d.siteid);
    }
    if (d.godownid > 0) {
      selectedGodown =
          godownList.firstWhereOrNull((g) => g.id == d.godownid.toString()) ??
              IndentDropdownOption(
                  id: d.godownid.toString(), label: d.godownname);
    }
    if (d.departmentid > 0) {
      selectedDepartment = departmentList
          .firstWhereOrNull((dep) => dep.id == d.departmentid.toString()) ??
          IndentDropdownOption(
              id: d.departmentid.toString(), label: d.department);
    }
    if (d.jobtypeid > 0) {
      selectedJobType =
          jobTypeList.firstWhereOrNull((j) => j.id == d.jobtypeid.toString()) ??
              IndentDropdownOption(
                  id: d.jobtypeid.toString(), label: d.jobtype);
    }
    if (d.workorderid > 0) {
      selectedWorkOrder = workOrderList
          .firstWhereOrNull((w) => w.id == d.workorderid.toString()) ??
          IndentDropdownOption(
              id: d.workorderid.toString(), label: d.workorderno);
    }

    itemLines = d.items
        .map((i) => IndentItemLine(
      itemId: i.itemid.toString(),
      itemName: i.itemname,
      itemCode: i.itemid.toString(),
      unit: i.unitname,
      unitId: i.unitid.toString(),
      prQty: i.prqty,
      indentQty: i.indentqty,
      delQty: i.delqty,
      rate: i.rate,
      stockAtSite: i.stockatsite,
      itemDescription: i.itemdescription,
      transId: i.transid,
    ))
        .toList();

    if (kDebugMode) print('📦 Indent items populated: ${itemLines.length}');
    update();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoggedInUser() {
    requestByCtrl.text = _home.currentUserData?.name ?? '';
  }

  String _generateIndentNumber() {
    final year = DateTime.now().year;
    final seq =
    (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
    return 'IND-$year-$seq';
  }

  void _setDateCtrl(TextEditingController ctrl, String raw) {
    if (raw.isEmpty) return;
    try {
      DateTime? dt = DateTime.tryParse(raw);
      dt ??= DateFormat('dd-MM-yyyy').tryParseStrict(raw);
      dt ??= DateFormat('dd/MM/yyyy').tryParseStrict(raw);
      if (dt != null) ctrl.text = DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {}
  }

  // ── Fetch all dropdowns on init ────────────────────────────────────────────
  // ── Fetch all dropdowns on init ────────────────────────────────────────────
  Future<void> _fetchAllDropdowns() async {
    await Future.wait([
      fetchSites(),
      fetchDepartments(),
      fetchJobTypes(),
      fetchWorkOrders(),
      fetchItems(),
      fetchUnits(),
    ]);
  }

  Map<String, dynamic> _dropdownBody(
      String type, {
        int siteId = 0,
        int partyId = 0,
      }) =>
      {
        'type':     type,
        'compid':   _home.currentUserData?.compId   ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
        'userid':   _home.currentUserData?.userid   ?? 0,
        'siteid':   siteId,
        'partyid':  partyId,
      };

  // Future<void> fetchSites() async {
  //   isLoadingSite = true;
  //   update();
  //   try {
  //     final res = await api.getIndentDropdownList(_dropdownBody('Site'));
  //     if (res.status == 200 || res.success == true) {
  //       siteList = res.data;
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Site', '$e');
  //   } finally {
  //     isLoadingSite = false;
  //     update();
  //   }
  // }
  //
  // Future<void> fetchGodowns({int siteId = 0}) async {
  //   isLoadingGodown = true;
  //   selectedGodown = null;
  //   update();
  //   try {
  //     final res = await api.getIndentDropdownList(
  //         _dropdownBody('Godown', siteId: siteId));
  //     if (res.status == 200 || res.success == true) {
  //       godownList = res.data;
  //       if (godownList.isNotEmpty) selectedGodown = godownList.first;
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Godown', '$e');
  //   } finally {
  //     isLoadingGodown = false;
  //     update();
  //   }
  // }
  //
  // Future<void> fetchDepartments() async {
  //   isLoadingDepartment = true;
  //   update();
  //   try {
  //     final res = await api.getIndentDropdownList(
  //         _dropdownBody('department'));
  //     if (res.status == 200 || res.success == true) {
  //       departmentList = res.data;
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Department', '$e');
  //   } finally {
  //     isLoadingDepartment = false;
  //     update();
  //   }
  // }
  //
  // Future<void> fetchJobTypes() async {
  //   isLoadingJobType = true;
  //   update();
  //   try {
  //     final res = await api.getIndentDropdownList(
  //         _dropdownBody('Jobtype'));
  //     if (res.status == 200 || res.success == true) {
  //       jobTypeList = res.data;
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Job Type', '$e');
  //   } finally {
  //     isLoadingJobType = false;
  //     update();
  //   }
  // }
  //
  // Future<void> fetchWorkOrders({int siteId = 0}) async {
  //   isLoadingWorkOrder = true;
  //   update();
  //   try {
  //     final res = await api.getIndentDropdownList(
  //         _dropdownBody('workorder', siteId: siteId));
  //     if (res.status == 200 || res.success == true) {
  //       workOrderList = res.data;
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Work Order', '$e');
  //   } finally {
  //     isLoadingWorkOrder = false;
  //     update();
  //   }
  // }
  //
  // Future<void> fetchItems() async {
  //   isLoadingItems = true;
  //   update();
  //   try {
  //     final res = await api.getIndentDropdownList(_dropdownBody('Item'));
  //     if (res.status == 200 || res.success == true) {
  //       itemList = res.data;
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Items', '$e');
  //   } finally {
  //     isLoadingItems = false;
  //     update();
  //   }
  // }
  //
  // Future<void> fetchUnits() async {
  //   isLoadingUnits = true;
  //   update();
  //   try {
  //     final res = await api.getIndentDropdownList(_dropdownBody('Unit'));
  //     if (res.status == 200 || res.success == true) {
  //       unitList = res.data;
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Units', '$e');
  //   } finally {
  //     isLoadingUnits = false;
  //     update();
  //   }
  // }
  //
  Future<double?> fetchStockAtSite(int itemId) async {
    final siteId = int.tryParse(selectedSite?.id ?? '0') ?? 0;
    try {
      final res = await api.getIndentItemStock(
        itemId:   itemId,
        siteId:   siteId,
        compId:   _home.currentUserData?.compId   ?? 0,
        branchId: _home.currentUserData?.branchId ?? 0,
      );
      if (res.status == 200 || res.success == true) return res.stock;
      return null;
    } catch (e) {
      if (kDebugMode) print('fetchStockAtSite error: $e');
      return null;
    }
  }
///mock data  (delete it and uncomment the real api above)
  Future<void> fetchSites() async {
    isLoadingSite = true;
    update();
    try {
      // ── MOCK ──
      await Future.delayed(const Duration(milliseconds: 500));
      siteList = [
        const IndentDropdownOption(id: '1', label: 'Site A'),
        const IndentDropdownOption(id: '2', label: 'Site B'),
        const IndentDropdownOption(id: '3', label: 'Site C'),
      ];
      // ── REAL API ──
      // final res = await api.getIndentDropdownList(_dropdownBody('Site'));
      // if (res.status == 200 || res.success == true) siteList = res.data;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Site', '$e');
      });
    } finally {
      isLoadingSite = false;
      update();
    }
  }

  Future<void> fetchDepartments() async {
    isLoadingDepartment = true;
    update();
    try {
      // ── MOCK ──
      await Future.delayed(const Duration(milliseconds: 500));
      departmentList = [
        const IndentDropdownOption(id: '1', label: 'IT'),
        const IndentDropdownOption(id: '2', label: 'HR'),
        const IndentDropdownOption(id: '3', label: 'Admin'),
      ];
      // ── REAL API ──
      // final res = await api.getIndentDropdownList(_dropdownBody('department'));
      // if (res.status == 200 || res.success == true) departmentList = res.data;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Department', '$e');
      });
    } finally {
      isLoadingDepartment = false;
      update();
    }
  }

  Future<void> fetchJobTypes() async {
    isLoadingJobType = true;
    update();
    try {
      // ── MOCK ──
      await Future.delayed(const Duration(milliseconds: 500));
      jobTypeList = [
        const IndentDropdownOption(id: '1', label: 'Internal'),
        const IndentDropdownOption(id: '2', label: 'External'),
      ];
      // ── REAL API ──
      // final res = await api.getIndentDropdownList(_dropdownBody('Jobtype'));
      // if (res.status == 200 || res.success == true) jobTypeList = res.data;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Job Type', '$e');
      });
    } finally {
      isLoadingJobType = false;
      update();
    }
  }

  Future<void> fetchWorkOrders({int siteId = 0}) async {
    isLoadingWorkOrder = true;
    update();
    try {
      // ── MOCK ──
      await Future.delayed(const Duration(milliseconds: 500));
      workOrderList = [
        const IndentDropdownOption(id: '1', label: 'WO-2024-001'),
        const IndentDropdownOption(id: '2', label: 'WO-2024-002'),
      ];
      // ── REAL API ──
      // final res = await api.getIndentDropdownList(_dropdownBody('workorder', siteId: siteId));
      // if (res.status == 200 || res.success == true) workOrderList = res.data;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Work Order', '$e');
      });
    } finally {
      isLoadingWorkOrder = false;
      update();
    }
  }

  Future<void> fetchItems() async {
    isLoadingItems = true;
    update();
    try {
      // ── MOCK ──
      await Future.delayed(const Duration(milliseconds: 500));
      itemList = [
        const IndentDropdownOption(id: '101', label: 'Cement Bag'),
        const IndentDropdownOption(id: '102', label: 'Steel Rod'),
        const IndentDropdownOption(id: '103', label: 'Paint Tin'),
      ];
      // ── REAL API ──
      // final res = await api.getIndentDropdownList(_dropdownBody('Item'));
      // if (res.status == 200 || res.success == true) itemList = res.data;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Items', '$e');
      });
    } finally {
      isLoadingItems = false;
      update();
    }
  }

  Future<void> fetchUnits() async {
    isLoadingUnits = true;
    update();
    try {
      // ── MOCK ──
      await Future.delayed(const Duration(milliseconds: 500));
      unitList = [
        const IndentDropdownOption(id: '1', label: 'Nos'),
        const IndentDropdownOption(id: '2', label: 'Kg'),
        const IndentDropdownOption(id: '3', label: 'Ltr'),
      ];
      // ── REAL API ──
      // final res = await api.getIndentDropdownList(_dropdownBody('Unit'));
      // if (res.status == 200 || res.success == true) unitList = res.data;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Units', '$e');
      });
    } finally {
      isLoadingUnits = false;
      update();
    }
  }
  Future<void> fetchGodowns({int siteId = 0}) async {
    isLoadingGodown = true;
    selectedGodown = null;
    update();
    try {
      // ── MOCK ──
      await Future.delayed(const Duration(milliseconds: 500));
      godownList = [
        const IndentDropdownOption(id: '1', label: 'Main Godown'),
        const IndentDropdownOption(id: '2', label: 'Store 2'),
        const IndentDropdownOption(id: '3', label: 'Warehouse A'),
      ];
      if (godownList.isNotEmpty) selectedGodown = godownList.first;
      // ── REAL API ──
      // final res = await api.getIndentDropdownList(_dropdownBody('Godown', siteId: siteId));
      // if (res.status == 200 || res.success == true) {
      //   godownList = res.data;
      //   if (godownList.isNotEmpty) selectedGodown = godownList.first;
      // }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowMessage.showSnackBar('Godown', '$e');
      });
    } finally {
      isLoadingGodown = false;
      update();
    }
  }

}