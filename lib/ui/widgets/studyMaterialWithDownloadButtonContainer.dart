import 'package:dotted_border/dotted_border.dart';
import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/ui/widgets/downloadFileButton.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudyMaterialWithDownloadButtonContainer extends StatelessWidget {
  final BoxConstraints boxConstraints;
  final StudyMaterial studyMaterial;
  const StudyMaterialWithDownloadButtonContainer({
    Key? key,
    required this.boxConstraints,
    required this.studyMaterial,
  }) : super(key: key);

  Future<void> _handleOtherLinkTap() async {
    final Uri uri = Uri.parse(studyMaterial.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: GestureDetector(
        onTap: studyMaterial.isOtherLink
            ? _handleOtherLinkTap
            : () {
                Utils.openDownloadBottomsheet(
                  context: context,
                  storeInExternalStorage: false,
                  studyMaterial: studyMaterial,
                );
              },
        child: DottedBorder(
          borderType: BorderType.RRect,
          dashPattern: const [10, 10],
          radius: const Radius.circular(10.0),
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 7.5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    studyMaterial.isOtherLink
                        ? studyMaterial.fileUrl
                        : studyMaterial.fileName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                studyMaterial.isOtherLink
                    ? _buildLinkButton(context)
                    : DownloadFileButton(
                        studyMaterial: studyMaterial,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link,
            color: Theme.of(context).scaffoldBackgroundColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Open',
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
