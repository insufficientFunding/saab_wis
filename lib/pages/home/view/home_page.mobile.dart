part of 'home_page.dart';

class _HomePageMobile extends StatefulWidget {
  const _HomePageMobile();

  @override
  State<_HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<_HomePageMobile> with SingleTickerProviderStateMixin {
  final MenuController _menuController = MenuController();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<HomeCubit>();

    return WisScaffold(
      appBar: WisAppBar(
        compactTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            cubit.toggleProjectDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              cubit.toggleDiagnosticsDrawer();
            },
          ),
        ],
      ),
      onDrawerChanged: (open) => _onDrawerChanged(context, open),
      onEndDrawerChanged: (open) => _onEndDrawerChanged(context, open),
      drawer: const Drawer(
        child: DocumentExplorer(),
      ),
      endDrawer: const Drawer(
        width: 300,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: DtcExplorer(),
        ),
      ),
      body: BlocListener<HomeCubit, HomeState>(
        listener: _onStateChanged,
        listenWhen: (previous, current) =>
            previous.isProjectOpen != current.isProjectOpen || previous.isDiagnosticsOpen != current.isDiagnosticsOpen,
        child: _buildBody(context: context),
      ),
    );
  }

  Widget _buildBody({required BuildContext context}) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionSelector(context: context),
              const Flexible(
                child: Reader(),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) => RotationTransition(
              turns: Tween<double>(begin: 0, end: -0.5).animate(_animationController),
              child: IconButton(
                icon: const Icon(CupertinoIcons.chevron_down),
                iconSize: 20,
                tooltip: 'Toggle section selector',
                onPressed: () {
                  if (_animationController.isCompleted) {
                    _animationController.reverse();
                  } else {
                    _animationController.forward();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSelector({required BuildContext context}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -1),
        ).animate(_animationController),
        child: SizedBox(
          width: double.maxFinite,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: context.watchTheme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(child: _buildSectionDropdown(context: context)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDropdown({required BuildContext context}) {
    final cubit = context.watch<HomeCubit>();
    final state = cubit.state;
    final theme = context.watchTheme;

    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.brightness == Brightness.dark ? colorScheme.tertiary : colorScheme.primary;
    final selectedTextColor = colorScheme.brightness == Brightness.dark ? null : colorScheme.onPrimary;

    final selectedType = state.selectedDocumentType;
    final selectedSection = state.selectedSection;

    // WisDocumentSectionType.values that are present in the selected section
    final availableTypes = selectedSection?.documentSections?.map((e) => e.type).toSet().toList() ??
        [WisDocumentSectionType.technicalDescription];
    if (!availableTypes.contains(selectedType)) {
      context.read<HomeCubit>().selectSectionType(availableTypes.first);
    }

    bool canSelect(WisDocumentSectionType type) => availableTypes.contains(type);

    isSelected(WisDocumentSectionType type) {
      return type == state.selectedDocumentType;
    }

    return MenuAnchor(
      menuChildren: [
        for (final type in WisDocumentSectionType.values)
          MenuItemButton(
            onPressed: canSelect(type) ? () => cubit.selectSectionType(type) : null,
            closeOnActivate: true,
            style: MenuItemButton.styleFrom(
              textStyle: theme.textTheme.bodyLarge,
              fixedSize: const Size(240, 30),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: isSelected(type) ? selectedColor : null,
              foregroundColor: isSelected(type) ? selectedTextColor : null,
            ),
            child: Text(type.name),
          ),
      ],
      clipBehavior: Clip.antiAlias,
      style: MenuStyle(
        visualDensity: VisualDensity.compact,
        fixedSize: const WidgetStatePropertyAll(Size(240, 400)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        alignment: Alignment.bottomCenter,
      ),
      alignmentOffset: const Offset(-120, 0),
      controller: _menuController,
      child: FilledButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.brightness == Brightness.dark ? colorScheme.tertiary : null,
          textStyle: theme.textTheme.bodyLarge,
          minimumSize: const Size(250, 46),
        ),
        icon: const Icon(Icons.swap_horiz),
        label: Text(state.selectedDocumentType.name),
        onPressed: () {
          if (_menuController.isOpen) {
            _menuController.close();
          } else {
            _menuController.open();
          }
        },
      ),
    );
  }

  void _onDrawerChanged(BuildContext context, bool open) {
    final cubit = context.read<HomeCubit>();
    final state = cubit.state;
    if (open != state.isProjectOpen) {
      cubit.toggleProjectDrawer();
    }
  }

  void _onEndDrawerChanged(BuildContext context, bool open) {
    final cubit = context.read<HomeCubit>();
    final state = cubit.state;
    if (open != state.isDiagnosticsOpen) {
      cubit.toggleDiagnosticsDrawer();
    }
  }

  void _onStateChanged(BuildContext context, HomeState state) {
    final scaffold = Scaffold.of(context);
    if (state.isProjectOpen) {
      if (!scaffold.isDrawerOpen) {
        scaffold.openDrawer();
      }
    } else {
      if (scaffold.isDrawerOpen) {
        scaffold.closeDrawer();
      }
    }

    if (state.isDiagnosticsOpen) {
      if (!scaffold.isEndDrawerOpen) {
        scaffold.openEndDrawer();
      }
    } else {
      if (scaffold.isEndDrawerOpen) {
        scaffold.closeEndDrawer();
      }
    }
  }
}
