import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';
import 'package:saab_wis/extensions/string.dart';
import 'package:saab_wis/pages/home/cubit/home_cubit.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:wis_base/wis_base.dart';

class DtcExplorer extends StatefulWidget {
  const DtcExplorer({
    super.key,
  });

  @override
  State<DtcExplorer> createState() => _DtcExplorerState();
}

class _DtcExplorerState extends State<DtcExplorer> {
  String? _selectedEcm;
  List<WisDtc> _filteredDtcs = [];
  final MenuController _menuController = MenuController();
  Future<void> _updateFilter(List<WisEcm> ecms, String? ecm) async {
    setState(() {
      if (ecm == 'Show all') {
        _selectedEcm = null;
      } else {
        _selectedEcm = ecm;
      }
    });

    _filteredDtcs.clear();
    if (_selectedEcm == null) {
      for (final ecm in ecms) {
        _filteredDtcs.addAll(ecm.dtcs);
      }
    } else {
      _filteredDtcs = ecms.firstWhere((element) => element.name == ecm).dtcs;
    }
  }

  @override
  void initState() {
    super.initState();

    _filteredDtcs = context.read<HomeCubit>().state.model!.ecms.expand((element) => element.dtcs).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeCubit>().state;
    if (state.model == null) {
      return const SizedBox();
    }

    final ecms = state.model!.ecms;
    final Map<WisDtc, String> dtcs = {};
    for (final ecm in ecms) {
      for (final dtc in ecm.dtcs) {
        dtcs[dtc] = ecm.name;
      }
    }

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildFilterButton(ecms: ecms),
            const Gap(16),
            Expanded(
              child: _buildList(dtcs),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({required List<WisEcm> ecms}) {
    final theme = context.watch<AppBloc>().state.theme;
    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.brightness == Brightness.dark ? colorScheme.tertiary : colorScheme.primary;
    final selectedTextColor = colorScheme.brightness == Brightness.dark ? null : colorScheme.onPrimary;

    isSelected(WisEcm ecm) {
      if (ecm.name == _selectedEcm) {
        return _selectedEcm == null;
      }

      return ecm.name == _selectedEcm;
    }

    return MenuAnchor(
      menuChildren: [
        for (final ecm in ecms.toList()..insert(0, WisEcm(name: 'Show all', id: '*')))
          MenuItemButton(
            onPressed: () => _updateFilter(ecms, ecm.name),
            closeOnActivate: true,
            style: MenuItemButton.styleFrom(
              textStyle: theme.textTheme.bodyLarge,
              fixedSize: const Size(200, 30),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: isSelected(ecm) ? selectedColor : null,
              foregroundColor: isSelected(ecm) ? selectedTextColor : null,
            ),
            child: Text(ecm.name),
          ),
      ],
      clipBehavior: Clip.antiAlias,
      style: MenuStyle(
        visualDensity: VisualDensity.compact,
        fixedSize: const WidgetStatePropertyAll(Size(200, 400)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      controller: _menuController,
      builder: (context, controller, child) => FilledButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.brightness == Brightness.dark ? colorScheme.tertiary : null,
          textStyle: theme.textTheme.bodyLarge,
          minimumSize: const Size(200, 40),
        ),
        icon: const Icon(Icons.swap_horiz),
        label: Text(_selectedEcm ?? 'Filter by ECM'),
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
    );
  }

  Widget _buildList(Map<WisDtc, String> dtcs) {
    final theme = context.watch<AppBloc>().state.theme;
    final colorScheme = theme.colorScheme;
    final buttonColor = colorScheme.brightness == Brightness.dark ? colorScheme.tertiary : colorScheme.primary;
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: buttonColor.withOpacity(0.5),
        selectionHandleColor: buttonColor,
        cursorColor: buttonColor,
      ),
      child: SearchableList(
        seperatorBuilder: (_, __) => const Divider(),
        initialList: _filteredDtcs,
        spaceBetweenSearchAndList: 8,
        inputDecoration: InputDecoration(
          hintText: 'Search DTCs',
          fillColor: colorScheme.surfaceContainer,
          prefixIcon: Icon(Icons.search, color: buttonColor),
        ),
        style: theme.textTheme.titleSmall?.copyWith(height: 1.7),
        searchFieldHeight: 40,
        // displayClearIcon: false,
        displaySearchIcon: false,
        defaultSuffixIconSize: 12,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        emptyWidget: const Align(
          alignment: Alignment.topCenter,
          child: Text('No DTCs found, try another ECM or check your search query'),
        ),
        shrinkWrap: true,
        filter: (query) =>
            _filteredDtcs.where((element) => element.code.toLowerNoSpaces().contains(query.toLowerNoSpaces())).toList(),
        itemBuilder: (dtc) {
          final ecm = dtcs[dtc]!;
          return ListTile(
            dense: true,
            key: ValueKey(dtc.code),
            title: Row(
              children: [
                Text(dtc.code.toUpperCase(), style: theme.textTheme.titleSmall),
                const Gap(4),
                Text(ecm, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.secondary))
              ],
            ),
            subtitle: dtc.description.trim().isNotEmpty ? Text(dtc.description.trim()) : null,
            onTap: () {
              context.read<HomeCubit>().selectDocument(dtc);
            },
          );
        },
      ),
    );
  }
}
