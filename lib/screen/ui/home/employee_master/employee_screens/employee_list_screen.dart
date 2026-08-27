// ─────────────────────────────────────────────────────────────────────────────
// employee_list_screen.dart
// Employee Master landing screen: search, list, and an Add button that opens
// the create form. Tapping a row opens the read-only detail screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../employee_controller/employee_list_controller.dart';
import '../employee_response/employee_read_models.dart';
import '../employee_widgets.dart';
import 'employee_detail_screen.dart';
import 'employee_master_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeListController>(
      init: EmployeeListController(),
      builder: (ctrl) => Scaffold(
        backgroundColor: empSurfaceColor,
        floatingActionButton: FloatingActionButton(
          backgroundColor: empBlueColor,
          onPressed: () async {
            // Refresh on return so a newly-added employee shows without the
            // user having to pull down.
            await Get.to(() => const EmployeeMasterScreen());
            ctrl.fetchList();
          },
          shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 2)),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _appBar(ctrl),
            _searchBar(ctrl),
            const Divider(height: 1, color: empBorderColor),
            Expanded(child: _body(ctrl)),
          ]),
        ),
      ),
    );
  }

  Widget _appBar(EmployeeListController ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
      child: Row(children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: empTextPrimary),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Employee Master',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: empTextPrimary)),
            Text(
              ctrl.isLoadingList
                  ? 'Loading…'
                  : '${ctrl.filtered.length} employee${ctrl.filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: empTextSecondary),
            ),
          ]),
        ),
        GestureDetector(
          onTap: ctrl.isLoadingList ? null : ctrl.fetchList,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.refresh_rounded, size: 20, color: empBlueColor),
          ),
        ),
      ]),
    );
  }

  Widget _searchBar(EmployeeListController ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: TextField(
        onChanged: ctrl.onSearchChanged,
        style: const TextStyle(fontSize: 13, color: empTextPrimary),
        decoration: InputDecoration(
          hintText: 'Search name, code, site, designation…',
          hintStyle: const TextStyle(fontSize: 13, color: empTextHint),
          prefixIcon:
              const Icon(Icons.search_rounded, size: 18, color: empTextSecondary),
          filled: true,
          fillColor: empSurfaceColor,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: empBorderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: empBorderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: empBlueColor, width: 1.5)),
        ),
      ),
    );
  }

  Widget _body(EmployeeListController ctrl) {
    if (ctrl.isLoadingList) {
      return const Center(
          child: CircularProgressIndicator(color: empBlueColor, strokeWidth: 2));
    }
    if (ctrl.filtered.isEmpty) return _emptyState(ctrl);

    return RefreshIndicator(
      color: empBlueColor,
      onRefresh: ctrl.fetchList,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
        itemCount: ctrl.filtered.length,
        itemBuilder: (_, i) => _row(ctrl.filtered[i]),
      ),
    );
  }

  Widget _emptyState(EmployeeListController ctrl) {
    final IconData icon;
    final String title;
    final String note;

    if (ctrl.endpointMissing) {
      icon = Icons.cloud_off_rounded;
      title = 'Employee list not available yet';
      note =
          'The list API is not live yet. The screen is ready and will fill in as soon as the backend deploys it.';
    } else if (ctrl.errorMessage.isNotEmpty) {
      icon = Icons.error_outline_rounded;
      title = 'Could not load employees';
      note = ctrl.errorMessage;
    } else if (ctrl.searchQuery.trim().isNotEmpty) {
      icon = Icons.search_off_rounded;
      title = 'No matches';
      note = 'No employee matches “${ctrl.searchQuery.trim()}”.';
    } else {
      icon = Icons.badge_outlined;
      title = 'No employees yet';
      note = 'Tap Add Employee to onboard the first one.';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 70, 30, 30),
      children: [
        Icon(icon, size: 40, color: empTextHint),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: empTextPrimary)),
        const SizedBox(height: 6),
        Text(note,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: empTextSecondary)),
        if (ctrl.errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: ctrl.fetchList,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: empBlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(EmployeeListItem e) {
    return GestureDetector(
      onTap: () => Get.to(() => EmployeeDetailScreen(item: e)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: empBorderColor),
        ),
        child: Row(children: [
          _avatar(e),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name.isEmpty ? '—' : e.name,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: empTextPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (e.designation.isNotEmpty || e.department.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    [e.designation, e.department]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: empBlueColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (e.site.isNotEmpty || e.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    if (e.site.isNotEmpty) ...[
                      const Icon(Icons.place_outlined,
                          size: 11, color: empTextSecondary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(e.site,
                            style: const TextStyle(
                                fontSize: 10.5, color: empTextSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    if (e.site.isNotEmpty && e.phone.isNotEmpty)
                      const SizedBox(width: 10),
                    if (e.phone.isNotEmpty) ...[
                      const Icon(Icons.call_outlined,
                          size: 11, color: empTextSecondary),
                      const SizedBox(width: 3),
                      Text(e.phone,
                          style: const TextStyle(
                              fontSize: 10.5, color: empTextSecondary)),
                    ],
                  ]),
                ],
              ],
            ),
          ),
          if (e.employeeCode.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: empBlueLightColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(e.employeeCode,
                  style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: empBlueColor)),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: empTextHint),
        ]),
      ),
    );
  }

  Widget _avatar(EmployeeListItem e) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: empBlueLightColor,
        borderRadius: BorderRadius.circular(10),
        image: e.hasPhoto
            ? DecorationImage(image: NetworkImage(e.photoUrl), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: e.hasPhoto
          ? null
          : Text(e.initials,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: empBlueColor)),
    );
  }
}
