import 'dart:io';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/utils/app_constant.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../mrn_response/mrn_models.dart';

class MrnController extends AppBaseController {
  //  Step tracking 
  int currentStep = 0; // 0=Source 1=Items 2=Scan 3=Review
  final PageController pageController = PageController();

  //  Step 1: Header & Source 
  final TextEditingController mrnDateCtrl = TextEditingController();
  final TextEditingController invoiceNoCtrl = TextEditingController();
  final TextEditingController invoiceDateCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();

  MrnSourceType selectedSource = MrnSourceType.purchaseOrder;
  String selectedWarehouse = 'Main Store';
  String mrnNumber = '';
  String selectedSupplier = '';

  final List<String> warehouseList = ['Main Store', 'Branch Store', 'Cold Store'];
  final List<String> supplierList = [
    'Global Logistics Pvt. Ltd.',
    'Shree Enterprises',
    'Modi Metals & Co.',
    'Raj Suppliers',
  ];

  //  Step 2: PO & Items 
  List<MrnPOItem> poList = [];
  List<MrnItemLine> itemLines = [];
  bool isLoadingPO = false;

  //  Step 3: Barcode Scan 
  final TextEditingController barcodeCtrl = TextEditingController();
  List<MrnScannedItem> scannedItems = [];
  bool isCameraActive = false;

  //  Step 4: Documents & Review 
  MrnDocType selectedDocType = MrnDocType.invoice;
  List<MrnDocument> attachedDocuments = [];
  final ImagePicker picker = ImagePicker();

  //  Financials 
  double gstPercent = 18.0;
  double transportCharges = 2500.0;
  double discount = 5000.0;

  @override
  void onInit() {
    super.onInit();
    mrnDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    mrnNumber = _generateMrnNumber();
    selectedSupplier = supplierList.first;
    _loadDummyPOList();
    _loadDummyItems();
  }

  @override
  void onClose() {
    pageController.dispose();
    mrnDateCtrl.dispose();
    invoiceNoCtrl.dispose();
    invoiceDateCtrl.dispose();
    remarksCtrl.dispose();
    barcodeCtrl.dispose();
    super.onClose();
  }

  //  Navigation 
  void goToStep(int step) {
    if (step < 0 || step > 3) return;
    currentStep = step;
    pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    update();
  }

  void nextStep() => goToStep(currentStep + 1);
  void prevStep() => goToStep(currentStep - 1);

  //  Step 1 
  void setSource(MrnSourceType src) {
    selectedSource = src;
    update();
  }

  void setWarehouse(String w) {
    selectedWarehouse = w;
    update();
  }

  void setSupplier(String s) {
    selectedSupplier = s;
    _loadDummyPOList();
    update();
  }

  Future<void> pickMrnDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: AppConst.calenderFirstDate,
      lastDate: AppConst.calenderLastDate,
      builder: (c, child) => Theme(
        data: ThemeData.light()
            .copyWith(colorScheme: const ColorScheme.light(primary: newBlueColor)),
        child: child!,
      ),
    );
    if (picked != null) {
      mrnDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      update();
    }
  }

  Future<void> pickInvoiceDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: AppConst.calenderFirstDate,
      lastDate: AppConst.calenderLastDate,
      builder: (c, child) => Theme(
        data: ThemeData.light()
            .copyWith(colorScheme: const ColorScheme.light(primary: newBlueColor)),
        child: child!,
      ),
    );
    if (picked != null) {
      invoiceDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      update();
    }
  }

  //  Step 2: PO & Items 
  void togglePO(MrnPOItem po) {
    po.isSelected = !po.isSelected;
    update();
  }

  void increaseQty(MrnItemLine item) {
    item.receiveNowQty++;
    update();
  }

  void decreaseQty(MrnItemLine item) {
    if (item.receiveNowQty > 0) {
      item.receiveNowQty--;
      update();
    }
  }

  void setQtyFromText(MrnItemLine item, String val) {
    item.receiveNowQty = double.tryParse(val) ?? item.receiveNowQty;
    update();
  }

  //  Step 3: Barcode 
  void addBarcodeItem() {
    final code = barcodeCtrl.text.trim();
    if (code.isEmpty) return;
    // Simulate lookup
    final known = _knownBarcodes[code];
    if (known != null) {
      final existing = scannedItems.where((i) => i.barcode == code);
      if (existing.isNotEmpty) {
        existing.first.qty++;
      } else {
        scannedItems.add(MrnScannedItem(
          barcode: code,
          itemName: known['name']!,
          itemCode: known['code']!,
          rate: double.parse(known['rate']!),
          isUnknown: false,
        ));
      }
    } else {
      scannedItems.add(MrnScannedItem(
        barcode: code,
        itemName: 'Unknown Item',
        itemCode: 'N/A',
        rate: 0,
        isUnknown: true,
      ));
    }
    barcodeCtrl.clear();
    update();
  }

  void increaseScannedQty(MrnScannedItem item) {
    item.qty++;
    update();
  }

  void decreaseScannedQty(MrnScannedItem item) {
    if (item.qty > 1) {
      item.qty--;
      update();
    }
  }

  //  Step 4: Documents 
  void setDocType(MrnDocType t) {
    selectedDocType = t;
    update();
  }

  Future<void> pickFromCamera() async {
    try {
      final xfile = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
      if (xfile != null) {
        _addDocument(xfile.path, 'image', 'Camera');
      }
    } catch (e) {
      ShowMessage.showSnackBar('Camera', 'Could not open camera: $e');
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
      if (xfile != null) {
        _addDocument(xfile.path, 'image', 'Gallery');
      }
    } catch (e) {
      ShowMessage.showSnackBar('Gallery', 'Could not open gallery: $e');
    }
  }

  Future<void> pickFile() async {
    // In production: use file_picker package (add to pubspec: file_picker: ^5.x)
    // Simulated for demo purposes
    final mockDoc = MrnDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: 'Invoice_${invoiceNoCtrl.text.isNotEmpty ? invoiceNoCtrl.text : "file"}.pdf',
      filePath: '',
      fileType: 'pdf',
      fileSize: '2.3 MB',
      docType: selectedDocType,
      source: 'File',
      uploadedAt: DateTime.now(),
    );
    attachedDocuments.add(mockDoc);
    update();
  }

  void removeDocument(String id) {
    attachedDocuments.removeWhere((d) => d.id == id);
    update();
  }

  void _addDocument(String path, String type, String source) {
    final file = File(path);
    final name = path.split('/').last;
    attachedDocuments.add(MrnDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: name,
      filePath: path,
      fileType: type,
      fileSize: _fileSize(file),
      docType: selectedDocType,
      source: source,
      uploadedAt: DateTime.now(),
    ));
    update();
  }

  //  Financials 
  double get subtotal {
    double total = 0;
    for (final i in allItems) {
      total += i.lineTotal;
    }
    return total;
  }

  double get gstAmount => subtotal * gstPercent / 100;
  double get grandTotal => subtotal + gstAmount + transportCharges - discount;

  List<MrnItemLine> get allItems {
    final scanLines = scannedItems
        .where((s) => !s.isUnknown)
        .map((s) => MrnItemLine(
              itemId: s.itemCode,
              itemName: s.itemName,
              itemCode: s.barcode,
              poQty: 0,
              receivedQty: 0,
              rate: s.rate,
              unit: 'Nos',
              source: 'Scan',
              receiveNowQty: s.qty,
            ))
        .toList();
    return [...itemLines, ...scanLines];
  }

  //  Submit 
  Future<void> submitMRN() async {
    if (selectedSupplier.isEmpty) {
      ShowMessage.showSnackBar('Validation', 'Please select a supplier');
      return;
    }
    if (allItems.isEmpty) {
      ShowMessage.showSnackBar('Validation', 'Please add at least one item');
      return;
    }
    setBusy(true);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      ShowMessage.showSnackBar('Success', 'MRN $mrnNumber submitted successfully');
      Get.back();
    } catch (e) {
      ShowMessage.showSnackBar('Error', '$e');
    } finally {
      setBusy(false);
    }
  }

  //  Helpers 
  String _generateMrnNumber() {
    final year = DateTime.now().year;
    final seq = (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
    return 'MRN-$year-$seq';
  }

  String _fileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '—';
    }
  }

  String docTypeLabel(MrnDocType t) {
    switch (t) {
      case MrnDocType.invoice: return 'Invoice';
      case MrnDocType.indent: return 'Indent / MR';
      case MrnDocType.deliveryChallan: return 'Delivery Challan';
      case MrnDocType.inspection: return 'Inspection';
      case MrnDocType.other: return 'Other';
    }
  }

  String sourceLabel(MrnSourceType s) {
    switch (s) {
      case MrnSourceType.purchaseOrder: return 'Purchase Order';
      case MrnSourceType.indent: return 'Indent / MR';
      case MrnSourceType.directPurchase: return 'Direct Purchase';
      case MrnSourceType.barcodeScan: return 'Barcode Scan';
    }
  }

  //  Dummy data 
  void _loadDummyPOList() {
    poList = [
      MrnPOItem(poNumber: 'PO-2026-0117', date: '15 Jan 2026', itemCategory: 'Steel & Pipes', amount: 245000, status: 'Partial', isSelected: true),
      MrnPOItem(poNumber: 'PO-2026-0098', date: '08 Jan 2026', itemCategory: 'Safety Equipment', amount: 88500, status: 'Open'),
      MrnPOItem(poNumber: 'PO-2026-0074', date: '02 Jan 2026', itemCategory: 'Tools', amount: 112000, status: 'Open'),
    ];
    update();
  }

  void _loadDummyItems() {
    itemLines = [
      MrnItemLine(itemId: 'ITM-0041', itemName: 'SS Pipe CI-115 (3.15×350MM)', itemCode: 'ITM-0041', poQty: 100, receivedQty: 40, rate: 1999, unit: 'Nos', source: 'PO', receiveNowQty: 60),
      MrnItemLine(itemId: 'ITM-0088', itemName: 'Open Spanner CI-115', itemCode: 'ITM-0088', poQty: 50, receivedQty: 0, rate: 850, unit: 'Nos', source: 'PO', receiveNowQty: 50),
      MrnItemLine(itemId: 'ITM-0102', itemName: 'Safety Goggles CI-115', itemCode: 'ITM-0102', poQty: 25, receivedQty: 0, rate: 1200, unit: 'Nos', source: 'PO', receiveNowQty: 25),
      MrnItemLine(itemId: 'ITM-0055', itemName: 'SS Square Pipe 40×40MM', itemCode: 'ITM-0055', poQty: 200, receivedQty: 80, rate: 750, unit: 'Mtr', source: 'PO', receiveNowQty: 120),
    ];
    update();
  }

  final Map<String, Map<String, String>> _knownBarcodes = {
    '6901234567890': {'name': 'Drill Bit Set HSS 10pc', 'code': 'ITM-0199', 'rate': '450'},
    '6901234599001': {'name': 'Cable Tie 200mm (100pc)', 'code': 'ITM-0211', 'rate': '120'},
    '4901234512345': {'name': 'Safety Helmet Red', 'code': 'ITM-0312', 'rate': '380'},
  };
}
