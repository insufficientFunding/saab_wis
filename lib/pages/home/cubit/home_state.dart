part of 'home_cubit.dart';

class HomeState extends Equatable {
  HomeState({
    TreeController<WisSection>? treeController,
    this.selectedDocumentType = WisDocumentSectionType.technicalDescription,
    this.selectedDocument,
    this.selectedSection,
    this.model,
    this.isDiagnosticsOpen = false,
    this.isProjectOpen = false,
  }) {
    if (treeController != null) {
      this.treeController = treeController;
    } else {
      this.treeController = TreeController<WisSection>(
        roots: model?.sections ?? [],
        childrenProvider: (node) => node.subsections,
        parentProvider: (node) => model?.sections
            .expand((section) => section.subsections)
            .expand((subsection) => subsection.subsections)
            .firstWhereOrNull((section) => section.subsections.contains(node)),
      );
    }
  }

  late final TreeController<WisSection> treeController;
  final WisModelData? model;
  final bool isDiagnosticsOpen;
  final bool isProjectOpen;
  final WisDocumentSectionType selectedDocumentType;
  final WisSection? selectedSection;
  final WisDocument? selectedDocument;

  @override
  List<Object?> get props => [
        treeController,
        model,
        isDiagnosticsOpen,
        isProjectOpen,
        selectedDocumentType,
        selectedSection,
        selectedDocument,
      ];

  HomeState copyWith({
    TreeController<WisSection>? treeController,
    WisModelData? model,
    WisDocumentSectionType? selectedDocumentType,
    bool? isDiagnosticsOpen,
    bool? isProjectOpen,
    WisSection? selectedSection,
    WisDocument? selectedDocument,
  }) {
    return HomeState(
      treeController: treeController ?? this.treeController,
      model: model ?? this.model,
      isDiagnosticsOpen: isDiagnosticsOpen ?? this.isDiagnosticsOpen,
      isProjectOpen: isProjectOpen ?? this.isProjectOpen,
      selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
      selectedSection: selectedSection ?? this.selectedSection,
      selectedDocument: selectedDocument ?? this.selectedDocument,
    );
  }
}
