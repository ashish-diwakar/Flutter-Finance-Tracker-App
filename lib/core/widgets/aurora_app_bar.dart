import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuroraAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      titleSpacing: 16,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: const Color(0xFFF8FCFA),
      foregroundColor: const Color(0xFF315F53),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF315F53),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: title,
      ),
      actions: actions,
    );
  }
}
