import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:shadow_widget/shadow_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';
import 'package:saab_wis/extensions/context.dart';
import 'package:saab_wis/extensions/widget.dart';
import 'package:saab_wis/pages/home/cubit/home_cubit.dart';
import 'package:saab_wis/pages/home/view/document_explorer.dart';
import 'package:saab_wis/pages/home/view/dtc_explorer.dart';
import 'package:saab_wis/pages/home/view/reader/reader.dart';
import 'package:saab_wis/widgets/app_bar.dart';
import 'package:saab_wis/widgets/scaffold.dart';
import 'package:wis_base/wis_base.dart';

part 'home_page.mobile.dart';
part 'home_page.desktop.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(model: context.read<AppBloc>().state.model),
      lazy: false,
      child: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) {
          final model = context.read<AppBloc>().state.model;
          if (model != null) {
            context.read<HomeCubit>().onModelSelected(model: model);
          }
        },
        listenWhen: (previous, current) => previous.model != current.model,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isLargeScreen = width > 800;

      if (isLargeScreen) {
        return const _HomePageDesktop();
      } else {
        return const _HomePageMobile();
      }
    });
  }
}
