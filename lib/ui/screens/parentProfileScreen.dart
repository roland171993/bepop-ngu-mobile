import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/guardianDetailsContainer.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({Key? key}) : super(key: key);

  static Widget routeInstance() {
    return const ParentProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: Utils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.05),
                  ),
                  GuardianDetailsContainer(
                    guardian: context.read<AuthCubit>().getParentDetails(),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: CustomAppBar(
              title: Utils.getTranslatedLabel(profileKey),
            ),
          ),
        ],
      ),
    );
  }
}
