import 'package:bepop_ngu/data/models/announcement.dart';
import 'package:bepop_ngu/ui/widgets/studyMaterialWithDownloadButtonContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';

class AnnouncementDetailsContainer extends StatefulWidget {
  final Announcement announcement;
  const AnnouncementDetailsContainer({Key? key, required this.announcement})
      : super(key: key);

  @override
  State<AnnouncementDetailsContainer> createState() =>
      _AnnouncementDetailsContainerState();
}

class _AnnouncementDetailsContainerState
    extends State<AnnouncementDetailsContainer>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  bool get _shouldShowReadMore {
    return widget.announcement.description.length >
        maxAnnouncementDescriptionLength;
  }

  String get _displayText {
    if (!_shouldShowReadMore) {
      return widget.announcement.description;
    }
    return _isExpanded
        ? widget.announcement.description
        : '${widget.announcement.description.substring(0, maxAnnouncementDescriptionLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _shouldShowReadMore
          ? () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10.0),
          // Add subtle visual feedback when tappable
          border: _shouldShowReadMore
              ? Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  width: 1,
                )
              : null,
        ),
        width: MediaQuery.of(context).size.width * (0.85),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.announcement.title,
                  style: TextStyle(
                    height: 1.2,
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(
                  height: widget.announcement.description.isEmpty ? 0 : 5,
                ),
                widget.announcement.description.isEmpty
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Text(
                              _displayText,
                              style: TextStyle(
                                height: 1.2,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w400,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          if (_shouldShowReadMore) ...[
                            const SizedBox(height: 5),
                            Text(
                              _isExpanded
                                  ? Utils.getTranslatedLabel(readLessKey)
                                  : Utils.getTranslatedLabel(readMoreKey),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                ...widget.announcement.files
                    .map(
                      (studyMaterial) => GestureDetector(
                        onTap: null, // Disable parent tap for file downloads
                        child: StudyMaterialWithDownloadButtonContainer(
                          boxConstraints: boxConstraints,
                          studyMaterial: studyMaterial,
                        ),
                      ),
                    )
                    .toList(),
                SizedBox(
                  height: widget.announcement.files.isNotEmpty ? 0 : 5,
                ),
                Text(
                  widget.announcement.createdAt,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75),
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.start,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
