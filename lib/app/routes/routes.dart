import 'package:auto_route/auto_route.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';

import 'routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({required this.appBloc});

  final AppBloc appBloc;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          path: '/',
          initial: true,
          guards: [RequireSelectionGuard(appBloc: appBloc)],
        ),
        AutoRoute(
          page: ModelSelectRoute.page,
          path: '/select-model',
        ),
      ];
}

class RequireSelectionGuard extends AutoRouteGuard {
  final AppBloc appBloc;

  RequireSelectionGuard({required this.appBloc});

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (appBloc.state.model == null) {
      router.replaceAll([const ModelSelectRoute()]);
    } else {
      resolver.next(true);
    }
  }
}
