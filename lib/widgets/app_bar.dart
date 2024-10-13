import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';
import 'package:saab_wis/extensions/context.dart';
import 'package:saab_wis/extensions/widget.dart';

class WisAppBar extends AppBar {
  WisAppBar({
    super.key,
    super.title,
    super.leading,
    super.actions,
    super.bottom,
    super.bottomOpacity,
    this.compactTitle = false,
  });

  final bool compactTitle;

  @override
  State<AppBar> createState() {
    return _WisAppBarState();
  }
}

class _WisAppBarState extends State<WisAppBar> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.watchColorScheme;
    return AppBar(
      notificationPredicate: (_) => false,
      title: InkWell(
        onTap: () {
          context.read<AppBloc>().add(AppEvent.themeChanged(
                colorScheme.brightness == Brightness.light ? Brightness.dark : Brightness.light,
              ));
        },
        borderRadius: BorderRadius.circular(50.0),
        child: _getTitle(context: context),
      ).tooltip('Toggle theme'),
      titleSpacing: 0,
      leadingWidth: widget.leading != null ? 181 : 150,
      bottom: widget.bottom,
      bottomOpacity: widget.bottomOpacity,
      actions: widget.actions,
      leading: _getLeading(context: context),
    );
  }

  Widget _getTitle({
    required BuildContext context,
  }) {
    final colorScheme = context.colorScheme;

    if (widget.compactTitle) {
      return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.4), blurRadius: 12)],
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('assets/logo.png'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 14.0),
      child: widget.title ??
          Image.asset(
            'assets/logo_alt.png',
            height: 34,
            color: colorScheme.brightness == Brightness.light ? colorScheme.primary : colorScheme.tertiary,
          ),
    );
  }

  Widget? _getLeading({
    required BuildContext context,
  }) {
    final model = context.read<AppBloc>().state.model;
    if (model == null) {
      return null;
    }

    final color = context.colorScheme.secondary;

    final child = Padding(
      padding: EdgeInsets.only(left: widget.leading != null ? 4 : 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(model.model.name, style: context.textTheme.titleMedium, textScaler: const TextScaler.linear(1.2)),
          const Gap(5),
          Text(
            model.year,
            style: context.textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );

    if (widget.leading != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            widget.leading!,
            child,
          ],
        ),
      );
    }

    return child;
  }
}
