// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:saab_wis/pages/home/view/home_page.dart' as _i1;
import 'package:saab_wis/pages/model_select/model_select_page.dart' as _i2;

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i3.PageRouteInfo<void> {
  const HomeRoute({List<_i3.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomePage();
    },
  );
}

/// generated route for
/// [_i2.ModelSelectPage]
class ModelSelectRoute extends _i3.PageRouteInfo<void> {
  const ModelSelectRoute({List<_i3.PageRouteInfo>? children})
      : super(
          ModelSelectRoute.name,
          initialChildren: children,
        );

  static const String name = 'ModelSelectRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.ModelSelectPage();
    },
  );
}