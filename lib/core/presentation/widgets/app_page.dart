import 'package:flutter/material.dart';

/// Consistent page scaffold: themed AppBar + themed background.
/// Use everywhere a simple page is needed to keep the design system uniform.
class AppPage extends StatelessWidget {
  const AppPage({
    required this.body,
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showAppBar = true,
    this.centerTitle = true,
    this.background,
    this.appBarBottom,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showAppBar;
  final bool centerTitle;
  final Color? background;
  final PreferredSizeWidget? appBarBottom;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              leading:
                  leading ??
                  (canPop && title != null ? const BackButton() : null),
              actions: actions,
              centerTitle: centerTitle,
              bottom: appBarBottom,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
