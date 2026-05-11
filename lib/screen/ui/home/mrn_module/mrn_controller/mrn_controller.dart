import 'dart:io';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/utils/app_constant.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  List<MrnDropdownOption> paidTypeList = [];
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

  // ── Step 2: PO list & Items ────────────────────────────────────────────────
  List<MrnPOItem> poList = [];
  bool isLoadingPO = false;
  List<MrnItemLine> itemLines = [];
  bool isLoadingItems = false;
  String? expandedPoNumber;

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

  final ImagePicker picker = ImagePicker();

  // ── Init / Dispose ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    mrnDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    billDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    challanDateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
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
    super.onClose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void goToStep(int step) {
    if (step < 0 || step > 2) return;
    currentStep = step;
    pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    update();
  }

  void nextStep() => goToStep(currentStep + 1);
  void prevStep() => goToStep(currentStep - 1);

  // ── Source ─────────────────────────────────────────────────────────────────
  void setSource(MrnSourceType src) {
    selectedSource = src;
    itemLines.clear();
    poList.clear();
    if (src == MrnSourceType.purchaseOrder || src == MrnSourceType.grn) {
      _loadPOList();
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
  void setPaidType(MrnDropdownOption? v) { selectedPaidType = v; update(); }
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

  // ── Attachments ────────────────────────────────────────────────────────────
  Future<void> pickBillFromCamera() async => _pickImageCamera(MrnAttachmentType.bill);
  Future<void> pickBillFromGallery() async => _pickImageGallery(MrnAttachmentType.bill);
  Future<void> pickBillFile() async => _pickFileMock(MrnAttachmentType.bill);

  Future<void> pickChallanFromCamera() async => _pickImageCamera(MrnAttachmentType.challan);
  Future<void> pickChallanFromGallery() async => _pickImageGallery(MrnAttachmentType.challan);
  Future<void> pickChallanFile() async => _pickFileMock(MrnAttachmentType.challan);

  void removeBillAttachment(String id) {
    billAttachments.removeWhere((d) => d.id == id);
    update();
  }

  void removeChallanAttachment(String id) {
    challanAttachments.removeWhere((d) => d.id == id);
    update();
  }

  Future<void> _pickImageCamera(MrnAttachmentType type) async {
    try {
      final xfile = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
      if (xfile != null) _addAttachment(xfile.path, 'image', 'Camera', type);
    } catch (e) {
      ShowMessage.showSnackBar('Camera', 'Could not open camera: $e');
    }
  }

  Future<void> _pickImageGallery(MrnAttachmentType type) async {
    try {
      final xfiles = await picker.pickMultiImage(imageQuality: 75);
      for (final f in xfiles) {
        _addAttachment(f.path, 'image', 'Gallery', type);
      }
    } catch (e) {
      ShowMessage.showSnackBar('Gallery', 'Could not open gallery: $e');
    }
  }

  Future<void> _pickFileMock(MrnAttachmentType type) async {
    final label = type == MrnAttachmentType.bill
        ? 'Bill_${billNoCtrl.text.isEmpty ? "file" : billNoCtrl.text}'
        : 'Challan_${challanNoCtrl.text.isEmpty ? "file" : challanNoCtrl.text}';
    _addAttachment('', 'pdf', 'File', type,
        overrideName: '$label.pdf', overrideSize: '1.2 MB');
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
  Future<void> togglePO(MrnPOItem po) async {
    po.isSelected = !po.isSelected;
    update();
    if (po.isSelected) {
      await _loadItemsForPO(po.poNumber);
    } else {
      itemLines.removeWhere((i) => i.orderNo == po.poNumber);
      update();
    }
  }

  Future<void> _loadItemsForPO(String poNumber) async {
    isLoadingItems = true;
    update();
    try {
      // TODO: Replace with real API call using poNumber
      await Future.delayed(const Duration(milliseconds: 600));
      final loaded = _dummyItemsForPO(poNumber);
      for (final item in loaded) {
        if (!itemLines.any((i) => i.itemId == item.itemId)) {
          itemLines.add(item);
        }
      }
    } catch (e) {
      ShowMessage.showSnackBar('Error', 'Failed to load items: $e');
    } finally {
      isLoadingItems = false;
      update();
    }
  }

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

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> submitMRN() async {
    if (partyNameCtrl.text.trim().isEmpty) {
      ShowMessage.showSnackBar('Validation', 'Please enter party name');
      return;
    }
    if (selectedSite == null) {
      ShowMessage.showSnackBar('Validation', 'Please select a site');
      return;
    }
    if (itemLines.isEmpty) {
      ShowMessage.showSnackBar('Validation', 'Please add at least one item');
      return;
    }
    if (itemLines.any((i) => i.receiveNowQty <= 0)) {
      ShowMessage.showSnackBar(
          'Validation', 'All items must have received qty > 0');
      return;
    }
    setBusy(true);
    try {
      // TODO: Replace with actual submit API call
      await Future.delayed(const Duration(seconds: 1));
      ShowMessage.showSnackBar('Success', 'MRN $mrnNumber submitted successfully');
      Get.back();
    } catch (e) {
      ShowMessage.showSnackBar('Error', '$e');
    } finally {
      setBusy(false);
    }
  }

  // ── Source label ───────────────────────────────────────────────────────────
  String sourceLabel(MrnSourceType s) {
    switch (s) {
      case MrnSourceType.purchaseOrder: return 'Purchase Order';
      case MrnSourceType.directPurchase: return 'Direct Purchase';
      case MrnSourceType.grn: return 'GRN';
      default: return '';
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
      fetchPaidTypes(),
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

  Future<void> fetchPaidTypes() async {
    isLoadingPaidType = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('employee'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        paidTypeList = res.data!;
      }
    } catch (e) {
      ShowMessage.showSnackBar('PaidType', '$e');
    } finally { isLoadingPaidType = false; update(); }
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
    if (selectedSource != MrnSourceType.purchaseOrder &&
        selectedSource != MrnSourceType.grn) return;
    isLoadingPO = true; update();
    try {
      final res = await api.getMrnDropdownList(_mrnDropdownBody('documentlist'));
      if ((res.status == 200 || res.success == true) && res.data != null) {
        poList = res.data!
            .map((o) => MrnPOItem(
          poNumber: o.id.toString(),
          date: '',
          itemCategory: '',
          amount: 0,
          status: 'Open',
        ))
            .toList();
      }
    } catch (e) {
      ShowMessage.showSnackBar('PO List', '$e');
    } finally {
      isLoadingPO = false; update();
    }
  }

  // ── Dummy items for PO (remove once real item API is ready) ───────────────
  List<MrnItemLine> _dummyItemsForPO(String poNumber) {
    final map = {
      'PO-2026-0117': [
        MrnItemLine(itemId: 'ITM-0041', itemName: 'SS Pipe CI-115 (3.15×350MM)', itemCode: 'ITM-0041', unit: 'Nos', source: 'PO', orderNo: poNumber, poQty: 100, previouslyReceivedQty: 40, rate: 1999, discountPercent: 0, gstPercent: 18, receiveNowQty: 60),
        MrnItemLine(itemId: 'ITM-0055', itemName: 'SS Square Pipe 40×40MM', itemCode: 'ITM-0055', unit: 'Mtr', source: 'PO', orderNo: poNumber, poQty: 200, previouslyReceivedQty: 80, rate: 750, discountPercent: 0, gstPercent: 18, receiveNowQty: 120),
        MrnItemLine(itemId: 'ITM-0061', itemName: '25 mm Elbow', itemCode: 'ITM-0061', unit: 'Nos', source: 'PO', orderNo: poNumber, poQty: 42, previouslyReceivedQty: 0, rate: 85, discountPercent: 0, gstPercent: 18, receiveNowQty: 42),
        MrnItemLine(itemId: 'ITM-0062', itemName: '32 mm Elbow', itemCode: 'ITM-0062', unit: 'Nos', source: 'PO', orderNo: poNumber, poQty: 36, previouslyReceivedQty: 0, rate: 136, discountPercent: 0, gstPercent: 18, receiveNowQty: 36),
      ],
      'PO-2026-0098': [
        MrnItemLine(itemId: 'ITM-0102', itemName: 'Safety Goggles CI-115', itemCode: 'ITM-0102', unit: 'Nos', source: 'PO', orderNo: poNumber, poQty: 25, previouslyReceivedQty: 0, rate: 1200, discountPercent: 0, gstPercent: 18, receiveNowQty: 25),
        MrnItemLine(itemId: 'ITM-0103', itemName: 'Safety Helmet Red', itemCode: 'ITM-0103', unit: 'Nos', source: 'PO', orderNo: poNumber, poQty: 50, previouslyReceivedQty: 10, rate: 380, discountPercent: 0, gstPercent: 18, receiveNowQty: 40),
      ],
      'PO-2026-0074': [
        MrnItemLine(itemId: 'ITM-0088', itemName: 'Open Spanner CI-115', itemCode: 'ITM-0088', unit: 'Nos', source: 'PO', orderNo: poNumber, poQty: 50, previouslyReceivedQty: 0, rate: 850, discountPercent: 0, gstPercent: 18, receiveNowQty: 50),
        MrnItemLine(itemId: 'ITM-0199', itemName: 'Drill Bit Set HSS 10pc', itemCode: 'ITM-0199', unit: 'Set', source: 'PO', orderNo: poNumber, poQty: 20, previouslyReceivedQty: 5, rate: 450, discountPercent: 0, gstPercent: 18, receiveNowQty: 15),
      ],
    };
    return map[poNumber] ?? [];
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
}