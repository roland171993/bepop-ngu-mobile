import 'package:cached_network_image/cached_network_image.dart';
import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/socketSettingCubit.dart';
import 'package:bepop_ngu/cubits/userChatHistoryCubit.dart';
import 'package:bepop_ngu/data/models/chatContact.dart';
import 'package:bepop_ngu/data/models/chatUserRole.dart';
import 'package:bepop_ngu/ui/screens/chat/chatScreen.dart';
import 'package:bepop_ngu/ui/widgets/customBackButton.dart';
import 'package:bepop_ngu/ui/widgets/customCircularProgressIndicator.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/widgets/customTabBarContainer.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:bepop_ngu/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ChatContactsScreen extends StatefulWidget {
  ChatContactsScreen({Key? key}) : super(key: key);

  static Widget routeInstance() {
    // final args = Get.arguments as Map<String, dynamic>;

    return BlocProvider(
      create: (_) => UserChatHistoryCubit(),
      child: ChatContactsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ChatContactsScreen> createState() => _ChatContactsScreenState();
}

class _ChatContactsScreenState extends State<ChatContactsScreen> {
  final _scrollController = ScrollController();

  // Tab management
  late String _selectedTabTitle = teachersKey;
  bool isStudent = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Check if user is a student or parent
    final authState = context.read<AuthCubit>().state as Authenticated;
    isStudent = authState.isStudent;

    _fetchUserChatHistory();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<UserChatHistoryCubit>().hasMore) {
        final role = _selectedTabTitle == teachersKey
            ? ChatUserRole.teacher
            : ChatUserRole.staff;
        context
            .read<UserChatHistoryCubit>()
            .fetchMoreUserChatHistory(role: role);
      }
    }
  }

  void _fetchUserChatHistory() {
    final role = _selectedTabTitle == teachersKey
        ? ChatUserRole.teacher
        : ChatUserRole.staff;
    context.read<UserChatHistoryCubit>().fetchUserChatHistory(role: role);
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
              const CustomBackButton(),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.5),
                  child: Text(
                    Utils.getTranslatedLabel(chatsKey),
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
                        _fetchUserChatHistory();
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
                        _fetchUserChatHistory();
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
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: BlocBuilder<UserChatHistoryCubit, UserChatHistoryState>(
              builder: (context, state) {
                if (state is UserChatHistoryFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: _fetchUserChatHistory,
                    ),
                  );
                }

                if (state is UserChatHistoryFetchSuccess) {
                  /// if there are no chat contacts, show a message to start a new chat
                  if (state.userChatHistory.chatContacts.isEmpty)
                    return _buildStartNewChat(context);

                  /// if there are chat contacts, show the chat contacts
                  return BlocListener<SocketSettingCubit, SocketSettingState>(
                    listener: (context, state) {
                      if (state is SocketMessageReceived) {
                        context.read<UserChatHistoryCubit>().messageReceived(
                              from: state.from,
                              message: state.message.message ?? "",
                              updatedAt: state.message.updatedAt,
                              incrementUnreadCount:
                                  Get.currentRoute == Routes.chatContacts,
                            );
                      }
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: Utils.getScrollViewTopPadding(
                          context: context,
                          appBarHeightPercentage: isStudent
                              ? 0.13 // Match the ultra-compact header
                              : Utils.appBarBiggerHeightPercentage,
                        ),
                      ),
                      controller: _scrollController,
                      child: Column(
                        children: [
                          ...state.userChatHistory.chatContacts
                              .map((contact) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          Utils.screenContentHorizontalPadding,
                                    ),
                                    child: _buildChatContact(contact),
                                  ))
                              .toList(),

                          ///
                          if (state.loadMore)
                            Center(
                              child: CustomCircularProgressIndicator(
                                indicatorColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
      floatingActionButton:
          BlocBuilder<UserChatHistoryCubit, UserChatHistoryState>(
        builder: (context, state) {
          if (state is UserChatHistoryFetchSuccess) {
            if (state.userChatHistory.chatContacts.isEmpty) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              onPressed: () async {
                Get.toNamed(Routes.newChatContacts)?.then((_) {
                  _fetchUserChatHistory();
                });
              },
              child: SvgPicture.asset(
                Utils.getImagePath("add_chat.svg"),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStartNewChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          SvgPicture.asset(
            Utils.getImagePath("new_chat_icon.svg"),
            width: 132,
            height: 132,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              Utils.getTranslatedLabel(_selectedTabTitle == teachersKey
                  ? "connectWithTeachers"
                  : "connectWithStaff"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              Utils.getTranslatedLabel(_selectedTabTitle == teachersKey
                  ? "connectWithTeachersDesc"
                  : "connectWithStaffDesc"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomRoundedButton(
            onTap: () {
              Get.toNamed(Routes.newChatContacts)?.then((_) {
                _fetchUserChatHistory();
              });
            },
            widthPercentage: 0.5,
            height: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            buttonTitle: Utils.getTranslatedLabel("letsStartChat"),
            showBorder: false,
            textSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildChatContact(ChatContact contact) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          Get.toNamed(
            Routes.chat,
            arguments: ChatScreen.buildArguments(
              receiverId: contact.user.id,
              image: contact.user.image,
              appbarSubtitle:
                  contact.user.subjectTeachers.firstOrNull?.subjectWithName ??
                      "",
              teacherName: contact.user.fullName,
            ),
          )?.then(
            (result) {
              if (result.unreadCount > 0) {
                context
                    .read<UserChatHistoryCubit>()
                    .updateUnreadCount(contact.user.id, result.unreadCount);
              }

              if (result.lastMessage != null) {
                context.read<UserChatHistoryCubit>().updateLastMessage(
                      contact.user.id,
                      result.lastMessage,
                      result.lastMessageTime,
                    );
              }
            },
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: colorScheme.surface,
          ),
          child: Row(
            children: [
              /// User profile image
              Container(
                width: 45,
                height: 45,
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
                    imageUrl: contact.user.image,
                    fit: BoxFit.cover,
                    width: 45,
                    height: 45,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              ///
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// User name and last message time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.user.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            Utils.extractTimeFromDateString(contact.updatedAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  colorScheme.secondary.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1.5),

                      /// Last message and unread count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.lastMessage ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.secondary
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),

                          ///
                          if (contact.unreadCount > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.5),
                                color: colorScheme.onPrimary,
                              ),
                              child: Text(
                                contact.unreadCount.toString(),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
