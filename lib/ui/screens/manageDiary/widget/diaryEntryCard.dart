import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class DiaryEntryCard extends StatefulWidget {
  final Map<String, dynamic> entry;

  const DiaryEntryCard({
    super.key,
    required this.entry,
  });

  @override
  State<DiaryEntryCard> createState() => _DiaryEntryCardState();
}

class _DiaryEntryCardState extends State<DiaryEntryCard> {
  bool _isExpanded = false;
  bool _hasTextOverflow = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  bool _checkTextOverflow({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = widget.entry['categoryType'] == 'positive';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for text (accounting for padding and margins)
        final double availableWidth = constraints.maxWidth -
            (appContentHorizontalPadding * 2) -
            16 - // Padding for the bullet point
            8; // SizedBox width

        // Check if title or description overflows
        final titleStyle = TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
        final descriptionStyle = TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
          height: 1.4,
        );

        final titleOverflows = _checkTextOverflow(
          text: widget.entry['title'] ?? '',
          style: titleStyle,
          maxWidth: availableWidth,
          maxLines: 1,
        );

        final descriptionOverflows = _checkTextOverflow(
          text: widget.entry['description'] ?? '',
          style: descriptionStyle,
          maxWidth: availableWidth,
          maxLines: 3,
        );

        final hasOverflow = titleOverflows || descriptionOverflows;

        // Update overflow state if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_hasTextOverflow != hasOverflow) {
            setState(() {
              _hasTextOverflow = hasOverflow;
            });
          }
        });

        return Container(
          margin: EdgeInsets.only(
            left: appContentHorizontalPadding,
            right: appContentHorizontalPadding,
            bottom: 15,
          ),
          padding: EdgeInsets.all(appContentHorizontalPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.tertiary,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Category and Timestamp
              Row(
                children: [
                  // Category Tag
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomTextContainer(
                        textKey: widget.entry['category'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Timestamp
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CustomTextContainer(
                        textKey: widget.entry['timestamp'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Expand/Collapse Button - Only shown when text overflows
                  if (_hasTextOverflow)
                    GestureDetector(
                      onTap: _toggleExpanded,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _isExpanded
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary // Dark teal/blue when active
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(
                                      alpha: 0.2), // Light blue when inactive
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isExpanded
                                ? Icons
                                    .arrow_drop_up // Upward arrow when expanded
                                : Icons
                                    .arrow_drop_down, // Downward arrow when collapsed
                            key: ValueKey(
                                _isExpanded), // Key for smooth transition
                            size: 24,
                            color: _isExpanded
                                ? Colors.white // White arrow when active
                                : Theme.of(context)
                                    .colorScheme
                                    .primary, // Dark blue arrow when inactive
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // First Divider
              Container(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.9),
              ),

              const SizedBox(height: 14),

              // Entry Title with Color Indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Title
                  Expanded(
                    child: CustomTextContainer(
                      textKey: widget.entry['title'] ?? '',
                      style: titleStyle,
                      maxLines: _isExpanded ? null : 1,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Entry Description - Expandable
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: CustomTextContainer(
                  textKey: widget.entry['description'] ?? '',
                  style: descriptionStyle,
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),

              // Divider after description - Always visible
              const SizedBox(height: 16),

              Container(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.9),
              ),

              // Subject Information Section - Only visible when subject data exists
              if (widget.entry['subject'] != null &&
                  widget.entry['subject'].toString().trim().isNotEmpty) ...[
                const SizedBox(height: 12),

                // Subject Row with Vertical Divider
                Row(
                  children: [
                    // Subject Label
                    CustomTextContainer(
                      textKey: subjectKey,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Vertical Divider
                    Container(
                      width: 1,
                      height: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.9),
                    ),

                    const SizedBox(width: 12),

                    // Subject Name
                    Expanded(
                      child: CustomTextContainer(
                        textKey: widget.entry['subject']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
