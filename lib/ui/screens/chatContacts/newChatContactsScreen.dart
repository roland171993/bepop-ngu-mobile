import 'package:cached_network_image/cached_network_image.dart';
import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/chatUsersCubit.dart';
import 'package:bepop_ngu/data/models/chatUser.dart';
import 'package:bepop_ngu/data/models/chatUserRole.dart';
import 'package:bepop_ngu/data/models/student.dart';
import 'package:bepop_ngu/ui/screens/chat/chatScreen.dart';
import 'package:bepop_ngu/ui/widgets/customBackButton.dart';
import 'package:bepop_ngu/ui/widgets/customCircularProgressIndicator.dart';
import 'package:bepop_ngu/ui/widgets/customTabBarContainer.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/noDataContainer.dart';
import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:bepop_ngu/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class NewChatContactsScreen extends StatefulWidget {
  const NewChatContactsScreen({super.key});

  static Widget routeInstance() {
    // final args = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (_) => ChatUsersCubit(),
      child: NewChatContactsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<NewChatContactsScreen> createState() => _NewChatContactsScreenState();
}

class _NewChatContactsScreenState extends State<NewChatContactsScreen> {
  final _scrollController = ScrollController();
  Student? currentStudent;

  //Used to hold the children of a particular parent in case of parent login
  List<Student>? children;

  bool isStudent = true;

  // Tab management
  late String _selectedTabTitle = teachersKey;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    //Initializing this at initState as the authState would never change while a login session is running
    final authState = context.read<AuthCubit>().state as Authenticated;
    if (authState.isStudent) {
      currentStudent = authState.student;
    } else {
      children = authState.parent.children;
      currentStudent = children?.firstOrNull;
      isStudent = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<ChatUsersCubit>().hasMore) {
        final role = _selectedTabTitle == teachersKey
            ? ChatUserRole.teacher
            : ChatUserRole.staff;
        context
            .read<ChatUsersCubit>()
            .fetchMoreChatUsers(role: role, studentId: '${currentStudent?.id}');
      }
    }
  }

  Widget _fetchChatUsers() {
    final role = _selectedTabTitle == teachersKey
        ? ChatUserRole.teacher
        : ChatUserRole.staff;
    context
        .read<ChatUsersCubit>()
        .fetchChatUsers(role: role, childId: '${currentStudent?.id}');
    return SizedBox.shrink();
  }

  Widget _buildStudentFilterDropdown() {
    if (isStudent) {
      return SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
            color: Utils.getColorScheme(context).primary, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Student>(
          isExpanded: true,
          dropdownColor: Utils.getColorScheme(context).surface,
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          value: currentStudent,
          items: children
              ?.map((student) =>
                  DropdownMenuItem(child: Text('$student'), value: student))
              .toList(),
          onChanged: (value) {
            if (value != currentStudent) {
              setState(() {
                currentStudent = value;
              });
              _fetchChatUsers();
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      heightPercentage: isStudent
          ? 0.13 // Ultra-compact for students (12% vs 15%)
          : Utils.appBarBiggerHeightPercentage,
      padding: isStudent
          ? EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10)
          : null, // Use default padding for parents (they need space for tabs)
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              CustomBackButton(
                onTap: () {
                  Get.back<bool>(result: false);
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.5),
                  child: Text(
                    Utils.getTranslatedLabel("contacts"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
              // Only show tabs for parent users
              !isStudent
                  ? AnimatedAlign(
                      curve: Utils.tabBackgroundContainerAnimationCurve,
                      duration: Utils.tabBackgroundContainerAnimationDuration,
                      alignment: _selectedTabTitle == teachersKey
                          ? AlignmentDirectional.centerStart
                          : AlignmentDirectional.centerEnd,
                      child: TabBarBackgroundContainer(
                          boxConstraints: boxConstraints),
                    )
                  : const SizedBox.shrink(),
              !isStudent
                  ? CustomTabBarContainer(
                      boxConstraints: boxConstraints,
                      alignment: AlignmentDirectional.centerStart,
                      isSelected: _selectedTabTitle == teachersKey,
                      onTap: () {
                        setState(() {
                          _selectedTabTitle = teachersKey;
                        });
                        _fetchChatUsers();
                      },
                      titleKey: teachersKey,
                    )
                  : const SizedBox(),
              !isStudent
                  ? CustomTabBarContainer(
                      boxConstraints: boxConstraints,
                      alignment: AlignmentDirectional.centerEnd,
                      isSelected: _selectedTabTitle == staffKey,
                      onTap: () {
                        setState(() {
                          _selectedTabTitle = staffKey;
                        });
                        _fetchChatUsers();
                      },
                      titleKey: staffKey,
                    )
                  : const SizedBox(),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        Get.back<bool>(result: false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: Utils.getScrollViewTopPadding(
                    context: context,
                    appBarHeightPercentage: isStudent
                        ? 0.12 // Match the ultra-compact header
                        : Utils.appBarBiggerHeightPercentage,
                  ),
                ),
                child: Column(
                  children: [
                    // Only add padding if student filter dropdown is visible (for parents)
                    !isStudent
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Utils.screenContentHorizontalPadding,
                              vertical: 16,
                            ),
                            child: _buildStudentFilterDropdown(),
                          )
                        : const SizedBox.shrink(),
                    BlocBuilder<ChatUsersCubit, ChatUsersState>(
                        builder: (context, state) {
                      return switch (state.status) {
                        ChatUsersFetchStatus.initial => _fetchChatUsers(),
                        ChatUsersFetchStatus.loading => SizedBox(
                            height: 400,
                            child: Center(
                              child: CustomCircularProgressIndicator(
                                indicatorColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ChatUsersFetchStatus.success => state.hasUsers
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      Utils.screenContentHorizontalPadding,
                                ),
                                controller: _scrollController,
                                itemCount:
                                    state.chatUsersResponse!.chatUsers.length,
                                itemBuilder: (context, index) {
                                  return _buildChatUserContact(state
                                      .chatUsersResponse!.chatUsers[index]);
                                },
                              )
                            : SizedBox(
                                height: 400,
                                child: NoDataContainer(
                                  titleKey: _selectedTabTitle == teachersKey
                                      ? noTeachersFoundKey
                                      : noStaffFoundKey,
                                ),
                              ),
                        ChatUsersFetchStatus.failure => SizedBox(
                            height: 400,
                            child: Center(
                              child: ErrorContainer(
                                errorMessageCode: state.errorMessage!,
                                onTapRetry: _fetchChatUsers,
                              ),
                            ),
                          ),
                      };
                    }),
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
      ),
    );
  }

  Widget _buildChatUserContact(ChatUser chatUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Get.toNamed(
          Routes.chat,
          arguments: ChatScreen.buildArguments(
            receiverId: chatUser.id,
            image: chatUser.image,
            appbarSubtitle:
                chatUser.subjectTeachers.firstOrNull?.subjectWithName ?? "",
            teacherName: chatUser.fullName,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        margin: EdgeInsets.zero,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(
            top: BorderSide.none,
            left: BorderSide.none,
            right: BorderSide.none,
            bottom: BorderSide(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: .1),
            ),
          ),
        ),
        child: Row(
          children: [
            /// User profile image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colorScheme.tertiary,
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: chatUser.image,
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                ),
              ),
            ),
            const SizedBox(width: 16),

            ///
            Expanded(
              child: Text(
                chatUser.fullName,
                maxLines: 1,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
