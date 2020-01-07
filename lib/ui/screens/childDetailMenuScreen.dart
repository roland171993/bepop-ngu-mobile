import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/vehicleAssignmentStatusCubit.dart';
import 'package:bepop_ngu/data/models/student.dart';
import 'package:bepop_ngu/data/models/subject.dart';
import 'package:bepop_ngu/ui/widgets/customBackButton.dart';
import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:bepop_ngu/utils/animationConfiguration.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/systemModules.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/transportRequestDetailsScreen.dart';
import 'package:bepop_ngu/data/models/transportDashboard.dart';

class ChildDetailMenuScreen extends StatefulWidget {
  final Student student;
  final List<Subject> subjectsForFilter;
  const ChildDetailMenuScreen({
    Key? key,
    required this.student,
    required this.subjectsForFilter,
  }) : super(key: key);

  @override
  ChildDetailMenuScreenState createState() => ChildDetailMenuScreenState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => VehicleAssignmentStatusCubit(),
      child: ChildDetailMenuScreen(
        subjectsForFilter: arguments['subjectsForFilter'],
        student: arguments['student'],
      ),
    );
  }
}

class ChildDetailMenuScreenState extends State<ChildDetailMenuScreen> {
  List<MenuContainerDetails> _menuItems = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      // Check vehicle assignment status first
      context.read<VehicleAssignmentStatusCubit>().checkVehicleAssignmentStatus(
            userId: widget.student.userId ?? widget.student.id ?? 0,
          );
      setMenuItems();
    });
    super.initState();
  }

  Future<void> handleTransportNavigation() async {
    final assignmentCubit = context.read<VehicleAssignmentStatusCubit>();

    if (!assignmentCubit.isDataLoaded()) {
      // If data not loaded yet, default to enrollment screen
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: widget.student.userId ?? widget.student.id,
      );
      return;
    }

    // Check status and navigate accordingly based on API response data value
    if (assignmentCubit.isStatusAssigned()) {
      // data = "assigned" - navigate to transport home
      Get.toNamed(
        Routes.transportEnrollHomeScreen,
        arguments: widget.student.userId ?? widget.student.id,
      );
    } else if (assignmentCubit.isExpired()) {
      // data = "expired" - fetch request data and navigate to plan renewal
      await _navigateToPlanRenewal();
    } else if (assignmentCubit.isPending()) {
      // data = "pending" - fetch request data and navigate to request details
      await _navigateToRequestDetails();
    } else {
      // data = "false" or any other value - navigate to enrollment screen
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: widget.student.userId ?? widget.student.id,
      );
    }
  }

  Future<void> _navigateToPlanRenewal() async {
    try {
      // For expired plans, fetch request data instead of dashboard
      final transportRepo = TransportRepository();
      final requestsResponse = await transportRepo.getTransportRequests(
        userId: widget.student.userId ?? widget.student.id ?? 0,
      );

      if (requestsResponse.data.isNotEmpty) {
        // Get the most recent request (first one)
        final request = requestsResponse.data.first;

        // Create TransportPlan from request data for renewal screen
        final planFromRequest = TransportPlan(
          planId: null, // Will be null for expired/renewal
          status: 'expired',
          duration: request.details?.plan?.duration ?? 'N/A',
          validFrom: request.details?.plan?.validity?.split(' - ').first,
          validTo: request.details?.plan?.validity?.split(' - ').last,
          route: request.details?.route?.name != null
              ? TransportRoute(id: null, name: request.details?.route?.name)
              : null,
          pickupStop: request.details?.pickupStop,
          expiresInDays: 0, // Already expired
        );

        // Navigate to plan renewal screen with plan data from request and userId
        Get.toNamed(Routes.planRenewalScreen, arguments: {
          'plan': planFromRequest,
          'userId': widget.student.userId ?? widget.student.id,
        });
      } else {
        // No request found, navigate with null to show renewal screen anyway
        Get.toNamed(Routes.planRenewalScreen, arguments: {
          'plan': null,
          'userId': widget.student.userId ?? widget.student.id,
        });
      }
    } catch (e) {
      // Even on error, navigate to renewal screen
      // User can still proceed with renewal manually
      if (context.mounted) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: 'Could not load previous plan data',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
      // Navigate anyway
      Get.toNamed(Routes.planRenewalScreen, arguments: {
        'plan': null,
        'userId': widget.student.userId ?? widget.student.id,
      });
    }
  }

  Future<void> _navigateToRequestDetails() async {
    try {
      // Fetch request data
      final transportRepo = TransportRepository();
      final requestsResponse = await transportRepo.getTransportRequests(
        userId: widget.student.userId ?? widget.student.id ?? 0,
      );

      if (requestsResponse.data.isNotEmpty) {
        // Get the most recent request (first one)
        final request = requestsResponse.data.first;

        // Build request details arguments
        final args = RequestDetailsArgs(
          title: 'Transportation Request',
          requestedOn: request.requestedOn ?? 'N/A',
          statusText: request.status?.capitalize ?? 'Pending',
          statusBg: _getStatusColor(request.status).bg,
          statusFg: _getStatusColor(request.status).fg,
          sections: buildDynamicSections(request),
          footerNote: request.status?.toLowerCase() == 'rejected'
              ? 'Your transportation request was rejected. Please contact support for more information.'
              : 'Your request is being processed',
          showNewRequest: request.status?.toLowerCase() == 'rejected',
          transportRequest: request,
        );

        // Navigate to request details screen
        Get.toNamed(Routes.transportRequestDetailsScreen, arguments: args);
      } else {
        // No requests found - redirect to enrollment screen
        if (context.mounted) {
          Utils.showCustomSnackBar(
            context: context,
            errorMessage: 'No pending requests found',
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        }
        Get.toNamed(
          Routes.staffTransportEnrollScreen,
          arguments: widget.student.userId ?? widget.student.id,
        );
      }
    } catch (e) {
      // On error, show message and redirect to enrollment screen
      if (context.mounted) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: 'Could not load request details',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: widget.student.userId ?? widget.student.id,
      );
    }
  }

  ({Color bg, Color fg}) _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return (bg: const Color(0xFFFFF2E8), fg: const Color(0xFFFF8C00));
      case 'approved':
        return (bg: const Color(0xFFDFF6E2), fg: const Color(0xFF37C748));
      case 'rejected':
        return (bg: const Color(0xFFFFE8E8), fg: const Color(0xFFE53935));
      default:
        return (bg: const Color(0xFFFFF2E8), fg: const Color(0xFFFF8C00));
    }
  }

  void setMenuItems() {
    //Menu will have module Id attache to it same as student home bottm sheet
    _menuItems = [
      MenuContainerDetails(
        moduleId: assignmentManagementModuleId.toString(),
        route: Routes.childAssignments,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("assignment_icon_parent.svg"),
        title: Utils.getTranslatedLabel(assignmentsKey),
      ),
      MenuContainerDetails(
        moduleId: defaultModuleId.toString(),
        route: Routes.childTeachers,
        arguments: widget.student.id,
        iconPath: Utils.getImagePath("teachers_icon.svg"),
        title: Utils.getTranslatedLabel(teachersKey),
      ),
      MenuContainerDetails(
        moduleId: attendanceManagementModuleId.toString(),
        route: Routes.childAttendance,
        arguments: widget.student.id,
        iconPath: Utils.getImagePath("attendance_icon.svg"),
        title: Utils.getTranslatedLabel(attendanceKey),
      ),
      MenuContainerDetails(
        moduleId: transportationManagementModuleId.toString(),
        route: '', // Route will be determined dynamically
        arguments: widget.student.userId ?? widget.student.id,
        iconPath: Utils.getImagePath("transportation.svg"),
        title: Utils.getTranslatedLabel(transportationKey),
        isTransportation: true, // Flag to identify transportation menu
      ),
      MenuContainerDetails(
        moduleId: timetableManagementModuleId.toString(),
        route: Routes.childTimeTable,
        arguments: widget.student.id,
        iconPath: Utils.getImagePath("timetable_icon.svg"),
        title: Utils.getTranslatedLabel(timeTableKey),
      ),
      MenuContainerDetails(
        moduleId: holidayManagementModuleId.toString(),
        route: Routes.holidays,
        arguments: widget.student.id,
        iconPath: Utils.getImagePath("holiday_icon.svg"),
        title: Utils.getTranslatedLabel(holidaysKey),
      ),
      MenuContainerDetails(
        moduleId: examManagementModuleId.toString(),
        route: Routes.exam,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("exam_icon.svg"),
        title: Utils.getTranslatedLabel(examsKey),
      ),
      MenuContainerDetails(
        moduleId: examManagementModuleId.toString(),
        route: Routes.childResults,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("result_icon.svg"),
        title: Utils.getTranslatedLabel(resultKey),
      ),
      MenuContainerDetails(
        moduleId:
            "$assignmentManagementModuleId$moduleIdJoiner$examManagementModuleId",
        route: Routes.subjectWiseReport,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("reports_icon.svg"),
        title: Utils.getTranslatedLabel(reportsKey),
      ),
      MenuContainerDetails(
        moduleId: feesManagementModuleId.toString(),
        route: Routes.childFees,
        arguments: widget.student,
        iconPath: Utils.getImagePath("fees_icon.svg"),
        title: Utils.getTranslatedLabel(feesKey),
      ),
      MenuContainerDetails(
        moduleId: galleryManagementModuleId.toString(),
        route: Routes.schoolGallery,
        arguments: widget.student,
        iconPath: Utils.getImagePath("gallery.svg"),
        title: Utils.getTranslatedLabel(galleryKey),
      ),
      MenuContainerDetails(
        moduleId: studentManagementModuleId.toString(),
        route: Routes.studentDiaryScreen,
        arguments: {
          "studentId": widget.student.userId,
        },
        iconPath: Utils.getImagePath("diary.svg"),
        title: Utils.getTranslatedLabel(studentDiaryKey),
      ),
    ];

    setState(() {});
  }

  Widget _buildAppBar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: Utils.appBarSmallerHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          context.read<AuthCubit>().isParent()
              ? const CustomBackButton()
              : const SizedBox(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              Utils.getTranslatedLabel(menuKey),
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: Utils.screenTitleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationAndMenu() {
    return BlocListener<VehicleAssignmentStatusCubit,
        VehicleAssignmentStatusState>(
      listener: (context, state) {
        // Update menu items when assignment status changes
        if (state is VehicleAssignmentStatusFetchSuccess) {
          setState(() {
            setMenuItems();
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 25,
          left: MediaQuery.of(context).size.width * (0.075),
          right: MediaQuery.of(context).size.width * (0.075),
          top: Utils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: Utils.appBarMediumtHeightPercentage,
          ),
        ),
        child: Column(
          children: List.generate(
            _menuItems.length,
            (index) => _buildMenuContainer(itemIndex: index),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContainer({required int itemIndex}) {
    final menuItem = _menuItems[itemIndex];
    return Utils.isModuleEnabled(context: context, moduleId: menuItem.moduleId)
        ? Animate(
            effects: listItemAppearanceEffects(
              itemIndex: itemIndex,
              totalLoadedItems: _menuItems.length,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  // Handle transportation navigation differently
                  if (menuItem.isTransportation) {
                    await handleTransportNavigation();
                  } else {
                    print(_menuItems[itemIndex].arguments);
                    Get.toNamed(
                      _menuItems[itemIndex].route,
                      arguments: _menuItems[itemIndex].arguments,
                    );
                  }
                },
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withValues(alpha: 0.225),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            width: boxConstraints.maxWidth * (0.225),
                            child: SvgPicture.asset(
                              _menuItems[itemIndex].iconPath,
                            ),
                          ),
                          SizedBox(width: boxConstraints.maxWidth * (0.025)),
                          SizedBox(
                            width: boxConstraints.maxWidth * (0.475),
                            child: Text(
                              _menuItems[itemIndex].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            radius: 17.5,
                            child: Icon(
                              Icons.arrow_forward,
                              size: 22.5,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          SizedBox(width: boxConstraints.maxWidth * (0.035)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [_buildInformationAndMenu(), _buildAppBar(context)],
      ),
    );
  }
}

//class to maintain details required by each menu items
class MenuContainerDetails {
  String iconPath;
  String title;
  String route;
  String moduleId;
  Object? arguments;
  bool isTransportation;

  MenuContainerDetails({
    required this.iconPath,
    required this.title,
    required this.route,
    required this.moduleId,
    this.arguments,
    this.isTransportation = false,
  });
}
