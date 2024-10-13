import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';
import 'package:saab_wis/app/routes/routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => __AppViewState();
}

class __AppViewState extends State<_AppView> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();

    _router = AppRouter(appBloc: context.read());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) => previous.theme != current.theme,
      builder: (context, state) {
        return MaterialApp.router(
          routerConfig: _router.config(),
          theme: state.theme,
        );
      },
    );
  }
}
