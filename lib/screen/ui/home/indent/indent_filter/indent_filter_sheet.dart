// ─────────────────────────────────────────────────────────────────────────────
// indent_filter_sheet.dart
//
// Usage (inside IndentListScreen or wherever you open the sheet):
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => IndentFilterSheet(
//       items:        ctrl.indentItems,
//       activeFilter: ctrl.activeFilter,
//       onApply:      ctrl.applyFilter,
//       onReset:      ctrl.resetFilter,
//     ),
//   );
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../indent_response/indent_model.dart';
import '../indent_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FILTER MODEL
// ═══════════════════════════════════════════════════════════════════════════

class IndentFilter {
  final Set<String> requestedBy;   // maps to IndentListItem.requestBy
  final Set<String> siteNames;     // maps to IndentListItem.siteName
  final Set<String> jobTypes;      // maps to IndentListItem.jobType
  final Set<String> statuses;      // maps to IndentListItem.status
  final Set<String> priorities;    // maps to IndentListItem.priority
  final Set<String> departments;   // maps to IndentListItem.department

  const IndentFilter({
    this.requestedBy = const {},
    this.siteNames   = const {},
    this.jobTypes    = const {},
    this.statuses    = const {},
    this.priorities  = const {},
    this.departments = const {},
  });

  // ── helpers ──────────────────────────────────────────────────────────────

  bool get isActive =>
      requestedBy.isNotEmpty ||
          siteNames.isNotEmpty   ||
          jobTypes.isNotEmpty    ||
          statuses.isNotEmpty    ||
          priorities.isNotEmpty  ||
          departments.isNotEmpty;

  int get activeCount {
    int n = 0;
    if (requestedBy.isNotEmpty)  n++;
    if (siteNames.isNotEmpty)    n++;
    if (jobTypes.isNotEmpty)     n++;
    if (statuses.isNotEmpty)     n++;
    if (priorities.isNotEmpty)   n++;
    if (departments.isNotEmpty)  n++;
    return n;
  }

  IndentFilter copyWith({
    Set<String>? requestedBy,
    Set<String>? siteNames,
    Set<String>? jobTypes,
    Set<String>? statuses,
    Set<String>? priorities,
    Set<String>? departments,
  }) =>
      IndentFilter(
        requestedBy:  requestedBy  ?? this.requestedBy,
        siteNames:    siteNames    ?? this.siteNames,
        jobTypes:     jobTypes     ?? this.jobTypes,
        statuses:     statuses     ?? this.statuses,
        priorities:   priorities   ?? this.priorities,
        departments:  departments  ?? this.departments,
      );

  List<IndentListItem> apply(List<IndentListItem> all) {
    return all.where((item) {
      if (requestedBy.isNotEmpty  && !requestedBy.contains(item.requestBy))   return false;
      if (siteNames.isNotEmpty    && !siteNames.contains(item.siteName))       return false;
      if (jobTypes.isNotEmpty     && !jobTypes.contains(item.jobType))         return false;
      if (statuses.isNotEmpty     && !statuses.contains(item.status))          return false;
      if (priorities.isNotEmpty   && !priorities.contains(item.priority))      return false;
      if (departments.isNotEmpty  && !departments.contains(item.department))   return false;
      return true;
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHEET WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class IndentFilterSheet extends StatefulWidget {
  final List<IndentListItem> items;
  final IndentFilter activeFilter;
  final void Function(IndentFilter) onApply;
  final VoidCallback? onReset;

  const IndentFilterSheet({
    super.key,
    required this.items,
    required this.activeFilter,
    required this.onApply,
    this.onReset,
  });

  @override
  State<IndentFilterSheet> createState() => _IndentFilterSheetState();
}

class _IndentFilterSheetState extends State<IndentFilterSheet> {
  late IndentFilter _draft;

  // option lists built from data
  late List<String> _requestedByOptions;
  late List<String> _siteOptions;
  late List<String> _jobTypeOptions;
  late List<String> _statusOptions;
  late List<String> _priorityOptions;
  late List<String> _departmentOptions;

  // accordion expand state
  final Map<String, bool> _expanded = {
    'requestedBy': false,
    'site':        false,
    'jobType':     false,
    'status':      false,
    'priority':    false,
    'department':  false,
  };

  // search state (only for large lists)
  final Map<String, String> _search = {
    'requestedBy': '',
    'site':        '',
    'department':  '',
  };

  @override
  void initState() {
    super.initState();
    _draft = widget.activeFilter;
    _buildOptions();
  }

  void _buildOptions() {
    List<String> _unique(Iterable<String> src) =>
        src.where((s) => s.trim().isNotEmpty).toSet().toList()..sort();

    _requestedByOptions = _unique(widget.items.map((e) => e.requestBy));
    _siteOptions        = _unique(widget.items.map((e) => e.siteName));
    _jobTypeOptions     = _unique(widget.items.map((e) => e.jobType));
    _statusOptions      = _unique(widget.items.map((e) => e.status));
    _priorityOptions    = _unique(widget.items.map((e) => e.priority));
    _departmentOptions  = _unique(widget.items.map((e) => e.department));
  }

  // ── toggle helpers ──────────────────────────────────────────────────────

  void _toggleExpand(String key, bool val) =>
      setState(() => _expanded[key] = val);

  void _toggleItem(Set<String> current, String item, String field) {
    final next = Set<String>.from(current);
    next.contains(item) ? next.remove(item) : next.add(item);
    setState(() {
      switch (field) {
        case 'requestedBy':
          _draft = _draft.copyWith(requestedBy: next);
          break;
        case 'site':
          _draft = _draft.copyWith(siteNames: next);
          break;
        case 'jobType':
          _draft = _draft.copyWith(jobTypes: next);
          break;
        case 'status':
          _draft = _draft.copyWith(statuses: next);
          break;
        case 'priority':
          _draft = _draft.copyWith(priorities: next);
          break;
        case 'department':
          _draft = _draft.copyWith(departments: next);
          break;
      }
    });
  }

  // ── actions ─────────────────────────────────────────────────────────────

  void _reset() {
    setState(() {
      _draft = const IndentFilter();
      for (final k in _search.keys) _search[k] = '';
    });
    Navigator.pop(context);
    widget.onApply(const IndentFilter());
    widget.onReset?.call();
  }

  void _apply() {
    Navigator.pop(context);
    widget.onApply(_draft);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final mq    = MediaQuery.of(context);
    final count = _draft.activeCount;

    return Container(
      height: mq.size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        _header(count),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              // ── Requested By ──────────────────────────────────────────
              _Accordion(
                title:         'Requested By',
                icon:          Icons.person_outline_rounded,
                selectedCount: _draft.requestedBy.length,
                expanded:      _expanded['requestedBy']!,
                onToggle:      (v) => _toggleExpand('requestedBy', v),
                child: _Checklist(
                  options:          _requestedByOptions,
                  selected:         _draft.requestedBy,
                  search:           _search['requestedBy']!,
                  onSearchChanged:  (v) => setState(() => _search['requestedBy'] = v),
                  onToggle:         (o) => _toggleItem(_draft.requestedBy, o, 'requestedBy'),
                  showSearch:       _requestedByOptions.length > 5,
                ),
              ),
              const SizedBox(height: 8),

              // ── Site Name ─────────────────────────────────────────────
              _Accordion(
                title:         'Site Name',
                icon:          Icons.location_on_outlined,
                selectedCount: _draft.siteNames.length,
                expanded:      _expanded['site']!,
                onToggle:      (v) => _toggleExpand('site', v),
                child: _Checklist(
                  options:          _siteOptions,
                  selected:         _draft.siteNames,
                  search:           _search['site']!,
                  onSearchChanged:  (v) => setState(() => _search['site'] = v),
                  onToggle:         (o) => _toggleItem(_draft.siteNames, o, 'site'),
                  showSearch:       _siteOptions.length > 5,
                ),
              ),
              const SizedBox(height: 8),

              // ── Department ────────────────────────────────────────────
              _Accordion(
                title:         'Department',
                icon:          Icons.corporate_fare_rounded,
                selectedCount: _draft.departments.length,
                expanded:      _expanded['department']!,
                onToggle:      (v) => _toggleExpand('department', v),
                child: _Checklist(
                  options:          _departmentOptions,
                  selected:         _draft.departments,
                  search:           _search['department']!,
                  onSearchChanged:  (v) => setState(() => _search['department'] = v),
                  onToggle:         (o) => _toggleItem(_draft.departments, o, 'department'),
                  showSearch:       _departmentOptions.length > 5,
                ),
              ),
              const SizedBox(height: 8),

              // ── Job Type ──────────────────────────────────────────────
              _Accordion(
                title:         'Job Type',
                icon:          Icons.work_outline_rounded,
                selectedCount: _draft.jobTypes.length,
                expanded:      _expanded['jobType']!,
                onToggle:      (v) => _toggleExpand('jobType', v),
                child: _Checklist(
                  options:         _jobTypeOptions,
                  selected:        _draft.jobTypes,
                  search:          '',
                  onSearchChanged: (_) {},
                  onToggle:        (o) => _toggleItem(_draft.jobTypes, o, 'jobType'),
                  showSearch:      false,
                  showJobTypeDot:  true,
                ),
              ),
              const SizedBox(height: 8),

              // ── Status ────────────────────────────────────────────────
              _Accordion(
                title:         'Status',
                icon:          Icons.flag_outlined,
                selectedCount: _draft.statuses.length,
                expanded:      _expanded['status']!,
                onToggle:      (v) => _toggleExpand('status', v),
                child: _Checklist(
                  options:         _statusOptions,
                  selected:        _draft.statuses,
                  search:          '',
                  onSearchChanged: (_) {},
                  onToggle:        (o) => _toggleItem(_draft.statuses, o, 'status'),
                  showSearch:      false,
                  showStatusDot:   true,
                ),
              ),
              const SizedBox(height: 8),

              // ── Priority ──────────────────────────────────────────────
              _Accordion(
                title:         'Priority',
                icon:          Icons.priority_high_rounded,
                selectedCount: _draft.priorities.length,
                expanded:      _expanded['priority']!,
                onToggle:      (v) => _toggleExpand('priority', v),
                child: _Checklist(
                  options:          _priorityOptions,
                  selected:         _draft.priorities,
                  search:           '',
                  onSearchChanged:  (_) {},
                  onToggle:         (o) => _toggleItem(_draft.priorities, o, 'priority'),
                  showSearch:       false,
                  showPriorityDot:  true,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        _bottomBar(count),
        SizedBox(height: mq.padding.bottom),
      ]),
    );
  }

  // ── header ───────────────────────────────────────────────────────────────

  Widget _header(int count) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(children: [
        // drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.filter_list_rounded, size: 20, color: indBlueColor),
          const SizedBox(width: 8),
          Text(
            'Filter Indent',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: indBlueColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ],
          const Spacer(),
          if (count > 0)
            TextButton(
              onPressed: _reset,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
        ]),
      ]),
    );
  }

  // ── bottom bar ────────────────────────────────────────────────────────────

  Widget _bottomBar(int count) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: _reset,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              foregroundColor: Colors.grey.shade700,
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.dmSans(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: _apply,
            style: ElevatedButton.styleFrom(
              backgroundColor: indBlueColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              count > 0 ? 'Apply ($count)' : 'Apply',
              style: GoogleFonts.dmSans(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACCORDION
// ═══════════════════════════════════════════════════════════════════════════

class _Accordion extends StatelessWidget {
  final String title;
  final IconData icon;
  final int selectedCount;
  final bool expanded;
  final void Function(bool) onToggle;
  final Widget child;

  const _Accordion({
    required this.title,
    required this.icon,
    required this.selectedCount,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expanded || selectedCount > 0
              ? indBlueColor.withValues(alpha: 0.3)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(children: [
        InkWell(
          onTap: () => onToggle(!expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Icon(icon, size: 18, color: indBlueColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E)),
                ),
              ),
              if (selectedCount > 0) ...[
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: indBlueColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$selectedCount',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: Colors.grey.shade400),
              ),
            ]),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(children: [
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            child,
          ]),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHECKLIST
// ═══════════════════════════════════════════════════════════════════════════

class _Checklist extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final String search;
  final void Function(String) onSearchChanged;
  final void Function(String) onToggle;
  final bool showSearch;
  final bool showJobTypeDot;
  final bool showStatusDot;
  final bool showPriorityDot;

  const _Checklist({
    required this.options,
    required this.selected,
    required this.search,
    required this.onSearchChanged,
    required this.onToggle,
    this.showSearch      = true,
    this.showJobTypeDot  = false,
    this.showStatusDot   = false,
    this.showPriorityDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = search.isEmpty
        ? options
        : options
        .where((o) => o.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (showSearch) ...[
          TextField(
            onChanged: onSearchChanged,
            style: GoogleFonts.dmSans(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search…',
              hintStyle: GoogleFonts.dmSans(
                  fontSize: 13, color: Colors.grey.shade400),
              prefixIcon:
              Icon(Icons.search, size: 18, color: Colors.grey.shade400),
              isDense: true,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No options found',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: Colors.grey.shade400),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: Column(
                children: filtered
                    .map((opt) => _CheckItem(
                  label:           opt,
                  selected:        selected.contains(opt),
                  onToggle:        () => onToggle(opt),
                  showJobTypeDot:  showJobTypeDot,
                  showStatusDot:   showStatusDot,
                  showPriorityDot: showPriorityDot,
                ))
                    .toList(),
              ),
            ),
          ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHECK ITEM
// ═══════════════════════════════════════════════════════════════════════════

class _CheckItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onToggle;
  final bool showJobTypeDot;
  final bool showStatusDot;
  final bool showPriorityDot;

  const _CheckItem({
    required this.label,
    required this.selected,
    required this.onToggle,
    this.showJobTypeDot  = false,
    this.showStatusDot   = false,
    this.showPriorityDot = false,
  });

  // ── dot colour helpers ───────────────────────────────────────────────────

  Color _jobTypeColor(String s) {
    switch (s.toLowerCase().trim()) {
      case 'electrical':        return const Color(0xFF2196F3);
      case 'civil':             return const Color(0xFF795548);
      case 'plumbing':          return const Color(0xFF00BCD4);
      case 'fire fighting':     return const Color(0xFFF44336);
      case 'fire alarm system':
      case 'fire alarm & pa system': return const Color(0xFFFF5722);
      case 'cctv':              return const Color(0xFF9C27B0);
      case 'networking':        return const Color(0xFF4CAF50);
      case 'pa system':         return const Color(0xFF607D8B);
      case 'access control':    return const Color(0xFF009688);
      default:                  return newOrangeColor;
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase().trim()) {
      case 'approved':   return const Color(0xFF4CAF50);
      case 'rejected':   return const Color(0xFFF44336);
      case 'pending':    return const Color(0xFFFF9800);
      case 'cancelled':  return const Color(0xFF9E9E9E);
      case 'partial':    return const Color(0xFF2196F3);
      default:           return const Color(0xFF9E9E9E);
    }
  }

  Color _priorityColor(String s) {
    switch (s.toLowerCase().trim()) {
      case 'high':    return const Color(0xFFF44336);
      case 'medium':  return const Color(0xFFFF9800);
      case 'low':     return const Color(0xFF4CAF50);
      default:        return const Color(0xFF9E9E9E);
    }
  }

  Color get _dotColor {
    if (showJobTypeDot)  return _jobTypeColor(label);
    if (showStatusDot)   return _statusColor(label);
    if (showPriorityDot) return _priorityColor(label);
    return Colors.transparent;
  }

  bool get _showDot => showJobTypeDot || showStatusDot || showPriorityDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(children: [
          // checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color:
              selected ? indBlueColor : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: selected ? indBlueColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          // optional coloured dot
          if (_showDot)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: _dotColor, shape: BoxShape.circle),
            ),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? const Color(0xFF1A1A2E)
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}