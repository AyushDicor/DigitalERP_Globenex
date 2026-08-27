// ─────────────────────────────────────────────────────────────────────────────
// employee_card_screen.dart
// The employee ID card generated once the details are saved.
//
// Deliberately small: photo + name + five fields. The on-screen card and the
// PDF are laid out from the same [EmpCardData], so what you see is what prints.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:digitalerp/repo/employee_master_repo.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';

import '../employee_response/employee_read_models.dart';
import '../employee_widgets.dart';

/// Everything the card shows. Built from the form once, so the screen and the
/// PDF can never drift apart.
class EmpCardData {
  final String name;
  final String designation;
  final String department;
  final String vendor;
  final String site;
  final String phone;
  final String employeeId;

  /// Local file — set when the card is built straight after a save, while the
  /// picked photo is still on the device.
  final String photoPath;

  /// Server URL — set when the card is opened from an existing employee's
  /// detail, where the only copy of the photo lives on the ERP.
  final String photoUrl;

  /// From api/employeeidcard. The company name and logo live nowhere else in
  /// the app's session, and qrData is built server-side so the app never has
  /// to invent the QR payload.
  final String companyName;
  final String companyLogoUrl;
  final String qrData;

  const EmpCardData({
    required this.name,
    required this.designation,
    required this.department,
    required this.site,
    required this.phone,
    this.vendor = '',
    this.employeeId = '',
    this.photoPath = '',
    this.photoUrl = '',
    this.companyName = '',
    this.companyLogoUrl = '',
    this.qrData = '',
  });

  /// Built straight from the ERP's own card endpoint — the preferred source,
  /// because it is the only one that knows the company and the QR payload.
  /// api/employeeidcard does not return the vendor or department, so those are
  /// carried over from whatever the caller already knew rather than dropped.
  factory EmpCardData.fromCardInfo(
    EmployeeCardInfo i, {
    String department = '',
    String vendor = '',
  }) =>
      EmpCardData(
        name: i.employeeName,
        designation: i.designation,
        department: department,
        vendor: vendor,
        site: i.siteName,
        phone: i.phone,
        employeeId: i.empId,
        photoUrl: i.photoUrl,
        companyName: i.companyName,
        companyLogoUrl: i.companyLogoUrl,
        qrData: i.qrData,
      );

  File? get photoFile =>
      photoPath.isEmpty || !File(photoPath).existsSync() ? null : File(photoPath);

  bool get hasNetworkPhoto => photoFile == null && photoUrl.startsWith('http');

  /// Label/value rows, skipping anything the form left blank so the card never
  /// shows an empty line.
  List<MapEntry<String, String>> get rows => [
        if (employeeId.trim().isNotEmpty) MapEntry('EMP ID', employeeId),
        if (vendor.trim().isNotEmpty) MapEntry('VENDOR', vendor),
        if (site.trim().isNotEmpty) MapEntry('SITE', site),
        if (department.trim().isNotEmpty) MapEntry('DEPARTMENT', department),
        if (phone.trim().isNotEmpty) MapEntry('PHONE', phone),
      ];
}

class EmployeeCardScreen extends StatefulWidget {
  /// What to draw until (or unless) the card endpoint answers. For a fresh
  /// save this holds the form's own values and the local photo, so the card is
  /// never blank while the network call is in flight.
  final EmpCardData data;

  /// When set, api/employeeidcard is asked for the authoritative version —
  /// company name, logo and the QR payload, none of which the app can derive.
  final String partyId;

  /// True right after a save, where the green tick is the point of the screen.
  /// False when an existing employee's card is opened from their detail.
  final bool justSaved;

  const EmployeeCardScreen({
    super.key,
    required this.data,
    this.partyId = '',
    this.justSaved = true,
  });

  @override
  State<EmployeeCardScreen> createState() => _EmployeeCardScreenState();
}

class _EmployeeCardScreenState extends State<EmployeeCardScreen> {
  bool _busy = false;

  /// Starts as the caller's snapshot, then upgrades in place once the ERP's
  /// card endpoint answers.
  late EmpCardData _card = widget.data;
  bool _loadingCard = false;

  @override
  void initState() {
    super.initState();
    if (widget.partyId.trim().isNotEmpty) _fetchCard();
  }

  Future<void> _fetchCard() async {
    setState(() => _loadingCard = true);
    try {
      final home = Get.find<HomeController>();
      final res = await EmployeeMasterRepo.getEmployeeIdCard({
        'compid': home.currentUserData?.compId ?? 0,
        'branchid': home.currentUserData?.branchId ?? 0,
        'userid': home.currentUserData?.userid ?? 0,
        'partyid': int.tryParse(widget.partyId) ?? widget.partyId,
      });
      final record =
          EmployeeMasterRepo.succeeded(res) ? extractRecord(res.data) : null;
      if (record != null && mounted) {
        final info = EmployeeCardInfo.fromJson(record);
        setState(() {
          _card = EmpCardData.fromCardInfo(
            info,
            // Neither department nor vendor is on the card endpoint; keep
            // whatever the caller already knew rather than dropping the rows.
            department: widget.data.department,
            vendor: widget.data.vendor,
          );
        });
      }
    } catch (e) {
      // The snapshot already on screen stays — a missing QR beats no card.
      log('employee id card fetch failed: $e');
    } finally {
      if (mounted) setState(() => _loadingCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: empSurfaceColor,
      body: SafeArea(
        child: Column(children: [
          _appBar(),
          const Divider(height: 1, color: empBorderColor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
              child: Column(children: [
                if (widget.justSaved) ...[
                  const Icon(Icons.check_circle_rounded,
                      size: 34, color: empGreenColor),
                  const SizedBox(height: 8),
                  const Text('Employee saved',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: empTextPrimary)),
                  const SizedBox(height: 2),
                  const Text('Here is the generated card',
                      style: TextStyle(fontSize: 12, color: empTextSecondary)),
                  const SizedBox(height: 22),
                ],
                EmpIdCard(data: _card),
                if (_loadingCard) ...[
                  const SizedBox(height: 14),
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.6, color: empBlueColor),
                  ),
                ],
              ]),
            ),
          ),
          _actions(),
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
          child: Text('Employee Card',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: empTextPrimary)),
        ),
      ]),
    );
  }

  Widget _actions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: empBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: _secondaryBtn(
              label: 'Share',
              icon: Icons.share_outlined,
              onTap: _busy ? null : () => _export(share: true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: EmpPrimaryBtn(
              label: 'Download PDF',
              icon: Icons.download_rounded,
              isBusy: _busy,
              onTap: _busy ? null : () => _export(share: false),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _secondaryBtn(
      {required String label,
      required IconData icon,
      required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: empSurfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: empBorderColor),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: empTextSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: empTextSecondary)),
        ]),
      ),
    );
  }

  // ── PDF export ─────────────────────────────────────────────────────────────
  Future<void> _export({required bool share}) async {
    setState(() => _busy = true);
    try {
      final file = await EmployeeCardPdf.build(_card);
      if (share) {
        await SharePlus.instance.share(
          ShareParams(
            text: '${_card.name} — Employee Card',
            files: [
              XFile(file.path,
                  name: file.uri.pathSegments.last,
                  mimeType: 'application/pdf')
            ],
          ),
        );
      } else {
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not create the card PDF: $e'),
              backgroundColor: empRedColor),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}


// ═════════════════════════════════════════════════════════════════════════════
// On-screen card
//
// Layout: company band across the top, a narrow left rail holding the photo
// with the QR directly beneath it, the identity block on the right, and a
// footer band captioned EMPLOYEE ID CARD.
// ═════════════════════════════════════════════════════════════════════════════
class EmpIdCard extends StatelessWidget {
  final EmpCardData data;
  const EmpIdCard({super.key, required this.data});

  /// CR80 — the standard ID-card ratio (85.6 x 54 mm), so the on-screen card
  /// and the printed one are the same shape.
  static const double kCardRatio = 85.6 / 54.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kCardRatio,
      child: LayoutBuilder(
        builder: (context, box) {
          // Every size below is a multiple of 1% of the card width, so the
          // design holds together at any screen size instead of only looking
          // right on one phone.
          final u = box.maxWidth / 100;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.2 * u),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.13),
                  blurRadius: 5 * u,
                  offset: Offset(0, 1.6 * u),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              _header(u),
              Expanded(child: _body(u)),
              _footer(u),
            ]),
          );
        },
      ),
    );
  }

  // ── Company band ───────────────────────────────────────────────────────────
  Widget _header(double u) {
    final hasLogo = data.companyLogoUrl.startsWith('http');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4 * u, vertical: 2.2 * u),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [empCardInk, empBlueColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(children: [
        if (hasLogo) ...[
          // White plate behind the logo: company marks are drawn for light
          // backgrounds and disappear straight onto the navy band.
          Container(
            height: 7 * u,
            width: 7 * u,
            padding: EdgeInsets.all(0.6 * u),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1 * u),
            ),
            child: Image.network(
              data.companyLogoUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          SizedBox(width: 2.4 * u),
        ] else ...[
          Container(
            width: 1.1 * u,
            height: 4 * u,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0.6 * u),
            ),
          ),
          SizedBox(width: 2 * u),
        ],
        Expanded(
          child: Text(
            data.companyName.isNotEmpty ? data.companyName : empCardBrand,
            style: TextStyle(
              fontSize: 3.4 * u,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  // ── Photo + QR rail, identity block ────────────────────────────────────────
  Widget _body(double u) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4 * u, 2.8 * u, 4 * u, 2.2 * u),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _rail(u),
        SizedBox(width: 3.6 * u),
        Expanded(child: _identity(u)),
      ]),
    );
  }

  /// Photo on top, QR directly beneath — both the same width so the rail reads
  /// as one column rather than two stacked odds and ends.
  Widget _rail(double u) {
    const railW = 16.5;
    return SizedBox(
      width: railW * u,
      child: Column(children: [
        _photo(u, railW),
        if (data.qrData.trim().isNotEmpty) ...[
          SizedBox(height: 1.4 * u),
          Container(
            padding: EdgeInsets.all(0.5 * u),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1 * u),
              border: Border.all(color: empBorderColor, width: 0.3 * u),
            ),
            child: EmpQrCode(data: data.qrData, size: (railW - 1.6) * u),
          ),
        ],
      ]),
    );
  }

  Widget _photo(double u, double railW) {
    final file = data.photoFile;
    final ImageProvider<Object>? image = file != null
        ? FileImage(file)
        : (data.hasNetworkPhoto
            ? NetworkImage(data.photoUrl) as ImageProvider<Object>
            : null);
    return Container(
      width: railW * u,
      // Passport proportions (3:4) at the smaller rail width.
      height: railW * 4 / 3 * u,
      decoration: BoxDecoration(
        color: empSurfaceColor,
        borderRadius: BorderRadius.circular(1.4 * u),
        border: Border.all(color: empBorderColor, width: 0.3 * u),
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: image == null
          ? Icon(Icons.person_rounded, size: 8 * u, color: empTextHint)
          : null,
    );
  }

  Widget _identity(double u) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.name.isEmpty ? '-' : data.name.toUpperCase(),
          style: TextStyle(
            fontSize: 4.3 * u,
            fontWeight: FontWeight.w900,
            color: empCardInk,
            height: 1.05,
            letterSpacing: 0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (data.designation.trim().isNotEmpty) ...[
          SizedBox(height: 0.6 * u),
          Text(
            data.designation.toUpperCase(),
            style: TextStyle(
              fontSize: 2.4 * u,
              fontWeight: FontWeight.w800,
              color: empBlueColor,
              letterSpacing: 0.7,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: 1.7 * u),
        Container(height: 0.25 * u, color: empBorderColor),
        SizedBox(height: 1.7 * u),
        ...data.rows.map((e) => _row(e, u)),
      ],
    );
  }

  Widget _row(MapEntry<String, String> e, double u) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.05 * u),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 17 * u,
          child: Text(
            e.key,
            style: TextStyle(
              fontSize: 1.95 * u,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: empTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            e.value,
            style: TextStyle(
              fontSize: 2.4 * u,
              fontWeight: FontWeight.w800,
              color: empCardInk,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  // ── Caption band ───────────────────────────────────────────────────────────
  Widget _footer(double u) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.5 * u),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [empBlueColor, empCardInk],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'EMPLOYEE ID CARD',
        style: TextStyle(
          fontSize: 2.3 * u,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.95),
          letterSpacing: 2.2,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PDF card — one page, cut to the real CR80 size
//
// Mirrors [EmpIdCard] proportion for proportion, so the printed card is the
// one you previewed. Sizes are PDF points against an 85.6mm-wide page.
// ═════════════════════════════════════════════════════════════════════════════
class EmployeeCardPdf {
  static const PdfColor _blue = PdfColor.fromInt(0xFF5B6CF6);
  static const PdfColor _ink = PdfColor.fromInt(0xFF1E2235);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _border = PdfColor.fromInt(0xFFE2E6EA);
  static const PdfColor _surface = PdfColor.fromInt(0xFFF8FAFC);

  /// Width of the photo/QR rail in points, and the photo height at 3:4.
  static const double _railW = 40;
  static const double _photoH = _railW * 4 / 3;

  static Future<File> build(EmpCardData data) async {
    final doc = pw.Document();

    // Real card stock size, so it prints and cuts to a wallet card.
    const format = PdfPageFormat(
      85.6 * PdfPageFormat.mm,
      54 * PdfPageFormat.mm,
      marginAll: 0,
    );

    final photo = await _image(data.photoFile, data.photoUrl, 'photo');
    final logo = await _image(null, data.companyLogoUrl, 'logo');

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (_) => pw.Column(children: [
          _pdfHeader(data, logo),
          pw.Expanded(child: _pdfBody(data, photo)),
          _pdfFooter(),
        ]),
      ),
    );

    // Slug the name so two cards never collide and the file is recognisable
    // in the Downloads list.
    final slug = data.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final dir = await getApplicationDocumentsDirectory();
    final out = File(
        '${dir.path}/employee_card_${slug.isEmpty ? 'employee' : slug}.pdf');
    await out.writeAsBytes(await doc.save());
    return out;
  }

  /// Local file first, then the server URL. A failed fetch leaves the slot
  /// empty rather than sinking the whole card.
  static Future<pw.MemoryImage?> _image(
      File? file, String url, String label) async {
    if (file != null) {
      try {
        return pw.MemoryImage(await file.readAsBytes());
      } catch (e) {
        log('card $label read failed: $e');
      }
    }
    if (!url.startsWith('http')) return null;
    try {
      // encodeFull because the ERP serves logos with spaces in the filename.
      final res = await http
          .get(Uri.parse(Uri.encodeFull(url)))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        return pw.MemoryImage(res.bodyBytes);
      }
    } catch (e) {
      log('card $label download failed: $e');
    }
    return null;
  }

  static pw.Widget _pdfHeader(EmpCardData data, pw.MemoryImage? logo) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(colors: [_ink, _blue]),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null) ...[
            pw.Container(
              width: 17,
              height: 17,
              padding: const pw.EdgeInsets.all(1.5),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(2.5),
              ),
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 6),
          ] else ...[
            pw.Container(width: 2.6, height: 10, color: PdfColors.white),
            pw.SizedBox(width: 5),
          ],
          pw.Expanded(
            child: pw.Text(
              data.companyName.isNotEmpty ? data.companyName : empCardBrand,
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfBody(EmpCardData data, pw.MemoryImage? photo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Rail: photo above, QR below.
          pw.SizedBox(
            width: _railW,
            child: pw.Column(children: [
              pw.Container(
                width: _railW,
                height: _photoH,
                decoration: pw.BoxDecoration(
                  color: _surface,
                  border: pw.Border.all(color: _border, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(3.5),
                  image: photo == null
                      ? null
                      : pw.DecorationImage(image: photo, fit: pw.BoxFit.cover),
                ),
              ),
              if (data.qrData.trim().isNotEmpty) ...[
                pw.SizedBox(height: 3.5),
                pw.Container(
                  padding: const pw.EdgeInsets.all(1.2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: _border, width: 0.7),
                    borderRadius: pw.BorderRadius.circular(2.5),
                  ),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: data.qrData,
                    width: _railW - 4,
                    height: _railW - 4,
                    color: _ink,
                    drawText: false,
                  ),
                ),
              ],
            ]),
          ),
          pw.SizedBox(width: 9),
          pw.Expanded(child: _pdfIdentity(data)),
        ],
      ),
    );
  }

  static pw.Widget _pdfIdentity(EmpCardData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          data.name.isEmpty ? '-' : data.name.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
            letterSpacing: 0.2,
          ),
          maxLines: 2,
        ),
        if (data.designation.trim().isNotEmpty) ...[
          pw.SizedBox(height: 1.5),
          pw.Text(
            data.designation.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 6.2,
              fontWeight: pw.FontWeight.bold,
              color: _blue,
              letterSpacing: 0.7,
            ),
            maxLines: 1,
          ),
        ],
        pw.SizedBox(height: 4.5),
        pw.Container(height: 0.6, color: _border),
        pw.SizedBox(height: 4.5),
        ...data.rows.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2.6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 42,
                  child: pw.Text(
                    e.key,
                    style: pw.TextStyle(
                      fontSize: 5,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.5,
                      color: _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    e.value,
                    style: pw.TextStyle(
                      fontSize: 6.2,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _pdfFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(colors: [_blue, _ink]),
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        'EMPLOYEE ID CARD',
        style: pw.TextStyle(
          fontSize: 5.8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          letterSpacing: 2.2,
        ),
      ),
    );
  }
}
