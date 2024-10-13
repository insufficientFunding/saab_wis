part of 'home_page.dart';

class _HomePageDesktop extends HookWidget {
  const _HomePageDesktop();

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: WisDocumentSectionType.values.length);

    final cubit = context.watch<HomeCubit>();
    var projectOpen = cubit.state.isProjectOpen;
    var diagnosticsOpen = cubit.state.isDiagnosticsOpen;

    final overlayColor =
        context.colorScheme.brightness == Brightness.light ? context.colorScheme.primary : context.colorScheme.tertiary;

    return WisScaffold(
      appBar: WisAppBar(),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -58),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  boxShadow: [BoxShadow(color: context.colorScheme.shadow.withOpacity(0.3), blurRadius: 12)],
                ),
                height: 58,
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(builder: (context, constraints) {
              final projectOpen = context.watch<HomeCubit>().state.isProjectOpen;
              final diagnosticsOpen = context.watch<HomeCubit>().state.isDiagnosticsOpen;
              final double widthOffsetLeft = projectOpen ? 350 : 50;
              final double widthOffsetRight = diagnosticsOpen ? 350 : 50;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: constraints.maxHeight,
                padding: EdgeInsets.only(left: widthOffsetLeft, right: widthOffsetRight),
                child: Column(
                  children: [
                    const Expanded(
                      child: SingleChildScrollView(child: Reader()),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildTabBar(context: context, overlayColor: overlayColor, tabController: tabController),
                    ),
                  ],
                ),
              );
            }),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 350,
              child: _buildDesktopDrawer(
                context: context,
                expanded: projectOpen,
                icon: Icons.folder,
                child: const DocumentExplorer(),
                right: false,
                onToggle: () => cubit.toggleProjectDrawer(),
                tooltip: 'project drawer',
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 350,
              child: _buildDesktopDrawer(
                context: context,
                expanded: diagnosticsOpen,
                icon: Icons.bug_report,
                right: true,
                onToggle: () => cubit.toggleDiagnosticsDrawer(),
                tooltip: 'diagnostics drawer',
                child: const DtcExplorer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Align _buildTabBar(
      {required BuildContext context, required Color overlayColor, required TabController tabController}) {
    final state = context.watch<HomeCubit>().state;
    final selectedType = state.selectedDocumentType;
    final selectedSection = state.selectedSection;

    // WisDocumentSectionType.values that are present in the selected section
    final availableTypes = selectedSection?.documentSections?.map((e) => e.type).toSet().toList() ??
        [WisDocumentSectionType.technicalDescription];
    if (!availableTypes.contains(selectedType)) {
      context.read<HomeCubit>().selectSectionType(availableTypes.first);
    }

    bool canSelect(WisDocumentSectionType type) => availableTypes.contains(type);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          boxShadow: [BoxShadow(color: context.colorScheme.shadow.withOpacity(0.2), blurRadius: 12)],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4).copyWith(bottom: 0),
        child: Material(
          color: Colors.transparent,
          child: TabBar(
            // controller: _tabController,
            tabs: WisDocumentSectionType.values
                .map((e) => Tab(
                      height: 30,
                      child: SizedBox.expand(
                        child: Icon(
                          e.icon,
                          size: 16,
                          color: canSelect(e) ? null : context.colorScheme.onSurface.withOpacity(0.3),
                        ).tooltip(e.name),
                      ),
                    ))
                .toList(),
            controller: tabController,
            indicator: BoxDecoration(
              color: overlayColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              boxShadow: [BoxShadow(color: overlayColor.withOpacity(0.2), blurRadius: 12)],
            ),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return overlayColor.withOpacity(0.2);
              }
              if (states.contains(WidgetState.hovered)) {
                return overlayColor.withOpacity(0.1);
              }

              if (states.contains(WidgetState.focused)) {
                return overlayColor.withOpacity(0.1);
              }

              return null;
            }),
            onTap: (index) {
              if (availableTypes.contains(WisDocumentSectionType.values[index])) {
                context.read<HomeCubit>().selectSectionType(WisDocumentSectionType.values[index]);
              } else {
                tabController.index = WisDocumentSectionType.values.indexOf(selectedType);
              }
            },
            indicatorSize: TabBarIndicatorSize.tab,
            textScaler: const TextScaler.linear(0.9),
            labelColor: context.colorScheme.surface,
            automaticIndicatorColorAdjustment: true,
            splashBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
            dividerHeight: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopDrawer({
    required BuildContext context,
    required bool expanded,
    Widget? child,
    bool right = false,
    void Function()? onToggle,
    required IconData icon,
    required String tooltip,
  }) {
    final button = IconButton(
      icon: Icon(
        right
            ? expanded
                ? Icons.chevron_right
                : icon
            : expanded
                ? Icons.chevron_left
                : icon,
        size: 20,
        color: context.watchColorScheme.brightness == Brightness.light
            ? context.watchColorScheme.primary
            : context.watchColorScheme.tertiary,
      ),
      onPressed: onToggle,
    );
    final align = Align(
      alignment: right ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4).copyWith(
          top: 0,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(right ? 0 : 20),
            bottomLeft: Radius.circular(right ? 20 : 0),
          ),
          // boxShadow: [BoxShadow(color: context.colorScheme.shadow, blurRadius: 12)],
        ),
        child: button,
      ).tooltip('${expanded ? 'Collapse' : 'Expand'} $tooltip'),
    );
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: expanded
          ? Offset.zero
          : right
              ? const Offset(0.868, 0)
              : const Offset(-0.868, 0),
      child: ShadowWidget(
        color: context.colorScheme.shadow.withOpacity(0.25),
        blurRadius: 10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          textDirection: right ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                // boxShadow: [BoxShadow(color: context.colorScheme.shadow.withOpacity(0.2), blurRadius: 12)],
              ),
              child: child,
            ),
            align,
          ],
        ),
      ),
    );
  }
}
