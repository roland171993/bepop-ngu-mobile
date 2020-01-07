import 'package:bepop_ngu/cubits/diariesCubit.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/studentDetailsCubit.dart';
import 'package:bepop_ngu/data/models/diaryStudent.dart';
import 'package:bepop_ngu/data/models/studentDiaryDetails.dart';
import 'package:bepop_ngu/ui/screens/manageDiary/widget/diaryStatsContainer.dart';
import 'package:bepop_ngu/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/customCircularProgressIndicator.dart';
import 'package:bepop_ngu/ui/widgets/customTextButton.dart';
import 'package:bepop_ngu/ui/screens/manageDiary/widget/diaryEntryCard.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/filterButton.dart';
import 'package:bepop_ngu/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:bepop_ngu/ui/widgets/noDataContainer.dart';
import 'package:bepop_ngu/ui/widgets/sortSelectionBottomsheet.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class StudentDiaryScreen extends StatefulWidget {
  final int studentId;

  const StudentDiaryScreen({super.key, required this.studentId});

  static Widget getRouteInstance({required int studentId, String? diaryType}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DiariesCubit()),
        BlocProvider(create: (context) => StudentDetailsCubit()),
      ],
      child: StudentDiaryScreen(studentId: studentId),
    );
  }

  @override
  State<StudentDiaryScreen> createState() => _StudentDiaryScreenState();
}

class _StudentDiaryScreenState extends State<StudentDiaryScreen> {
  String _selectedCategory = "allCategories";
  String _selectedSubject = "allSubjects";
  String _selectedSort = "new"; // Default to newest first
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_scrollListener);

  @override
  void initState() {
    super.initState();
    // Note: Keep _selectedCategory as "allCategories" by default
    // If diaryType is provided, it will be used for filtering in _getFilteredEntries
    // but we keep the UI showing "All Categories" unless user explicitly changes it

    // Fetch diaries and student details when screen initializes
    Future.delayed(Duration.zero, () {
      context.read<DiariesCubit>().getDiaries(
            sort: _selectedSort,
            studentId: widget.studentId,
          );
      context
          .read<StudentDetailsCubit>()
          .getStudentDetails(studentId: widget.studentId);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<DiariesCubit>().hasMore()) {
        // Get the actual IDs for selected filters
        int? categoryId;
        int? subjectId;

        if (_selectedCategory != "allCategories") {
          categoryId = _getCategoryIdFromName(_selectedCategory);
        }

        if (_selectedSubject != "allSubjects") {
          subjectId = _getSubjectIdFromName(_selectedSubject);
        }

        context.read<DiariesCubit>().fetchMore(
              sort: _selectedSort,
              diaryCategoryId: categoryId,
              subjectId: subjectId,
            );
      }
    }
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _selectedCategory = value ?? "allCategories";
    });
    // Refresh data with new filter
    _refreshData();
  }

  void _onSubjectChanged(String? value) {
    setState(() {
      _selectedSubject = value ?? "allSubjects";
    });
    // Refresh data with new filter
    _refreshData();
  }

  void _refreshData() {
    // Get the actual IDs for selected filters
    int? categoryId;
    int? subjectId;

    if (_selectedCategory != "allCategories") {
      categoryId = _getCategoryIdFromName(_selectedCategory);
    }

    if (_selectedSubject != "allSubjects") {
      subjectId = _getSubjectIdFromName(_selectedSubject);
    }

    context.read<DiariesCubit>().getDiaries(
          studentId: widget.studentId,
          sort: _selectedSort,
          diaryCategoryId: categoryId,
          subjectId: subjectId,
        );
  }

  void _onSortChanged(String? value) {
    setState(() {
      _selectedSort = value ?? "new";
    });
    // Refresh data with new sort
    _refreshData();
  }

  void _showSortBottomSheet() {
    Utils.showBottomSheet(
      child: SortSelectionBottomsheet(
        selectedValue: _selectedSort,
        onSelection: (value) {
          _onSortChanged(value);
          Get.back();
        },
      ),
      context: context,
    );
  }

  List<DiaryStudent> _getFilteredEntries(List<StudentDiaryDetails> students) {
    List<DiaryStudent> allEntries = [];

    for (final student in students) {
      allEntries.addAll(student.diaryStudent);
    }

    return allEntries.where((entry) {
      bool categoryMatch;

      // Priority 2: Use user's selected category filter
      if (_selectedCategory != "allCategories") {
        categoryMatch = entry.diary.diaryCategory.name == _selectedCategory;
      }
      // Priority 3: Show all categories
      else {
        categoryMatch = true;
      }

      // Filter by subject
      bool subjectMatch = _selectedSubject == "allSubjects" ||
          entry.diary.subject?.nameWithType == _selectedSubject;

      return categoryMatch && subjectMatch;
    }).toList();
  }

  int _getPositiveCount(List<DiaryStudent> entries) {
    return entries
        .where((entry) => entry.diary.diaryCategory.type == 'positive')
        .length;
  }

  int _getNegativeCount(List<DiaryStudent> entries) {
    return entries
        .where((entry) => entry.diary.diaryCategory.type == 'negative')
        .length;
  }

  Map<String, dynamic> _convertDiaryStudentToEntryMap(
      DiaryStudent diaryStudent) {
    return {
      'id': diaryStudent.id.toString(),
      'category': diaryStudent.diary.diaryCategory.name,
      'title': diaryStudent.diary.title ?? 'No Title',
      'description': diaryStudent.diary.description ?? 'No description',
      'timestamp': diaryStudent.diary.createdAt,
      'type': diaryStudent.diary.subject?.nameWithType ?? '',
      'categoryType': diaryStudent.diary.diaryCategory.type,
      'subject': diaryStudent.diary.subject?.nameWithType,
      'showActions': false, // You can add logic here for permissions
    };
  }

  // Get unique categories from the API data
  List<String> _getCategories(List<StudentDiaryDetails> students) {
    Set<String> categories = {"allCategories"};
    for (final student in students) {
      for (final diaryStudent in student.diaryStudent) {
        categories.add(diaryStudent.diary.diaryCategory.name);
      }
    }
    return categories.toList();
  }

  // Get unique subjects from the student details API
  List<String> _getSubjects() {
    Set<String> subjects = {"allSubjects"};

    // Get subjects from StudentDetailsCubit
    final studentDetailsState = context.read<StudentDetailsCubit>().state;
    if (studentDetailsState is StudentDetailsFetchSuccess) {
      final subjectNames =
          context.read<StudentDetailsCubit>().getSubjectNames();
      subjects.addAll(subjectNames);
    }

    return subjects.toList();
  }

  // Get category ID from category name
  int? _getCategoryIdFromName(String categoryName) {
    final diariesState = context.read<DiariesCubit>().state;
    if (diariesState is DiariesFetchSuccess) {
      for (final student in diariesState.students) {
        for (final diaryStudent in student.diaryStudent) {
          if (diaryStudent.diary.diaryCategory.name == categoryName) {
            return diaryStudent.diary.diaryCategory.id;
          }
        }
      }
    }
    return null;
  }

  // Get subject ID from subject name
  int? _getSubjectIdFromName(String subjectName) {
    final studentDetailsState = context.read<StudentDetailsCubit>().state;
    if (studentDetailsState is StudentDetailsFetchSuccess) {
      final allSubjects = studentDetailsState.studentDetails.getAllSubjects();
      for (final subject in allSubjects) {
        if (subject.nameWithType == subjectName) {
          return subject.id;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate header pieces to avoid magic numbers and preserve rounded corners
    final double appBarHeight = MediaQuery.of(context).size.height *
        Utils.appBarSmallerHeightPercentage;
    const double filterBarHeight = 80.0;

    return Scaffold(
      body: BlocBuilder<DiariesCubit, DiariesState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Main Content
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  // Place content strictly below header (app bar + filter bar)
                  margin:
                      EdgeInsets.only(top: appBarHeight + filterBarHeight),
                  child: _buildContent(state),
                ),
              ),
      
              // Custom App Bar with back button and filter button
              Align(
                alignment: Alignment.topCenter,
                child: CustomAppBar(
                  title: context.read<AuthCubit>().isParent()
                      ? Utils.getTranslatedLabel(studentDiaryKey)
                      : Utils.getTranslatedLabel(myDiaryKey),
                  showBackButton: true,
                  trailingWidget: IconButton(
                    onPressed: _showSortBottomSheet,
                    icon: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
      
              // Filter Section
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  // Ensure the filter bar starts just below the curved app bar
                  margin: EdgeInsets.only(top: appBarHeight),
                  child: AppbarFilterBackgroundContainer(
                    height: filterBarHeight,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilterButton(
                              onTap: () {
                                if (state is DiariesFetchSuccess) {
                                  final categories =
                                      _getCategories(state.students);
                                  Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<String>(
                                      onSelection: (value) {
                                        _onCategoryChanged(value);
                                        Get.back();
                                      },
                                      selectedValue: _selectedCategory,
                                      titleKey: "categories",
                                      values: categories,
                                      showFilterByLabel: false,
                                    ),
                                    context: context,
                                  );
                                }
                              },
                              titleKey: _selectedCategory,
                              width: boxConstraints.maxWidth * 0.48,
                            ),
                            FilterButton(
                              onTap: () {
                                final subjects = _getSubjects();
                                Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<String>(
                                    onSelection: (value) {
                                      _onSubjectChanged(value);
                                      Get.back();
                                    },
                                    selectedValue: _selectedSubject,
                                    titleKey: "subjects",
                                    values: subjects,
                                    showFilterByLabel: false,
                                  ),
                                  context: context,
                                );
                              },
                              titleKey: _selectedSubject,
                              width: boxConstraints.maxWidth * 0.48,
                            ),
                          ],
                        );
                      },
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

  Widget _buildContent(DiariesState state) {
    if (state is DiariesFetchInProgress) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
          child: CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (state is DiariesFetchFailure) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
          child: ErrorContainer(
            onTapRetry: () {
              // Get the actual IDs for selected filters
              int? categoryId;
              int? subjectId;

              if (_selectedCategory != "allCategories") {
                categoryId = _getCategoryIdFromName(_selectedCategory);
              }

              if (_selectedSubject != "allSubjects") {
                subjectId = _getSubjectIdFromName(_selectedSubject);
              }

              context.read<DiariesCubit>().getDiaries(
                    studentId: widget.studentId,
                    sort: _selectedSort,
                    diaryCategoryId: categoryId,
                    subjectId: subjectId,
                  );
            },
            errorMessageCode: state.errorMessage,
          ),
        ),
      );
    }

    if (state is DiariesFetchSuccess) {
      final filteredEntries = _getFilteredEntries(state.students);
      final positiveCount = _getPositiveCount(filteredEntries);
      final negativeCount = _getNegativeCount(filteredEntries);

      return Column(
        children: [
          // Fixed Content (Statistics and Add Note Button)
          Container(
            padding: EdgeInsets.symmetric(
              vertical: appContentHorizontalPadding,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: _FixedContentWidget(
              positiveCount: positiveCount,
              negativeCount: negativeCount,
              onAddNoteTap: () {
                // Get.toNamed(Routes.addNoteScreen);
              },
            ),
          ),

          // Scrollable Content (Diary Entries List)
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20, top: 16),
              child: Column(
                children: [
                  // Diary Entries List
                  if (filteredEntries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: NoDataContainer(
                        titleKey: "noDiaryEntriesFound",
                      ),
                    )
                  else
                    ...filteredEntries.map((diaryStudent) {
                      final entry =
                          _convertDiaryStudentToEntryMap(diaryStudent);
                      return DiaryEntryCard(
                        entry: entry,
                      );
                    }),

                  // Load more indicator
                  if (state.fetchMoreInProgress)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                  // Load more error
                  if (state.fetchMoreError)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CustomTextButton(
                          buttonTextKey: retryKey,
                          onTapButton: () {
                            // Get the actual IDs for selected filters
                            int? categoryId;
                            int? subjectId;

                            if (_selectedCategory != "allCategories") {
                              categoryId =
                                  _getCategoryIdFromName(_selectedCategory);
                            }

                            if (_selectedSubject != "allSubjects") {
                              subjectId =
                                  _getSubjectIdFromName(_selectedSubject);
                            }

                            context.read<DiariesCubit>().fetchMore(
                                  sort: _selectedSort,
                                  diaryCategoryId: categoryId,
                                  subjectId: subjectId,
                                );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }
}

class _FixedContentWidget extends StatelessWidget {
  final int positiveCount;
  final int negativeCount;
  final VoidCallback onAddNoteTap;

  const _FixedContentWidget({
    required this.positiveCount,
    required this.negativeCount,
    required this.onAddNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: DiaryStatsContainer(
        positiveCount: positiveCount,
        negativeCount: negativeCount,
      ),
    );
  }
}
