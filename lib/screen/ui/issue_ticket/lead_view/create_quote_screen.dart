// import 'dart:developer';
//
// import 'package:digitalerp/model/get_quote_response_model.dart';
// import 'package:digitalerp/model/getleadentry_response_model.dart';
// import 'package:digitalerp/utils/app_constant.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart' as p;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../reimbursemnt_view/controller/reimbursement_controller.dart';
// import 'controller/lead_management_controller.dart';
//
// class QuoteItem {
//   String description;
//   int qty;
//   double price;
//
//   QuoteItem({required this.description, required this.qty, required this.price});
//
//   double get total => qty * price;
// }
//
// class CreateQuoteScreen extends StatefulWidget {
//   final GetleadentryList? lead;
//   const CreateQuoteScreen({super.key, this.lead});
//
//   @override
//   State<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
// }
//
// class _CreateQuoteScreenState extends State<CreateQuoteScreen> {
//   LeadViewController controller = Get.put(LeadViewController());
//   ReimbursementController reimbursementController = Get.put(ReimbursementController());
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     controller.pickCurrencyData();
//     controller.getAddQuotes(leadId: widget.lead?.leadEntryId);
//   }
//
//   String taxOption = "Without Tax";
//   double taxRate = 18.0;
//
//   List<QuoteItem> items = [];
//   final _formKey = GlobalKey<FormState>();
//
//   double get subTotal => items.fold(0, (sum, item) => sum + item.total);
//
//   double get additionalCharges => double.tryParse(controller.additionalChargesController.text) ?? 0.0;
//
//   double get taxAmount => taxOption == "With Tax" ? (subTotal + additionalCharges) * (taxRate / 100) : 0.0;
//
//   double get totalAmount => subTotal + additionalCharges + taxAmount;
//
//   InputDecoration _roundedInputDecoration(String hint, {IconData? icon}) {
//     return InputDecoration(
//       hintText: hint,
//       prefixIcon: icon != null ? Icon(icon, color: purpleColor) : null,
//       hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//     );
//   }
//
//   void _addItem() {
//     TextEditingController desc = TextEditingController();
//     TextEditingController qty = TextEditingController();
//     TextEditingController price = TextEditingController();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           top: 16,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Center(
//                 child: Container(
//                   height: 5,
//                   width: 40,
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//               Text("Add Item", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: desc,
//                 decoration: _roundedInputDecoration("Services", icon: Icons.description),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: qty,
//                 decoration: _roundedInputDecoration("Quantity", icon: Icons.confirmation_number),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: price,
//                 decoration: _roundedInputDecoration("Unit Price", icon: Icons.attach_money),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: purpleColor,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       items.add(
//                         QuoteItem(
//                           description: desc.text,
//                           qty: int.tryParse(qty.text) ?? 0,
//                           price: double.tryParse(price.text) ?? 0.0,
//                         ),
//                       );
//                     });
//                     Navigator.pop(context);
//                   },
//                   child: Text("Add Item", style: GoogleFonts.poppins(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickExpiryDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 7)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (pickedDate != null) {
//       controller.expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//     }
//   }
//
//   Future<void> _generateAndSharePDF() async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageTheme: pw.PageTheme(margin: const pw.EdgeInsets.all(24)),
//         build: (pw.Context context) => [
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     "Your Company Name",
//                     style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
//                   ),
//                   pw.Text("Address line 1"),
//                   pw.Text("Phone: +91-9876543210"),
//                   pw.Text("Email: info@company.com"),
//                 ],
//               ),
//               pw.Text(
//                 "QUOTE",
//                 style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.purple),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 20),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text("Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}"),
//               pw.Text(
//                   "Expiry: ${controller.expiryDateController.text.isEmpty ? '-' : controller.expiryDateController.text}"),
//             ],
//           ),
//           pw.Divider(),
//           pw.Container(
//             width: double.infinity,
//             padding: const pw.EdgeInsets.all(10),
//             decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(6)),
//             child: pw.Text(controller.bodyTextController.text, style: const pw.TextStyle(fontSize: 12)),
//           ),
//           pw.SizedBox(height: 20),
//           pw.Table.fromTextArray(
//             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
//             headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
//             cellAlignment: pw.Alignment.centerLeft,
//             headers: ["Description", "Qty", "Unit Price", "Total"],
//             data: items
//                 .map((item) => [
//                       item.description,
//                       item.qty.toString(),
//                       "${item.price.toStringAsFixed(2)} ${controller.selectedCurrency}",
//                       "${item.total.toStringAsFixed(2)} ${controller.selectedCurrency}",
//                     ])
//                 .toList(),
//           ),
//           pw.SizedBox(height: 10),
//           pw.Container(
//             alignment: pw.Alignment.centerRight,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.end,
//               children: [
//                 pw.Text("Subtotal: ${subTotal.toStringAsFixed(2)} ${controller.selectedCurrency}"),
//                 if (additionalCharges > 0)
//                   pw.Text(
//                       "Additional: ${additionalCharges.toStringAsFixed(2)} ${controller.selectedCurrency}"),
//                 if (taxOption == "With Tax")
//                   pw.Text("Tax ($taxRate%): ${taxAmount.toStringAsFixed(2)} $controller.{selectedCurrency}"),
//                 pw.Divider(),
//                 pw.Text(
//                   "Grand Total: ${totalAmount.toStringAsFixed(2)} ${controller.selectedCurrency}",
//                   style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 20),
//           if (controller.additionalRemarksController.text.isNotEmpty)
//             pw.Container(
//               width: double.infinity,
//               padding: const pw.EdgeInsets.all(10),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(color: PdfColors.grey),
//                 borderRadius: pw.BorderRadius.circular(6),
//               ),
//               child: pw.Text("Remarks: ${controller.additionalRemarksController.text}"),
//             ),
//           pw.SizedBox(height: 30),
//           pw.Align(
//             alignment: pw.Alignment.centerRight,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.end,
//               children: [
//                 pw.Text("Authorized Signatory"),
//                 pw.SizedBox(height: 40),
//                 pw.Container(width: 100, height: 1, color: PdfColors.black),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//
//     final output = await getTemporaryDirectory();
//     final file = File("${output.path}/quote.pdf");
//     await file.writeAsBytes(await pdf.save());
//
//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: 'Here is your quotation.',
//       subject: p.basename(file.path),
//     );
//   }
//
//   void _saveQuote() {
//     if (_formKey.currentState!.validate() && items.isNotEmpty) {
//       _generateAndSharePDF();
//     } else if (items.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please add at least one item")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<LeadViewController>(
//       builder: (controller) {
//         return Scaffold(
//           backgroundColor: lightGrey,
//           appBar: AppBar(
//             title:
//                 Text("Create Quote", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
//             backgroundColor: purpleColor,
//             foregroundColor: white,
//             elevation: 0,
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: controller.descriptionController,
//                     style: GoogleFonts.poppins(fontSize: 13),
//                     decoration: _roundedInputDecoration("Enter quote description", icon: Icons.text_fields),
//                     validator: (value) => value!.isEmpty ? "Please enter description" : null,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: controller.bodyTextController,
//                     style: GoogleFonts.poppins(fontSize: 13),
//                     maxLines: 3,
//                     decoration: _roundedInputDecoration("Standard Body Text", icon: Icons.notes),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           isExpanded: true,
//                           value: controller.selectedCurrency,
//                           style: GoogleFonts.poppins(fontSize: 13),
//                           decoration: _roundedInputDecoration(
//                             "Select currency",
//                             icon: Icons.currency_exchange,
//                           ),
//                           items: controller.currencyDataList.map<DropdownMenuItem<String>>((c) {
//                             return DropdownMenuItem<String>(
//                               value: c.currencyCode,
//                               child: Text(
//                                 c.currencyCode.toString(),
//                                 style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (val) {
//                             setState(() {
//                               controller.selectedCurrency = val!;
//
//                               final selectedCurrencyObj = controller.currencyDataList
//                                   .firstWhere((c) => c.currencyCode == val);
//
//                               controller.selectedInrId = selectedCurrencyObj.currencyId;
//
//                               log('selectedCurrency code ===== $val');
//                               log('selectedCurrency id   ===== ${controller.selectedInrId}');
//                             });
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: controller.expiryDateController,
//                           readOnly: true,
//                           style: GoogleFonts.poppins(fontSize: 13),
//                           onTap: _pickExpiryDate,
//                           decoration:
//                               _roundedInputDecoration("Select expiry date", icon: Icons.calendar_today),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Card(
//                     color: white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     elevation: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Items",
//                                 style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.add_circle, color: purpleColor),
//                                 onPressed: _addItem,
//                               ),
//                             ],
//                           ),
//                           const Divider(),
//                           controller.getQuote.isEmpty
//                               ? Text(
//                                   "No items added yet",
//                                   style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
//                                 )
//                               : Column(
//                                   children: controller.getQuote.asMap().entries.map((entry) {
//                                     int index = entry.key;
//                                     GetQuote item = entry.value;
//                                     return Card(
//                                       margin: const EdgeInsets.symmetric(vertical: 6),
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                                       elevation: 0,
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "Service / Item",
//                                               style: GoogleFonts.poppins(
//                                                 fontSize: 12,
//                                                 color: Colors.grey[600],
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             TextFormField(
//                                               initialValue: item.itemName,
//                                               style: GoogleFonts.poppins(fontSize: 13),
//                                               decoration: _roundedInputDecoration("Description"),
//                                               onChanged: (val) => setState(() => item.itemName = val),
//                                             ),
//                                             const SizedBox(height: 10),
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         "Qty",
//                                                         style: GoogleFonts.poppins(
//                                                           fontSize: 12,
//                                                           color: Colors.grey[600],
//                                                           fontWeight: FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       TextFormField(
//                                                         initialValue: item.quantity.toString(),
//                                                         style: GoogleFonts.poppins(fontSize: 13),
//                                                         keyboardType: TextInputType.number,
//                                                         decoration: _roundedInputDecoration("Qty"),
//                                                         onChanged: (val) => setState(
//                                                             () => item.quantity = int.tryParse(val) ?? 0),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         "Price",
//                                                         style: GoogleFonts.poppins(
//                                                           fontSize: 12,
//                                                           color: Colors.grey[600],
//                                                           fontWeight: FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       TextFormField(
//                                                         initialValue: item.amount.toString(),
//                                                         style: GoogleFonts.poppins(fontSize: 13),
//                                                         keyboardType: TextInputType.number,
//                                                         decoration: _roundedInputDecoration("Price"),
//                                                         onChanged: (val) => setState(
//                                                           () => item.amount = double.tryParse(val) ?? 0.0,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(top: 23.0),
//                                                   child: IconButton(
//                                                     icon: const Icon(Icons.delete, color: red),
//                                                     onPressed: () => setState(() => items.removeAt(index)),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 8),
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.end,
//                                               children: [
//                                                 Text(
//                                                   "Total: ${item.salesPrice.toStringAsFixed(2)} ${controller.selectedCurrency}",
//                                                   style: GoogleFonts.poppins(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: green,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: controller.additionalChargesController,
//                     style: GoogleFonts.poppins(fontSize: 13),
//                     keyboardType: TextInputType.number,
//                     decoration: _roundedInputDecoration("Additional Charges", icon: Icons.add_card),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: controller.additionalRemarksController,
//                     style: GoogleFonts.poppins(fontSize: 13),
//                     decoration:
//                         _roundedInputDecoration("Remarks for Additional Charges", icon: Icons.comment),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: RadioListTile(
//                           title: Text("With Tax", style: GoogleFonts.poppins(fontSize: 13)),
//                           value: "With Tax",
//                           groupValue: taxOption,
//                           onChanged: (val) => setState(() => taxOption = val.toString()),
//                         ),
//                       ),
//                       Expanded(
//                         child: RadioListTile(
//                           title: Text("Without Tax", style: GoogleFonts.poppins(fontSize: 13)),
//                           value: "Without Tax",
//                           groupValue: taxOption,
//                           onChanged: (val) => setState(() => taxOption = val.toString()),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Card(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     color: white,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Total Amount",
//                             style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
//                           ),
//                           Text(
//                             "$totalAmount ${controller.selectedCurrency}",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: green,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: purpleColor,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       onPressed: _saveQuote,
//                       child: Text(
//                         "Save & Share Quote",
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:digitalerp/utils/lead_app_bar.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:digitalerp/app_routes/app_routes.dart';
import 'package:digitalerp/model/get_quote_response_model.dart';
import 'package:digitalerp/model/getleadentry_response_model.dart';
// This app's app_constant.dart also declares newTextPrimary — hide it so the
// app_constant_new value wins, as the screen intends.
import 'package:digitalerp/utils/app_constant.dart' hide newTextPrimary;
import 'package:digitalerp/utils/app_constant_new.dart' show newTextPrimary;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'controller/lead_management_controller.dart';

class CreateQuoteScreen extends StatefulWidget {
  final GetleadentryList? lead;
  const CreateQuoteScreen({super.key, this.lead});

  @override
  State<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends State<CreateQuoteScreen> {
  LeadViewController controller = Get.put(LeadViewController());

  // String taxOption = "Without Tax";
  double taxRate = 18.0;
  String? taxOption;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.pickCurrencyData();
    if (widget.lead?.leadEntryId != null) {
      controller.getAddQuotes(leadId: widget.lead!.leadEntryId);
    }
    controller.additionalChargesController.addListener(() {
      setState(() {});
    });
  }

  double get subTotal =>
      controller.getQuote.fold(0, (sum, item) => sum + ((item.amount ?? 0) * (item.quantity ?? 0)));

  double get additionalCharges => double.tryParse(controller.additionalChargesController.text) ?? 0;

  double get taxAmount => taxOption == "With Tax" ? (subTotal + additionalCharges) * (taxRate / 100) : 0;

  double get totalAmount => subTotal + additionalCharges + taxAmount;

  InputDecoration _roundedInputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: purpleColor) : null,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _addItem() {
    TextEditingController desc = TextEditingController();
    TextEditingController qty = TextEditingController();
    TextEditingController price = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Text("Add Item", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: desc,
                decoration: _roundedInputDecoration("Service / Item", icon: Icons.description),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qty,
                decoration: _roundedInputDecoration("Quantity", icon: Icons.confirmation_number),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: price,
                decoration: _roundedInputDecoration("Unit Price", icon: Icons.attach_money),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpleColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      controller.getQuote.add(
                        GetQuote(
                          itemName: desc.text,
                          quantity: int.tryParse(qty.text) ?? 0,
                          amount: double.tryParse(price.text) ?? 0,
                          vatPercent: 18.0,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Add Item", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      controller.expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _generateAndSharePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(margin: const pw.EdgeInsets.all(24)),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Your Company Name",
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Address line 1"),
                  pw.Text("Phone: +91-9876543210"),
                  pw.Text("Email: info@company.com"),
                ],
              ),
              pw.Text("QUOTE",
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}"),
              pw.Text(
                  "Expiry: ${controller.expiryDateController.text.isEmpty ? '-' : controller.expiryDateController.text}"),
            ],
          ),
          pw.Divider(),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text(controller.bodyTextController.text, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ["Description", "Qty", "Unit Price", "Total"],
            data: controller.getQuote
                .map((item) => [
                      item.itemName,
                      item.quantity.toString(),
                      "${item.amount.toStringAsFixed(2)} ${controller.selectedCurrency}",
                      "${(item.amount! * item.quantity!).toStringAsFixed(2)} ${controller.selectedCurrency}"
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("Subtotal: ${subTotal.toStringAsFixed(2)} ${controller.selectedCurrency}"),
                if (additionalCharges > 0)
                  pw.Text(
                      "Additional: ${additionalCharges.toStringAsFixed(2)} ${controller.selectedCurrency}"),
                if (taxOption == "With Tax")
                  pw.Text("Tax ($taxRate%): ${taxAmount.toStringAsFixed(2)} ${controller.selectedCurrency}"),
                pw.Divider(),
                pw.Text("Grand Total: ${totalAmount.toStringAsFixed(2)} ${controller.selectedCurrency}",
                    style:
                        pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
              ],
            ),
          ),
          if (controller.additionalRemarksController.text.isNotEmpty) pw.SizedBox(height: 20),
          if (controller.additionalRemarksController.text.isNotEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text("Remarks: ${controller.additionalRemarksController.text}"),
            ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/quote.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Here is your quotation.');
  }

  // void _saveQuote() {
  //   if (_formKey.currentState!.validate() && controller.getQuote.isNotEmpty) {
  //     if (widget.lead?.leadEntryId != null) {
  //       controller.insertLeadQuote(leadId: widget.lead!.leadEntryId);
  //     }
  //
  //     _generateAndSharePDF();
  //   } else if (controller.getQuote.isEmpty) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(const SnackBar(content: Text("Please add at least one item")));
  //   }
  // }
  Future<void> _downloadAndSharePdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/quote.pdf");
        await file.writeAsBytes(bytes, flush: true);

        await Share.shareXFiles([XFile(file.path)], text: "Here is your quotation PDF");
      } else {
        Get.snackbar("Error", "Failed to download PDF");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  void _saveQuote({int? totalAmount}) async {
    if (_formKey.currentState!.validate() && controller.getQuote.isNotEmpty) {
      if (widget.lead?.leadEntryId != null) {
        await controller.insertLeadQuote(leadId: widget.lead!.leadEntryId, totalAmount: totalAmount);
        final pdfUrl = controller.leadInsertQuoteResponseModel?.data.first.url;
        if (pdfUrl != null && pdfUrl.isNotEmpty) {
          await _downloadAndSharePdf(pdfUrl);
        } else {
          Get.snackbar("Error", "PDF URL not available");
        }
      }
    } else if (controller.getQuote.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadViewController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: LeadAppBar(
            title: 'Create Quote',
            subtitle: widget.lead?.companyName ?? widget.lead?.leadName,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.descriptionController,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: _roundedInputDecoration("Enter quote description", icon: Icons.text_fields),
                    validator: (value) => value!.isEmpty ? "Please enter description" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.bodyTextController,
                    style: GoogleFonts.poppins(fontSize: 13),
                    maxLines: 3,
                    decoration: _roundedInputDecoration("Standard Body Text", icon: Icons.notes),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: controller.selectedCurrency,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: _roundedInputDecoration(
                            "Select currency",
                            icon: Icons.currency_exchange,
                          ),
                          items: controller.currencyDataList.map<DropdownMenuItem<String>>((c) {
                            return DropdownMenuItem<String>(
                              value: c.currencyCode,
                              child: Text(
                                c.currencyCode.toString(),
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              controller.selectedCurrency = val!;

                              final selectedCurrencyObj = controller.currencyDataList
                                  .firstWhere((c) => c.currencyCode == val);

                              controller.selectedInrId = selectedCurrencyObj.currencyId;

                              log('selectedCurrency code ===== $val');
                              log('selectedCurrency id   ===== ${controller.selectedInrId}');
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.expiryDateController,
                          readOnly: true,
                          style: GoogleFonts.poppins(fontSize: 13),
                          onTap: _pickExpiryDate,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select expiry date";
                            }
                            return null;
                          },
                          decoration: _roundedInputDecoration(
                            "Select expiry date",
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Items",
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),

                              GestureDetector(
                                  onTap: () {
                                    Get.toNamed(AppRoutes.allQuotationScreen, arguments: widget.lead);
                                  },
                                  child: Text("View All Quotations",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline))),

                              // IconButton(
                              //     icon: const Icon(Icons.add_circle, color: purpleColor),
                              //     onPressed: _addItem),
                            ],
                          ),
                          const Divider(),
                          controller.getQuote.isEmpty
                              ? Text("No items added yet", style: GoogleFonts.poppins(fontSize: 13))
                              : Column(
                                  children: controller.getQuote.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    GetQuote item = entry.value;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 2,
                                      shadowColor: Colors.grey.withOpacity(0.2),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Header Row with Title + Delete Icon
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Service / Item ${index + 1}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline,
                                                      color: Colors.redAccent),
                                                  onPressed: () =>
                                                      setState(() => controller.getQuote.removeAt(index)),
                                                  tooltip: "Remove item",
                                                ),
                                              ],
                                            ),

                                            // Item Name
                                            TextFormField(
                                              initialValue: item.itemName,
                                              style: GoogleFonts.poppins(fontSize: 13),
                                              decoration: _roundedInputDecoration(
                                                "Enter description",
                                              ),
                                              onChanged: (val) => setState(() => item.itemName = val),
                                            ),

                                            const SizedBox(height: 16),

                                            // Qty + Price
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Quantity",
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color: Colors.grey[600],
                                                              fontWeight: FontWeight.w500)),
                                                      const SizedBox(height: 6),
                                                      TextFormField(
                                                        initialValue: item.quantity.toString(),
                                                        style: GoogleFonts.poppins(fontSize: 13),
                                                        keyboardType: TextInputType.number,
                                                        decoration: _roundedInputDecoration("Qty"),
                                                        onChanged: (val) => setState(
                                                            () => item.quantity = int.tryParse(val) ?? 0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Price",
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color: Colors.grey[600],
                                                              fontWeight: FontWeight.w500)),
                                                      const SizedBox(height: 6),
                                                      TextFormField(
                                                        initialValue: item.amount.toString(),
                                                        style: GoogleFonts.poppins(fontSize: 13),
                                                        keyboardType: TextInputType.number,
                                                        decoration: _roundedInputDecoration("Price"),
                                                        onChanged: (val) => setState(
                                                            () => item.amount = double.tryParse(val) ?? 0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 14),

                                            // Total
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "Total: ${(item.amount! * item.quantity!).toStringAsFixed(2)} ${controller.selectedCurrency}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green[700],
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.additionalChargesController,
                    style: GoogleFonts.poppins(fontSize: 13),
                    keyboardType: TextInputType.number,
                    decoration: _roundedInputDecoration("Additional Charges", icon: Icons.add_card),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller.additionalRemarksController,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration:
                        _roundedInputDecoration("Remarks for Additional Charges", icon: Icons.comment),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: Text(
                            "With Tax",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          value: "With Tax",
                          groupValue: taxOption,
                          onChanged: (val) {
                            setState(() {
                              taxOption = val.toString();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: Text(
                            "Without Tax",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          value: "Without Tax",
                          groupValue: taxOption,
                          onChanged: (val) {
                            setState(() {
                              taxOption = val.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text("$totalAmount ${controller.selectedCurrency}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.addTermsAndCondition,
                    style: GoogleFonts.poppins(fontSize: 13),
                    maxLines: 5,
                    decoration: _roundedInputDecoration(
                      "Terms & Conditions",
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        int taxFlag = taxOption == "With Tax" ? 1 : 0;
                        log('taxFlag=================>>>>>${taxFlag}');

                        _saveQuote(totalAmount: taxFlag);
                      },
                      child: Text("Save & Share Quote", style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
