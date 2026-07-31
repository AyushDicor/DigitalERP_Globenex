import 'dart:developer';
import 'dart:io';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/controller/get_all_quotation_controller.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/create_quote_screen.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class AllQuotationScreen extends StatelessWidget {
  AllQuotationScreen({super.key});

  final GetAllQuotationController controller =
      Get.put(GetAllQuotationController());
  final RxMap<int, bool> isDownloading = <int, bool>{}.obs;

  void _initController() {
    // Receive the lead from arguments
    final lead = Get.arguments as GetleadentryList?;
    controller.lead.value = lead;

    log("Received lead => ${lead?.leadName}");
    if (lead != null) {
      controller.getAllList();
    } else {
      log("No lead data received in AllQuotationScreen");
    }
  }

  Future<void> _downloadAndSharePdf(String url, int quoteId) async {
    isDownloading[quoteId] = true;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/quote_$quoteId.pdf');
        await file.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Here is your quotation PDF');
      } else {
        Get.snackbar("Error", "Failed to download PDF");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isDownloading[quoteId] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: purpleColor,
        elevation: 3,
        shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 2.5)),
        onPressed: () {
          final lead = controller.lead.value;
          if (lead == null) {
            Get.snackbar("Error", "Lead data not found");
            return;
          }
          Get.to(() => CreateQuoteScreen(lead: lead));
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: newTextPrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All Quotations',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: newTextPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final quotations =
                    controller.getAllQuotation.value?.data ?? [];
                if (quotations.isEmpty) {
                  return Center(
                      child: Text("No quotations available",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: newTextSecondary)));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: quotations.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final quote = quotations[index];
                    final downloading = isDownloading[quote.id] ?? false;

                    return GestureDetector(
                      onTap: () {
                        if (quote.url != null && quote.url!.isNotEmpty) {
                          _downloadAndSharePdf(quote.url!, quote.id ?? index);
                        } else {
                          Get.snackbar("Error", "PDF URL not available");
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: newBorderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Quotation No : ${quote.quotationNo ?? '-'}',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: newTextPrimary),
                                    ),
                                  ),
                                  downloading
                                      ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : Image.asset('assets/images/pdf.png',
                                          height: 28),
                                ],
                              ),
                            ),
                            const Divider(
                                height: 1, color: Color(0xFFEFF2F7)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  _infoBlock(
                                      'Company', quote.companyName ?? '-'),
                                  const SizedBox(width: 10),
                                  _infoBlock('Mobile', quote.mobileNo ?? '-'),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 14, right: 14, bottom: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 14, color: newTextSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Date : ${quote.quotationDate != null ? "${quote.quotationDate!.day}-${quote.quotationDate!.month}-${quote.quotationDate!.year}" : '-'}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: newTextSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBlock(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: newBlueLightColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: newBlueColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: newTextSecondary)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: newTextPrimary)),
          ],
        ),
      ),
    );
  }
}
