import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The Lead module's app bar.
///
/// Every screen in the module used to roll its own header — a bare
/// `Icons.arrow_back_ios_new` next to a title, at three different font sizes
/// (17, 18 and 20), some with a boxed action button and some without. This is
/// the one the Lead Management list already used, extracted so every screen
/// reads as the same module.
///
/// It implements [PreferredSizeWidget] so it can be passed to `Scaffold.appBar`,
/// and it is an ordinary widget, so screens that build their header inside the
/// body Column can drop it straight in without restructuring.
class LeadAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;

  /// Defaults to `Get.back()`.
  final VoidCallback? onBack;

  /// Boxed action buttons — build them with [leadAppBarAction].
  final List<Widget> actions;

  const LeadAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
  });

  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _border = Color(0xFFE8EAF0);
  static const Color _textPrimary = Color(0xFF1A1D26);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Get.back(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textPrimary, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// A boxed 38x38 action button for [LeadAppBar.actions], matching the filter
/// button on the Lead Management list.
Widget leadAppBarAction(
  IconData icon,
  VoidCallback onTap, {
  Color color = const Color(0xFF5B5FC7),
  Color background = const Color(0xFFF0F3FF),
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(left: 8),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    ),
  );
}
