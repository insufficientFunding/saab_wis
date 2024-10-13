import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';
import 'package:saab_wis/app/routes/routes.gr.dart';
import 'package:saab_wis/extensions/context.dart';
import 'package:saab_wis/widgets/app_bar.dart';
import 'package:saab_wis/widgets/scaffold.dart';
import 'package:gap/gap.dart';
import 'package:wis_base/wis_base.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

@RoutePage()
class ModelSelectPage extends StatefulWidget {
  const ModelSelectPage({super.key});

  @override
  State<ModelSelectPage> createState() => _ModelSelectPageState();
}

class _ModelSelectPageState extends State<ModelSelectPage> {
  Future<List<String>> _modelYears = Future.value([]);
  Model _selectedModel = Model.none;
  late PageController _pageController;

  static const double _boxWidth = 360;
  static const double _boxHeight = 0.5;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(keepPage: false);
  }

  @override
  Widget build(BuildContext context) {
    return WisScaffold(
      appBar: WisAppBar(
        title: const SizedBox(
          width: 50,
          height: 40,
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: BlocConsumer<AppBloc, AppState>(
            listener: (context, state) {
              if (state.model != null) {
                context.router.replaceAll([const HomeRoute()]);
              }
            },
            buildWhen: (previous, current) => previous.status != current.status,
            listenWhen: (previous, current) => previous.model != current.model,
            builder: (context, state) {
              Widget child = SizedBox(
                height: MediaQuery.of(context).size.height * _boxHeight,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeCap: StrokeCap.round,
                    color: context.colorScheme.brightness == Brightness.light
                        ? context.colorScheme.primary
                        : context.colorScheme.tertiary,
                  ),
                ),
              );

              if (state.status != AppStatus.loading) {
                child = Material(
                  clipBehavior: Clip.antiAlias,
                  elevation: 4,
                  surfaceTintColor: Colors.transparent,
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  child: ExpandablePageView(
                    physics: const NeverScrollableScrollPhysics(),
                    allowImplicitScrolling: false,
                    controller: _pageController,
                    children: [
                      _buildModelPicker(context),
                      _buildYearPicker(context),
                    ],
                  ),
                );
              }

              return SizedBox(
                width: _boxWidth,
                // height: MediaQuery.of(context).size.height * _boxHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Gap(24),
                    Image.asset(
                      'assets/logo.png',
                      height: 200,
                    ),
                    const Gap(24),
                    child,
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget _buildModelPicker(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _boxWidth,
        maxHeight: MediaQuery.of(context).size.height * _boxHeight,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select a model',
            style: context.textTheme.headlineLarge,
          ),
          const Gap(4),
          Text(
            'Please select a model to continue',
            style: context.textTheme.bodyLarge,
          ),
          const Gap(24),
          ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: Model.values.length - 1,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final model = Model.values[index + 1];
              return ListTile(
                title: Text(model.name),
                onTap: () {
                  setState(() {
                    _selectedModel = model;
                    _modelYears = context.read<AppBloc>().getModelYears(model: model);
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYearPicker(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _boxWidth,
        maxHeight: MediaQuery.of(context).size.height * _boxHeight,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select a year',
            style: context.textTheme.headlineLarge,
          ),
          const Gap(4),
          Text(
            'Please select a year to continue',
            style: context.textTheme.bodyLarge,
          ),
          const Gap(24),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _modelYears,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || (snapshot.data?.isEmpty ?? true)) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final year = snapshot.data![index];
                    return ListTile(
                      title: Text(year, style: context.textTheme.titleMedium),
                      onTap: () {
                        setState(() {
                          context.read<AppBloc>().add(AppModelSelected(
                                model: _selectedModel,
                                modelYear: year,
                                language: Language.english,
                              ));
                          _selectedModel = Model.none;
                          _modelYears = Future.value([]);
                          _pageController.jumpTo(0);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Gap(12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.secondary,
              foregroundColor: context.colorScheme.onSecondary,
            ),
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              'Back',
              style: context.textTheme.headlineSmall
                  ?.copyWith(color: context.colorScheme.onSecondary, fontSize: 20, height: 1.4),
            ),
          )
        ],
      ),
    );
  }
}
