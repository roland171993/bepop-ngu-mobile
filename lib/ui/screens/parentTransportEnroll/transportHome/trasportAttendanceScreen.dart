import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/transportAttendanceCubit.dart';
import 'package:bepop_ngu/data/models/transportAttendance.dart';
import 'package:bepop_ngu/ui/widgets/customShimmerContainer.dart';
import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:bepop_ngu/ui/widgets/shimmerLoadingContainer.dart';
import 'package:bepop_ngu/ui/widgets/changeCalendarMonthButton.dart';
import 'package:bepop_ngu/ui/widgets/customBackButton.dart';
import 'package:bepop_ngu/ui/widgets/customTabBarContainer.dart';
import 'package:bepop_ngu/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:bepop_ngu/utils/utils.dart';

class TransportAttendanceScreen extends StatefulWidget {
  final int? userId;

  const TransportAttendanceScreen({super.key, this.userId});

  static Widget getRouteInstance() {
    final int? userId = Get.arguments as int?;
    return BlocProvider(
      create: (context) => TransportAttendanceCubit(),
      child: TransportAttendanceScreen(userId: userId),
    );
  }

  @override
  State<TransportAttendanceScreen> createState() =>
      _TransportAttendanceScreenState();
}

class _TransportAttendanceScreenState extends State<TransportAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime focusedDay = DateTime.now();
  late DateTime firstDay = DateTime.now().subtract(const Duration(days: 365));
  late DateTime lastDay = DateTime.now();

  PageController? calendarPageController;
  String selectedTripType = 'pickup';
  late String _selectedTabTitle = 'Pickup Trip';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchAttendance();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        selectedTripType = _tabController.index == 0 ? 'pickup' : 'drop';
        _selectedTabTitle =
            _tabController.index == 0 ? 'Pickup Trip' : 'Drop Trip';
      });
      _fetchAttendance();
    }
  }

  void _fetchAttendance() {
    int? userId = widget.userId;

    if (userId == null) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        userId = authState.student.id;
      }
    }

    final month = focusedDay.month.toString().padLeft(2, '0');

    if (userId != null) {
      context.read<TransportAttendanceCubit>().fetchTransportAttendance(
            userId: userId,
            month: month,
            tripType: selectedTripType,
          );
    }
  }

  void _onMonthChanged(DateTime dateTime) {
    setState(() {
      focusedDay = dateTime;
    });

    int? userId = widget.userId;

    if (userId == null) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        userId = authState.student.id;
      }
    }

    final month = dateTime.month.toString().padLeft(2, '0');

    if (userId != null) {
      context.read<TransportAttendanceCubit>().fetchTransportAttendance(
            userId: userId,
            month: month,
            tripType: selectedTripType,
          );
    }
  }

  bool _disableChangeNextMonthButton() {
    return focusedDay.year == DateTime.now().year &&
        focusedDay.month == DateTime.now().month;
  }

  Widget _buildCalendarNavigationHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .secondary
                .withValues(alpha: 0.075),
            offset: const Offset(2.5, 2.5),
            blurRadius: 5,
          )
        ],
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Stack(
        children: [
          Align(
            child: Text(
              "${Utils.getTranslatedLabel(Utils.getMonthName(focusedDay.month))} ${focusedDay.year}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ChangeCalendarMonthButton(
              isDisable: false,
              isNextButton: false,
              onTap: () {
                if (context.read<TransportAttendanceCubit>().state
                    is TransportAttendanceFetchInProgress) {
                  return;
                }
                calendarPageController?.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ChangeCalendarMonthButton(
              onTap: () {
                if (context.read<TransportAttendanceCubit>().state
                    is TransportAttendanceFetchInProgress) {
                  return;
                }
                if (_disableChangeNextMonthButton()) {
                  return;
                }
                calendarPageController?.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              isDisable: _disableChangeNextMonthButton(),
              isNextButton: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerAttendanceCounterContainer(
      BoxConstraints boxConstraints) {
    return ShimmerLoadingContainer(
      child: CustomShimmerContainer(
        height: boxConstraints.maxWidth * (0.425),
        width: boxConstraints.maxWidth * (0.425),
      ),
    );
  }

  Widget _buildAttendanceCounterContainer({
    required String title,
    required BoxConstraints boxConstraints,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      height: boxConstraints.maxWidth * (0.425),
      width: boxConstraints.maxWidth * (0.425),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.25),
            offset: const Offset(5, 5),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: boxConstraints.maxWidth * (0.45) * (0.125),
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: backgroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              const CustomBackButton(),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.5),
                  child: Text(
                    'Transportation Attendance',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
              AnimatedAlign(
                curve: Utils.tabBackgroundContainerAnimationCurve,
                duration: Utils.tabBackgroundContainerAnimationDuration,
                alignment: _selectedTabTitle == 'Pickup Trip'
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: _selectedTabTitle == 'Pickup Trip',
                onTap: () {
                  setState(() {
                    _selectedTabTitle = 'Pickup Trip';
                    selectedTripType = 'pickup';
                  });
                  _tabController.animateTo(0);
                  _fetchAttendance();
                },
                titleKey: 'Pickup Trip',
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: _selectedTabTitle == 'Drop Trip',
                onTap: () {
                  setState(() {
                    _selectedTabTitle = 'Drop Trip';
                    selectedTripType = 'drop';
                  });
                  _tabController.animateTo(1);
                  _fetchAttendance();
                },
                titleKey: 'Drop Trip',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarContainer({
    required List<AttendanceRecord> presentRecords,
    required List<AttendanceRecord> absentRecords,
    required Function(DateTime) onMonthChanged,
  }) {
    try {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.075),
              offset: const Offset(5.0, 5),
              blurRadius: 10,
            )
          ],
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.only(top: 20),
        child: TableCalendar(
          headerVisible: false,
          daysOfWeekHeight: 40,
          onPageChanged: onMonthChanged,
          onCalendarCreated: (controller) {
            calendarPageController = controller;
          },
          holidayPredicate: (dateTime) {
            try {
              return presentRecords.any((record) {
                final recordDate = record.dateTime;
                if (recordDate == null) return false;
                return dateTime.year == recordDate.year &&
                    dateTime.month == recordDate.month &&
                    dateTime.day == recordDate.day;
              });
            } catch (e) {
              return false;
            }
          },
          selectedDayPredicate: (dateTime) {
            try {
              return absentRecords.any((record) {
                final recordDate = record.dateTime;
                if (recordDate == null) return false;
                return dateTime.year == recordDate.year &&
                    dateTime.month == recordDate.month &&
                    dateTime.day == recordDate.day;
              });
            } catch (e) {
              return false;
            }
          },
          availableGestures: AvailableGestures.none,
          calendarStyle: CalendarStyle(
            isTodayHighlighted: false,
            holidayTextStyle:
                TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
            holidayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            selectedDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            weekdayStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          headerStyle: const HeaderStyle(
              titleCentered: true, formatButtonVisible: false),
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: focusedDay,
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text('Error loading calendar: $e'),
      );
    }
  }

  Widget _buildAttendanceCalendar(TransportAttendanceState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: Utils.getScrollViewBottomPadding(context),
        top: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
        ),
      ),
      child: Column(
        children: [
          _buildCalendarNavigationHeader(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.075),
            ),
            child: Column(
              children: [
                // Always show calendar
                _buildCalendarWithData(state),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.05),
                ),
                // Always show attendance counters
                _buildAttendanceCounters(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarWithData(TransportAttendanceState state) {
    List<AttendanceRecord> presentRecords = [];
    List<AttendanceRecord> absentRecords = [];
    bool isLoading = false;

    if (state is TransportAttendanceFetchSuccess) {
      // Extract data directly from the state instead of using context.read()
      final successState = state;
      final attendanceData = successState.attendanceResponse.data;
      if (attendanceData != null) {
        presentRecords =
            attendanceData.records.where((record) => record.isPresent).toList();
        absentRecords =
            attendanceData.records.where((record) => record.isAbsent).toList();
      }
    } else if (state is TransportAttendanceFetchInProgress) {
      isLoading = true;
    }
    // For other states (NoData, Failure), use empty lists

    if (isLoading) {
      return ShimmerLoadingContainer(
        child: CustomShimmerContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * (0.425),
        ),
      );
    }

    return _buildCalendarContainer(
      presentRecords: presentRecords,
      absentRecords: absentRecords,
      onMonthChanged: _onMonthChanged,
    );
  }

  Widget _buildAttendanceCounters(TransportAttendanceState state) {
    int presentCount = 0;
    int absentCount = 0;
    bool isLoading = false;

    if (state is TransportAttendanceFetchSuccess) {
      // Extract data directly from the state instead of using context.read()
      final successState = state;
      final attendanceData = successState.attendanceResponse.data;
      if (attendanceData != null) {
        presentCount = attendanceData.summary.present;
        absentCount = attendanceData.summary.absent;
      }
    } else if (state is TransportAttendanceFetchInProgress) {
      isLoading = true;
    }
    // For other states (NoData, Failure), use 0 counts

    if (isLoading) {
      return LayoutBuilder(
        builder: (context, boxConstraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShimmerAttendanceCounterContainer(boxConstraints),
              const Spacer(),
              _buildShimmerAttendanceCounterContainer(boxConstraints),
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAttendanceCounterContainer(
              boxConstraints: boxConstraints,
              title: 'Total Present',
              value: presentCount.toString(),
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const Spacer(),
            _buildAttendanceCounterContainer(
              boxConstraints: boxConstraints,
              title: 'Total Absent',
              value: absentCount.toString(),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<TransportAttendanceCubit, TransportAttendanceState>(
            listener: (context, state) {
              // Handle any side effects if needed
            },
            builder: (context, state) {
              return _buildAttendanceCalendar(state);
            },
          ),
          _buildAppBar(),
        ],
      ),
    );
  }
}
