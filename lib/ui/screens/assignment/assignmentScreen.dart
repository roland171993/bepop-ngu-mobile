import 'package:bepop_ngu/cubits/assignmentsCubit.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/undoAssignmentSubmissionCubit.dart';
import 'package:bepop_ngu/cubits/uploadAssignmentCubit.dart';
import 'package:bepop_ngu/data/models/assignment.dart';
import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/data/repositories/assignmentRepository.dart';
import 'package:bepop_ngu/ui/screens/assignment/widgets/undoAssignmentBottomsheetContainer.dart';
import 'package:bepop_ngu/ui/screens/assignment/widgets/uploadAssignmentFilesBottomsheetContainer.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/studyMaterialWithDownloadButtonContainer.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';

class AssignmentScreen extends StatefulWidget {
  final Assignment assignment;
  const AssignmentScreen({Key? key, required this.assignment})
      : super(key: key);

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();

  static Widget routeInstance() {
    return AssignmentScreen(
      assignment: Get.arguments as Assignment,
    );
  }
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  //if this is true, we can show the undo assignment submission button
  bool isUndoAssignmentSubmissionButtonToBeShown = false;

  late bool assignmentSubmitted =
      submittedAssignment.assignmentSubmission.id != 0;
  late Assignment submittedAssignment = widget.assignment;

  void uploadAssignment() {
    Utils.showBottomSheet(
      child: BlocProvider<UploadAssignmentCubit>(
        create: (_) => UploadAssignmentCubit(AssignmentRepository()),
        child: UploadAssignmentFilesBottomsheetContainer(
          assignment: submittedAssignment,
        ),
      ),
      context: context,
      enableDrag: false,
    ).then((value) {
      if (value != null) {
        if (value['error']) {
          Utils.showCustomSnackBar(
            context: context,
            errorMessage: value['message'],
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        } else {
          submittedAssignment = submittedAssignment
              .updateAssignmentSubmission(value['assignmentSubmission']);
          assignmentSubmitted = true;
          context
              .read<AssignmentsCubit>()
              .updateAssignments(submittedAssignment);
          setState(() {});
        }
      }
    });
  }

  void undoAssignment() {
    Utils.showBottomSheet(
      child: BlocProvider<UndoAssignmentSubmissionCubit>(
        create: (_) => UndoAssignmentSubmissionCubit(AssignmentRepository()),
        child: UndoAssignmentBottomsheetContainer(
          assignmentSubmissionId: submittedAssignment.assignmentSubmission.id,
        ),
      ),
      context: context,
      enableDrag: false,
    ).then((value) {
      if (value != null) {
        if (value['error']) {
          Utils.showCustomSnackBar(
            context: context,
            errorMessage: Utils.getErrorMessageFromErrorCode(
              context,
              value['message'].toString(),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        } else {
          submittedAssignment = submittedAssignment
              .updateAssignmentSubmission(AssignmentSubmission.fromJson({}));
          assignmentSubmitted = false;
          isUndoAssignmentSubmissionButtonToBeShown = false;
          setState(() {});
          context
              .read<AssignmentsCubit>()
              .updateAssignments(submittedAssignment);
          uploadAssignment();
        }
      }
    });
  }

  TextStyle _getAssignmentDetailsLabelValueTextStyle() {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _getAssignmentDetailsLabelTextStyle() {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
  }

  bool _showUploadAssignmentButton() {
    if (context.read<AuthCubit>().isParent()) {
      return false;
    }

    String assignmentStatusKey = Utils.getAssignmentSubmissionStatusKey(
      submittedAssignment.assignmentSubmission.status,
    );

    DateTime currentDayDateTime = DateTime.now();

    // Parse the due date using the assignment's dueDateOriginal field
    DateTime? dueDate = submittedAssignment.getParsedDueDate();
    if (dueDate == null) {
      // If parsing fails, hide the button to be safe
      return false;
    }

    //they can undo the assignment submission if it's still in review & due date is not passed
    if (assignmentStatusKey == inReviewKey &&
        currentDayDateTime.compareTo(dueDate) != 1) {
      isUndoAssignmentSubmissionButtonToBeShown = true;
      return true;
    }

    //if assignment submission accepted
    //then hide upload submit button
    if (assignmentStatusKey == acceptedKey ||
        assignmentStatusKey == inReviewKey ||
        assignmentStatusKey == resubmittedKey) {
      return false;
    }

    if (Utils.getAssignmentSubmissionStatusKey(
          submittedAssignment.assignmentSubmission.status,
        ) ==
        rejectedKey) {
      //if assignment submission rejected and resubmission is not allow
      //then hide upload submit button
      if (Utils.getAssignmentSubmissionStatusKey(
            submittedAssignment.assignmentSubmission.status,
          ) ==
          rejectedKey) {
        //if assignment resubmission is not allow then
        //then hide upload submit button
        if (submittedAssignment.resubmission == 0) {
          return false;
        }
        //if extra days for resubmission has passed then
        //hide upload assignment button
        DateTime extendedDueDate = dueDate.add(
          Duration(
            days: submittedAssignment.extraDaysForResubmission,
          ),
        );
        if (currentDayDateTime.compareTo(extendedDueDate) == 1) {
          return false;
        }
        return true;
      }
    }

    //if assignment submission due date has passed
    //check if resubmission is allowed for unsubmitted assignments
    int dueDateComparison = currentDayDateTime.compareTo(dueDate);

    if (dueDateComparison == 1) {
      // Due date has passed, but check if resubmission is allowed for unsubmitted assignments
      if (submittedAssignment.resubmission == 1) {
        // Check if we're within the extra days for resubmission
        DateTime extendedDueDate = dueDate.add(
          Duration(
            days: submittedAssignment.extraDaysForResubmission,
          ),
        );
        if (currentDayDateTime.compareTo(extendedDueDate) == 1) {
          return false;
        }
        return true;
      } else {
        return false;
      }
    }

    return true;
  }

  Widget _uploadOrUndoAssignmentButton() {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 25.0, bottom: 25.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            if (isUndoAssignmentSubmissionButtonToBeShown) {
              undoAssignment();
            } else {
              uploadAssignment();
            }
          },
          child: Container(
            width: 60,
            height: 60,
            padding: EdgeInsets.all(
                isUndoAssignmentSubmissionButtonToBeShown ? 18 : 15),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.275),
                )
              ],
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              Utils.getImagePath(isUndoAssignmentSubmissionButtonToBeShown
                  ? "undo_assignment_submission.svg"
                  : "file_upload_icon.svg"),
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentDetailBackgroundContainer(Widget child) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: MediaQuery.of(context).size.width * (0.85),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: child,
      ),
    );
  }

  Widget _buildAssignmentNameContainer() {
    return _buildAssignmentDetailBackgroundContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Utils.getTranslatedLabel(assignmentNameKey),
            style: _getAssignmentDetailsLabelTextStyle(),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            submittedAssignment.name,
            style: _getAssignmentDetailsLabelValueTextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentSubjectNameContainer() {
    return _buildAssignmentDetailBackgroundContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Utils.getTranslatedLabel(subjectNameKey),
            style: _getAssignmentDetailsLabelTextStyle(),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            submittedAssignment.subject.getSubjectName(context: context),
            style: _getAssignmentDetailsLabelValueTextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentPointsContainer() {
    if (submittedAssignment.points == 0) {
      return const SizedBox();
    }

    return _buildAssignmentDetailBackgroundContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Utils.getTranslatedLabel(
              assignmentSubmitted ? pointsKey : possiblePointsKey,
            ),
            style: _getAssignmentDetailsLabelTextStyle(),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            assignmentSubmitted
                ? "${submittedAssignment.assignmentSubmission.points}/${submittedAssignment.points}"
                : submittedAssignment.points.toString(),
            style: _getAssignmentDetailsLabelValueTextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentDueDateContainer() {
    String assignmentStatusKey = Utils.getAssignmentSubmissionStatusKey(
      submittedAssignment.assignmentSubmission.status,
    );

    String dueDateToDisplay;

    //Since dueDate is now a string from API, we'll always use the raw date string
    //For resubmission cases, we'll show the original due date with a note about extra days
    if ((assignmentStatusKey == rejectedKey &&
            submittedAssignment.resubmission == 1) ||
        assignmentStatusKey == resubmittedKey) {
      dueDateToDisplay =
          "${submittedAssignment.dueDate} (+${submittedAssignment.extraDaysForResubmission} days for resubmission)";
    } else {
      // Use the due date string from API directly
      dueDateToDisplay = submittedAssignment.dueDate;
    }

    return _buildAssignmentDetailBackgroundContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Utils.getTranslatedLabel(dueDateKey),
            style: _getAssignmentDetailsLabelTextStyle(),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            dueDateToDisplay,
            style: _getAssignmentDetailsLabelValueTextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentInstructionsContainer() {
    return submittedAssignment.instructions.isEmpty
        ? const SizedBox()
        : _buildAssignmentDetailBackgroundContainer(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Utils.getTranslatedLabel(instructionsKey),
                  style: _getAssignmentDetailsLabelTextStyle(),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  submittedAssignment.instructions,
                  style: _getAssignmentDetailsLabelValueTextStyle(),
                ),
              ],
            ),
          );
  }

  Widget _buildAssignmentRemarksContainer() {
    if (!assignmentSubmitted) {
      return const SizedBox();
    }
    if (submittedAssignment.assignmentSubmission.feedback.isEmpty) {
      return const SizedBox();
    }
    return _buildAssignmentDetailBackgroundContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Utils.getTranslatedLabel(remarksKey),
            style: _getAssignmentDetailsLabelTextStyle(),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            submittedAssignment.assignmentSubmission.feedback,
            style: _getAssignmentDetailsLabelValueTextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentReferenceMaterialContainer({
    required BoxConstraints boxConstraints,
    required StudyMaterial studyMaterial,
  }) {
    return StudyMaterialWithDownloadButtonContainer(
      boxConstraints: boxConstraints,
      studyMaterial: studyMaterial,
    );
  }

  Widget _buildUploadedAssignmentsContainer() {
    if (!assignmentSubmitted) {
      return const SizedBox();
    }

    return _buildAssignmentDetailBackgroundContainer(
      LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Utils.getTranslatedLabel(myWorkKey),
                style: _getAssignmentDetailsLabelTextStyle(),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ...submittedAssignment.assignmentSubmission.submittedFiles
                  .map(
                    (studyMaterial) =>
                        _buildAssignmentReferenceMaterialContainer(
                      boxConstraints: boxConstraints,
                      studyMaterial: studyMaterial,
                    ),
                  )
                  .toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAssignmentReferenceMaterialsContainer() {
    if (submittedAssignment.referenceMaterials.isEmpty) {
      return const SizedBox();
    }

    return _buildAssignmentDetailBackgroundContainer(
      LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Utils.getTranslatedLabel(referenceMaterialsKey),
                style: _getAssignmentDetailsLabelTextStyle(),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ...submittedAssignment.referenceMaterials
                  .map(
                    (studyMaterial) =>
                        _buildAssignmentReferenceMaterialContainer(
                      boxConstraints: boxConstraints,
                      studyMaterial: studyMaterial,
                    ),
                  )
                  .toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAssignmentDetailsContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: Utils.getScrollViewBottomPadding(context),
        top: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAssignmentNameContainer(),
          _buildAssignmentSubjectNameContainer(),
          _buildAssignmentDueDateContainer(),
          _buildAssignmentInstructionsContainer(),
          _buildAssignmentReferenceMaterialsContainer(),
          _buildUploadedAssignmentsContainer(),
          _buildAssignmentPointsContainer(),
          _buildAssignmentRemarksContainer(),
        ],
      ),
    );
  }

  String getAssignmentSubmissionStatus() {
    if (Utils.getAssignmentSubmissionStatusKey(
      submittedAssignment.assignmentSubmission.status,
    ).isNotEmpty) {
      return Utils.getTranslatedLabel(
        Utils.getAssignmentSubmissionStatusKey(
          submittedAssignment.assignmentSubmission.status,
        ),
      );
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowButton = _showUploadAssignmentButton();

    return Scaffold(
      body: Stack(
        children: [
          _buildAssignmentDetailsContainer(),
          CustomAppBar(
            subTitle:
                assignmentSubmitted ? getAssignmentSubmissionStatus() : null,
            title: Utils.getTranslatedLabel(assignmentKey),
            onPressBackButton: () {
              Get.back(result: submittedAssignment);
            },
          ),
          shouldShowButton ? _uploadOrUndoAssignmentButton() : const SizedBox(),
        ],
      ),
    );
  }
}
