import 'package:bepop_ngu/data/repositories/onlineExamRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitOnlineExamAnswersState {}

class SubmitOnlineExamAnswersInitial extends SubmitOnlineExamAnswersState {}

class SubmitOnlineExamAnswersInProgress extends SubmitOnlineExamAnswersState {}

class SubmitOnlineExamAnswersSuccess extends SubmitOnlineExamAnswersState {
  final String message;

  SubmitOnlineExamAnswersSuccess({required this.message});
}

class SubmitOnlineExamAnswersFailure extends SubmitOnlineExamAnswersState {
  final String errorMessage;

  SubmitOnlineExamAnswersFailure(this.errorMessage);
}

class SubmitOnlineExamAnswersCubit extends Cubit<SubmitOnlineExamAnswersState> {
  final OnlineExamRepository _onlineExamRepository;

  SubmitOnlineExamAnswersCubit(this._onlineExamRepository)
      : super(SubmitOnlineExamAnswersInitial());

  void submitAnswers(
      {required int examId, required Map<int, List<int>> answers}) async {
    if (isClosed) return; // Prevent operation on closed cubit

    emit(SubmitOnlineExamAnswersInProgress());

    try {
      final result = await _onlineExamRepository.setExamOnlineAnswers(
          examId: examId, answerData: answers);

      if (!isClosed) {
        // Check before emitting
        emit(SubmitOnlineExamAnswersSuccess(message: result));
      }
    } catch (e) {
      if (!isClosed) {
        // Check before emitting
      emit(SubmitOnlineExamAnswersFailure(e.toString()));
      }
    }
  }
}
