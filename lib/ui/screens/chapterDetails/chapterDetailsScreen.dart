import 'package:bepop_ngu/data/models/lesson.dart';
import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/ui/widgets/filesContainer.dart';
import 'package:bepop_ngu/ui/widgets/otherLinksContainer.dart';
import 'package:bepop_ngu/ui/screens/chapterDetails/widgets/topicsContainer.dart';
import 'package:bepop_ngu/ui/widgets/videosContainer.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterDetailsScreen extends StatefulWidget {
  final Lesson lesson;

  final int? childId;
  const ChapterDetailsScreen({Key? key, required this.lesson, this.childId})
      : super(key: key);

  @override
  State<ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;

    return ChapterDetailsScreen(
      lesson: arguments['lesson'],
      childId: arguments['childId'],
    );
  }
}

class _ChapterDetailsScreenState extends State<ChapterDetailsScreen> {
  late String _selectedTabTitleKey = topicsKey;
  late List<String> chapterContentTitles = [
    topicsKey,
    filesKey,
    videosKey,
    otherLinkKey
  ];

  Widget _buildAppBar() {
    return CustomAppBar(title: widget.lesson.name);
  }

  Widget _buildChapterContentTitles() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (0.05),
      ),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: chapterContentTitles
            .map(
              (title) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabTitleKey = title;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _selectedTabTitleKey == title
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    alignment: Alignment.center,
                    child: Text(
                      Utils.getTranslatedLabel(title),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedTabTitleKey == title
                            ? Theme.of(context).scaffoldBackgroundColor
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: Utils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
                ),
              ),
              child: Column(
                children: [
                  _buildChapterContentTitles(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.025),
                  ),
                  _selectedTabTitleKey == topicsKey
                      ? TopicsContainer(
                          topics: widget.lesson.topics,
                          childId: widget.childId,
                        )
                      : _selectedTabTitleKey == filesKey
                          ? FilesContainer(
                              files: widget.lesson.studyMaterials
                                  .where(
                                    (element) =>
                                        element.studyMaterialType ==
                                        StudyMaterialType.file,
                                  )
                                  .toList(),
                            )
                          : _selectedTabTitleKey == videosKey
                              ? VideosContainer(
                                  studyMaterials: widget.lesson.studyMaterials
                                      .where(
                                        (element) =>
                                            element.studyMaterialType ==
                                                StudyMaterialType
                                                    .youtubeVideo ||
                                            element.studyMaterialType ==
                                                StudyMaterialType
                                                    .uploadedVideoUrl,
                                      )
                                      .toList(),
                                )
                              : OtherLinksContainer(
                                  studyMaterials: widget.lesson.studyMaterials
                                      .where(
                                        (element) =>
                                            element.studyMaterialType ==
                                            StudyMaterialType.other,
                                      )
                                      .toList(),
                                )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
    );
  }
}
