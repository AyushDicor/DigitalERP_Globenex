import 'dart:convert';
import 'dart:io';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/utils/app_constant.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../repo/reimbursement_repo.dart';
import '../../home_controller.dart';
import '../mrn_response/mrn_models.dart';

class MrnController extends AppBaseController {
  final HomeController homeController = Get.find<HomeController>();

  // ── Step tracking ──────────────────────────────────────────────────────────
  int currentStep = 0; // 0=Source  1=Items  2=Review
  final PageController pageController = PageController();

  // ── Step 1: Header ─────────────────────────────────────────────────────────
  List<MrnDropdownOption> seriesTypeList = [];
  MrnDropdownOption? selectedSeriesType;
  bool isLoadingSeriesType = false;

  final TextEditingController mrnDateCtrl = TextEditingController();
  String mrnNumber = '';

  // ── Source selection ───────────────────────────────────────────────────────
  MrnSourceType selectedSource = MrnSourceType.purchaseOrder;


  // ── Party ──────────────────────────────────────────────────────────────────
  final TextEditingController partyNameCtrl = TextEditingController();
  List<MrnDropdownOption> partyList = [];
  MrnDropdownOption? selectedParty;
  bool isLoadingParty = false;

  void setParty(MrnDropdownOption? v) {
    selectedParty = v;
    partyNameCtrl.text = v?.label ?? '';
    if (v != null) {
      fetchSites(partyId: int.tryParse(v.id) ?? 0);
      fetchWorkOrders(
        partyId: int.tryParse(v.id) ?? 0,
        siteId: int.tryParse(selectedSite?.id ?? '0') ?? 0,
      );
    }
    update();
  }

  // ── Site / Godown ──────────────────────────────────────────────────────────
  List<MrnDropdownOption> siteList = [];
  MrnDropdownOption? selectedSite;
  bool isLoadingSite = false;

  List<MrnDropdownOption> godownList = [];
  MrnDropdownOption? selectedGodown;
  bool isLoadingGodown = false;

  // ── Bill / Challan ─────────────────────────────────────────────────────────
  final TextEditingController billNoCtrl = TextEditingController();
  final TextEditingController billDateCtrl = TextEditingController();
  final TextEditingController challanNoCtrl = TextEditingController();
  final TextEditingController challanDateCtrl = TextEditingController();
  String receivedByName = '';

  // ── Addresses ──────────────────────────────────────────────────────────────
  MrnAddress? shippingAddress;
  MrnAddress? billingAddress;
  bool isLoadingAddresses = false;

  // ── Attachments ────────────────────────────────────────────────────────────
  Set<MrnAttachmentType> selectedAttachmentTypes = {
    MrnAttachmentType.bill,
    MrnAttachmentType.challan,
  };
  List<MrnDocument> billAttachments = [];
  List<MrnDocument> challanAttachments = [];
  final TextEditingController reasonNACtrl = TextEditingController();

  // ── Additional fields ──────────────────────────────────────────────────────
  List<MrnDropdownOption> paidTypeList = [
    MrnDropdownOption(id: 'Employee', label: 'Employee'),
    MrnDropdownOption(id: 'Company', label: 'Company'),
  ];
  List<MrnDropdownOption> paidByList = [];
  MrnDropdownOption? selectedPaidBy;
  bool isLoadingPaidBy = false;
  MrnDropdownOption? selectedPaidType;
  bool isLoadingPaidType = false;

  String selectedQcRequired = 'Yes';
  final List<String> qcRequiredOptions = ['Yes', 'No'];

  List<MrnDropdownOption> customerPoList = [];
  MrnDropdownOption? selectedCustomerPo;
  bool isLoadingCustomerPo = false;

  List<MrnDropdownOption> jobTypeList = [];
  MrnDropdownOption? selectedJobType;
  bool isLoadingJobType = false;

  List<MrnDropdownOption> workOrderList = [];
  MrnDropdownOption? selectedWorkOrder;
  bool isLoadingWorkOrder = false;

  // Add these fields to MrnController:
  final TextEditingController lotNoCtrl = TextEditingController();
  final TextEditingController grnNoCtrl = TextEditingController();
  final TextEditingController grnDateCtrl = TextEditingController();
  final TextEditingController gateEntryNoCtrl = TextEditingController();

  // ── Step 2: PO list & Items ────────────────────────────────────────────────
  List<PendingPoItem> poList = [];
  bool isLoadingPO = false;
  List<MrnItemLine> itemLines = [];
  bool isLoadingItems = false;
  String? expandedPoNumber;
  PendingPoItem? processingPo;

  // ── Direct entry dropdowns ─────────────────────────────────────────────────
  List<MrnDropdownOption> directItemList = [];
  bool isLoadingDirectItems = false;

  List<MrnDropdownOption> unitList = [];
  bool isLoadingUnit = false;

  List<MrnDropdownOption> makeList = [];
  bool isLoadingMake = false;

  // ── Step 3: Review ─────────────────────────────────────────────────────────
  final TextEditingController reviewRemarksCtrl = TextEditingController();

  // ── Financials ─────────────────────────────────────────────────────────────
  double get subtotal => itemLines.fold(0, (s, i) => s + i.amount);
  double get totalGst => itemLines.fold(0, (s, i) => s + i.gstAmount);
  double get grandTotal => subtotal + totalGst;
  double get roundOff {
    final exact = grandTotal;
    final rounded = exact.roundToDouble();
    return double.parse((rounded - exact).toStringAsFixed(2));
  }
  double get grandTotalRounded => grandTotal + roundOff;

  final ImagePicker picker = ImagePicker();

  // ── Init / Dispose ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    mrnDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    billDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    challanDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    grnDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    mrnNumber = _generateMrnNumber();
    _setLoggedInUser();
    _fetchAllDropdowns();
  }

  @override
  void onClose() {
    pageController.dispose();
    mrnDateCtrl.dispose();
    billDateCtrl.dispose();
    challanDateCtrl.dispose();
    partyNameCtrl.dispose();
    billNoCtrl.dispose();
    challanNoCtrl.dispose();
    reasonNACtrl.dispose();
    reviewRemarksCtrl.dispose();
    lotNoCtrl.dispose();
    grnNoCtrl.dispose();
    grnDateCtrl.dispose();
    gateEntryNoCtrl.dispose();
    super.onClose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void goToStep(int step) {
    if (step < 0 || step > 2) return;
    currentStep = step;
    pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

    // ✅ Only PO source needs refresh
    if (step == 1 && selectedSource == MrnSourceType.purchaseOrder) {
      fetchPendingPoList();
    }

    update();
  }

  void nextStep() => goToStep(currentStep + 1);
  void prevStep() => goToStep(currentStep - 1);

  // ── Source ─────────────────────────────────────────────────────────────────
  void setSource(MrnSourceType src) {
    selectedSource = src;
    itemLines.clear();
    poList.clear();
    processingPo = null;
    // ✅ Only PO needs the list fetch now
    if (src == MrnSourceType.purchaseOrder) {
      fetchPendingPoList();
    }
    update();
  }

  // ── Step 1 setters ─────────────────────────────────────────────────────────
  void setSeriesType(MrnDropdownOption? v) { selectedSeriesType = v; update(); }
  void setSite(MrnDropdownOption? v) {
    selectedSite = v;
    // Re-fetch work orders with both ids
    fetchWorkOrders(
      partyId: int.tryParse(selectedParty?.id ?? '0') ?? 0,
      siteId: int.tryParse(v?.id ?? '0') ?? 0,
    );
    update();
  }
  void setGodown(MrnDropdownOption? v) { selectedGodown = v; update(); }
  void setQcRequired(String v) { selectedQcRequired = v; update(); }
  void setCustomerPo(MrnDropdownOption? v) { selectedCustomerPo = v; update(); }
  void setJobType(MrnDropdownOption? v) { selectedJobType = v; update(); }
  void setWorkOrder(MrnDropdownOption? v) { selectedWorkOrder = v; update(); }

  void toggleAttachmentType(MrnAttachmentType type) {
    if (selectedAttachmentTypes.contains(type)) {
      selectedAttachmentTypes.remove(type);
    } else {
      selectedAttachmentTypes.add(type);
    }
    update();
  }

  String get attachmentTypeLabel {
    if (selectedAttachmentTypes.isEmpty) return 'None selected';
    return selectedAttachmentTypes.map((t) {
      switch (t) {
        case MrnAttachmentType.bill: return 'Bill';
        case MrnAttachmentType.challan: return 'Challan';
      }
    }).join(', ');
  }

  // ── Financial year string (e.g. "2026-27") ────────────────────────────────
  // ✅ FIXED — e.g. May 2026 → "2026-27"
  String get currentYearId {
    final now = DateTime.now();
    final fyStart = now.month >= 4 ? now.year : now.year - 1;
    final fyEnd = fyStart + 1;
    // Last 2 digits of fyEnd
    final fyEndShort = fyEnd.toString().substring(2);
    return '$fyStart-$fyEndShort'; // "2026-27"
  }
  void setPaidType(MrnDropdownOption? v) {
    selectedPaidType = v;
    selectedPaidBy = null; // reset paid by on type change
    if (v?.id == 'Employee') {
      fetchPaidByEmployees();
    } else {
      paidByList = [];
    }
    update();
  }

  void setPaidBy(MrnDropdownOption? v) {
    selectedPaidBy = v;
    update();
  }


  Future<void> fetchPaidByEmployees() async {
    isLoadingPaidBy = true;
    update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('employee'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        paidByList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Paid By', '$e');
    } finally {
      isLoadingPaidBy = false;
      update();
    }
  }


  // ── Date pickers ───────────────────────────────────────────────────────────
  Future<void> _pickDate(BuildContext ctx, TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: AppConst.calenderFirstDate,
      lastDate: AppConst.calenderLastDate,
      builder: (c, child) => Theme(
        data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: newBlueColor)),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
      update();
    }
  }

  Future<void> pickMrnDate(BuildContext ctx) => _pickDate(ctx, mrnDateCtrl);
  Future<void> pickBillDate(BuildContext ctx) => _pickDate(ctx, billDateCtrl);
  Future<void> pickChallanDate(BuildContext ctx) => _pickDate(ctx, challanDateCtrl);
  Future<void> pickGrnDate(BuildContext ctx) => _pickDate(ctx, grnDateCtrl);

  // ── Attachments ────────────────────────────────────────────────────────────
  Future<void> pickBillFromCamera() async => _pickImageCamera(MrnAttachmentType.bill);
  Future<void> pickBillFromGallery() async => _pickImageGallery(MrnAttachmentType.bill);
  Future<void> pickBillFile() async => _pickRealFile(MrnAttachmentType.bill);
  Future<void> pickChallanFile() async => _pickRealFile(MrnAttachmentType.challan);
  Future<void> pickChallanFromCamera() async => _pickImageCamera(MrnAttachmentType.challan);
  Future<void> pickChallanFromGallery() async => _pickImageGallery(MrnAttachmentType.challan);


  void removeBillAttachment(String id) {
    billAttachments.removeWhere((d) => d.id == id);
    update();
  }

  void removeChallanAttachment(String id) {
    challanAttachments.removeWhere((d) => d.id == id);
    update();
  }

  Future<void> _pickRealFile(MrnAttachmentType type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      if (result != null) {
        for (final pf in result.files) {
          if (pf.path != null) {
            final file = File(pf.path!);
            final bytes = await file.length();
            _addAttachment(
              pf.path!,
              pf.extension?.toLowerCase() == 'pdf' ? 'pdf' : 'image',
              'File',
              type,
              overrideName: pf.name,
              overrideSize: _formatBytes(bytes),
            );
          }
        }
      }
    } catch (e) {
      ShowMessage.showSnackBar('File', 'Could not pick file: $e');
    }
  }

// ── Also fix gallery to support multiple images ────────────────────────────
  Future<void> _pickImageGallery(MrnAttachmentType type) async {
    try {
      final xfiles = await picker.pickMultiImage(imageQuality: 75);
      for (final f in xfiles) {
        final file = File(f.path);
        final bytes = await file.length();
        _addAttachment(
          f.path,
          'image',
          'Gallery',
          type,
          overrideSize: _formatBytes(bytes),
        );
      }
    } catch (e) {
      ShowMessage.showSnackBar('Gallery', 'Could not open gallery: $e');
    }
  }

// ── Replace _fileSize with _formatBytes ────────────────────────────────────
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }


  Future<void> _pickImageCamera(MrnAttachmentType type) async {
    try {
      final xfile = await picker.pickImage(
          source: ImageSource.camera, imageQuality: 75);
      if (xfile != null) {
        final bytes = await File(xfile.path).length();
        _addAttachment(
          xfile.path,
          'image',
          'Camera',
          type,
          overrideSize: _formatBytes(bytes),
        );
      }
    } catch (e) {
      ShowMessage.showSnackBar('Camera', 'Could not open camera: $e');
    }
  }


  void _addAttachment(String path, String type, String source,
      MrnAttachmentType attachmentType,
      {String? overrideName, String? overrideSize}) {
    final file = File(path);
    final doc = MrnDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: overrideName ?? path.split('/').last,
      filePath: path,
      fileType: type,
      fileSize: overrideSize ?? _fileSize(file),
      attachmentType: attachmentType,
      source: source,
      uploadedAt: DateTime.now(),
    );
    if (attachmentType == MrnAttachmentType.bill) {
      billAttachments.add(doc);
    } else {
      challanAttachments.add(doc);
    }
    update();
  }

  // ── Step 2: PO selection ───────────────────────────────────────────────────
  // Future<void> togglePO(MrnPOItem po) async {
  //   po.isSelected = !po.isSelected;
  //   update();
  //   if (po.isSelected) {
  //     await _loadItemsForPO(po.poNumber);
  //   } else {
  //     itemLines.removeWhere((i) => i.orderNo == po.poNumber);
  //     update();
  //   }
  // }
  // Future<void> _loadItemsForPO(String poNumber) async {
  //   // Find the matching PO from the list
  //   final po = poList.firstWhereOrNull((p) => p.orderid.toString() == poNumber || p.orderno == poNumber);
  //   if (po == null) return;
  //
  //   isLoadingItems = true;
  //   update();
  //   try {
  //     final req = GetPendingPoRequest(
  //       compid:   homeController.currentUserData?.compId ?? 0,
  //       branchid: homeController.currentUserData?.branchId ?? 0,
  //       userid:   homeController.currentUserData?.userid ?? 0,
  //       partyid:  int.tryParse(selectedParty?.id ?? '0') ?? 0,
  //       siteid:   int.tryParse(selectedSite?.id  ?? '0') ?? 0,
  //       orderid:  po.orderid.toString(),
  //       stockid:  po.stockid,
  //     );
  //     final res = await api.getPendingPoItems(req);
  //     if ((res.status == 200 || res.success == true) &&
  //         res.data != null && res.data!.isNotEmpty) {
  //       final loaded = res.data!
  //           .map((raw) => raw.toItemLine(poNumber: po.orderid.toString()))
  //           .toList();
  //       for (final item in loaded) {
  //         if (!itemLines.any((i) => i.itemId == item.itemId)) {
  //           itemLines.add(item);
  //         }
  //       }
  //     } else {
  //       ShowMessage.showSnackBar('Items', res.message ?? 'No items found for this PO');
  //     }
  //   } catch (e) {
  //     ShowMessage.showSnackBar('Error', 'Failed to load items: $e');
  //   } finally {
  //     isLoadingItems = false;
  //     update();
  //   }
  // }

  // ── Item interactions ──────────────────────────────────────────────────────
  void toggleItemExpanded(MrnItemLine item) {
    item.isExpanded = !item.isExpanded;
    update();
  }

  void setReceivedQty(MrnItemLine item, double qty) {
    final double clamped = qty.clamp(0.0, item.maxReceivable).toDouble();
    if (qty > item.maxReceivable) {
      ShowMessage.showSnackBar('Quantity Limit',
          'Max receivable is ${item.maxReceivable.toInt()} ${item.unit}');
    }
    item.receiveNowQty = clamped;
    update();
  }

  void increaseQty(MrnItemLine item) {
    if (item.receiveNowQty < item.maxReceivable) {
      item.receiveNowQty++;
      update();
    } else {
      ShowMessage.showSnackBar('Limit Reached',
          'Cannot exceed PO balance of ${item.maxReceivable.toInt()} ${item.unit}');
    }
  }

  void decreaseQty(MrnItemLine item) {
    if (item.receiveNowQty > 0) {
      item.receiveNowQty--;
      update();
    }
  }

  void setItemGodown(MrnItemLine item, MrnDropdownOption? godown) {
    item.selectedGodownId = godown?.id;
    update();
  }

  void setItemRemarks(MrnItemLine item, String val) {
    item.remarks = val;
    update();
  }

  void removeItem(MrnItemLine item) {
    itemLines.remove(item);
    update();
  }

  void resetMakeSelection() {
    makeList = [];
    update();
  }

  String effectiveGodownLabel(MrnItemLine item) {
    if (item.selectedGodownId != null) {
      return godownList
          .firstWhereOrNull((g) => g.id == item.selectedGodownId)
          ?.label ??
          selectedGodown?.label ??
          '—';
    }
    return selectedGodown?.label ?? '—';
  }

  // ── Direct purchase: add item ──────────────────────────────────────────────
  void addDirectItem({
    required String itemName,
    required String itemCode,
    required String unit,
    required String make,
    required String godownId,
    required String godownLabel,
    required double qty,
    required double rate,
    required double gstPct,
    required double discount,
    required String remarks,
  }) {
    itemLines.add(MrnItemLine(
      itemId: itemCode,
      itemName: itemName,
      itemCode: itemCode,
      unit: unit,
      source: 'Direct',
      orderNo: '',
      poQty: qty,
      previouslyReceivedQty: 0,
      receiveNowQty: qty,
      rate: rate,
      discountPercent: (qty * rate) > 0 ? (discount / (qty * rate) * 100) : 0,
      gstPercent: gstPct,
      selectedGodownId: godownId,
      remarks: remarks,
    ));
    update();
  }

  void togglePOSelection(PendingPoItem po) {
    for (final p in poList) {
      p.isSelected = false;
    }
    po.isSelected = true;
    processingPo = po;
    // Clear any previously loaded items when user changes PO selection
    itemLines.clear();
    update();
  }



  // ── File upload helper ─────────────────────────────────────────────────────
  Future<String> _uploadAttachments(List<MrnDocument> docs) async {
    if (docs.isEmpty) return '';

    final List<String> uploadedNames = [];

    for (final doc in docs) {
      // Skip mock/dummy files (no real path)
      if (doc.filePath.isEmpty) continue;

      try {
        final res = await ReimbursementRepo.uploadReimbursementFile(doc.filePath);

        if (res.status == true && res.statusCode == 200) {
          final jsonData = res.data as Map<String, dynamic>?;
          // ✅ Same extraction pattern as PaymentRequestController
          final filename = jsonData?['data']?['filename'] as String?
              ?? jsonData?['filename'] as String?
              ?? '';

          if (filename.isNotEmpty) {
            uploadedNames.add(filename);
          } else {
            if (kDebugMode) print('MRN upload: filename empty for ${doc.fileName}');
          }
        } else {
          ShowMessage.showSnackBar(
              'Upload Failed', 'Could not upload ${doc.fileName}');
        }
      } catch (e) {
        if (kDebugMode) print('MRN upload error for ${doc.fileName}: $e');
        ShowMessage.showSnackBar('Upload Error', '${doc.fileName}: $e');
      }
    }

    // ✅ Multiple files → comma separated (same as payment request)
    return uploadedNames.join(',');
  }



  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> submitMRN() async {
    // Validations
    if (partyNameCtrl.text.trim().isEmpty) {
      ShowMessage.showSnackBar('Validation', 'Please select a party'); return;
    }
    if (selectedSite == null) {
      ShowMessage.showSnackBar('Validation', 'Please select a site'); return;
    }
    if (itemLines.isEmpty) {
      ShowMessage.showSnackBar('Validation', 'Please add at least one item'); return;
    }
    if (itemLines.any((i) => i.receiveNowQty <= 0)) {
      ShowMessage.showSnackBar('Validation', 'All items must have qty > 0'); return;
    }

    setBusy(true);
    try {

      // ── Step 1: Upload bill attachments ───────────────────────────────
      final billFileStr = await _uploadAttachments(billAttachments);

      // ── Step 2: Upload challan attachments ────────────────────────────
      final challanFileStr = await _uploadAttachments(challanAttachments);
      // ── Parse dates to ISO ──────────────────────────────────────────────
      DateTime parseDate(String d) {
        try { return DateFormat('dd/MM/yyyy').parse(d); }
        catch (_) { return DateTime.now(); }
      }

      // ── Build items list ────────────────────────────────────────────────
      final items = itemLines.map((i) => {
        'itemname':        i.itemName,
        'itemid':          int.tryParse(i.itemId) ?? 0,
        'rate':            i.rate,
        'quantity':        i.receiveNowQty,
        'amount':          i.amount,
        'gstpercent':      i.gstPercent,
        'gstamount':       i.gstAmount,
        'discountpercent': i.discountPercent,
        'discountamount':  i.discountAmount,
        'specification':   i.remarks,
        'make':            i.make,
        'makeid':          i.makeId,
        'unitid':          i.unitId,
        'godownid':        int.tryParse(
            i.selectedGodownId ?? selectedGodown?.id ?? '0'
        ) ?? 0,
        'poid':            processingPo?.orderid ?? 0,
        'transid':         i.transId,
        'stockqty':        i.receiveNowQty,
        'sgst':            0,
        'sgstamt':         0,
        'cgst':            0,
        'cgstamt':         0,
        'igst':            0,
        'igstamt':         0,
        'batchno':         i.batchNo,
        'expirydate':      '',
        'manufacturedate': '',
        'uniqueid':        i.uniqueId,
      }).toList();

      // ── Build request body ────────────────────────────────────────────
      final body = {
        'stockid':          0,
        'type':             selectedSource == MrnSourceType.purchaseOrder ? 'PO' : 'Direct',
        'pono':             processingPo?.orderno ?? '',
        'seriesid':         int.tryParse(selectedSeriesType?.id ?? '0') ?? 0,
        'receiptdate':      parseDate(mrnDateCtrl.text).toIso8601String(),
        'partyname':        partyNameCtrl.text.trim(),
        'partyid':          int.tryParse(selectedParty?.id ?? '0') ?? 0,
        'billno':           billNoCtrl.text.trim(),
        'godownid':         int.tryParse(selectedGodown?.id ?? '0') ?? 0,
        'receivedby':       receivedByName,
        'totalweight':      0,
        'description':      reviewRemarksCtrl.text.trim(),
        'lotno':            lotNoCtrl.text.trim(),
        'grnno':            grnNoCtrl.text.trim(),
        'grndate':          parseDate(grnDateCtrl.text).toIso8601String(),
        'totalamount':      subtotal,
        'totalquantity':    itemLines.fold(0.0, (s, i) => s + i.receiveNowQty),
        'poid':             processingPo?.orderid ?? 0,
        'qcstatus':         selectedQcRequired,
        'compid':           homeController.currentUserData?.compId   ?? 0,
        'branchid':         homeController.currentUserData?.branchId ?? 0,
        'userid':           homeController.currentUserData?.userid   ?? 0,
        'yearid':           currentYearId,
        'ledgertrans':      '',
        'grandtotal':       grandTotalRounded,
        'roundoff':         roundOff,
        'menuid':           0,
        'totaltax':         totalGst,
        'updateinvoiceid':  0,
        'freightmode':      '',
        'freightmodeid':    0,
        'billdate':         parseDate(billDateCtrl.text).toIso8601String(),
        'othervaluetaxxml': '',
        'mrntype':          '',
        'gateentryNo':      gateEntryNoCtrl.text.trim(),
        'billfile':         billFileStr,
        'filetypeId':       billAttachments.isNotEmpty ? 1 : 0,
        'dcno':             challanNoCtrl.text.trim(),
        'dcdate':           parseDate(challanDateCtrl.text).toIso8601String(),
        'dcfile':           challanFileStr,
        'reason':           reasonNACtrl.text.trim(),
        'siteid':           int.tryParse(selectedSite?.id ?? '0') ?? 0,
        'paidbyid':         int.tryParse(selectedPaidBy?.id ?? '0') ?? 0,
        'paidby':           selectedPaidBy?.label ?? '',
        'paidtype':         selectedPaidType?.label ?? '',
        'customerpoid':     int.tryParse(selectedCustomerPo?.id ?? '0') ?? 0,
        'jobtypeid':        int.tryParse(selectedJobType?.id ?? '0') ?? 0,
        'mrnitems':         items,
      };

// ── Pretty-print log matching exact API schema ────────────────────
      if (kDebugMode) {
        const encoder = JsonEncoder.withIndent('  ');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📦 MRN SUBMIT PAYLOAD');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print(encoder.convert(body));
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      final res = await api.saveMrnEntry(body);
      if (res.status == 200 || res.success == true) {
        ShowMessage.showSnackBar('Success',
            res.message ?? 'MRN saved successfully');
        Get.back();
      } else {
        ShowMessage.showSnackBar('Error',
            res.message ?? 'Failed to save MRN');
      }
    } catch (e) {
      ShowMessage.showSnackBar('Error', '$e');
    } finally {
      setBusy(false);
    }
  }

  // ── Source label ───────────────────────────────────────────────────────────
  String sourceLabel(MrnSourceType s) {
    switch (s) {
      case MrnSourceType.purchaseOrder:  return 'Purchase Order';
      case MrnSourceType.directPurchase: return 'Direct Purchase';
    }
  }

  // ── Base API body ──────────────────────────────────────────────────────────
  Map<String, dynamic> _mrnDropdownBody(String type, {
    int partyId = 0,
    int siteId = 0,
    int dependentId = 0,
  }) =>
      {
        'type': type,
        'compid': homeController.currentUserData?.compId ?? 0,
        'branchid': homeController.currentUserData?.branchId ?? 0,
        'userid': homeController.currentUserData?.userid ?? 0,
        'partyid': partyId,
        'siteid': siteId,
        'dependentid': dependentId,
      };

  // ── Fetch all dropdowns ────────────────────────────────────────────────────
  Future<void> _fetchAllDropdowns() async {
    await Future.wait([
      fetchSeriesTypes(),
      fetchSites(),
      fetchGodowns(),
    //  fetchPaidTypes(),
      fetchCustomerPOs(),
      fetchJobTypes(),
      fetchWorkOrders(),
      fetchDirectItems(),
      fetchUnits(),
      fetchMakes(),
      fetchParties(),
      fetchAddresses(),
      _loadPOList(),
    ]);
  }

  // ── Individual fetch methods (real API) ────────────────────────────────────
  Future<void> fetchSeriesTypes() async {
    isLoadingSeriesType = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('series'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        seriesTypeList = res.data!;
        if (seriesTypeList.isNotEmpty) selectedSeriesType = seriesTypeList.first;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Series', '$e');
    } finally { isLoadingSeriesType = false; update(); }
  }

  Future<void> fetchSites({int partyId = 0}) async {
    isLoadingSite = true;
    selectedSite = null; // reset on party change
    update();
    try {
      final res = await api.getMrnDropdownList(
        _mrnDropdownBody('Site', partyId: partyId),
      );
      if ((res.status == 200 || res.success == true) && res.data != null) {
        siteList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Site', '$e');
    } finally {
      isLoadingSite = false;
      update();
    }
  }

  Future<void> fetchGodowns() async {
    isLoadingGodown = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('Godown'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        godownList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Godown', '$e');
    } finally { isLoadingGodown = false; update(); }
  }


  Future<void> fetchCustomerPOs() async {
    isLoadingCustomerPo = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('customerorder'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        customerPoList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('CustomerPO', '$e');
    } finally { isLoadingCustomerPo = false; update(); }
  }

  Future<void> fetchJobTypes() async {
    isLoadingJobType = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('Jobtype'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        jobTypeList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('JobType', '$e');
    } finally { isLoadingJobType = false; update(); }
  }

  Future<void> fetchWorkOrders({int partyId = 0, int siteId = 0}) async {
    isLoadingWorkOrder = true;
    update();
    try {
      final res = await api.getMrnDropdownList(
        _mrnDropdownBody('workorder', partyId: partyId, siteId: siteId),
      );
      if ((res.status == 200 || res.success == true) && res.data != null) {
        workOrderList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('WorkOrder', '$e');
    } finally {
      isLoadingWorkOrder = false;
      update();
    }
  }

  Future<void> fetchDirectItems() async {
    isLoadingDirectItems = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('Item'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        directItemList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Items', '$e');
    } finally { isLoadingDirectItems = false; update(); }
  }

  Future<void> fetchUnits() async {
    isLoadingUnit = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('Unit'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        unitList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Unit', '$e');
    } finally { isLoadingUnit = false; update(); }
  }

  Future<void> fetchMakes({int dependentId = 0}) async {
    isLoadingMake = true;
    update();
    try {
      final res = await api.getMrnDropdownList(
        _mrnDropdownBody('Brand', dependentId: dependentId),
      );
      if ((res.status == 200 || res.success == true) && res.data != null) {
        makeList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Brand', '$e');
    } finally {
      isLoadingMake = false;
      update();
    }
  }

  Future<void> fetchParties() async {
    isLoadingParty = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('Party'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        partyList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('Party', '$e');
    } finally { isLoadingParty = false; update(); }
  }

  Future<void> fetchAddresses() async {
    isLoadingAddresses = true; update();
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(milliseconds: 300));
      shippingAddress = MrnAddress(
        label: 'Shipping',
        line1: 'Plot No. 12, MIDC Industrial Area',
        line2: 'Taloja Phase II',
        city: 'Navi Mumbai',
        state: 'Maharashtra',
        pincode: '410208',
      );
      billingAddress = MrnAddress(
        label: 'Billing',
        line1: '4th Floor, Tower B, Infinity IT Park',
        line2: 'DLF Cyber City',
        city: 'Gurugram',
        state: 'Haryana',
        pincode: '122002',
      );
    } finally {
      isLoadingAddresses = false; update();
    }
  }

  Future<void> _loadPOList() async {
    if (selectedSource != MrnSourceType.purchaseOrder) return;
    isLoadingPO = true;
    update();
    try {
      // Using the real getPendingPoList API (stockid=0 = PO list)
      final req = GetPendingPoRequest(
        compid:   homeController.currentUserData?.compId ?? 0,
        branchid: homeController.currentUserData?.branchId ?? 0,
        userid:   homeController.currentUserData?.userid ?? 0,
        partyid:  int.tryParse(selectedParty?.id ?? '0') ?? 0,
        siteid:   int.tryParse(selectedSite?.id  ?? '0') ?? 0,
        orderid:  '',
        stockid:  0,
      );
      final res = await api.getPendingPoList(req);
      if ((res.status == 200 || res.success == true) && res.data != null) {
        poList = res.data!; // List<PendingPoItem> ✅
      } else {
        poList = [];
      }
    } catch (e) {
      poList = [];
      ShowMessage.showSnackBar('PO List', '$e');
    } finally {
      isLoadingPO = false;
      update();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoggedInUser() {
    // TODO: Pull from session
    receivedByName = homeController.currentUserData?.name ?? 'User';
  }

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

  Future<void> fetchPendingPoList() async {
    isLoadingPO = true;
    poList.clear();
    processingPo = null;
    update();
    try {
      final req = GetPendingPoRequest(
        compid:   homeController.currentUserData?.compId ?? 0,
        branchid: homeController.currentUserData?.branchId ?? 0,
        userid:   homeController.currentUserData?.userid ?? 0,
        partyid:  int.tryParse(selectedParty?.id ?? '0') ?? 0,
        siteid:   int.tryParse(selectedSite?.id  ?? '0') ?? 0,
        orderid:  '',
        stockid:  0, // 0 = PO list, not items
      );
      final res = await api.getPendingPoList(req);
      if ((res.status == 200 || res.success == true) && res.data != null) {
        poList = res.data!;
      } else {
        poList = [];
        ShowMessage.showSnackBar(
            'PO List', res.message ?? 'No pending POs found');
      }
    } catch (e) {
      poList = [];
      ShowMessage.showSnackBar('PO List', '$e');
    } finally {
      isLoadingPO = false;
      update();
    }
  }

  Future<void> processSelectedPO() async {
    if (processingPo == null) {
      ShowMessage.showSnackBar('Select PO', 'Please select a PO first');
      return;
    }
    isLoadingItems = true;
    itemLines.clear();
    update();
    try {
      final req = ProcessPendingPoRequest(
        type:     1,
        compid:   homeController.currentUserData?.compId   ?? 0,
        branchid: homeController.currentUserData?.branchId ?? 0,
        userid:   homeController.currentUserData?.userid   ?? 0,
        partyid:  int.tryParse(selectedParty?.id ?? '0')   ?? 0,
        siteid:   int.tryParse(selectedSite?.id  ?? '0')   ?? 0,
        orderid:  processingPo!.orderid.toString(), // ✅ "27658"
        stockid:  0,
      );

      final res = await api.processPoItems(req);

      if ((res.status == 200 || res.success == true) &&
          res.data != null &&
          res.data!.isNotEmpty) {
        itemLines = res.data!
            .map((item) => item.toItemLine(
          poNumber: processingPo!.orderno.isNotEmpty
              ? processingPo!.orderno
              : processingPo!.orderid.toString(),
        ))
            .toList();
      } else {
        ShowMessage.showSnackBar(
            'No Items', res.message ?? 'No pending items found for this PO');
      }
    } catch (e) {
      ShowMessage.showSnackBar('Items', '$e');
    } finally {
      isLoadingItems = false;
      update();
    }
  }


}