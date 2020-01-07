import 'dart:async';
import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/examTabSelectionCubit.dart';
import 'package:bepop_ngu/cubits/examsOnlineCubit.dart';
import 'package:bepop_ngu/cubits/submitOnlineExamAnswersCubit.dart';
import 'package:bepop_ngu/data/models/answerOption.dart';
import 'package:bepop_ngu/data/models/question.dart';
import 'package:bepop_ngu/data/repositories/onlineExamRepository.dart';
import 'package:bepop_ngu/ui/screens/home/homeScreen.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';

import 'package:bepop_ngu/cubits/onlineExamQuestionsCubit.dart';
import 'package:bepop_ngu/ui/screens/exam/onlineExam/widgets/examQuestionStatusBottomSheetContainer.dart';
import 'package:bepop_ngu/ui/screens/exam/onlineExam/widgets/examTimerContainer.dart';
import 'package:bepop_ngu/ui/screens/exam/onlineExam/widgets/optionContainer.dart';
import 'package:bepop_ngu/ui/screens/exam/onlineExam/widgets/questionContainer.dart';

import 'package:bepop_ngu/ui/widgets/customBackButton.dart';
import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';

import 'package:bepop_ngu/data/models/examOnline.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ExamOnlineScreen extends StatefulWidget {
  final ExamOnline exam;
  const ExamOnlineScreen({Key? key, required this.exam}) : super(key: key);

  @override
  ExamOnlineScreenState createState() => ExamOnlineScreenState();
  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => SubmitOnlineExamAnswersCubit(OnlineExamRepository()),
      child: ExamOnlineScreen(
        exam: arguments['exam'],
      ),
    );
  }
}

class ExamOnlineScreenState extends State<ExamOnlineScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ExamTimerContainerState> timerKey =
      GlobalKey<ExamTimerContainerState>();
  late PageController pageController = PageController();

  bool isExitDialogOpen = false;
  bool isExamQuestionStatusBottomsheetOpen = false;
  bool isExamCompleted = false;
  bool isSubmissionInProgress = false;
  bool isExitTriggeredSubmission = false;

  int currentQuestionIndex = 0;
  Map<int, List<int>> _selectedAnswersWithQuestionId = {};

  Timer? canGiveExamAgainTimer;
  bool canGiveExamAgain = true;

  int canGiveExamAgainTimeInSeconds = 5;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      timerKey.currentState?.startTimer();
    });

    WakelockPlus.enable();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    canGiveExamAgainTimer?.cancel();
    WakelockPlus.disable();

    super.dispose();
  }

  void setCanGiveExamTimer() {
    canGiveExamAgainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (canGiveExamAgainTimeInSeconds == 0) {
        timer.cancel();

        //can give exam again false
        canGiveExamAgain = false;

        //show exam complete
        if (!isExamCompleted) submitExamAnswers();
        //submit only if not submitted before
      } else {
        canGiveExamAgainTimeInSeconds--;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      setCanGiveExamTimer();
    } else if (state == AppLifecycleState.resumed) {
      canGiveExamAgainTimer?.cancel();
      //if user can give exam again
      if (canGiveExamAgain) {
        canGiveExamAgainTimeInSeconds = 5;
      }
    }
  }

  void onBackPress() {
    // Prevent multiple dialogs from opening
    if (isExitDialogOpen) return;

    isExitDialogOpen = true;

    if (!isExamCompleted) {
      // Use WidgetsBinding to show dialog after current frame to avoid navigation conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && isExitDialogOpen) {
          _showExitConfirmationDialog();
        }
      });
    } else {
      // If exam is completed, allow back navigation
      isExitDialogOpen = false;
      Get.back();
    }
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            Utils.getTranslatedLabel(quitExamKey),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                Utils.getTranslatedLabel(noKey),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onPressed: () {
                setState(() {
                  isExitDialogOpen = false;
                });
                Navigator.of(context).pop(); // Close dialog only
              },
            ),
            TextButton(
              child: Text(
                Utils.getTranslatedLabel(yesKey),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                setState(() {
                  isExitDialogOpen = false;
                  isExamCompleted =
                      true; // Mark exam as completed to allow navigation
                  isExitTriggeredSubmission =
                      true; // Track that this was an exit-triggered submission
                });
                Navigator.of(context).pop(); // Close dialog
                submitExamAnswers(); // Submit exam - BlocListener will handle navigation
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildOnlineExamAppbar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: Utils.appBarMediumtHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomBackButton(onTap: onBackPress),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              widget.exam.subject?.getSubjectName(context: context) ?? "",
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: Utils.screenTitleFontSize,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 25.0),
              child: ExamTimerContainer(
                navigateToResultScreen: finishExamOnline,
                examDurationInMinutes: widget.exam.duration ?? 0,
                key: timerKey,
              ),
            ),
          ),
          Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.exam.title ?? "",
                    style: TextStyle(
                      color: Utils.getColorScheme(context).surface,
                      fontSize: Utils.screenSubTitleFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Utils.getColorScheme(context).surface,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Flexible(
                  child: Text(
                    "${widget.exam.totalMarks} ${Utils.getTranslatedLabel(marksKey)}",
                    style: TextStyle(
                      color: Utils.getColorScheme(context).surface,
                      fontSize: Utils.screenSubTitleFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showExamQuestionStatusBottomSheet() {
    final submitOnlineExamAnswersCubit =
        context.read<SubmitOnlineExamAnswersCubit>();
    isExamQuestionStatusBottomsheetOpen = true;
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5.0,
      context: context,
      isDismissible: !isSubmissionInProgress,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return ExamQuestionStatusBottomSheetContainer(
          submitOnlineExamAnswersCubit: submitOnlineExamAnswersCubit,
          onlineExamId: widget.exam.id ?? 0,
          submittedAnswers: _selectedAnswersWithQuestionId,
          navigateToResultScreen: finishExamOnline,
          pageController: pageController,
        );
      },
    );
    /*
    .then((value) {
      isExamQuestionStatusBottomsheetOpen = false;
    });
     */
  }

  void submitQuestionAnswer(Question question, AnswerOption answerOption) {
    List<int> submittedAnswerIds =
        _selectedAnswersWithQuestionId[question.id] ?? List<int>.from([]);

    //If the total correct answer and submitted answer length is same then

    if (question.totalCorrectAnswer() == submittedAnswerIds.length) {
      // If all options are already selected, do nothing
      if (submittedAnswerIds.length == (question.options ?? []).length) {
        return;
      }

      // Only remove if the list is not empty (prevents RangeError)
      if (submittedAnswerIds.isNotEmpty) {
        submittedAnswerIds.removeAt(0);
      }
      submittedAnswerIds.add(answerOption.id ?? 0);
    } else {
      //submit the answer
      submittedAnswerIds.add(answerOption.id ?? 0);
    }

    _selectedAnswersWithQuestionId[question.id ?? 0] = submittedAnswerIds;

    setState(() {});
  }

  void submitExamAnswers() {
    context.read<SubmitOnlineExamAnswersCubit>().submitAnswers(
        examId: widget.exam.id ?? 0, answers: _selectedAnswersWithQuestionId);
  }

  void finishExamOnline() {
    Future.delayed(Duration.zero, () {
      timerKey.currentState?.cancelTimer();
    });

    if (isExamQuestionStatusBottomsheetOpen && !isSubmissionInProgress) {
      Get.back();
    }
    if (isExitDialogOpen) {
      Get.back();
    }
    if (!isExamCompleted) {
      submitExamAnswers();
    }
  }

  Widget buildBottomButton() {
    return Container(
      width: MediaQuery.of(context).size.width * (0.345),
      height: MediaQuery.of(context).size.height * (0.045),
      decoration: BoxDecoration(
        color: Utils.getColorScheme(context).primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: IconButton(
        onPressed: () {
          showExamQuestionStatusBottomSheet();
        },
        padding: EdgeInsets.zero,
        color: Utils.getColorScheme(context).surface,
        highlightColor: Colors.transparent,
        icon: const Icon(
          Icons.keyboard_arrow_up_rounded,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildQuestions() {
    return BlocBuilder<OnlineExamQuestionsCubit, OnlineExamQuestionsState>(
      builder: (context, state) {
        if (state is OnlineExamQuestionsFetchSuccess) {
          return PageView.builder(
            onPageChanged: (index) {
              currentQuestionIndex = index;
              setState(() {});
            },
            controller: pageController,
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final question = state.questions[index];
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: Utils.getScrollViewTopPadding(
                    context: context,
                    appBarHeightPercentage: Utils.appBarMediumtHeightPercentage,
                  ),
                  bottom: MediaQuery.of(context).size.height * 0.06,
                ),
                child: Column(
                  children: [
                    QuestionContainer(
                      questionColor: Utils.getColorScheme(context).secondary,
                      questionNumber: index + 1,
                      question: question,
                    ),
                    (question.totalCorrectAnswer() > 1)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "${Utils.getTranslatedLabel(noteKey)} ${Utils.getTranslatedLabel(selectKey)} ${question.totalCorrectAnswer()} ${Utils.getTranslatedLabel(examMultipleAnsNoteKey)}",
                                    style: TextStyle(
                                      color: Utils.getColorScheme(context)
                                          .onSurface,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      height: 25,
                    ),
                    ...(question.options ?? [])
                        .map(
                          (option) => OptionContainer(
                            question: question,
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * (0.85),
                              maxHeight: MediaQuery.of(context).size.height *
                                  Utils.questionContainerHeightPercentage,
                            ),
                            answerOption: option,
                            submittedAnswerIds:
                                _selectedAnswersWithQuestionId[question.id] ??
                                    List<int>.from([]),
                            submitAnswer: submitQuestionAnswer,
                          ),
                        )
                        .toList(),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget buildExamCompleteDialog() {
    isExamCompleted = true;
    return Container(
      alignment: Alignment.center,
      color: Utils.getColorScheme(context).secondary.withValues(alpha: 0.5),
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/animations/payment_success.json",
              animate: true,
            ),
            Text(
              Utils.getTranslatedLabel(examCompletedKey),
              textAlign: TextAlign.center,
              style: TextStyle(color: Utils.getColorScheme(context).secondary),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          CustomRoundedButton(
            backgroundColor: Utils.getColorScheme(context).primary,
            buttonTitle: Utils.getTranslatedLabel(homeKey),
            titleColor: Theme.of(context).scaffoldBackgroundColor,
            showBorder: false,
            widthPercentage: 0.3,
            height: 45,
            onTap: () {
              Get.back();
              //goto 1st tab [Home] in bottomNavigatonbar
              Get.until((route) => route.isFirst);
              HomeScreen.homeScreenKey.currentState!.changeBottomNavItem(0);
            },
          ),
          CustomRoundedButton(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            buttonTitle: Utils.getTranslatedLabel(resultKey),
            titleColor: Utils.getColorScheme(context).primary,
            showBorder: true,
            borderColor: Utils.getColorScheme(context).primary,
            widthPercentage: 0.3,
            height: 45,
            onTap: () {
              context.read<ExamsOnlineCubit>().getExamsOnline(
                  classSubjectId: context
                              .read<ExamTabSelectionCubit>()
                              .state
                              .examFilterByClassSubjectId ==
                          0
                      ? 0
                      : widget.exam.classSubjectId ?? 0,
                  childId: 0,
                  useParentApi: false);

              Get.offNamed(
                Routes.resultOnline,
                arguments: {
                  "examId": widget.exam.id,
                  "examName": widget.exam.title,
                  "subjectName":
                      widget.exam.subject?.getSubjectName(context: context) ??
                          "",
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isExamCompleted,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !isExamCompleted) {
          onBackPress();
        }
      },
      child: Scaffold(
        floatingActionButton: buildBottomButton(),
        //bottom center button
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        body: Stack(
          children: [
            _buildQuestions(),
            buildOnlineExamAppbar(context),
            BlocConsumer<SubmitOnlineExamAnswersCubit,
                SubmitOnlineExamAnswersState>(
              listener: (context, state) {
                if (state is SubmitOnlineExamAnswersFailure) {
                  isSubmissionInProgress = false;
                  // Reset flags on failure so user can try again
                  if (isExitTriggeredSubmission) {
                    setState(() {
                      isExamCompleted = false;
                      isExitTriggeredSubmission = false;
                    });
                  }
                  Utils.showCustomSnackBar(
                    context: context,
                    errorMessage: Utils.getErrorMessageFromErrorCode(
                      context,
                      state.errorMessage,
                    ),
                    backgroundColor: Utils.getColorScheme(context).error,
                  );
                }
                if (state is SubmitOnlineExamAnswersSuccess) {
                  isExamQuestionStatusBottomsheetOpen = true;
                  isSubmissionInProgress = false;

                  // If submission was triggered by exit dialog, navigate back
                  if (isExitTriggeredSubmission) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        Get.back();
                      }
                    });
                  }
                }
                if (state is SubmitOnlineExamAnswersInProgress) {
                  isSubmissionInProgress = true;
                }
              },
              builder: (context, state) {
                if (state is SubmitOnlineExamAnswersSuccess) {
                  return buildExamCompleteDialog();
                }
                if (isSubmissionInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
