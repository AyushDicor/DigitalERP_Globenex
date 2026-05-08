//  Shared widgets used across MRN screens 
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';

//  Section heading 
class MrnSectionHead extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const MrnSectionHead(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: newTextSecondary, letterSpacing: .6)),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

//  White card wrapper 
class MrnCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const MrnCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: newBorderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

//  Labelled input field 
class MrnField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType keyboard;
  final int minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  const MrnField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboard = TextInputType.text,
    this.minLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: newTextPrimary)),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        readOnly: readOnly,
        onTap: onTap,
        minLines: minLines,
        maxLines: minLines > 1 ? minLines + 2 : 1,
        style: const TextStyle(fontSize: 13, color: newTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: newTextHint, fontSize: 13),
          suffixIcon: suffix,
          filled: true,
          fillColor: newSurfaceColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: newBorderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: newBorderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: newBlueColor, width: 1.5)),
        ),
      ),
    ]);
  }
}

//  Dropdown field 
class MrnDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const MrnDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: newTextPrimary)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
          color: newSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: newBorderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: newTextSecondary, size: 20),
            style: const TextStyle(fontSize: 13, color: newTextPrimary),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: items
                .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }
}

//  Step progress bar 
class MrnStepBar extends StatelessWidget {
  final int current; // 0-based

  const MrnStepBar({super.key, required this.current});

  static const steps = ['Source', 'Items', 'Scan', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIdx < current ? newGreenColor : newBorderColor,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isDone = stepIdx < current;
          final isActive = stepIdx == current;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? newGreenColor
                      : isActive
                          ? newBlueColor
                          : newBorderColor,
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : Text('${stepIdx + 1}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isActive ? Colors.white : newTextSecondary)),
              ),
              const SizedBox(height: 3),
              Text(steps[stepIdx],
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? newBlueColor : newTextSecondary)),
            ],
          );
        }),
      ),
    );
  }
}

//  Status badge 
class MrnBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const MrnBadge(this.label, {super.key, required this.bg, required this.fg});

  static MrnBadge status(String s) {
    switch (s.toLowerCase()) {
      case 'completed': return MrnBadge(s, bg: newGreenLightColor, fg: newGreenColor);
      case 'partial':   return MrnBadge(s, bg: newOrangeLightColor, fg: newOrangeColor);
      case 'open':      return MrnBadge(s, bg: newBlueLightColor, fg: newBlueColor);
      default:          return MrnBadge(s, bg: newBorderColor, fg: newTextSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

//  Qty control row 
class MrnQtyControl extends StatelessWidget {
  final double qty;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const MrnQtyControl({
    super.key,
    required this.qty,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: newBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.remove, onDecrease),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(qty.toInt().toString(),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: newTextPrimary)),
        ),
        _btn(Icons.add, onIncrease, filled: true),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: filled ? newBlueColor : Colors.transparent,
          borderRadius: filled
              ? const BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7))
              : const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7)),
        ),
        child: Icon(icon, size: 14,
            color: filled ? Colors.white : newBlueColor),
      ),
    );
  }
}

//  Blue full-width submit button 
class MrnPrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? color;
  final IconData? icon;

  const MrnPrimaryBtn({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? newBlueColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
              ]),
      ),
    );
  }
}
