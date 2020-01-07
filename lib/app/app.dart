import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bepop_ngu/app/appTranslation.dart';
import 'package:bepop_ngu/cubits/assignmentReportCubit.dart';
import 'package:bepop_ngu/cubits/assignmentsCubit.dart';
import 'package:bepop_ngu/cubits/childFeeDetailsCubit.dart';
import 'package:bepop_ngu/cubits/onlineExamReportCubit.dart';
import 'package:bepop_ngu/cubits/resultsOnlineCubit.dart';
import 'package:bepop_ngu/cubits/schoolConfigurationCubit.dart';
import 'package:bepop_ngu/cubits/schoolDetailsCubit.dart';
import 'package:bepop_ngu/cubits/socketSettingCubit.dart';
import 'package:bepop_ngu/cubits/studentProfileCubit.dart';
import 'package:bepop_ngu/data/repositories/assignmentRepository.dart';
import 'package:bepop_ngu/data/repositories/feeRepository.dart';
import 'package:bepop_ngu/data/repositories/resultRepository.dart';
import 'package:bepop_ngu/data/repositories/schoolRepository.dart';
import 'package:bepop_ngu/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bepop_ngu/app/routes.dart';

import 'package:bepop_ngu/cubits/appConfigurationCubit.dart';
import 'package:bepop_ngu/cubits/appLocalizationCubit.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/examDetailsCubit.dart';
import 'package:bepop_ngu/cubits/examsOnlineCubit.dart';
import 'package:bepop_ngu/cubits/noticeBoardCubit.dart';
import 'package:bepop_ngu/cubits/notificationSettingsCubit.dart';
import 'package:bepop_ngu/cubits/postFeesPaymentCubit.dart';
import 'package:bepop_ngu/cubits/reportTabSelectionCubit.dart';
import 'package:bepop_ngu/cubits/resultTabSelectionCubit.dart';
import 'package:bepop_ngu/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:bepop_ngu/cubits/examTabSelectionCubit.dart';

import 'package:bepop_ngu/data/repositories/announcementRepository.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/data/repositories/onlineExamRepository.dart';
import 'package:bepop_ngu/data/repositories/settingsRepository.dart';
import 'package:bepop_ngu/data/repositories/studentRepository.dart';
import 'package:bepop_ngu/data/repositories/systemInfoRepository.dart';

import 'package:bepop_ngu/cubits/onlineExamQuestionsCubit.dart';
import 'package:bepop_ngu/data/repositories/reportRepository.dart';
import 'package:bepop_ngu/ui/styles/colors.dart';

import 'package:bepop_ngu/utils/hiveBoxKeys.dart';
import 'package:bepop_ngu/utils/notificationUtility.dart';
import 'package:intl/date_symbol_data_local.dart';

//to avoid handshake error on some devices
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  HttpOverrides.global = MyHttpOverrides();
  //Register the licence of font
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  await AppTranslation.loadJsons();

  await NotificationUtility.initializeAwesomeNotification();

  await Hive.initFlutter();
  await Hive.openBox(showCaseBoxKey);
  await Hive.openBox(authBoxKey);
  await Hive.openBox(notificationsBoxKey);
  await Hive.openBox(settingsBoxKey);
  await Hive.openBox(studentSubjectsBoxKey);
  await initializeDateFormatting('en_US', null);

  runApp(const MyApp());
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationUtility.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationUtility.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationUtility.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationUtility.onDismissActionReceivedMethod,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //SVG images are automatically cached by flutter_svg
    return MultiBlocProvider(
      providers: [
        BlocProvider<SchooldetailsCubit>(
          create: (_) => SchooldetailsCubit(),
        ),
        BlocProvider<AppLocalizationCubit>(
          create: (_) => AppLocalizationCubit(SettingsRepository()),
        ),
        BlocProvider<NotificationSettingsCubit>(
          create: (_) => NotificationSettingsCubit(SettingsRepository()),
        ),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<StudentProfileCubit>(
          create: (_) =>
              StudentProfileCubit(StudentRepository(), AuthRepository()),
        ),
        BlocProvider<StudentSubjectsAndSlidersCubit>(
          create: (_) => StudentSubjectsAndSlidersCubit(),
        ),
        BlocProvider<NoticeBoardCubit>(
          create: (context) => NoticeBoardCubit(AnnouncementRepository()),
        ),
        BlocProvider<AppConfigurationCubit>(
          create: (context) => AppConfigurationCubit(SystemRepository()),
        ),
        BlocProvider<ExamDetailsCubit>(
          create: (context) => ExamDetailsCubit(StudentRepository()),
        ),
        BlocProvider<PostFeesPaymentCubit>(
          create: (context) => PostFeesPaymentCubit(StudentRepository()),
        ),
        BlocProvider<ResultTabSelectionCubit>(
          create: (_) => ResultTabSelectionCubit(),
        ),
        BlocProvider<ReportTabSelectionCubit>(
          create: (_) => ReportTabSelectionCubit(),
        ),
        BlocProvider<OnlineExamReportCubit>(
          create: (_) => OnlineExamReportCubit(ReportRepository()),
        ),
        BlocProvider<AssignmentReportCubit>(
          create: (_) => AssignmentReportCubit(ReportRepository()),
        ),
        BlocProvider<ExamTabSelectionCubit>(
          create: (_) => ExamTabSelectionCubit(),
        ),
        BlocProvider<OnlineExamQuestionsCubit>(
          create: (_) => OnlineExamQuestionsCubit(OnlineExamRepository()),
        ),
        BlocProvider<ExamsOnlineCubit>(
          create: (_) => ExamsOnlineCubit(OnlineExamRepository()),
        ),
        BlocProvider<ResultsOnlineCubit>(
          create: (_) => ResultsOnlineCubit(ResultRepository()),
        ),
        BlocProvider<AssignmentsCubit>(
          create: (_) => AssignmentsCubit(AssignmentRepository()),
        ),
        BlocProvider<SchoolConfigurationCubit>(
            create: (_) => SchoolConfigurationCubit(SchoolRepository())),
        BlocProvider<ChildFeeDetailsCubit>(
            create: (_) => ChildFeeDetailsCubit(FeeRepository())),
        BlocProvider<SocketSettingCubit>(
            create: (context) => SocketSettingCubit())
      ],
      child: Builder(
        builder: (context) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Theme.of(context).copyWith(
              textTheme:
                  GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              scaffoldBackgroundColor: pageBackgroundColor,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                    onPrimary: onPrimaryColor,
                    secondary: secondaryColor,
                    tertiary: tertiaryColor,
                    surface: backgroundColor,
                    error: errorColor,
                    onSecondary: onSecondaryColor,
                    onSurface: onBackgroundColor,
                  ),
            ),
            locale: context.read<AppLocalizationCubit>().state.language,
            fallbackLocale: const Locale("en"),
            getPages: Routes.getPages,
            initialRoute: Routes.splash,
            translationsKeys: AppTranslation.translationsKeys,
          );
        },
      ),
    );
  }
}
