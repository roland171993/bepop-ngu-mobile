import 'package:bepop_ngu/data/models/studentDiaryResponse.dart';
import 'package:bepop_ngu/data/models/studentDiaryDetails.dart';
import 'package:bepop_ngu/data/repositories/diaryRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DiariesState {}

class DiariesInitial extends DiariesState {}

class DiariesFetchInProgress extends DiariesState {}

class DiariesFetchSuccess extends DiariesState {
  final StudentDiaryResponse diaryResponse;
  final List<StudentDiaryDetails> students;
  final bool fetchMoreInProgress;
  final bool fetchMoreError;
  final int currentPage;
  final int totalPage;

  DiariesFetchSuccess({
    required this.diaryResponse,
    required this.students,
    required this.fetchMoreInProgress,
    required this.fetchMoreError,
    required this.currentPage,
    required this.totalPage,
  });

  DiariesFetchSuccess copyWith({
    StudentDiaryResponse? diaryResponse,
    List<StudentDiaryDetails>? students,
    bool? fetchMoreInProgress,
    bool? fetchMoreError,
    int? currentPage,
    int? totalPage,
  }) {
    return DiariesFetchSuccess(
      diaryResponse: diaryResponse ?? this.diaryResponse,
      students: students ?? this.students,
      fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
      fetchMoreError: fetchMoreError ?? this.fetchMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

class DiariesFetchFailure extends DiariesState {
  final String errorMessage;

  DiariesFetchFailure(this.errorMessage);
}

class DiariesCubit extends Cubit<DiariesState> {
  final DiaryRepository _diaryRepository = DiaryRepository();

  DiariesCubit() : super(DiariesInitial());

  void getDiaries({
    int? classSectionId,
    int? sessionYearId,
    int? diaryCategoryId,
    int? subjectId,
    int? studentId,
    String? search,
    String? sort,
  }) async {
    emit(DiariesFetchInProgress());
    try {
      final result = await _diaryRepository.getDiaries(
        page: 1,
        classSectionId: classSectionId,
        sessionYearId: sessionYearId,
        diaryCategoryId: diaryCategoryId,
        subjectId: subjectId,
        studentId: studentId,
        search: search,
        sort: sort,
      );

      emit(DiariesFetchSuccess(
        diaryResponse: result,
        students: result.students,
        fetchMoreInProgress: false,
        fetchMoreError: false,
        currentPage: result.currentPage,
        totalPage: result.lastPage,
      ));
    } catch (e) {
      emit(DiariesFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is DiariesFetchSuccess) {
      return (state as DiariesFetchSuccess).currentPage <
          (state as DiariesFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore({
    int? classSectionId,
    int? sessionYearId,
    int? diaryCategoryId,
    int? subjectId,
    String? search,
    String? sort,
  }) async {
    if (state is DiariesFetchSuccess) {
      final currentState = state as DiariesFetchSuccess;

      if (currentState.fetchMoreInProgress) {
        return;
      }

      try {
        emit(currentState.copyWith(fetchMoreInProgress: true));

        final result = await _diaryRepository.getDiaries(
          page: currentState.currentPage + 1,
          classSectionId: classSectionId,
          sessionYearId: sessionYearId,
          diaryCategoryId: diaryCategoryId,
          subjectId: subjectId,
          search: search,
          sort: sort,
        );

        List<StudentDiaryDetails> students = currentState.students;
        students.addAll(result.students);

        emit(DiariesFetchSuccess(
          diaryResponse: result,
          students: students,
          fetchMoreInProgress: false,
          fetchMoreError: false,
          currentPage: result.currentPage,
          totalPage: result.lastPage,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          fetchMoreInProgress: false,
          fetchMoreError: true,
        ));
      }
    }
  }
}
