// ─────────────────────────────────────────────────────────────────────────────
// employee_list_controller.dart
// Backs the Employee Master landing screen (POST api/employeeonboardinglist).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer';

import 'package:get/get.dart';

import 'package:digitalerp/repo/employee_master_repo.dart';
import 'package:digitalerp/screen/base/base_controller.dart';

import '../../home_controller.dart';
import '../employee_response/employee_read_models.dart';

class EmployeeListController extends AppBaseController {
  final HomeController _home = Get.find<HomeController>();

  bool isLoadingList = false;
  List<EmployeeListItem> employees = [];

  String searchQuery = '';

  /// Set when the list endpoint is not deployed yet, so the empty state can say
  /// so instead of implying the company has no employees.
  bool endpointMissing = false;

  /// Set when the call failed for some other reason, so the empty state can
  /// offer a retry rather than a misleading "nothing here".
  String errorMessage = '';

  List<EmployeeListItem> get filtered {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return employees;
    return employees.where((e) => e.searchBlob.contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchList();
  }

  void onSearchChanged(String v) {
    searchQuery = v;
    update();
  }

  Future<void> fetchList() async {
    isLoadingList = true;
    endpointMissing = false;
    errorMessage = '';
    update();
    try {
      final res = await EmployeeMasterRepo.getEmployeeList({
        'compid': _home.currentUserData?.compId ?? 0,
        'branchid': _home.currentUserData?.branchId ?? 0,
        'userid': _home.currentUserData?.userid ?? 0,
      });

      // Body-level success, not the HTTP code — this API answers 200 even when
      // it is rejecting the request.
      if (EmployeeMasterRepo.succeeded(res)) {
        employees =
            extractRows(res.data).map(EmployeeListItem.fromJson).toList();
      } else if (EmployeeMasterRepo.isNotDeployed(res)) {
        employees = [];
        endpointMissing = true;
      } else {
        employees = [];
        errorMessage = res.message?.isNotEmpty == true
            ? res.message!
            : 'Could not load employees';
      }
    } catch (e) {
      log('fetchList error: $e');
      employees = [];
      errorMessage = '$e';
    } finally {
      isLoadingList = false;
      update();
    }
  }
}
