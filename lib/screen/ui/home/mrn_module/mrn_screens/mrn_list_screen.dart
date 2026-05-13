import 'package:digitalerp/screen/ui/home/mrn_module/mrn_entry_view.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../mrn_controller/mrn_list_controller.dart';
import '../mrn_response/mrn_models.dart';

class MrnListScreen extends StatefulWidget {
  const MrnListScreen({super.key});

  @override
  State<MrnListScreen> createState() => _MrnListScreenState();
}

class _MrnListScreenState extends State<MrnListScreen> {
  late MrnListController ctrl;
  @override
  void initState() {
    super.initState();
    // ✅ Delete any stale instance, then create fresh
    Get.delete<MrnListController>(force: true);
    ctrl = Get.put(MrnListController());
  }

  @override
  void dispose() {
    Get.delete<MrnListController>(force: true);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MrnListController>(
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: newSurfaceColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: const Text('MRN List',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: newTextPrimary)),
            iconTheme: const IconThemeData(color: newTextPrimary),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: newBorderColor),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Get.to(() => const MrnEntryView());
              ctrl.fetchMrnList();                  // ✅ refresh on return
            },
            backgroundColor: newBlueColor,
            shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2)),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
          body: Column(children: [
            _filterBar(context, ctrl),
            Expanded(
              child: ctrl.isLoadingList
                  ? _shimmer()
                  : ctrl.htmlData.isEmpty
                  ? _emptyState()
                  : _MrnWebView(htmlContent: ctrl.htmlData),
            ),
          ]),
        );
      },
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return GetBuilder<MrnListController>(
  //     builder: (ctrl) {
  //       return Scaffold(
  //         backgroundColor: newSurfaceColor,
  //         appBar: AppBar(
  //           backgroundColor: Colors.white,
  //           elevation: 0,
  //           title: const Text('MRN List',
  //               style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w800,
  //                   color: newTextPrimary)),
  //           iconTheme: const IconThemeData(color: newTextPrimary),
  //           bottom: PreferredSize(
  //             preferredSize: const Size.fromHeight(1),
  //             child: Container(height: 1, color: newBorderColor),
  //           ),
  //         ),
  //         floatingActionButton: FloatingActionButton.extended(
  //           onPressed: () async {
  //             await Get.to(() => const MrnEntryView());
  //             Get.find<MrnListController>().fetchMrnList(); // ✅ refresh on return
  //           },
  //           backgroundColor: newBlueColor,
  //           icon: const Icon(Icons.add_rounded, color: Colors.white),
  //           label: const Text('New MRN',
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.w700,
  //                   fontSize: 13)),
  //         ),
  //         body: Column(children: [
  //           _filterBar(context, ctrl),
  //           Expanded(
  //             child: ctrl.isLoadingList
  //                 ? _shimmer()
  //                 : ctrl.htmlData.isEmpty
  //                 ? _emptyState()
  //                 : _MrnWebView(htmlContent: ctrl.htmlData),
  //           ),
  //           // Expanded(
  //           //   child: ctrl.isLoadingList
  //           //       ? _shimmer()
  //           //       : ctrl.mrnItems.isEmpty
  //           //       ? _emptyState()
  //           //       : RefreshIndicator(
  //           //     color: newBlueColor,
  //           //     onRefresh: ctrl.fetchMrnList,
  //           //     child: ListView.separated(
  //           //       physics: const AlwaysScrollableScrollPhysics(),
  //           //       padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
  //           //       itemCount: ctrl.mrnItems.length,
  //           //       separatorBuilder: (_, __) =>
  //           //       const SizedBox(height: 10),
  //           //       itemBuilder: (_, i) =>
  //           //           _MrnCard(item: ctrl.mrnItems[i]),
  //           //     ),
  //           //   ),
  //           // ),
  //         ]),
  //       );
  //     },
  //   );
  // }

  Widget _filterBar(BuildContext context, MrnListController ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(children: [
        Expanded(child: _dateField(
          label: 'From',
          controller: ctrl.fromDateCtrl,
          onTap: () => ctrl.pickFromDate(context),
        )),
        const SizedBox(width: 10),
        Expanded(child: _dateField(
          label: 'To',
          controller: ctrl.toDateCtrl,
          onTap: () => ctrl.pickToDate(context),
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: ctrl.fetchMrnList,
          child: Container(
            height: 44, width: 44,
            decoration: BoxDecoration(
                color: newBlueColor,
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: ctrl.isLoadingList
                ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.search_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: newSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: newBorderColor),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              size: 14, color: newTextSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 9,
                          color: newTextSecondary,
                          fontWeight: FontWeight.w600)),
                  Text(controller.text,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: newTextPrimary)),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 56, color: newBorderColor),
      const SizedBox(height: 12),
      const Text('No MRN records found',
          style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: newTextSecondary)),
      const SizedBox(height: 4),
      const Text('Try adjusting the date range',
          style: TextStyle(fontSize: 12, color: newTextSecondary)),
    ]),
  );

  Widget _shimmer() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
    itemCount: 5,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (_, __) => Container(
      height: 120,
      decoration: BoxDecoration(
          color: newBorderColor,
          borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _MrnWebView extends StatefulWidget {
  final String htmlContent;
  const _MrnWebView({required this.htmlContent});

  @override
  State<_MrnWebView> createState() => _MrnWebViewState();
}

class _MrnWebViewState extends State<_MrnWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_wrapHtml(widget.htmlContent));
  }

  String _wrapHtml(String body) => '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  body { font-family: sans-serif; font-size: 13px; margin: 0; padding: 12px; }
  table { width: 100%; border-collapse: collapse; }
  th { background: #EEF4FF; color: #2563EB; font-size: 11px;
       padding: 8px 6px; text-align: left; border-bottom: 2px solid #BFDBFE; }
  td { padding: 8px 6px; border-bottom: 1px solid #F1F5F9;
       color: #1E293B; font-size: 12px; }
  tr:nth-child(even) { background: #F8FAFC; }
</style>
</head>
<body>$body</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

// ── MRN Card ───────────────────────────────────────────────────────────────────
class _MrnCard extends StatelessWidget {
  final MrnListItem item;
  const _MrnCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Get.to(
              () => const MrnEntryView(),
          arguments: item,   // ✅ pass the MrnListItem as argument
        ),
        child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: newBorderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Blue header ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
              color: newBlueLightColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13))),
          child: Row(children: [
            const Icon(Icons.receipt_long_rounded, size: 15, color: newBlueColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item.mrnNo,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: newBlueColor,
                      letterSpacing: .2)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: newBlueColor.withValues(alpha: 0.3))),
              child: Text(item.mrnDate,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: newBlueColor)),
            ),
          ]),
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Party
            Text(item.partyName,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: newTextPrimary)),
            const SizedBox(height: 8),

            // Site + Job Type
            Row(children: [
              _pill(Icons.location_on_outlined, item.siteName,
                  newSurfaceColor, newTextSecondary),
              const SizedBox(width: 6),
              if (item.jobType.isNotEmpty)
                _pill(Icons.work_outline_rounded, item.jobType,
                    newOrangeLightColor, newOrangeColor),
            ]),
            const SizedBox(height: 10),

            // Bottom row
            Row(children: [
              if (item.billNo.isNotEmpty) ...[
                const Icon(Icons.receipt_outlined,
                    size: 12, color: newTextSecondary),
                const SizedBox(width: 4),
                Text('Bill: ${item.billNo}',
                    style: const TextStyle(
                        fontSize: 11, color: newTextSecondary)),
                const SizedBox(width: 12),
              ],
              const Icon(Icons.inventory_2_outlined,
                  size: 12, color: newTextSecondary),
              const SizedBox(width: 4),
              Text('${item.totalQty.toInt()} items',
                  style: const TextStyle(
                      fontSize: 11, color: newTextSecondary)),
              const Spacer(),
              Text('₹${_inr(item.totalAmt)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: newTextPrimary)),
            ]),
          ]),
        ),
      ]),
        ),
    );
  }

  Widget _pill(IconData icon, String label, Color bg, Color fg) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
        ]),
      );

  static String _inr(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)} L';
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0];
    if (whole.length <= 3) return '$whole.${parts[1]}';
    final last3 = whole.substring(whole.length - 3);
    final rest = whole.substring(0, whole.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '$buf,$last3.${parts[1]}';
  }
}