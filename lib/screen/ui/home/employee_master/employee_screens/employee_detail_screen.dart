// ─────────────────────────────────────────────────────────────────────────────
// employee_detail_screen.dart
// Read-only view of one employee (POST api/employeeonboarddetail).
// No editing by design — the list is view-only.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:digitalerp/repo/employee_master_repo.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';

import '../employee_response/employee_read_models.dart';
import '../employee_widgets.dart';
import 'employee_card_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  /// The list row that was tapped — used to paint the header immediately while
  /// the full record loads, so the screen is never blank on open.
  final EmployeeListItem item;

  const EmployeeDetailScreen({super.key, required this.item});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  bool _loading = true;
  bool _endpointMissing = false;
  String _error = '';
  EmployeeDetail? _detail;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _endpointMissing = false;
      _error = '';
    });
    try {
      final home = Get.find<HomeController>();
      final res = await EmployeeMasterRepo.getEmployeeDetail({
        'compid': home.currentUserData?.compId ?? 0,
        'branchid': home.currentUserData?.branchId ?? 0,
        'userid': home.currentUserData?.userid ?? 0,
        // `partyid` is the key this endpoint accepts — `employeeid` returns
        // "Employee detail Not Available".
        'partyid': int.tryParse(widget.item.id) ?? widget.item.id,
      });

      if (!mounted) return;

      // Body-level success, not the HTTP code — this API answers 200 even when
      // it is rejecting the request.
      if (EmployeeMasterRepo.succeeded(res)) {
        final record = extractRecord(res.data);
        setState(() {
          _detail = record == null ? null : EmployeeDetail.fromJson(record);
          if (record == null) _error = 'The detail response was empty';
        });
      } else if (EmployeeMasterRepo.isNotDeployed(res)) {
        setState(() => _endpointMissing = true);
      } else {
        setState(() => _error = res.message?.isNotEmpty == true
            ? res.message!
            : 'Could not load this employee');
      }
    } catch (e) {
      log('employee detail error: $e');
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: empSurfaceColor,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _appBar(),
          const Divider(height: 1, color: empBorderColor),
          Expanded(child: _body()),
        ]),
      ),
    );
  }

  Widget _appBar() {
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
        const Expanded(
          child: Text('Employee Details',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: empTextPrimary)),
        ),
        if (_detail != null)
          GestureDetector(
            onTap: _openCard,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(children: [
                Icon(Icons.badge_outlined, size: 16, color: empBlueColor),
                SizedBox(width: 4),
                Text('Card',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: empBlueColor)),
              ]),
            ),
          ),
        GestureDetector(
          onTap: _loading ? null : _fetch,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.refresh_rounded, size: 20, color: empBlueColor),
          ),
        ),
      ]),
    );
  }

  /// Rebuilds the same ID card shown after a save, from the stored record.
  /// The photo comes as a server URL here rather than a local file.
  void _openCard() {
    final d = _detail!;
    Get.to(() => EmployeeCardScreen(
          partyId: d.id,
          justSaved: false,
          data: EmpCardData(
            name: d.name.isNotEmpty ? d.name : widget.item.name,
            designation: d.designation,
            department: d.department,
            vendor: d.vendor,
            site: d.site,
            phone: d.phone,
            employeeId: d.employeeCode.isNotEmpty ? d.employeeCode : d.id,
            photoUrl: d.photoUrl,
          ),
        ));
  }

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        _header(),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
                child: CircularProgressIndicator(
                    color: empBlueColor, strokeWidth: 2)),
          )
        else if (_endpointMissing)
          _note(Icons.cloud_off_rounded, 'Details not available yet',
              'The detail API is not live yet. This screen will fill in as soon as the backend deploys it.')
        else if (_error.isNotEmpty)
          _note(Icons.error_outline_rounded, 'Could not load details', _error)
        else ...[
          for (final section in _detail?.sections ?? const <EmployeeDetailSection>[])
            _section(section),
          if ((_detail?.attachments ?? const []).isNotEmpty) _documents(),
        ],
      ],
    );
  }

  Widget _header() {
    final photoUrl = _detail?.photoUrl ?? widget.item.photoUrl;
    final hasPhoto = photoUrl.startsWith('http');
    final name = (_detail?.name.isNotEmpty ?? false)
        ? _detail!.name
        : widget.item.name;
    final designation = (_detail?.designation.isNotEmpty ?? false)
        ? _detail!.designation
        : widget.item.designation;
    final code = (_detail?.employeeCode.isNotEmpty ?? false)
        ? _detail!.employeeCode
        : widget.item.employeeCode;

    return EmpCard(
      child: Row(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: empBlueLightColor,
            borderRadius: BorderRadius.circular(12),
            image: hasPhoto
                ? DecorationImage(
                    image: NetworkImage(photoUrl), fit: BoxFit.cover)
                : null,
          ),
          alignment: Alignment.center,
          child: hasPhoto
              ? null
              : Text(widget.item.initials,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: empBlueColor)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.isEmpty ? '—' : name,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: empTextPrimary)),
            if (designation.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(designation,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: empBlueColor)),
            ],
            if (code.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: empBlueLightColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(code,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: empBlueColor)),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _section(EmployeeDetailSection section) {
    return EmpCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        EmpSectionHead(section.title),
        for (int i = 0; i < section.rows.length; i++) ...[
          if (i > 0) const Divider(height: 16, color: empBorderColor),
          _row(section.rows[i].key, section.rows[i].value),
        ],
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 116,
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: empTextSecondary)),
      ),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: empTextPrimary)),
      ),
    ]);
  }

  Widget _documents() {
    return EmpCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const EmpSectionHead('Attachments'),
        for (final a in _detail!.attachments) ...[
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(a.value),
                mode: LaunchMode.externalApplication),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: empSurfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: empBorderColor),
              ),
              child: Row(children: [
                const Icon(Icons.description_outlined,
                    size: 16, color: empBlueColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(a.key,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: empTextPrimary)),
                ),
                const Icon(Icons.open_in_new_rounded,
                    size: 14, color: empTextSecondary),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _note(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(children: [
        Icon(icon, size: 36, color: empTextHint),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: empTextPrimary)),
        const SizedBox(height: 6),
        Text(body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: empTextSecondary)),
      ]),
    );
  }
}
