import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:flutter/material.dart';

class InlineExpandableSelector extends StatelessWidget {
  final String label;
  final String hint;
  final String? selected;
  final List<String> values;
  final bool isOpen;
  final bool isDisabled;
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onSelected;

  const InlineExpandableSelector({
    super.key,
    required this.label,
    required this.hint,
    required this.selected,
    required this.values,
    required this.isOpen,
    required this.isDisabled,
    required this.onHeaderTap,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CustomTextContainer(
            textKey: label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isDisabled ? null : onHeaderTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: appContentHorizontalPadding,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextContainer(
                          textKey: selected ?? hint,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDisabled
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.5)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isOpen ? 0.5 : 0,
                        child: Icon(
                          Icons.expand_more,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Divider(
                          height: 1,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      ...values.map(
                        (v) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelected(v),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: appContentHorizontalPadding,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextContainer(
                                    textKey: v,
                                    style: const TextStyle(fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: (isOpen && !isDisabled)
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
