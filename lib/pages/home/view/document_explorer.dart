import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:gap/gap.dart';
import 'package:saab_wis/extensions/context.dart';
import 'package:saab_wis/pages/home/home.dart';
import 'package:wis_base/wis_base.dart';

class DocumentExplorer extends StatelessWidget {
  const DocumentExplorer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeCubit>().state;
    final treeController = state.treeController;
    final colorScheme = context.watchColorScheme;
    final textColor = Color.lerp(colorScheme.onSurface, colorScheme.surfaceContainerHighest, 0);
    final hoverColor = colorScheme.brightness == Brightness.light ? colorScheme.primary : colorScheme.tertiary;

    return Material(
      color: Colors.transparent,
      child: AnimatedTreeView<WisSection>(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        treeController: treeController,
        shrinkWrap: true,
        nodeBuilder: (context, node) {
          final canExpand = node.hasChildren;
          final text = Text(
            node.node.name,
            style: TextStyle(color: textColor),
          );
          return Container(
            color: state.selectedSection == node.node ? hoverColor.withOpacity(0.3) : Colors.transparent,
            child: InkWell(
              onTap: () {
                treeController.toggleExpansion(node.node);
                if (node.node.documentSections?.isNotEmpty == true) {
                  context.read<HomeCubit>().selectSection(node.node);
                }
              },
              hoverColor: hoverColor.withOpacity(0.3),
              splashColor: hoverColor.withOpacity(0.5),
              child: TreeIndentation(
                entry: node,
                guide: const IndentGuide.connectingLines(
                  indent: 20,
                  origin: 0.9,
                  thickness: 0.5,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4).copyWith(left: 12),
                  child: Row(
                    children: [
                      if (canExpand) ...[
                        Icon(node.isExpanded ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_right, size: 13),
                        const Gap(8),
                      ],
                      const Gap(4),
                      Expanded(child: text),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
