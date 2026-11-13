import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuroraAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const toolbarHeight = 64.0;
  static const surfaceColor = Color(0xFFF8FCFA);
  static const inkColor = Color(0xFF315F53);
  static const titleTextStyle = TextStyle(
    color: inkColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const statusBarStyle = SystemUiOverlayStyle.dark;

  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const AuroraAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      titleSpacing: 16,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: surfaceColor,
      foregroundColor: inkColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      systemOverlayStyle: statusBarStyle,
      title: DefaultTextStyle(
        style: titleTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: title,
      ),
      actions: actions,
    );
  }
}
