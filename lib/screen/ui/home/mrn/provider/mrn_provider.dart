// // lib/providers/mrn_provider.dart
// import 'package:flutter/foundation.dart';
// import '../model/mrn_models.dart';
// import '../services/mrn_service.dart';
//
// class MRNProvider extends ChangeNotifier {
//   final _service = MRNService();
//
//   List<MRN>          _mrns           = [];
//   bool               _loading        = false;
//   bool               _loadingMore    = false;
//   bool               _hasMore        = true;
//   int                _page           = 1;
//   String?            _error;
//   MRN?               _selected;
//   bool               _detailLoading  = false;
//   MRNFilterOptions?  _filterOptions;
//   bool               _dropdownLoading = false;
//
//   // Active filters
//   int?      _filterPartyId;
//   int?      _filterSiteId;
//   int?      _filterJobTypeId;
//   int?      _filterStatusId;
//   String?   _searchQuery;
//   DateTime? _fromDate;
//   DateTime? _toDate;
//
//   //  Getters 
//   List<MRN>         get mrns            => _mrns;
//   bool              get loading          => _loading;
//   bool              get loadingMore      => _loadingMore;
//   bool              get hasMore          => _hasMore;
//   String?           get error            => _error;
//   MRN?              get selected         => _selected;
//   bool              get detailLoading    => _detailLoading;
//   MRNFilterOptions? get filterOptions    => _filterOptions;
//   bool              get dropdownLoading  => _dropdownLoading;
//
//   bool get hasActiveFilters =>
//       _filterPartyId   != null ||
//           _filterSiteId    != null ||
//           _filterJobTypeId != null ||
//           _filterStatusId  != null ||
//           _searchQuery     != null ||
//           _fromDate        != null ||
//           _toDate          != null;
//
//   // Convenience getters — PascalCase keys from API
//   List<Map<String, dynamic>> get parties  =>
//       _filterOptions?.parties  ?? [];
//   List<Map<String, dynamic>> get sites    =>
//       _filterOptions?.sites    ?? [];
//   List<Map<String, dynamic>> get jobTypes =>
//       _filterOptions?.jobTypes ?? [];
//   List<Map<String, dynamic>> get godowns  =>
//       _filterOptions?.godowns  ?? [];
//
//   // Legacy aliases so existing screens don't break
//   List<Map<String, dynamic>> get suppliers  => parties;
//   List<Map<String, dynamic>> get warehouses => godowns;
//
//   //  Load list 
//   Future<void> loadMRNs({bool refresh = false}) async {
//     if (_loading) return;
//     if (refresh) {
//       _page    = 1;
//       _hasMore = true;
//       _mrns    = [];
//       _error   = null;
//     }
//     _loading = true;
//     notifyListeners();
//
//     final result = await _service.getMRNs(
//       page:       _page,
//       pageSize:   20,
//       partyId:    _filterPartyId,
//       siteId:     _filterSiteId,
//       jobTypeId:  _filterJobTypeId,
//       statusId:   _filterStatusId,
//       search:     _searchQuery,
//       fromDate:   _fromDate,
//       toDate:     _toDate,
//     );
//
//     _loading = false;
//     if (result.success && result.data != null) {
//       if (_page == 1) {
//         _mrns = result.data!.items;
//       } else {
//         _mrns.addAll(result.data!.items);
//       }
//       _hasMore = result.data!.hasNextPage;
//       _page++;
//     } else {
//       _error = result.message;
//     }
//     notifyListeners();
//   }
//
//   //  Load more 
//   Future<void> loadMore() async {
//     if (_loadingMore || !_hasMore) return;
//     _loadingMore = true;
//     notifyListeners();
//
//     final result = await _service.getMRNs(
//       page:      _page,
//       pageSize:  20,
//       partyId:   _filterPartyId,
//       siteId:    _filterSiteId,
//       jobTypeId: _filterJobTypeId,
//       statusId:  _filterStatusId,
//       search:    _searchQuery,
//       fromDate:  _fromDate,
//       toDate:    _toDate,
//     );
//
//     _loadingMore = false;
//     if (result.success && result.data != null) {
//       _mrns.addAll(result.data!.items);
//       _hasMore = result.data!.hasNextPage;
//       _page++;
//     }
//     notifyListeners();
//   }
//
//   //  Load single MRN 
//   Future<void> loadMRN(String id) async {
//     _detailLoading = true;
//     _selected      = null;
//     notifyListeners();
//
//     final result = await _service.getMRN(id);
//     _detailLoading = false;
//     if (result.success) _selected = result.data;
//     notifyListeners();
//   }
//
//   //  Create 
//   Future<String?> createMRN(CreateMRNRequest request) async {
//     final result = await _service.createMRN(request);
//     if (result.success) {
//       await loadMRNs(refresh: true);
//       return null;
//     }
//     return result.message ?? 'Failed to create MRN';
//   }
//
//   //  Update status 
//   Future<String?> updateStatus(
//       String id,
//       int    statusCode, {
//         String? remarks,
//       }) async {
//     final result = await _service.updateMRNStatus(
//         id, statusCode, remarks: remarks);
//     if (result.success) {
//       await loadMRN(id);
//       await loadMRNs(refresh: true);
//       return null;
//     }
//     return result.message ?? 'Failed to update status';
//   }
//
//   //  Delete 
//   Future<String?> deleteMRN(String id) async {
//     final result = await _service.deleteMRN(id);
//     if (result.success) {
//       _mrns.removeWhere((m) => m.mrnId == id);
//       notifyListeners();
//       return null;
//     }
//     return result.message ?? 'Failed to delete';
//   }
//
//   //  Upload attachment 
//   Future<String?> uploadAttachment(
//       String mrnId,
//       String filePath,
//       String fileName, {
//         String category = 'DOCUMENT',
//       }) async {
//     final result = await _service.uploadAttachment(
//         mrnId, filePath, fileName, category: category);
//     if (result.success) {
//       await loadMRN(mrnId);
//       return null;
//     }
//     return result.message ?? 'Failed to upload';
//   }
//
//   //  Load dropdowns 
//   Future<void> loadDropdowns({bool force = false}) async {
//     if (_filterOptions != null && !force) return;
//     _dropdownLoading = true;
//     notifyListeners();
//
//     final result = await _service.getFilterOptions();
//     _dropdownLoading = false;
//     if (result.success) {
//       _filterOptions = result.data;
//     }
//     notifyListeners();
//   }
//
//   //  Filters 
//   void setFilters({
//     int?      partyId,
//     int?      siteId,
//     int?      jobTypeId,
//     int?      statusId,
//     DateTime? fromDate,
//     DateTime? toDate,
//   }) {
//     _filterPartyId   = partyId;
//     _filterSiteId    = siteId;
//     _filterJobTypeId = jobTypeId;
//     _filterStatusId  = statusId;
//     _fromDate        = fromDate;
//     _toDate          = toDate;
//     loadMRNs(refresh: true);
//   }
//
//   void setSearch(String q) {
//     _searchQuery = q.isEmpty ? null : q;
//     loadMRNs(refresh: true);
//   }
//
//   void clearFilters() {
//     _filterPartyId   = null;
//     _filterSiteId    = null;
//     _filterJobTypeId = null;
//     _filterStatusId  = null;
//     _searchQuery     = null;
//     _fromDate        = null;
//     _toDate          = null;
//     loadMRNs(refresh: true);
//   }
// }