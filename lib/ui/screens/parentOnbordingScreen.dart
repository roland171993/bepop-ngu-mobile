
import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/schoolDetailsCubit.dart';
import 'package:bepop_ngu/utils/hiveBoxKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:bepop_ngu/ui/widgets/networkImageHandler.dart';

class ParentOnbordingScreen extends StatefulWidget {
  const ParentOnbordingScreen({super.key});

  @override
  State<ParentOnbordingScreen> createState() => _ParentOnbordingScreenState();
  static Widget routeInstance() {
    return ParentOnbordingScreen();
  }
}

class _ParentOnbordingScreenState extends State<ParentOnbordingScreen> {
  @override
  void initState() {
    context.read<SchooldetailsCubit>().fetchSchooldetails();
    super.initState();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    var box = await Hive.openBox(parentBoxKey);
    bool isFirstTime = box.get('isFirstTimeparent', defaultValue: true);
    if (isFirstTime) {
      await box.put('isFirstTimeparent', false);

      Future.delayed(Duration(seconds: 5), () {
        Get.offNamedUntil(Routes.parentHome, (Route<dynamic> route) => false);
      });
    } else {
      Get.offNamedUntil(Routes.parentHome, (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<SchooldetailsCubit, SchooldetailsState>(
      builder: (context, state) {
        if (state is SchooldetailsFetchSuccess) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: context.height * (0.06), left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NetworkImageHandler(
                    imageUrl: '${state.schoolDetails.schoolLogo}',
                    height: context.height * 0.17,
                    width: context.width * 0.4,
                    fit: BoxFit.fill,
                    errorWidget: SvgPicture.asset(
                      Utils.getImagePath("appLogo.svg"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: context.height * 0.03),
                  Text(
                    '${state.schoolDetails.schoolName}',
                    style: TextStyle(
                      fontSize: Utils.screenOnbordingTitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff22577a),
                    ),
                  ),
                  GridView.builder(
                    padding: EdgeInsets.only(top: context.height * 0.03),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 8,
                      mainAxisExtent: context.height * 0.22,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      String? imageUrl = (state.schoolDetails.schoolImages !=
                                  null &&
                              state.schoolDetails.schoolImages!.length > index)
                          ? state.schoolDetails.schoolImages![index]
                          : '';

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? NetworkImageHandler(
                                imageUrl: imageUrl,
                                fit: BoxFit.fill,
                                height: context.height * 0.22,
                                placeholder: Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: SvgPicture.asset(
                                  Utils.getImagePath("appLogo.svg"),
                                  fit: BoxFit.fill,
                                ),
                              )
                            : SvgPicture.asset(
                                Utils.getImagePath("appLogo.svg"),
                                fit: BoxFit.fill,
                              ),
                      );
                    },
                  ),
                  SizedBox(height: context.height * 0.03),
                  Text(
                    '${state.schoolDetails.schoolTagline}',
                    style: TextStyle(
                      fontSize: Utils.screenOnbordingTitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff22577a),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        if (state is SchooldetailsFetchInProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container();
      },
    ));
  }
}
