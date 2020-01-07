import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/topicStudyMaterialCubit.dart';
import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/data/models/topic.dart';
import 'package:bepop_ngu/data/repositories/subjectRepository.dart';
import 'package:bepop_ngu/ui/widgets/customRefreshIndicator.dart';
import 'package:bepop_ngu/ui/widgets/customShimmerContainer.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/filesContainer.dart';
import 'package:bepop_ngu/ui/widgets/otherLinksContainer.dart';

import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:bepop_ngu/ui/widgets/shimmerLoadingContainer.dart';
import 'package:bepop_ngu/ui/widgets/svgButton.dart';
import 'package:bepop_ngu/ui/widgets/videosContainer.dart';

import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TopicDetailsScreen extends StatefulWidget {
  final Topic topic;
  final int? childId;
  const TopicDetailsScreen({Key? key, required this.topic, this.childId})
      : super(key: key);

  @override
  State<TopicDetailsScreen> createState() => _TopicDetailsScreenState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider<TopicStudyMaterialCubit>(
      create: (context) => TopicStudyMaterialCubit(SubjectRepository()),
      child: TopicDetailsScreen(
        topic: arguments['topic'],
        childId: arguments['childId'],
      ),
    );
  }
}

class _TopicDetailsScreenState extends State<TopicDetailsScreen> {
  late String _selectedTabTitleKey = filesKey;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchStudyMaterials();
    });
  }

  void fetchStudyMaterials() {
    context.read<TopicStudyMaterialCubit>().fetchStudyMaterials(
          childId: widget.childId,
          userParentApi: context.read<AuthCubit>().isParent(),
          lessonId: widget.topic.lessonId,
          topicId: widget.topic.id,
        );
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: Utils.screenContentHorizontalPadding,
                  ),
                  child: SvgButton(
                    onTap: () {
                      Get.back();
                    },
                    svgIconUrl: Utils.getBackButtonPath(context),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: boxConstraints.maxWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: boxConstraints.maxWidth * (0.2),
                  ),
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.topic.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
              // Custom 3-tab background container
              AnimatedPositioned(
                duration: Utils.tabBackgroundContainerAnimationDuration,
                curve: Utils.tabBackgroundContainerAnimationCurve,
                left: _selectedTabTitleKey == filesKey
                    ? boxConstraints.maxWidth * 0.05
                    : _selectedTabTitleKey == videosKey
                        ? boxConstraints.maxWidth * 0.35
                        : boxConstraints.maxWidth * 0.65,
                top: boxConstraints.maxHeight * 0.4,
                child: Container(
                  width: boxConstraints.maxWidth * 0.3,
                  height: boxConstraints.maxHeight * 0.325,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              // Files Tab
              Positioned(
                left: boxConstraints.maxWidth * 0.05,
                top: boxConstraints.maxHeight * 0.4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabTitleKey = filesKey;
                    });
                  },
                  child: Container(
                    width: boxConstraints.maxWidth * 0.3,
                    height: boxConstraints.maxHeight * 0.325,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: AnimatedDefaultTextStyle(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: _selectedTabTitleKey == filesKey
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Text(
                        Utils.getTranslatedLabel(filesKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              // Videos Tab
              Positioned(
                left: boxConstraints.maxWidth * 0.35,
                top: boxConstraints.maxHeight * 0.4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabTitleKey = videosKey;
                    });
                  },
                  child: Container(
                    width: boxConstraints.maxWidth * 0.3,
                    height: boxConstraints.maxHeight * 0.325,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: AnimatedDefaultTextStyle(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: _selectedTabTitleKey == videosKey
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Text(
                        Utils.getTranslatedLabel(videosKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              // Other Links Tab
              Positioned(
                left: boxConstraints.maxWidth * 0.65,
                top: boxConstraints.maxHeight * 0.4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabTitleKey = otherLinkKey;
                    });
                  },
                  child: Container(
                    width: boxConstraints.maxWidth * 0.3,
                    height: boxConstraints.maxHeight * 0.325,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: AnimatedDefaultTextStyle(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: _selectedTabTitleKey == otherLinkKey
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Text(
                        Utils.getTranslatedLabel(otherLinkKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoadingFileContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return ShimmerLoadingContainer(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.6),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.4),
                    ),
                  ],
                ),
                const Spacer(),
                CustomShimmerContainer(
                  height: boxConstraints.maxWidth * (0.075),
                  width: boxConstraints.maxWidth * (0.075),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoadingVideoContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return ShimmerLoadingContainer(
            child: Row(
              children: [
                CustomShimmerContainer(
                  height: 65,
                  width: boxConstraints.maxWidth * (0.35),
                ),
                SizedBox(
                  width: boxConstraints.maxWidth * (0.05),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.5),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.35),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoadingOtherLinksContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return ShimmerLoadingContainer(
            child: Row(
              children: [
                CustomShimmerContainer(
                  height: 65,
                  width: boxConstraints.maxWidth * (0.3),
                ),
                SizedBox(
                  width: boxConstraints.maxWidth * (0.05),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.5),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.35),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(TopicStudyMaterialFetchSuccess state) {
    if (_selectedTabTitleKey == filesKey) {
      return FilesContainer(
        files: state.studyMaterials
            .where(
              (element) => element.studyMaterialType == StudyMaterialType.file,
            )
            .toList(),
      );
    } else if (_selectedTabTitleKey == videosKey) {
      return VideosContainer(
        studyMaterials: state.studyMaterials
            .where(
              (element) =>
                  element.studyMaterialType == StudyMaterialType.youtubeVideo ||
                  element.studyMaterialType ==
                      StudyMaterialType.uploadedVideoUrl,
            )
            .toList(),
      );
    } else {
      return OtherLinksContainer(
        studyMaterials: state.studyMaterials
            .where(
              (element) => element.studyMaterialType == StudyMaterialType.other,
            )
            .toList(),
      );
    }
  }

  Widget _buildShimmerContent() {
    if (_selectedTabTitleKey == filesKey) {
      return _buildShimmerLoadingFileContainer();
    } else if (_selectedTabTitleKey == videosKey) {
      return _buildShimmerLoadingVideoContainer();
    } else {
      return _buildShimmerLoadingOtherLinksContainer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child:
                BlocBuilder<TopicStudyMaterialCubit, TopicStudyMaterialState>(
              builder: (context, state) {
                if (state is TopicStudyMaterialFetchSuccess) {
                  return CustomRefreshIndicator(
                    onRefreshCallback: () {
                      fetchStudyMaterials();
                    },
                    displacment: Utils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          Utils.appBarBiggerHeightPercentage,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: Utils.getScrollViewTopPadding(
                          context: context,
                          appBarHeightPercentage:
                              Utils.appBarBiggerHeightPercentage,
                        ),
                      ),
                      child: _buildContent(state),
                    ),
                  );
                }
                if (state is TopicStudyMaterialFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      onTapRetry: () {
                        fetchStudyMaterials();
                      },
                      errorMessageCode: state.errorMessage,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: Utils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          Utils.appBarBiggerHeightPercentage,
                    ),
                  ),
                  child: Column(
                    children: List.generate(
                      Utils.defaultShimmerLoadingContentCount,
                      (index) => index,
                    )
                        .map(
                          (e) => _buildShimmerContent(),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
          Align(alignment: Alignment.topCenter, child: _buildAppBar()),
        ],
      ),
    );
  }
}
