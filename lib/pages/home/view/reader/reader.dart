import 'dart:async';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:saab_wis/extensions/context.dart';
import 'package:saab_wis/pages/home/cubit/home_cubit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:collection/collection.dart';
import 'package:saab_wis/pages/home/view/reader/widget_factory.dart';
import 'package:saab_wis/widgets/image.dart';
import 'package:wis_base/wis_base.dart';
import 'package:wis_navigation/wis_navigation.dart';

class Reader extends StatefulHookWidget {
  const Reader({
    super.key,
  });

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(
      keepPage: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<HomeCubit>();
    final state = cubit.state;
    final theme = context.watchTheme;

    final selectedType = state.selectedDocumentType;
    final selectedSection = state.selectedSection;
    final selectedDocument = state.selectedDocument;

    if (selectedSection?.documentSections == null || selectedSection!.documentSections!.isEmpty) {
      return const Center(child: Text('No document selected'));
    }

    if (!selectedSection.documentSections!.any((e) => e.type == selectedType)) {
      return const Center(child: Text('No document selected'));
    }

    final documents = selectedSection.documentSections?.firstWhereOrNull((e) => e.type == selectedType)?.documents;

    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (!_pageController.hasClients) {
              return;
            }
            if (state.selectedDocument != null) {
              _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else {
              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }
          },
          listenWhen: (previous, current) => previous.selectedDocument != current.selectedDocument,
        ),
        BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state.selectedSection != null) {
              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }
          },
          listenWhen: (previous, current) => previous.selectedSection != current.selectedSection,
        ),
        BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state.selectedDocumentType != selectedType) {
              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }
          },
          listenWhen: (previous, current) => previous.selectedDocumentType != current.selectedDocumentType,
        ),
      ],
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.topCenter,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.2), blurRadius: 12)],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpandablePageView(
              controller: _pageController,
              children: [
                _buildDocumentList(context: context, documents: documents, selectedSection: selectedSection),
                _buildDocument(context: context, selectedDocument: selectedDocument),
              ],
            ),
          ),
          if (selectedDocument != null && _pageController.hasClients)
            Positioned(
              top: 30,
              left: 30,
              child: Row(
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: context.colorForBrightness(
                        light: theme.colorScheme.primary,
                        dark: theme.colorScheme.tertiary,
                      ),
                      foregroundColor: context.colorForBrightness(
                          light: theme.colorScheme.onPrimary, dark: theme.colorScheme.onTertiary),
                    ),
                    onPressed: () {
                      _pageController.animateToPage(0,
                          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

                      context.read<HomeCubit>().selectDocument(null);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDocumentList(
      {required BuildContext context, required List<WisDocument>? documents, required WisSection selectedSection}) {
    final cubit = context.watch<HomeCubit>();
    final state = cubit.state;
    final theme = context.watchTheme;

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedSection.name,
              style: theme.textTheme.headlineMedium,
            ),
            ListView.separated(
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: documents?.length ?? 1,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (selectedSection.documentSections == null) {
                  return const Center(child: Text('No document selected'));
                }

                final item = documents![index];
                return ListTile(
                  title: Text(item.name),
                  onTap: () {
                    if (state.selectedDocument == item) {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      return;
                    }
                    cubit.selectDocument(item);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> loadDocument(WisDocument? selectedDocument, Model model) async {
    if (selectedDocument == null) {
      return '';
    }

    final parser = DocumentParser();

    final document = await parser.load(docId: selectedDocument.documentId, model: model, language: Language.english);
    // await _controller.loadUrl('file://$document');
    return document.data;
  }

  Widget _buildDocument({required BuildContext context, required WisDocument? selectedDocument}) {
    final theme = context.watchTheme;
    final future = useMemoized(
        () => loadDocument(selectedDocument, context.read<HomeCubit>().state.model!.model), [selectedDocument]);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedDocument?.name ?? '',
            style: theme.textTheme.headlineMedium,
          ),
          const Gap(16),
          FutureBuilder<String>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              return Flexible(
                child: HtmlWidget(
                  snapshot.data!,
                  renderMode: const ListViewMode(shrinkWrap: true),
                  buildAsync: true,
                  textStyle: context.watchTheme.textTheme.bodyMedium,
                  factoryBuilder: () => WisWidgetFactory(),
                  customWidgetBuilder: (element) {
                    if (element.localName == 'a' && element.attributes['href']?.startsWith('wisimg://') == true) {
                      final imagePath = element.attributes['href']!;
                      return Align(alignment: Alignment.topLeft, child: WisImage(imagePath: imagePath));
                    }

                    return null;
                  },
                  customStylesBuilder: (element) {
                    final styles = <String, String>{};
                    if (element.attributes['bgcolor'] == '#6699cc') {
                      final color = context.colorForBrightness(
                        light: theme.colorScheme.primary,
                        dark: theme.colorScheme.tertiary,
                      );

                      styles['background-color'] = '#${color.value.toRadixString(16).substring(2)}';
                    }

                    if (element.localName == 'h2') {
                      styles['font-family'] = 'Urbanist';
                    }

                    return styles;
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
