import 'package:bepop_ngu/ui/screens/aboutUsScreen.dart';
import 'package:bepop_ngu/ui/screens/assignment/assignmentScreen.dart';
import 'package:bepop_ngu/ui/screens/auth/authScreen.dart';
import 'package:bepop_ngu/ui/screens/auth/parentLoginScreen.dart';
import 'package:bepop_ngu/ui/screens/auth/studentLoginScreen.dart';
import 'package:bepop_ngu/ui/screens/chapterDetails/chapterDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/chat/chatScreen.dart';
import 'package:bepop_ngu/ui/screens/chatContacts/chatContactsScreen.dart';
import 'package:bepop_ngu/ui/screens/chatContacts/newChatContactsScreen.dart';
import 'package:bepop_ngu/ui/screens/childAssignmentsScreen.dart';
import 'package:bepop_ngu/ui/screens/childAttendanceScreen.dart';
import 'package:bepop_ngu/ui/screens/childDetailMenuScreen.dart';
import 'package:bepop_ngu/ui/screens/childDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/childFeeDetails/childFeeDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/childFeesScreen.dart';
import 'package:bepop_ngu/ui/screens/childResultsScreen.dart';
import 'package:bepop_ngu/ui/screens/childTeachers.dart';
import 'package:bepop_ngu/ui/screens/childTimeTableScreen.dart';
import 'package:bepop_ngu/ui/screens/confirmPaymentScreen.dart';
import 'package:bepop_ngu/ui/screens/contactUsScreen.dart';
import 'package:bepop_ngu/ui/screens/exam/examTimeTableScreen.dart';
import 'package:bepop_ngu/ui/screens/exam/onlineExam/examOnlineScreen.dart';
import 'package:bepop_ngu/ui/screens/examScreen.dart';
import 'package:bepop_ngu/ui/screens/faqsScreen.dart';
import 'package:bepop_ngu/ui/screens/galleryDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/galleryImagesScreen.dart';
import 'package:bepop_ngu/ui/screens/holidaysScreen.dart';
import 'package:bepop_ngu/ui/screens/home/homeScreen.dart';
import 'package:bepop_ngu/ui/screens/manageDiary/studentDiaryScreen.dart';
import 'package:bepop_ngu/ui/screens/noticeBoardScreen.dart';
import 'package:bepop_ngu/ui/screens/notificationsScreen.dart';
import 'package:bepop_ngu/ui/screens/parentOnbordingScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/selectTransport/staffTransportEnrollScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/selectTransport/widgets/requestSubmittedScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/trasportAttendanceScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/busRouteScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/changeRouteScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/planRenewalScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/transportHomeScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/transportPlanDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/transportRequestDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/studentOnbordingScreen.dart';
import 'package:bepop_ngu/ui/screens/parentHomeScreen.dart';
import 'package:bepop_ngu/ui/screens/parentProfileScreen.dart';
import 'package:bepop_ngu/ui/screens/playVideo/playVideoScreen.dart';
import 'package:bepop_ngu/ui/screens/privacyPolicyScreen.dart';
import 'package:bepop_ngu/ui/screens/reports/reportSubjectsContainer.dart';
import 'package:bepop_ngu/ui/screens/reports/subjectWiseDetailedReport.dart';
import 'package:bepop_ngu/ui/screens/resultOnline/resultOnlineScreen.dart';
import 'package:bepop_ngu/ui/screens/resultScreen.dart';
import 'package:bepop_ngu/ui/screens/schoolGalleryScreen.dart';
import 'package:bepop_ngu/ui/screens/selectSubjectsScreen.dart';
import 'package:bepop_ngu/ui/screens/settingsScreen.dart';
import 'package:bepop_ngu/ui/screens/splashScreen.dart';
import 'package:bepop_ngu/ui/screens/studentProfileScreen.dart';
import 'package:bepop_ngu/ui/screens/subjectDetails/subjectDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/termsAndConditionScreen.dart';
import 'package:bepop_ngu/ui/screens/topicDetailsScreen.dart';
import 'package:bepop_ngu/ui/screens/transactionsScreen.dart';
import 'package:bepop_ngu/ui/screens/transportationPayment/transportationPaymentScreen.dart';
import 'package:bepop_ngu/utils/paymentWebview.dart';
import 'package:get/route_manager.dart';

// ignore: avoid_classes_with_only_static_members
class Routes {
  static const String splash = "/splash";
  static const String studentOnbording = "/studentOnbording";
  static const String parentOnbording = "/parentOnbording";
  static const String home = "/";

  static const String auth = "/auth";
  static const String parentLogin = "/parentLogin";
  static const String studentLogin = "/studentLogin";
  static const String studentProfile = "/studentProfile";
  static const String assignment = "/assignment";

  static const String exam = "/exam";

  static const String examTimeTable = "/examTimeTable";

  static const String subjectDetails = "/subjectDetails";

  static const String chapterDetails = "/chapterDetails";

  static const String aboutUs = "/aboutUs";
  static const String privacyPolicy = "/privacyPolicy";

  static const String contactUs = "/contactUs";
  static const String faqs = "/faqs";

  static const String termsAndCondition = "/termsAndCondition";

  static const String selectSubjects = "/selectSubjects";
  static const String result = "/result";
  static const String parentHome = "/parent";

  static const String parentChildDetails = "/parent/studentDetails";

  static const String parentMenu = "/parent/studentDetailsMenu";

  static const String topicDetails = "/topicDetails";

  static const String playVideo = "/playVideo";

  static const String childAssignments = "/childAssignments";

  static const String childAttendance = "/childAttendance";

  static const String childTimeTable = "/childTimeTable";

  static const String childResults = "/childResults";

  static const String childTeachers = "/childTeachers";
  static const String childTransportation = "/childTransportation";
  static const String transportSuccess = "/transportSuccess";
  static const String liveBusTracking = "/liveBusTracking";
  static const String childFees = "/childFees";
  static const String settings = "/settings";
  static const String parentProfile = "/parentProfile";
  static const String noticeBoard = "/noticeBoard";
  static const String holidays = "/holidays";
  static const String subjectWiseReport = "/reportSubjectsContainer";
  static const String subjectWiseDetailedReport = "/subjectWiseDetailedReport";
  static const String examOnline = "/examOnline";
  static const String resultOnline = "/resultOnline";
  static const String childFeeDetails = "/childFeeDetails";
  static const String confirmPayment = "/confirmPayment";
  static const String transactions = "/transactions";
  static const String schoolGallery = "/schoolGallery";
  static const String galleryDetails = "/galleryDetails";
  static const String galleryImages = "/galleryImages";
  static const String notifications = "/notifications";
  static const String chatContacts = "/chatContacts";
  static const String newChatContacts = "/newChatContacts";
  static const String chat = "/chat";
  static const String paymentWebview = '/payment-webview';
  static const String transportationPayment = "/transportationPayment";
  static String studentDiaryScreen = "/studentDiary";

  static String staffTransportEnrollScreen = "/staffTransportEnroll";
  static String transportEnrollSubmittedScreen = "/transportEnrollSubmitted";
  static String transportEnrollHomeScreen = "/transportEnrollHome";
  static String transportPlanDetailsScreen = "/transportPlanDetails";
  static String busRouteScreen = "/busRoute";
  static String changeRouteScreen = "/changeRoute";
  static String transportAttendanceScreen = "/transportAttendance";
  static String transportRequestDetailsScreen = "/transportRequestDetails";
  static String planRenewalScreen = "/planRenewal";

  static List<GetPage> getPages = [
    GetPage(name: splash, page: () => SplashScreen.routeInstance()),
    GetPage(
        name: studentOnbording,
        page: () => StudentOnbordingScreen.routeInstance()),
    GetPage(
        name: parentOnbording,
        page: () => ParentOnbordingScreen.routeInstance()),
    GetPage(name: home, page: () => HomeScreen.routeInstance()),
    GetPage(name: auth, page: () => AuthScreen.routeInstance()),
    GetPage(name: studentLogin, page: () => StudentLoginScreen.routeInstance()),
    GetPage(name: parentLogin, page: () => ParentLoginScreen.routeInstance()),
    GetPage(name: parentHome, page: () => ParentHomeScreen.routeInstance()),
    GetPage(
        name: studentProfile, page: () => StudentProfileScreen.routeInstance()),
    GetPage(name: assignment, page: () => AssignmentScreen.routeInstance()),
    GetPage(name: exam, page: () => ExamScreen.routeInstance()),
    GetPage(
        name: examTimeTable, page: () => ExamTimeTableScreen.routeInstance()),
    GetPage(
        name: subjectDetails, page: () => SubjectDetailsScreen.routeInstance()),
    GetPage(
        name: chapterDetails, page: () => ChapterDetailsScreen.routeInstance()),
    GetPage(name: aboutUs, page: () => AboutUsScreen.routeInstance()),
    GetPage(
        name: privacyPolicy, page: () => PrivacyPolicyScreen.routeInstance()),
    GetPage(
        name: termsAndCondition,
        page: () => TermsAndConditionScreen.routeInstance()),
    GetPage(name: contactUs, page: () => ContactUsScreen.routeInstance()),
    GetPage(name: faqs, page: () => FaqsScreen.routeInstance()),
    GetPage(name: result, page: () => ResultScreen.routeInstance()),
    GetPage(
        name: selectSubjects, page: () => SelectSubjectsScreen.routeInstance()),
    GetPage(
        name: parentChildDetails,
        page: () => ChildDetailsScreen.routeInstance()),
    GetPage(name: topicDetails, page: () => TopicDetailsScreen.routeInstance()),
    GetPage(name: playVideo, page: () => PlayVideoScreen.routeInstance()),
    GetPage(
        name: childAssignments,
        page: () => ChildAssignmentsScreen.routeInstance()),
    GetPage(
        name: childAttendance,
        page: () => ChildAttendanceScreen.routeInstance()),
    GetPage(
        name: childTimeTable, page: () => ChildTimeTableScreen.routeInstance()),
    GetPage(name: childResults, page: () => ChildResultsScreen.routeInstance()),
    GetPage(
        name: childTeachers, page: () => ChildTeachersScreen.routeInstance()),
    GetPage(name: settings, page: () => SettingsScreen.routeInstance()),
    GetPage(
        name: parentProfile, page: () => ParentProfileScreen.routeInstance()),
    GetPage(name: noticeBoard, page: () => NoticeBoardScreen.routeInstance()),
    GetPage(name: holidays, page: () => HolidaysScreen.routeInstance()),
    GetPage(
        name: subjectWiseReport,
        page: () => ReportSubjectsContainer.routeInstance()),
    GetPage(
        name: subjectWiseDetailedReport,
        page: () => SubjectWiseDetailedReport.routeInstance()),
    GetPage(name: examOnline, page: () => ExamOnlineScreen.routeInstance()),
    GetPage(name: resultOnline, page: () => ResultOnlineScreen.routeInstance()),
    GetPage(
        name: parentMenu, page: () => ChildDetailMenuScreen.routeInstance()),
    GetPage(name: childFees, page: () => ChildFeesScreen.routeInstance()),
    GetPage(
        name: childFeeDetails,
        page: () => ChildFeeDetailsScreen.routeInstance()),
    GetPage(
        name: confirmPayment, page: () => ConfirmPaymentScreen.routeInstance()),
    GetPage(name: transactions, page: () => TransactionsScreen.routeInstance()),
    GetPage(
        name: schoolGallery, page: () => SchoolGalleryScreen.routeInstance()),
    GetPage(
        name: galleryDetails, page: () => GalleryDetailsScreen.routeInstance()),
    GetPage(
        name: galleryImages, page: () => GalleryImagesScreen.routeInstance()),
    GetPage(
        name: notifications, page: () => NotificationsScreen.routeInstance()),
    GetPage(name: chatContacts, page: () => ChatContactsScreen.routeInstance()),
    GetPage(name: chat, page: () => ChatScreen.routeInstance()),
    GetPage(
      name: newChatContacts,
      page: () => NewChatContactsScreen.routeInstance(),
    ),
    GetPage(
      name: Routes.paymentWebview,
      page: () => const PaymentWebView(),
    ),
    GetPage(
      name: transportationPayment,
      page: () => TransportationPaymentScreen.routeInstance(),
    ),
    GetPage(
        name: studentDiaryScreen,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>?;
          final studentId = arguments?['studentId'] as int? ?? 0;
          
          return StudentDiaryScreen.getRouteInstance(
            studentId: studentId,
           
          );
        }),

    // Staff transport enrollment
    GetPage(
      name: staffTransportEnrollScreen,
      page: () => StaffTransportEnrollScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportEnrollSubmittedScreen,
      page: () => TransportEnrollSubmittedScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportEnrollHomeScreen,
      page: () => TransportHomeScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportPlanDetailsScreen,
      page: () => TransportPlanDetailsScreen.getRouteInstance(),
    ),
    GetPage(
      name: busRouteScreen,
      page: () => BusRouteScreen.getRouteInstance(),
    ),
    GetPage(
      name: changeRouteScreen,
      page: () => ChangeRouteScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportAttendanceScreen,
      page: () => TransportAttendanceScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportRequestDetailsScreen,
      page: () => TransportRequestDetailsScreen.getRouteInstance(
        args: Get.arguments,
      ),
    ),
    GetPage(
        name: planRenewalScreen,
        page: () => PlanRenewalScreen.getRouteInstance()),
  ];
}
