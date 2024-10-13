import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';

class WisScaffold extends Scaffold {
  const WisScaffold({
    super.key,
    super.appBar,
    super.body,
    super.drawer,
    super.endDrawer,
    super.onDrawerChanged,
    super.onEndDrawerChanged,
  });

  @override
  ScaffoldState createState() => _WisScaffoldState();
}

class _WisScaffoldState extends ScaffoldState {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppBloc>().state.theme;
    return Scaffold(
      appBar: widget.appBar,
      onDrawerChanged: widget.onDrawerChanged,
      onEndDrawerChanged: widget.onEndDrawerChanged,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              child: Container(
                color: theme.colorScheme.surfaceContainerLowest,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SvgPicture.asset(
                  'assets/griffin_half.svg',
                  colorFilter: ColorFilter.mode(theme.colorScheme.surfaceContainerLow, BlendMode.srcIn),
                  alignment: Alignment.centerRight,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            if (widget.body != null) Material(color: Colors.transparent, child: widget.body!),
          ],
        ),
      ),
    );
  }
}
