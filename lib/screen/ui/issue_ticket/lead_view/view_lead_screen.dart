import 'package:digitalerp/utils/lead_app_bar.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:digitalerp/app_routes/app_routes.dart';
import 'package:digitalerp/model/get_lead_detail_from_id_response_model.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/all_quotation_screen.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/call_logs_screen.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/controller/get_all_quotation_controller.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/create_quote_screen.dart';
import 'package:digitalerp/screen/ui/issue_ticket/lead_view/notes_screen.dart';
// Unlike Balaji's, this app's app_constant.dart ALSO declares the new* colour
// tokens, so importing both files unprefixed makes every one of them ambiguous.
// The app_constant_new values are the ones this screen was written against.
import 'package:digitalerp/utils/app_constant.dart'
    hide
        newTextPrimary,
        newTextSecondary,
        newBlueColor,
        newBlueLightColor,
        newBorderColor,
        newSurfaceColor,
        newGreenColor,
        newGreenLightColor;
import 'package:digitalerp/utils/app_constant_new.dart'
    show
        newTextPrimary,
        newTextSecondary,
        newBlueColor,
        newBlueLightColor,
        newBorderColor,
        newSurfaceColor,
        newGreenColor,
        newGreenLightColor;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller/lead_management_controller.dart';
import 'follow_up_screen.dart';
import 'lead_managment_screen.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  LeadViewController controller = Get.put(LeadViewController());
  GetAllQuotationController getAllQuotationController = Get.put(GetAllQuotationController());
  List<LeadModel> leads = [];
  int? selectedIndex;

  @override
  void initState() {
    controller.getLeadEntryApiMethod();

    super.initState();
    loadLeads();
  }

  Future<void> loadLeads() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString("leads");
    if (data != null) {
      List decoded = jsonDecode(data);
      setState(() {
        leads = decoded.map((e) => LeadModel.fromJson(e)).toList();
        for (var lead in leads) {
          log('Lead: ${lead.toJson()}');
        }
      });
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  int calculateAgeing(String? leadDateStr) {
    if (leadDateStr == null || leadDateStr.isEmpty) return 0;
    try {
      final date = DateTime.parse(leadDateStr);
      return DateTime.now().difference(date).inDays;
    } catch (_) {
      return 0;
    }
  }

  void _openLeadActions(GetleadentryList lead, int index, String? id) async {
    setState(() {
      selectedIndex = index;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _actionButton(
                    Image.asset("assets/images/viewDetailIcon.png", width: 30, height: 30),
                    "View Details",
                    () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LeadDetailsScreen(onUpdate: loadLeads, id: id),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  _actionButton(
                    Image.asset("assets/images/callLogIcon.png", width: 30, height: 30),
                    "Call Logs",
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallLogsScreen(
                            lead: lead,
                          ),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    Image.asset("assets/images/notesIcon.png", width: 30, height: 30),
                    "Notes",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LeadRemarksScreen(lead: lead, type: 'Notes'),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    Icon(Icons.event, size: 25, color: newBlueColor),
                    "Followups",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LeadRemarksScreen(lead: lead, type: 'Followup'),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    Image.asset("assets/iconsnew/dialerIcon.png", width: 30, height: 30),
                    "Dialer",
                    () async {
                      Navigator.pop(context);
                      final Uri callUri = Uri(scheme: "tel", path: lead.mobileNo);
                      await launchUrl(callUri);
                    },
                  ),
                  _actionButton(
                    // Balaji uses an SVG here; this app doesn't ship flutter_svg,
                    // so a Material icon in WhatsApp green avoids adding a
                    // dependency for a single glyph.
                    const Icon(Icons.chat, size: 30, color: Color(0xFF25D366)),
                    "WhatsApp",
                    () async {
                      Navigator.pop(context);
                      final Uri waUri = Uri.parse("https://wa.me/${lead.mobileNo}");
                      await launchUrl(waUri);
                    },
                  ),
                  _actionButton(
                    Image.asset("assets/iconsnew/quateIcon.png", width: 30, height: 30),
                    "Quote",
                    () async {
                      await getAllQuotationController.getAllLists(leadId: lead.leadEntryId);
                      final quotations = getAllQuotationController.getAllQuotation.value?.data ?? [];
                      log('quotations=================>>>>>$quotations');
                      Navigator.pop(context);
                      quotations.isEmpty
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CreateQuoteScreen(
                                        lead: lead,
                                      )))
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllQuotationScreen(),
                                settings: RouteSettings(
                                  arguments: lead, // Pass the lead here
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(Widget icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundColor: Colors.transparent, radius: 28, child: icon),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String getWeekdayShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('E').format(date); // Returns Mon, Tue, etc.
    } catch (_) {
      return "-";
    }
  }

  void _showLeadPopup(Offset position, LeadModel lead) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _quickInfoRow("Name", lead.name),
                _quickInfoRow("Mobile", lead.mobile),
                _quickInfoRow("Status", lead.status?.toUpperCase()),
                _quickInfoRow("Lead Date", formatDate(lead.leadDate)),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(Duration(seconds: 3), () => entry.remove());
  }

  Widget _quickInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value ?? "-"),
          ],
        ),
      ),
    );
  }

  Widget _detailText(String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "${value ?? '-'}",
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadViewController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: purpleColor,
            elevation: 3,
            shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2.5)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LeadManagementScreen()));
            },
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: Column(
              children: [
                LeadAppBar(
                  title: 'Leads',
                  subtitle: 'Manage and track your leads',
                  onBack: () => Get.toNamed(AppRoutes.home),
                ),
                if (controller.isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (controller.getleadentryList.isEmpty)
                  Center(
                    child: Text("No leads available",
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 2.70,
                          mainAxisSpacing: 0,
                        ),
                        itemCount: controller.getleadentryList.length,
                        itemBuilder: (context, index) {
                          final lead = controller.getleadentryList[index];
                          final isSelected = index == selectedIndex;

                          return GestureDetector(
                            onTap: () => _openLeadActions(lead, index, lead.leadEntryId.toString()),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                              decoration: BoxDecoration(
                                color: isSelected ? newBlueLightColor : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? newBlueColor : newBorderColor,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTapDown: (details) {
                                          // _showLeadPopup(details.globalPosition, lead);
                                        },
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.purple.withOpacity(0.15),
                                          child: Text(
                                            (lead.leadName.isNotEmpty == true)
                                                ? lead.leadName[0].toUpperCase()
                                                : "?",
                                            style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.purple,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "${lead.ageing} days",
                                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _detailText(
                                              lead.leadName,
                                            ),
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  _detailText("${lead.ageing} days"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        _detailText(lead.companyName),
                                        _detailText(lead.mobileNo),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              _detailText(formatDate(lead.leadDate)),
                                              const SizedBox(width: 22),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 7.0),
                                                child: Text(
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  (index % 2 == 0 ? 'NEW' : "INPROGRESS").toUpperCase(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: index % 2 == 1 ? Colors.orange : Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      onRefresh: () async {
                        await controller.getLeadEntryApiMethod();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/////////////////////// Lead Edit

class LeadDetailsScreen extends StatefulWidget {
  final String? id;
  final VoidCallback onUpdate;

  const LeadDetailsScreen({
    Key? key,
    required this.onUpdate,
    this.id,
  }) : super(key: key);

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  final LeadViewController controller = Get.put(LeadViewController());

  @override
  void initState() {
    super.initState();
    // fetch details from API
    controller.getLeadEntryDetailFromId(int.parse(widget.id!));
  }

  /// Confirmation gate for the Delete button.
  ///
  /// The button previously called deleteLeadFun directly, so one stray tap
  /// permanently removed a lead from live data with no way back.
  Future<void> _confirmDeleteLead(
      BuildContext context, int? leadId, String? label) async {
    if (leadId == null) return;

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this lead?'),
        content: Text(
          label == null || label.trim().isEmpty
              ? 'This permanently deletes the lead. It cannot be undone.'
              : '"$label" will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: redColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await controller.deleteLeadFun(leadId);
    }
  }

  Future<void> _deleteLead(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("leads");
    if (data != null) {
      final decoded = jsonDecode(data);
      await prefs.setString("leads", jsonEncode(decoded));
      widget.onUpdate();
      Navigator.pop(context);
    }
  }

  // Future<void> _editLead(BuildContext context) async {
  //   final data = controller.getLeadDetailFromIdResponseModel?.data;
  //   if (data == null) return;
  //
  //   // final updated = await Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(
  //   //     builder: (_) => LeadManagementScreen(editLead: fromApiToLeadModel(data)),
  //   //   ),
  //   // );
  //   //
  //   // if (updated == true) {
  //   //   widget.onUpdate();
  //   //   Navigator.pop(context);
  //   // }
  // }

  Future<void> _editLead(BuildContext context) async {
    final data = controller.getLeadDetailFromIdResponseModel?.data;
    log('Full Edit Data=================>>>>>${jsonEncode(data)}');

    if (data != null) {
      final lead = controller.fromApiToLeadModel(data);

      log('LeadName: ${lead.leadName}');
      log('CompanyName: ${lead.companyName}');
      log('MobileNo: ${lead.mobileNo}');
      log('AlternateMobile: ${lead.alternateMobile}');
      log('Email: ${lead.email}');
      log('Website: ${lead.website}');
      log('LeadDate: ${lead.leadDate}');
      log('LastCommunicationDate: ${lead.lastCommunicationDate}');
      log('BusinessType: ${lead.businessType}');
      log('IndustryType: ${lead.industryType}');
      log('InterestedIn: ${lead.interestedIn}');
      log('CurrentSoftware: ${lead.currentSoftware}');
      log('DecisionTime: ${lead.decisionTime}');
      log('LeadItems: ${jsonEncode(lead.leadItems)}');
      // log('sources: ${jsonEncode(lead.leadItems)}');

      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LeadManagementScreen(editLead: lead),
        ),
      );

      if (updated == true) {
        widget.onUpdate();
        Navigator.pop(context);
      }
    }
  }

  String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: newTextPrimary),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: newBorderColor),
      ),
      child: child,
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
                style: GoogleFonts.poppins(fontSize: 11, color: newTextSecondary, fontWeight: FontWeight.w400)),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: newTextPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(List<MapEntry<String, String?>> fields) {
    final visible = fields.where((f) => f.value?.isNotEmpty ?? false).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    for (var i = 0; i < visible.length; i += 2) {
      final second = i + 1 < visible.length ? visible[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoBlock(visible[i].key, visible[i].value!),
              const SizedBox(width: 10),
              if (second != null) _infoBlock(second.key, second.value!) else const Spacer(),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _textBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: newTextPrimary)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: newSurfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: newBorderColor),
          ),
          child: Text(value, style: GoogleFonts.poppins(fontSize: 13, color: newTextSecondary, height: 1.5)),
        ),
      ],
    );
  }

  Widget _productCard(LeadItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: newSurfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: newBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: newBlueLightColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.inventory_2_outlined, color: newBlueColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? '-',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: newTextPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('Qty: ${item.quantity ?? 0}',
                    style: GoogleFonts.poppins(fontSize: 12, color: newTextSecondary)),
              ],
            ),
          ),
          Text('₹${item.salesPrice ?? 0}',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: newBlueColor)),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, Color color, Color bg, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: newTextSecondary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadViewController>(
      builder: (c) {
        final data = c.getLeadDetailFromIdResponseModel?.data;
        final items = data?.leadItems ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: Column(
            children: [
              // Header
              LeadAppBar(
                title: 'Lead Details',
                subtitle: data?.companyName ?? data?.leadName,
                onBack: () => Navigator.pop(context),
              ),

              // Body
              if (c.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (data == null)
                Expanded(
                  child: Center(
                    child: Text(
                      "No Lead Details Found",
                      style: GoogleFonts.poppins(fontSize: 14, color: grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Identity card
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: newBlueLightColor,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      _initials(data.leadName),
                                      style: GoogleFonts.poppins(
                                          fontSize: 16, fontWeight: FontWeight.w700, color: newBlueColor),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data.leadName ?? '-',
                                          style: GoogleFonts.poppins(
                                              fontSize: 17, fontWeight: FontWeight.w700, color: newTextPrimary),
                                        ),
                                        if ((data.companyName ?? '').isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            data.companyName!,
                                            style: GoogleFonts.poppins(fontSize: 13, color: newTextSecondary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if ((data.mobileNo ?? '').isNotEmpty) ...[
                                const SizedBox(height: 14),
                                const Divider(height: 1, color: Color(0xFFEFF2F7)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _quickAction(Icons.call_outlined, newGreenColor, newGreenLightColor, 'Call',
                                        () async {
                                      await launchUrl(Uri(scheme: 'tel', path: data.mobileNo));
                                    }),
                                    const SizedBox(width: 20),
                                    _quickAction(Icons.chat_outlined, newGreenColor, newGreenLightColor, 'WhatsApp',
                                        () async {
                                      await launchUrl(Uri.parse('https://wa.me/${data.mobileNo}'),
                                          mode: LaunchMode.externalApplication);
                                    }),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Contact details
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Contact Details'),
                              const SizedBox(height: 10),
                              _infoRow([
                                MapEntry('Mobile', data.mobileNo),
                                MapEntry('Alt Contact', data.alternateMobile),
                                MapEntry('Email', data.email),
                                MapEntry('Website', data.website),
                              ]),
                            ],
                          ),
                        ),

                        // Business details
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Business Details'),
                              const SizedBox(height: 10),
                              _infoRow([
                                MapEntry('Business Type', data.businessType),
                                MapEntry('Industry Type', data.industryType),
                                MapEntry('Sources', data.source),
                                if (data.interestedIn != null &&
                                    data.interestedIn!.isNotEmpty &&
                                    data.interestedIn != '0')
                                  MapEntry('Interested In', data.interestedIn),
                                if (data.currentSoftware != null &&
                                    data.currentSoftware!.isNotEmpty &&
                                    data.currentSoftware != '0')
                                  MapEntry('Current Software', data.currentSoftware),
                                if (data.decisionTime != null &&
                                    data.decisionTime!.isNotEmpty &&
                                    data.decisionTime != '0')
                                  MapEntry('Decision Timeline', data.decisionTime),
                              ]),
                            ],
                          ),
                        ),

                        // Products
                        if (items.isNotEmpty)
                          _sectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('Products'),
                                const SizedBox(height: 10),
                                ...items.map(_productCard),
                              ],
                            ),
                          ),

                        // Remarks
                        if ((data.requirement ?? '').isNotEmpty)
                          _sectionCard(child: _textBlock('Remarks', data.requirement!)),

                        // Address
                        if ((data.address ?? '').isNotEmpty)
                          _sectionCard(child: _textBlock('Address', data.address!)),

                        // Timeline
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Timeline'),
                              const SizedBox(height: 10),
                              _infoRow([
                                MapEntry('Lead Date', _formatDate(data.leadDate)),
                                MapEntry('Last Comm. Date', _formatDate(data.lastCommunicationDate)),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: newBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _editLead(context),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: Text("Edit", style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Deleting a lead is irreversible and this used to fire
                        // on a single tap with no confirmation at all.
                        onPressed: () =>
                            _confirmDeleteLead(context, data?.leadEntryId,
                                data?.leadName ?? data?.companyName),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
                      ),
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
  }
}

class LeadModel {
  String? name;
  String? company;
  String? mobile;
  String? altContact;
  String? email;
  String? website;
  String? businessType;
  String? industryType;
  String? products;
  String? remarks;
  String? interestedIn;
  String? currentSoftware;
  String? decisionTimeline;
  String? leadDate; // NEW
  String? lastCommDate; // NEW
  String? status;

  LeadModel({
    this.name,
    this.company,
    this.mobile,
    this.altContact,
    this.email,
    this.website,
    this.businessType,
    this.industryType,
    this.products,
    this.remarks,
    this.interestedIn,
    this.currentSoftware,
    this.decisionTimeline,
    this.leadDate,
    this.lastCommDate,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "company": company,
        "mobile": mobile,
        "altContact": altContact,
        "email": email,
        "website": website,
        "businessType": businessType,
        "industryType": industryType,
        "products": products,
        "remarks": remarks,
        "interestedIn": interestedIn,
        "currentSoftware": currentSoftware,
        "decisionTimeline": decisionTimeline,
        "leadDate": leadDate,
        "lastCommDate": lastCommDate,
        "status": status,
      };

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        name: json["name"],
        company: json["company"],
        mobile: json["mobile"],
        altContact: json["altContact"],
        email: json["email"],
        website: json["website"],
        businessType: json["businessType"],
        industryType: json["industryType"],
        products: json["products"],
        remarks: json["remarks"],
        interestedIn: json["interestedIn"],
        currentSoftware: json["currentSoftware"],
        decisionTimeline: json["decisionTimeline"],
        leadDate: json["leadDate"],
        lastCommDate: json["lastCommDate"],
        status: json["status"],
      );
}
