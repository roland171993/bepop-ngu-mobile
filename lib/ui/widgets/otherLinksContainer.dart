import 'package:cached_network_image/cached_network_image.dart';
import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/ui/widgets/noDataContainer.dart';
import 'package:bepop_ngu/utils/animationConfiguration.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherLinksContainer extends StatelessWidget {
  final List<StudyMaterial> studyMaterials;
  const OtherLinksContainer({Key? key, required this.studyMaterials})
      : super(key: key);

  Widget _buildOtherLinkContainer({
    required StudyMaterial studyMaterial,
    required BuildContext context,
  }) {
    return Animate(
      effects: customItemFadeAppearanceEffects(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final Uri uri = Uri.parse(studyMaterial.fileUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                  offset: const Offset(5, 5),
                  blurRadius: 10,
                )
              ],
            ),
            width: MediaQuery.of(context).size.width * (0.85),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: studyMaterial.fileThumbnail.isNotEmpty
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  studyMaterial.fileThumbnail,
                                ),
                              )
                            : null,
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 65,
                      width: boxConstraints.maxWidth * (0.3),
                      child: studyMaterial.fileThumbnail.isEmpty
                          ? Icon(
                              Icons.link,
                              size: 30,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            )
                          : null,
                    ),
                    SizedBox(
                      width: boxConstraints.maxWidth * (0.05),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studyMaterial.fileName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            studyMaterial.fileUrl,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                              fontSize: 11.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: studyMaterials.isEmpty
          ? [const NoDataContainer(titleKey: noOtherLinksUploadedKey)]
          : studyMaterials
              .map(
                (studyMaterial) => _buildOtherLinkContainer(
                  studyMaterial: studyMaterial,
                  context: context,
                ),
              )
              .toList(),
    );
  }
}
