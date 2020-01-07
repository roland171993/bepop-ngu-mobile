import 'package:bepop_ngu/data/models/studentDetailsResponse.dart';
import 'package:bepop_ngu/data/models/subject.dart';
import 'package:bepop_ngu/data/repositories/studentDetailsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentDetailsState {}

class StudentDetailsInitial extends StudentDetailsState {}

class StudentDetailsFetchInProgress extends StudentDetailsState {}

class StudentDetailsFetchSuccess extends StudentDetailsState {
  final StudentDetailsResponse studentDetails;

  StudentDetailsFetchSuccess({required this.studentDetails});
}

class StudentDetailsFetchFailure extends StudentDetailsState {
  final String errorMessage;

  StudentDetailsFetchFailure(this.errorMessage);
}

class StudentDetailsCubit extends Cubit<StudentDetailsState> {
  final StudentDetailsRepository _studentDetailsRepository =
      StudentDetailsRepository();

  StudentDetailsCubit() : super(StudentDetailsInitial());

  void getStudentDetails({required int studentId}) async {
    try {
      emit(StudentDetailsFetchInProgress());

      final studentDetails = await _studentDetailsRepository.getStudentDetails(
          studentId: studentId);

      emit(StudentDetailsFetchSuccess(studentDetails: studentDetails));
    } catch (e) {
      emit(StudentDetailsFetchFailure(e.toString()));
    }
  }

  // Get all subject names for filtering
  List<String> getSubjectNames() {
    if (state is StudentDetailsFetchSuccess) {
      return (state as StudentDetailsFetchSuccess)
          .studentDetails
          .getSubjectNames();
    }
    return [];
  }

  // Get all subjects as a flat list
  List<Subject> getAllSubjects() {
    if (state is StudentDetailsFetchSuccess) {
      return (state as StudentDetailsFetchSuccess)
          .studentDetails
          .getAllSubjects();
    }
    return [];
  }
}
