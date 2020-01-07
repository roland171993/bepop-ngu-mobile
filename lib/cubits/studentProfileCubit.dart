import 'package:equatable/equatable.dart';
import 'package:bepop_ngu/data/models/student.dart';
import 'package:bepop_ngu/data/repositories/studentRepository.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentProfileState extends Equatable {}

class StudentProfileInitial extends StudentProfileState {
  @override
  List<Object?> get props => [];
}

class StudentProfileFetchInProgress extends StudentProfileState {
  @override
  List<Object?> get props => [];
}

class StudentProfileFetchSuccess extends StudentProfileState {
  final Student student;

  StudentProfileFetchSuccess({required this.student});

  @override
  List<Object?> get props => [student];
}

class StudentProfileFetchFailure extends StudentProfileState {
  final String errorMessage;

  StudentProfileFetchFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class StudentProfileCubit extends Cubit<StudentProfileState> {
  final StudentRepository _studentRepository;
  final AuthRepository _authRepository;

  StudentProfileCubit(this._studentRepository, this._authRepository)
      : super(StudentProfileInitial());

  /// Get current student profile data from local storage
  Student getCurrentStudentProfile() {
    return _authRepository.getStudentProfileData();
  }

  /// Fetch student profile data from API and update local storage
  Future<void> fetchStudentProfile({
    required bool useParentApi,
    int? childId,
    bool forceRefresh = false,
  }) async {
    // If not force refresh and we have data, emit success with current data
    if (!forceRefresh) {
      final currentProfile = getCurrentStudentProfile();
      if (currentProfile.id != null) {
        emit(StudentProfileFetchSuccess(student: currentProfile));
      }
    }

    emit(StudentProfileFetchInProgress());

    try {
      final student = await _studentRepository.fetchStudentFullProfileDetails(
        useParentApi: useParentApi,
        childId: childId,
      );

      // Store the updated profile data in Hive
      await _authRepository.setStudentProfileData(student);

      // Also update the main student details in auth for backward compatibility
      await _authRepository.setStudentDetails(student);

      emit(StudentProfileFetchSuccess(student: student));
    } catch (e) {
      // If we have cached data, emit success with cached data
      final cachedProfile = getCurrentStudentProfile();
      if (cachedProfile.id != null) {
        emit(StudentProfileFetchSuccess(student: cachedProfile));
      } else {
        emit(StudentProfileFetchFailure(errorMessage: e.toString()));
      }
    }
  }

  /// Refresh student profile data from API
  Future<void> refreshStudentProfile({
    required bool useParentApi,
    int? childId,
  }) async {
    await fetchStudentProfile(
      useParentApi: useParentApi,
      childId: childId,
      forceRefresh: true,
    );
  }

  /// Clear profile data (for logout)
  Future<void> clearProfileData() async {
    await _authRepository.clearStudentProfileData();
    emit(StudentProfileInitial());
  }
}
