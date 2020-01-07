import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepop_ngu/cubits/examTabSelectionCubit.dart';
import 'package:bepop_ngu/cubits/examsOnlineCubit.dart';
import 'package:bepop_ngu/cubits/studentSubjectAndSlidersCubit.dart';

import 'package:bepop_ngu/data/models/examOnline.dart';
import 'package:bepop_ngu/data/models/subject.dart';

import 'package:bepop_ngu/ui/widgets/assignmentsSubjectsContainer.dart';
import 'package:bepop_ngu/ui/widgets/customRefreshIndicator.dart';
import 'package:bepop_ngu/ui/widgets/customShimmerContainer.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/examOnlineKeyBottomsheetContainer.dart';
import 'package:bepop_ngu/ui/widgets/listItemForOnlineExamAndOnlineResult.dart';
import 'package:bepop_ngu/ui/widgets/noDataContainer.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:bepop_ngu/ui/widgets/shimmerLoadingContainer.dart';

import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:get/get.dart';

class ExamOnlineListContainer extends StatefulWidget {
  final int? childId;
  final List<Subject>? subjects;

  const ExamOnlineListContainer({Key? key, this.childId, this.subjects})
      : super(key: key);

  @override
  State<ExamOnlineListContainer> createState() =>
      _ExamOnlineListContainerState();
}

class _ExamOnlineListContainerState extends State<ExamOnlineListContainer> {
  late ExamOnline examSelected;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_examOnlinesScrollListener);

  void _examOnlinesScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<ExamsOnlineCubit>().hasMore()) {
        context.read<ExamsOnlineCubit>().getMoreExamsOnline(
              childId: widget.childId ?? 0,
              useParentApi: context.read<AuthCubit>().isParent(),
            );
      }
    }
  }

  void fetchExamsList() {
    Future.delayed(Duration.zero, () {
      context.read<ExamsOnlineCubit>().getExamsOnline(
            classSubjectId: context
                .read<ExamTabSelectionCubit>()
                .state
                .examFilterByClassSubjectId,
            childId: widget.childId ?? 0,
            useParentApi: context.read<AuthCubit>().isParent(),
          );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExamsList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_examOnlinesScrollListener);
    _scrollController.dispose();
    super.dispose();
  }


  Future<void> navigateToExamScreen() async {
    Get.back();

    Get.toNamed(
      Routes.examOnline,
      arguments: {
        "exam": examSelected,
      },
    );
  }

  void onTapOnlineExam(ExamOnline exam) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      elevation: 5.0,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return ExamOnlineKeyBottomsheetContainer(
          navigateToExamScreen: navigateToExamScreen,
          exam: exam,
        );
      },
    );
  }

  Widget _buildExamOnlineList(List<ExamOnline> examList) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            examList.length,
            (index) => ListItemForOnlineExamAndOnlineResult(
              isExamStarted: examList[index].isExamStarted,
              examStartingDate: examList[index].startDateIso ??
                  examList[index].startDate ??
                  "",
              examEndingDate:
                  examList[index].endDateIso ?? examList[index].endDate,
              examName: examList[index].title ?? "",
              subjectName:
                  examList[index].subject?.getSubjectName(context: context) ??
                      "",
              totalMarks: examList[index].totalMarks ?? "",
              isSubjectSelected: context
                      .read<ExamTabSelectionCubit>()
                      .state
                      .examFilterByClassSubjectId !=
                  0,
              marks: '',
              onItemTap: () {
                if (context.read<AuthCubit>().isParent()) {
                  //do not allow parent to attend exam
                } else {
                  setState(() {
                    examSelected = examList[index];
                    //to be passed to Main Exam screen
                  });

                  // Check if exam can be taken using the new date-time logic
                  if (!examList[index].canTakeExam) {
                    if (!examList[index].isExamStarted) {
                      // Exam hasn't started yet
                      Utils.showCustomSnackBar(
                        context: context,
                        errorMessage: Utils.getTranslatedLabel(
                          noExamTodayKey,
                        ),
                        backgroundColor: Utils.getColorScheme(context).error,
                      );
                    } else if (examList[index].isExamEnded) {
                      // Exam has ended
                      Utils.showCustomSnackBar(
                        context: context,
                        errorMessage: Utils.getTranslatedLabel(
                          noExamNowKey,
                        ),
                        backgroundColor: Utils.getColorScheme(context).error,
                      );
                    }
                    return;
                  }

                  // Exam is currently active, allow student to take it
                  onTapOnlineExam(examList[index]);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: Utils.screenContentHorizontalPaddingInPercentage *
            MediaQuery.of(context).size.width,
      ),
      child: ShimmerLoadingContainer(
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.035),
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 9,
                    width: boxConstraints.maxWidth * (0.3),
                  ),
                ),
                SizedBox(
                  height: boxConstraints.maxWidth * (0.02),
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 10,
                    width: boxConstraints.maxWidth * (0.8),
                  ),
                ),
                SizedBox(
                  height: boxConstraints.maxWidth * (0.1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamLoading() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              Utils.defaultShimmerLoadingContentCount,
              (index) => _buildExamShimmerLoadingContainer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMySubjectsListContainer() {
    return BlocBuilder<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      builder: (context, state) {
        return BlocBuilder<ExamTabSelectionCubit, ExamTabSelectionState>(
          bloc: context.read<ExamTabSelectionCubit>(),
          builder: (context, state) {
            return AssignmentsSubjectContainer(
              cubitAndState: "onlineExam",
              subjects: (widget.subjects != null)
                  ? widget.subjects! //from parent
                  : context
                      .read<StudentSubjectsAndSlidersCubit>()
                      .getSubjectsForAssignmentContainer(),
              onTapSubject: (classSubjectId) {
                context
                    .read<ExamTabSelectionCubit>()
                    .changeExamFilterBySubjectId(classSubjectId);
                fetchExamsList();
              },
              selectedClassSubjectId: state.examFilterByClassSubjectId,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      displacment: Utils.getScrollViewTopPadding(
        context: context,
        appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
      ),
      onRefreshCallback: () {
        if (kDebugMode) {
          print("refresh - fetch exams list");
        }
        fetchExamsList();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: Utils.getScrollViewBottomPadding(context),
          top: Utils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
          ),
        ),
        child: Column(
          children: [
            buildMySubjectsListContainer(),
            BlocBuilder<ExamsOnlineCubit, ExamsOnlineState>(
              builder: (context, state) {
                if (state is ExamsOnlineFetchSuccess) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: state.examList.isEmpty
                        ? const NoDataContainer(titleKey: noExamsFoundKey)
                        : Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    (0.035),
                              ),
                              _buildExamOnlineList(state.examList),
                            ],
                          ),
                  );
                }
                if (state is ExamsOnlineFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: () {
                      if (kDebugMode) {
                        print("Retry - fetch exams list");
                      }
                      fetchExamsList();
                    },
                  );
                }
                return _buildExamLoading();
              },
            ),
          ],
        ),
      ),
    );
  }
}
