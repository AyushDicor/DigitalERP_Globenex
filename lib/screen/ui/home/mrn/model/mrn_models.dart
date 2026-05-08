// // lib/model/mrn_models.dart
// // Plain Dart model classes — no fromJson / toJson / API / Provider logic.
//
// class MRNItem {
//   final int erpItemId;
//   final String itemName;
//   final String? itemCode;
//   final String unit;
//   final double quantity;
//   final double unitPrice;
//   final double totalPrice;
//   final double taxAmount;
//   final double sgstPercent;
//   final double cgstPercent;
//   final double igstPercent;
//
//   const MRNItem({
//     required this.erpItemId,
//     required this.itemName,
//     this.itemCode,
//     required this.unit,
//     required this.quantity,
//     required this.unitPrice,
//     required this.totalPrice,
//     this.taxAmount = 0,
//     this.sgstPercent = 0,
//     this.cgstPercent = 0,
//     this.igstPercent = 0,
//   });
// }
//
// class MRNAttachment {
//   final String fileName;
//   final String category;
//   final DateTime uploadedAt;
//   final String filePath;
//
//   const MRNAttachment({
//     required this.fileName,
//     required this.category,
//     required this.uploadedAt,
//     required this.filePath,
//   });
// }
//
// class MRN {
//   final String mrnId;
//   final String mrnNumber;
//   final DateTime mrnDate;
//   final int statusId; // 1=Draft 2=Submitted 3=Approved 4=Rejected
//   final String status;
//   final String? supplierName;
//   final String? siteName;
//   final String? warehouseName;
//   final String? customerPO;
//   final String? billNo;
//   final DateTime? billDate;
//   final String? paidByName;
//   final String createdByName;
//   final DateTime createdAt;
//   final String? remarks;
//   final int itemCount;
//   final List<MRNItem> items;
//   final List<MRNAttachment> attachments;
//   final double subTotal;
//   final double taxAmount;
//   final double deliveryCharges;
//   final double totalAmount;
//
//   const MRN({
//     required this.mrnId,
//     required this.mrnNumber,
//     required this.mrnDate,
//     required this.statusId,
//     required this.status,
//     this.supplierName,
//     this.siteName,
//     this.warehouseName,
//     this.customerPO,
//     this.billNo,
//     this.billDate,
//     this.paidByName,
//     required this.createdByName,
//     required this.createdAt,
//     this.remarks,
//     this.itemCount = 0,
//     this.items = const [],
//     this.attachments = const [],
//     this.subTotal = 0,
//     this.taxAmount = 0,
//     this.deliveryCharges = 0,
//     this.totalAmount = 0,
//   });
// }
//
// // Filter value object
// class MRNFilter {
//   final DateTime? fromDate;
//   final DateTime? toDate;
//   final int? partyId;
//   final String? partyName;
//   final int? siteId;
//   final String? siteName;
//   final int? jobTypeId;
//   final String? jobTypeName;
//
//   const MRNFilter({
//     this.fromDate,
//     this.toDate,
//     this.partyId,
//     this.partyName,
//     this.siteId,
//     this.siteName,
//     this.jobTypeId,
//     this.jobTypeName,
//   });
//
//   bool get isActive =>
//       fromDate != null ||
//           toDate != null ||
//           partyId != null ||
//           siteId != null ||
//           jobTypeId != null;
//
//   static const empty = MRNFilter();
// }
//
// //  Shared dummy data 
// class MRNDummyData {
//   static final List<MRN> mrns = [
//     MRN(
//       mrnId: '1',
//       mrnNumber: 'MRN/2026/001',
//       mrnDate: DateTime(2026, 1, 20),
//       statusId: 3,
//       status: 'Approved',
//       supplierName: 'Tata Steel Ltd.',
//       siteName: 'Site Alpha',
//       warehouseName: 'Warehouse A',
//       customerPO: 'PO-2026-001',
//       billNo: 'BILL-001',
//       billDate: DateTime(2026, 1, 18),
//       paidByName: 'Rahul Sharma',
//       createdByName: 'Anjali Mehta',
//       createdAt: DateTime(2026, 1, 20, 10, 30),
//       itemCount: 2,
//       subTotal: 45000,
//       taxAmount: 8100,
//       deliveryCharges: 500,
//       totalAmount: 53600,
//       items: [
//         MRNItem(
//           erpItemId: 101,
//           itemName: 'Steel Rod 12mm',
//           itemCode: 'SR-12',
//           unit: 'Pcs',
//           quantity: 100,
//           unitPrice: 300,
//           totalPrice: 30000,
//           taxAmount: 5400,
//           sgstPercent: 9,
//           cgstPercent: 9,
//         ),
//         MRNItem(
//           erpItemId: 102,
//           itemName: 'Steel Plate 6mm',
//           itemCode: 'SP-06',
//           unit: 'Kg',
//           quantity: 50,
//           unitPrice: 300,
//           totalPrice: 15000,
//           taxAmount: 2700,
//           sgstPercent: 9,
//           cgstPercent: 9,
//         ),
//       ],
//       attachments: [
//         MRNAttachment(
//           fileName: 'invoice_001.pdf',
//           category: 'Invoice',
//           uploadedAt: DateTime(2026, 1, 20),
//           filePath: '/attachments/invoice_001.pdf',
//         ),
//       ],
//     ),
//     MRN(
//       mrnId: '2',
//       mrnNumber: 'MRN/2026/002',
//       mrnDate: DateTime(2026, 1, 22),
//       statusId: 2,
//       status: 'Submitted',
//       supplierName: 'JSW Cement',
//       siteName: 'Site Beta',
//       warehouseName: 'Warehouse B',
//       createdByName: 'Vikram Singh',
//       createdAt: DateTime(2026, 1, 22, 9, 15),
//       itemCount: 1,
//       subTotal: 20000,
//       taxAmount: 3600,
//       deliveryCharges: 0,
//       totalAmount: 23600,
//       items: [
//         MRNItem(
//           erpItemId: 201,
//           itemName: 'OPC Cement 53 Grade',
//           itemCode: 'CEM-53',
//           unit: 'Bags',
//           quantity: 200,
//           unitPrice: 100,
//           totalPrice: 20000,
//           taxAmount: 3600,
//           sgstPercent: 9,
//           cgstPercent: 9,
//         ),
//       ],
//     ),
//     MRN(
//       mrnId: '3',
//       mrnNumber: 'MRN/2026/003',
//       mrnDate: DateTime(2026, 1, 25),
//       statusId: 1,
//       status: 'Draft',
//       supplierName: 'Hindalco Industries',
//       siteName: 'Site Alpha',
//       warehouseName: 'Warehouse A',
//       createdByName: 'Priya Nair',
//       createdAt: DateTime(2026, 1, 25, 14, 0),
//       itemCount: 3,
//       subTotal: 75000,
//       taxAmount: 13500,
//       deliveryCharges: 1000,
//       totalAmount: 89500,
//     ),
//     MRN(
//       mrnId: '4',
//       mrnNumber: 'MRN/2026/004',
//       mrnDate: DateTime(2026, 1, 27),
//       statusId: 4,
//       status: 'Rejected',
//       supplierName: 'UltraTech Cement',
//       siteName: 'Site Gamma',
//       warehouseName: '',
//       remarks: 'Quantity mismatch in bill. Please resubmit.',
//       createdByName: 'Anjali Mehta',
//       createdAt: DateTime(2026, 1, 27, 11, 45),
//       itemCount: 1,
//       subTotal: 12000,
//       taxAmount: 2160,
//       deliveryCharges: 0,
//       totalAmount: 14160,
//     ),
//   ];
//
//   static final List<Map<String, dynamic>> parties = [
//     {'PartyID': 1, 'PartyName': 'Tata Steel Ltd.'},
//     {'PartyID': 2, 'PartyName': 'JSW Cement'},
//     {'PartyID': 3, 'PartyName': 'Hindalco Industries'},
//     {'PartyID': 4, 'PartyName': 'UltraTech Cement'},
//   ];
//
//   static final List<Map<String, dynamic>> sites = [
//     {'SiteID': 1, 'SiteName': 'Site Alpha'},
//     {'SiteID': 2, 'SiteName': 'Site Beta'},
//     {'SiteID': 3, 'SiteName': 'Site Gamma'},
//   ];
//
//   static final List<Map<String, dynamic>> jobTypes = [
//     {'JobTypeID': 1, 'JobTypeName': 'Warehouse A'},
//     {'JobTypeID': 2, 'JobTypeName': 'Warehouse B'},
//     {'JobTypeID': 3, 'JobTypeName': 'Direct'},
//   ];
//
//   static final List<Map<String, dynamic>> godowns = [
//     {'GodownID': 1, 'GodownName': 'Godown A'},
//     {'GodownID': 2, 'GodownName': 'Godown B'},
//     {'GodownID': 3, 'GodownName': 'Godown C'},
//   ];
// }