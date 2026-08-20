import 'package:flutter/material.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;
  final bool automaticallyImplyLeading;
  final double? leadingWidth;

  const SharedAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
    this.leadingWidth,
  });

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    Widget? _leading = leading;
    double? _leadingWidth = leadingWidth;

    if (_leading == null && automaticallyImplyLeading && canPop) {
      // 68pt width ensures 16pt left padding + 48pt standard touch target (total >= 44pt target)
      // This protects the button from iOS bezel/case lip conflicts while retaining full hit area.
      _leadingWidth = 68.0;
      _leading = Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return AppBar(
      title: title,
      backgroundColor: backgroundColor,
      elevation: elevation,
      actions: actions,
      leading: _leading,
      leadingWidth: _leadingWidth,
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
