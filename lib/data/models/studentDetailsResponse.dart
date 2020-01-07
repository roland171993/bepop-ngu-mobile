import 'package:bepop_ngu/data/models/subject.dart';

class StudentDetailsResponse {
  final int id;
  final int userId;
  final int? classId;
  final int classSectionId;
  final String applicationType;
  final String admissionNo;
  final int rollNumber;
  final String admissionDate;
  final int schoolId;
  final int applicationStatus;
  final int guardianId;
  final int? joinSessionYearId;
  final int? leaveSessionYearId;
  final int sessionYearId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final StudentSubjects subjects;
  final String firstName;
  final String lastName;
  final String fullName;
  final StudentUser user;
  final StudentClassSection classSection;

  StudentDetailsResponse({
    required this.id,
    required this.userId,
    this.classId,
    required this.classSectionId,
    required this.applicationType,
    required this.admissionNo,
    required this.rollNumber,
    required this.admissionDate,
    required this.schoolId,
    required this.applicationStatus,
    required this.guardianId,
    this.joinSessionYearId,
    this.leaveSessionYearId,
    required this.sessionYearId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.subjects,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.user,
    required this.classSection,
  });

  StudentDetailsResponse.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        userId = (json['user_id'] ?? 0) as int,
        classId = json['class_id'] as int?,
        classSectionId = (json['class_section_id'] ?? 0) as int,
        applicationType = (json['application_type'] ?? '') as String,
        admissionNo = (json['admission_no'] ?? '') as String,
        rollNumber = (json['roll_number'] ?? 0) as int,
        admissionDate = (json['admission_date'] ?? '') as String,
        schoolId = (json['school_id'] ?? 0) as int,
        applicationStatus = (json['application_status'] ?? 0) as int,
        guardianId = (json['guardian_id'] ?? 0) as int,
        joinSessionYearId = json['join_session_year_id'] as int?,
        leaveSessionYearId = json['leave_session_year_id'] as int?,
        sessionYearId = (json['session_year_id'] ?? 0) as int,
        createdAt = (json['created_at'] ?? '') as String,
        updatedAt = (json['updated_at'] ?? '') as String,
        deletedAt = json['deleted_at'] as String?,
        subjects = json['subjects'] != null && json['subjects'] is Map
            ? StudentSubjects.fromJson(
                Map<String, dynamic>.from(json['subjects']))
            : StudentSubjects(coreSubjects: [], electiveSubjects: []),
        firstName = (json['first_name'] ?? '') as String,
        lastName = (json['last_name'] ?? '') as String,
        fullName = (json['full_name'] ?? '') as String,
        user = StudentUser.fromJson(Map.from(json['user'] ?? {})),
        classSection =
            StudentClassSection.fromJson(Map.from(json['class_section'] ?? {}));

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'class_id': classId,
        'class_section_id': classSectionId,
        'application_type': applicationType,
        'admission_no': admissionNo,
        'roll_number': rollNumber,
        'admission_date': admissionDate,
        'school_id': schoolId,
        'application_status': applicationStatus,
        'guardian_id': guardianId,
        'join_session_year_id': joinSessionYearId,
        'leave_session_year_id': leaveSessionYearId,
        'session_year_id': sessionYearId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'subjects': subjects.toJson(),
        'first_name': firstName,
        'last_name': lastName,
        'full_name': fullName,
        'user': user.toJson(),
        'class_section': classSection.toJson(),
      };

  // Get all subjects (core + elective) as a flat list
  List<Subject> getAllSubjects() {
    List<Subject> allSubjects = [];

    // Add core subjects
    for (var coreSubject in subjects.coreSubjects) {
      allSubjects.add(coreSubject.subject);
    }

    // Add elective subjects
    for (var electiveSubject in subjects.electiveSubjects) {
      allSubjects.add(electiveSubject.classSubject.subject);
    }

    return allSubjects;
  }

  // Get unique subject names for filtering
  List<String> getSubjectNames() {
    Set<String> subjectNames = {};

    for (var coreSubject in subjects.coreSubjects) {
      subjectNames.add(coreSubject.subject.nameWithType ?? '');
    }

    for (var electiveSubject in subjects.electiveSubjects) {
      subjectNames.add(electiveSubject.classSubject.subject.nameWithType ?? '');
    }

    return subjectNames.where((name) => name.isNotEmpty).toList();
  }
}

class StudentSubjects {
  final List<CoreSubject> coreSubjects;
  final List<ElectiveSubject> electiveSubjects;

  StudentSubjects({
    required this.coreSubjects,
    required this.electiveSubjects,
  });

  StudentSubjects.fromJson(Map<String, dynamic> json)
      : coreSubjects = ((json['core_subject'] ?? []) as List)
            .map((subject) => CoreSubject.fromJson(Map.from(subject)))
            .toList(),
        electiveSubjects = ((json['elective_subject'] ?? []) as List)
            .map((subject) => ElectiveSubject.fromJson(Map.from(subject)))
            .toList();

  Map<String, dynamic> toJson() => {
        'core_subject': coreSubjects.map((e) => e.toJson()).toList(),
        'elective_subject': electiveSubjects.map((e) => e.toJson()).toList(),
      };
}

class CoreSubject {
  final int id;
  final String name;
  final String code;
  final String bgColor;
  final String image;
  final int mediumId;
  final String type;
  final int schoolId;
  final String? deletedAt;
  final int classSubjectId;
  final String nameWithType;
  final Pivot pivot;
  final Subject subject;

  CoreSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.bgColor,
    required this.image,
    required this.mediumId,
    required this.type,
    required this.schoolId,
    this.deletedAt,
    required this.classSubjectId,
    required this.nameWithType,
    required this.pivot,
    required this.subject,
  });

  CoreSubject.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        name = (json['name'] ?? '') as String,
        code = (json['code'] ?? '') as String,
        bgColor = (json['bg_color'] ?? '') as String,
        image = (json['image'] ?? '') as String,
        mediumId = (json['medium_id'] ?? 0) as int,
        type = (json['type'] ?? '') as String,
        schoolId = (json['school_id'] ?? 0) as int,
        deletedAt = json['deleted_at'] as String?,
        classSubjectId = (json['class_subject_id'] ?? 0) as int,
        nameWithType = (json['name_with_type'] ?? '') as String,
        pivot = json['pivot'] != null && json['pivot'] is Map
            ? Pivot.fromJson(Map<String, dynamic>.from(json['pivot']))
            : Pivot(classId: 0, subjectId: 0),
        subject = Subject.fromJson(Map<String, dynamic>.from(json));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'bg_color': bgColor,
        'image': image,
        'medium_id': mediumId,
        'type': type,
        'school_id': schoolId,
        'deleted_at': deletedAt,
        'class_subject_id': classSubjectId,
        'name_with_type': nameWithType,
        'pivot': pivot.toJson(),
      };
}

class ElectiveSubject {
  final int classSubjectId;
  final ClassSubject classSubject;

  ElectiveSubject({
    required this.classSubjectId,
    required this.classSubject,
  });

  ElectiveSubject.fromJson(Map<String, dynamic> json)
      : classSubjectId = json['class_subject_id'] as int,
        classSubject =
            ClassSubject.fromJson(Map.from(json['class_subject'] ?? {}));

  Map<String, dynamic> toJson() => {
        'class_subject_id': classSubjectId,
        'class_subject': classSubject.toJson(),
      };
}

class ClassSubject {
  final int id;
  final int classId;
  final int subjectId;
  final String type;
  final int electiveSubjectGroupId;
  final int? semesterId;
  final int virtualSemesterId;
  final int schoolId;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final String subjectWithName;
  final Subject subject;

  ClassSubject({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.type,
    required this.electiveSubjectGroupId,
    this.semesterId,
    required this.virtualSemesterId,
    required this.schoolId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.subjectWithName,
    required this.subject,
  });

  ClassSubject.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        classId = (json['class_id'] ?? 0) as int,
        subjectId = (json['subject_id'] ?? 0) as int,
        type = (json['type'] ?? '') as String,
        electiveSubjectGroupId =
            (json['elective_subject_group_id'] ?? 0) as int,
        semesterId = json['semester_id'] as int?,
        virtualSemesterId = (json['virtual_semester_id'] ?? 0) as int,
        schoolId = (json['school_id'] ?? 0) as int,
        deletedAt = json['deleted_at'] as String?,
        createdAt = (json['created_at'] ?? '') as String,
        updatedAt = (json['updated_at'] ?? '') as String,
        subjectWithName = (json['subject_with_name'] ?? '') as String,
        subject = Subject.fromJson(Map.from(json['subject'] ?? {}));

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_id': classId,
        'subject_id': subjectId,
        'type': type,
        'elective_subject_group_id': electiveSubjectGroupId,
        'semester_id': semesterId,
        'virtual_semester_id': virtualSemesterId,
        'school_id': schoolId,
        'deleted_at': deletedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'subject_with_name': subjectWithName,
        'subject': subject.toJson(),
      };
}

class Pivot {
  final int classId;
  final int subjectId;
  final int? semesterId;

  Pivot({
    required this.classId,
    required this.subjectId,
    this.semesterId,
  });

  Pivot.fromJson(Map<String, dynamic> json)
      : classId = (json['class_id'] ?? 0) as int,
        subjectId = (json['subject_id'] ?? 0) as int,
        semesterId = json['semester_id'] as int?;

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'subject_id': subjectId,
        'semester_id': semesterId,
      };
}

class StudentUser {
  final int id;
  final String firstName;
  final String lastName;
  final String? mobile;
  final String email;
  final String gender;
  final String image;
  final String dob;
  final String currentAddress;
  final String permanentAddress;
  final String? occupation;
  final int status;
  final int resetRequest;
  final String fcmId;
  final int schoolId;
  final String language;
  final String? emailVerifiedAt;
  final int twoFactorEnabled;
  final String? twoFactorSecret;
  final String? twoFactorExpiresAt;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String fullName;
  final String schoolNames;
  final String role;

  StudentUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.mobile,
    required this.email,
    required this.gender,
    required this.image,
    required this.dob,
    required this.currentAddress,
    required this.permanentAddress,
    this.occupation,
    required this.status,
    required this.resetRequest,
    required this.fcmId,
    required this.schoolId,
    required this.language,
    this.emailVerifiedAt,
    required this.twoFactorEnabled,
    this.twoFactorSecret,
    this.twoFactorExpiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.fullName,
    required this.schoolNames,
    required this.role,
  });

  StudentUser.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        firstName = (json['first_name'] ?? '') as String,
        lastName = (json['last_name'] ?? '') as String,
        mobile = json['mobile'] as String?,
        email = (json['email'] ?? '') as String,
        gender = (json['gender'] ?? '') as String,
        image = (json['image'] ?? '') as String,
        dob = (json['dob'] ?? '') as String,
        currentAddress = (json['current_address'] ?? '') as String,
        permanentAddress = (json['permanent_address'] ?? '') as String,
        occupation = json['occupation'] as String?,
        status = (json['status'] ?? 0) as int,
        resetRequest = (json['reset_request'] ?? 0) as int,
        fcmId = (json['fcm_id'] ?? '') as String,
        schoolId = (json['school_id'] ?? 0) as int,
        language = (json['language'] ?? 'en') as String,
        emailVerifiedAt = json['email_verified_at'] as String?,
        twoFactorEnabled = (json['two_factor_enabled'] ?? 0) as int,
        twoFactorSecret = json['two_factor_secret'] as String?,
        twoFactorExpiresAt = json['two_factor_expires_at'] as String?,
        createdAt = (json['created_at'] ?? '') as String,
        updatedAt = (json['updated_at'] ?? '') as String,
        deletedAt = json['deleted_at'] as String?,
        fullName = (json['full_name'] ?? '') as String,
        schoolNames = (json['school_names'] ?? '') as String,
        role = (json['role'] ?? '') as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'mobile': mobile,
        'email': email,
        'gender': gender,
        'image': image,
        'dob': dob,
        'current_address': currentAddress,
        'permanent_address': permanentAddress,
        'occupation': occupation,
        'status': status,
        'reset_request': resetRequest,
        'fcm_id': fcmId,
        'school_id': schoolId,
        'language': language,
        'email_verified_at': emailVerifiedAt,
        'two_factor_enabled': twoFactorEnabled,
        'two_factor_secret': twoFactorSecret,
        'two_factor_expires_at': twoFactorExpiresAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'full_name': fullName,
        'school_names': schoolNames,
        'role': role,
      };
}

class StudentClassSection {
  final int id;
  final int classId;
  final int sectionId;
  final int mediumId;
  final int schoolId;
  final String? deletedAt;
  final String name;
  final String fullName;
  final StudentClass classInfo;
  final StudentSection section;
  final StudentMedium medium;

  StudentClassSection({
    required this.id,
    required this.classId,
    required this.sectionId,
    required this.mediumId,
    required this.schoolId,
    this.deletedAt,
    required this.name,
    required this.fullName,
    required this.classInfo,
    required this.section,
    required this.medium,
  });

  StudentClassSection.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        classId = (json['class_id'] ?? 0) as int,
        sectionId = (json['section_id'] ?? 0) as int,
        mediumId = (json['medium_id'] ?? 0) as int,
        schoolId = (json['school_id'] ?? 0) as int,
        deletedAt = json['deleted_at'] as String?,
        name = (json['name'] ?? '') as String,
        fullName = (json['full_name'] ?? '') as String,
        classInfo = StudentClass.fromJson(Map.from(json['class'] ?? {})),
        section = StudentSection.fromJson(Map.from(json['section'] ?? {})),
        medium = StudentMedium.fromJson(Map.from(json['medium'] ?? {}));

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_id': classId,
        'section_id': sectionId,
        'medium_id': mediumId,
        'school_id': schoolId,
        'deleted_at': deletedAt,
        'name': name,
        'full_name': fullName,
        'class': classInfo.toJson(),
        'section': section.toJson(),
        'medium': medium.toJson(),
      };
}

class StudentClass {
  final int id;
  final String name;
  final int includeSemesters;
  final int mediumId;
  final int? shiftId;
  final int? streamId;
  final int schoolId;
  final String? deletedAt;
  final String fullName;
  final String semesterName;

  StudentClass({
    required this.id,
    required this.name,
    required this.includeSemesters,
    required this.mediumId,
    this.shiftId,
    this.streamId,
    required this.schoolId,
    this.deletedAt,
    required this.fullName,
    required this.semesterName,
  });

  StudentClass.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        name = (json['name'] ?? '') as String,
        includeSemesters = (json['include_semesters'] ?? 0) as int,
        mediumId = (json['medium_id'] ?? 0) as int,
        shiftId = json['shift_id'] as int?,
        streamId = json['stream_id'] as int?,
        schoolId = (json['school_id'] ?? 0) as int,
        deletedAt = json['deleted_at'] as String?,
        fullName = (json['full_name'] ?? '') as String,
        semesterName = (json['semester_name'] ?? '') as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'include_semesters': includeSemesters,
        'medium_id': mediumId,
        'shift_id': shiftId,
        'stream_id': streamId,
        'school_id': schoolId,
        'deleted_at': deletedAt,
        'full_name': fullName,
        'semester_name': semesterName,
      };
}

class StudentSection {
  final int id;
  final String name;
  final int schoolId;
  final String? deletedAt;

  StudentSection({
    required this.id,
    required this.name,
    required this.schoolId,
    this.deletedAt,
  });

  StudentSection.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        name = (json['name'] ?? '') as String,
        schoolId = (json['school_id'] ?? 0) as int,
        deletedAt = json['deleted_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'school_id': schoolId,
        'deleted_at': deletedAt,
      };
}

class StudentMedium {
  final int id;
  final String name;
  final int schoolId;
  final String? deletedAt;

  StudentMedium({
    required this.id,
    required this.name,
    required this.schoolId,
    this.deletedAt,
  });

  StudentMedium.fromJson(Map<String, dynamic> json)
      : id = (json['id'] ?? 0) as int,
        name = (json['name'] ?? '') as String,
        schoolId = (json['school_id'] ?? 0) as int,
        deletedAt = json['deleted_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'school_id': schoolId,
        'deleted_at': deletedAt,
      };
}
