import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';


class SortSelectionBottomsheet extends StatefulWidget {
  final String selectedValue;
  final Function(String) onSelection;

  const SortSelectionBottomsheet({
    super.key,
    required this.selectedValue,
    required this.onSelection,
  });

  @override
  State<SortSelectionBottomsheet> createState() =>
      _SortSelectionBottomsheetState();
}

class _SortSelectionBottomsheetState extends State<SortSelectionBottomsheet> {
  late String _selectedSort;

  final List<Map<String, String>> _sortOptions = [
    {'key': 'new', 'labelKey': 'newestFirst'},
    {'key': 'old', 'labelKey': 'oldestFirst'},
    {'key': 'negative', 'labelKey': 'negativeNotes'},
    {'key': 'positive', 'labelKey': 'positiveNotes'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator at the top
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with title and close button
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextContainer(
                  textKey: sortByKey,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Divider(
              color: Theme.of(context).colorScheme.tertiary,
              height: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
          ),

          // Sort options list
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Column(
              children: _sortOptions.map((option) {
                final isSelected = _selectedSort == option['key'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSort = option['key']!;
                    });
                    // Trigger the selection immediately
                    widget.onSelection(_selectedSort);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextContainer(
                          textKey: option['labelKey']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        // Radio button indicator - matching the image design
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary, // White dot in center like the image
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
