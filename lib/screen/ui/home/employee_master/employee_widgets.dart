// ─────────────────────────────────────────────────────────────────────────────
// employee_widgets.dart
// Shared UI components for the Employee Master module.
// Mirrors the Indent/MRN widget kits so the screen sits visually with the rest
// of the app instead of introducing a fourth look.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Color tokens ─────────────────────────────────────────────────────────────
const Color empBlueColor = Color(0xFF5B6CF6);
final Color empBlueLightColor = const Color(0xFF5B6CF6).withValues(alpha: 0.10);
const Color empGreenColor = Color(0xFF10B981);
const Color empGreenLightColor = Color(0xFFD1FAE5);
const Color empRedColor = Color(0xFFEF4444);
const Color empSurfaceColor = Color(0xFFF8FAFC);
const Color empBorderColor = Color(0xFFE2E6EA);
const Color empTextPrimary = Color(0xFF1A1D23);
const Color empTextSecondary = Color(0xFF6B7280);
const Color empTextHint = Color(0xFFADB5BD);

/// Deep navy used for the ID card's header/footer bands and its headline text.
/// Darker than empTextPrimary so the card reads as printed stock rather than
/// as another app screen.
const Color empCardInk = Color(0xFF1E2235);

/// Organisation name printed across the top of the ID card.
///
/// This is the ONE line that legitimately differs between the white-label
/// builds — set it to the brand this app ships as. Everything else in the
/// employee_master folder is identical across apps and copied verbatim.
const String empCardBrand = 'GLOBENEX';

// ── Card wrapper ─────────────────────────────────────────────────────────────
class EmpCard extends StatelessWidget {
  final Widget child;
  const EmpCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: empBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section heading ──────────────────────────────────────────────────────────
class EmpSectionHead extends StatelessWidget {
  final String text;
  const EmpSectionHead(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
              color: empBlueColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: empTextPrimary,
                letterSpacing: 0.2)),
      ]),
    );
  }
}

// ── Field label (with optional red asterisk) ─────────────────────────────────
class EmpLabel extends StatelessWidget {
  final String text;
  final bool required;
  const EmpLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: empTextSecondary),
        children: [
          if (required)
            const TextSpan(
                text: ' *',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: empRedColor)),
        ],
      ),
    );
  }
}

// ── Text field ───────────────────────────────────────────────────────────────
class EmpField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final bool required;
  final bool hasError;
  final VoidCallback? onTap;
  final Widget? suffix;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;

  const EmpField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.required = false,
    this.hasError = false,
    this.onTap,
    this.suffix,
    this.minLines,
    this.maxLines,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  static OutlineInputBorder _border(bool hasError) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? empRedColor.withValues(alpha: 0.5) : empBorderColor),
      );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      EmpLabel(label, required: required),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        minLines: minLines ?? 1,
        maxLines: maxLines ?? (minLines != null ? null : 1),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: empTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: empTextHint),
          suffixIcon: suffix,
          filled: true,
          fillColor: readOnly ? empSurfaceColor : Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: _border(hasError),
          enabledBorder: _border(hasError),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: empBlueColor, width: 1.5)),
        ),
      ),
    ]);
  }
}

// ── Searchable dropdown ──────────────────────────────────────────────────────
class EmpDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final bool isLoading;
  final bool required;
  final bool hasError;
  final bool enabled;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? hint;

  /// Shown under the field when the list came back empty — tells the user why
  /// the sheet would be blank instead of letting them tap into nothing.
  final String? emptyNote;

  const EmpDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.isLoading = false,
    this.required = false,
    this.hasError = false,
    this.enabled = true,
    this.hint,
    this.emptyNote,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || isLoading;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      EmpLabel(label, required: required),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: isDisabled ? null : () => _showSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDisabled ? empSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: hasError
                    ? empRedColor.withValues(alpha: 0.5)
                    : empBorderColor),
          ),
          child: Row(children: [
            Expanded(
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: empBlueColor))
                  : Text(
                      value != null ? itemLabel(value as T) : (hint ?? 'Select'),
                      style: TextStyle(
                          fontSize: 13,
                          color: value != null ? empTextPrimary : empTextHint),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: empTextSecondary),
          ]),
        ),
      ),
      if (!isLoading && items.isEmpty && emptyNote != null) ...[
        const SizedBox(height: 4),
        Text(emptyNote!,
            style: const TextStyle(fontSize: 10, color: empTextHint)),
      ],
    ]);
  }

  void _showSheet(BuildContext context) {
    final search = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          final filtered = items
              .where((i) =>
                  itemLabel(i).toLowerCase().contains(search.text.toLowerCase()))
              .toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder: (_, scroll) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(children: [
                const SizedBox(height: 10),
                Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                        color: empBorderColor,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: empTextPrimary)),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: search,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: empTextSecondary),
                      filled: true,
                      fillColor: empSurfaceColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: empBorderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: empBorderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: empBlueColor, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No options',
                              style: TextStyle(
                                  fontSize: 13, color: empTextSecondary)))
                      : ListView.separated(
                          controller: scroll,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: empBorderColor),
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final isSelected = value != null &&
                                itemLabel(value as T) == itemLabel(item);
                            return InkWell(
                              onTap: () {
                                onChanged(item);
                                Navigator.pop(ctx);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                child: Row(children: [
                                  Expanded(
                                    child: Text(itemLabel(item),
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? empBlueColor
                                                : empTextPrimary)),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle_rounded,
                                        size: 18, color: empBlueColor),
                                ]),
                              ),
                            );
                          },
                        ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Attachment row (pick → upload → uploaded state) ──────────────────────────
class EmpAttachment extends StatelessWidget {
  final String label;
  final String? fileName;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const EmpAttachment({
    super.key,
    required this.label,
    required this.fileName,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = (fileName ?? '').isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      EmpLabel(label),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: (isUploading || hasFile) ? null : onPick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: hasFile ? empGreenLightColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: hasFile
                    ? empGreenColor.withValues(alpha: 0.4)
                    : empBorderColor),
          ),
          child: Row(children: [
            if (isUploading)
              const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: empBlueColor))
            else
              Icon(
                  hasFile
                      ? Icons.check_circle_rounded
                      : Icons.attach_file_rounded,
                  size: 16,
                  color: hasFile ? empGreenColor : empTextSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isUploading
                    ? 'Uploading...'
                    : (hasFile ? fileName! : 'Choose file'),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: hasFile ? FontWeight.w700 : FontWeight.w500,
                    color: hasFile ? empGreenColor : empTextHint),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasFile && !isUploading)
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: empTextSecondary),
              ),
          ]),
        ),
      ),
    ]);
  }
}

// ── Primary button ───────────────────────────────────────────────────────────
class EmpPrimaryBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isBusy;
  final Color? color;

  const EmpPrimaryBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isBusy = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isBusy || onTap == null;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: disabled
              ? (color ?? empBlueColor).withValues(alpha: 0.45)
              : (color ?? empBlueColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isBusy)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            else
              Icon(icon, size: 17, color: Colors.white),
            const SizedBox(width: 8),
            Text(isBusy ? 'Saving...' : label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ── QR code ──────────────────────────────────────────────────────────────────

/// Paints a QR code with no extra plugin.
///
/// The `barcode` package (already in the tree, and what the PDF side uses) does
/// the encoding and hands back plain rectangles; this just fills them. Using
/// the same encoder for screen and PDF means the two codes are byte-identical.
class EmpQrCode extends StatelessWidget {
  final String data;
  final double size;
  final Color color;

  const EmpQrCode({
    super.key,
    required this.data,
    required this.size,
    this.color = empCardInk,
  });

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) return SizedBox(width: size, height: size);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _QrPainter(data: data, color: color)),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;
  final Color color;

  _QrPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    try {
      final elements =
          Barcode.qrCode().make(data, width: size.width, height: size.height);
      for (final e in elements) {
        if (e is BarcodeBar && e.black) {
          // +0.5 closes the hairline seams antialiasing leaves between modules,
          // which otherwise make the code harder for scanners to read.
          canvas.drawRect(
            Rect.fromLTWH(e.left, e.top, e.width + 0.5, e.height + 0.5),
            paint,
          );
        }
      }
    } catch (_) {
      // An un-encodable payload should leave a blank square, not crash a card.
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) =>
      old.data != data || old.color != color;
}
