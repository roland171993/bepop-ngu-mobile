import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/appConfigurationCubit.dart';
import 'package:bepop_ngu/cubits/studentProfileCubit.dart';
import 'package:bepop_ngu/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:bepop_ngu/ui/widgets/svgButton.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/systemModules.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeContainerTopProfileContainer extends StatelessWidget {
  const HomeContainerTopProfileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTopBackgroundContainer(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              //Bordered circles
              PositionedDirectional(
                top: MediaQuery.of(context).size.width * (-0.15),
                start: MediaQuery.of(context).size.width * (-0.225),
                child: Container(
                  padding:
                      const EdgeInsetsDirectional.only(end: 20.0, bottom: 20.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withValues(alpha: 0.1),
                    ),
                    shape: BoxShape.circle,
                  ),
                  width: MediaQuery.of(context).size.width * (0.6),
                  height: MediaQuery.of(context).size.width * (0.6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.1),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              //bottom fill circle
              PositionedDirectional(
                bottom: MediaQuery.of(context).size.width * (-0.15),
                end: MediaQuery.of(context).size.width * (-0.15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  width: MediaQuery.of(context).size.width * (0.4),
                  height: MediaQuery.of(context).size.width * (0.4),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                    end: boxConstraints.maxWidth * (0.065),
                    start: boxConstraints.maxWidth * (0.056),
                    bottom: boxConstraints.maxHeight * (0.2),
                  ),
                  child: BlocBuilder<StudentProfileCubit, StudentProfileState>(
                    builder: (context, profileState) {
                      // Get student data from profile cubit or fallback to current profile
                      final student = profileState is StudentProfileFetchSuccess
                          ? profileState.student
                          : context
                              .read<StudentProfileCubit>()
                              .getCurrentStudentProfile();

                      return Row(
                        children: [
                          BorderedProfilePictureContainer(
                            heightAndWidth: 60,
                            imageUrl: student.image ?? "",
                          ),
                          SizedBox(
                            width: boxConstraints.maxWidth * (0.03),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.getFullName(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${Utils.getTranslatedLabel(classKey)} : ${student.classSection?.fullName ?? ''}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Container(
                                      width: 1.5,
                                      height: 12.0,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "${Utils.getTranslatedLabel(rollNoKey)} : ${student.rollNumber ?? ''}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          BlocBuilder<AppConfigurationCubit,
                              AppConfigurationState>(
                            builder: (context, state) {
                              return Utils.isModuleEnabled(
                                      context: context,
                                      moduleId: chatModuleId.toString())
                                  ? SvgButton(
                                      onTap: () {
                                        Get.toNamed(Routes.chatContacts);
                                      },
                                      svgIconUrl:
                                          Utils.getImagePath("chat_icon.svg"),
                                    )
                                  : const SizedBox();
                            },
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
