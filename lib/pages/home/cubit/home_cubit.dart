import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:wis_base/wis_base.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({WisModelData? model}) : super(HomeState(model: model));

  Future<void> onModelSelected({required WisModelData model}) async {
    emit(state.copyWith(
      treeController: TreeController<WisSection>(
        roots: model.sections,
        childrenProvider: (node) => node.subsections,
        parentProvider: (node) => model.sections
            .expand((section) => section.subsections)
            .expand((subsection) => subsection.subsections)
            .firstWhereOrNull((section) => section.subsections.contains(node)),
      ),
      model: model,
    ));
  }

  void toggleProjectDrawer() {
    emit(state.copyWith(isProjectOpen: !state.isProjectOpen));
  }

  void toggleDiagnosticsDrawer() {
    emit(state.copyWith(isDiagnosticsOpen: !state.isDiagnosticsOpen));
  }

  void selectSectionType(WisDocumentSectionType type) {
    emit(state.copyWith(selectedDocumentType: type));
  }

  void selectSection(WisSection section) {
    emit(state.copyWith(selectedSection: section));
  }

  void selectDocument(WisDocument? document) {
    emit(state.copyWith(selectedDocument: document));
  }
}
