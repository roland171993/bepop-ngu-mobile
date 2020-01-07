import 'package:bepop_ngu/cubits/appSettingsCubit.dart';
import 'package:bepop_ngu/data/repositories/systemInfoRepository.dart';
import 'package:bepop_ngu/ui/widgets/appSettingsBlocBuilder.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();

  static Widget routeInstance() {
    return BlocProvider<AppSettingsCubit>(
      create: (context) => AppSettingsCubit(SystemRepository()),
      child: const TermsAndConditionScreen(),
    );
  }
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  final String termsAndConditionType = "student_terms_condition";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context
          .read<AppSettingsCubit>()
          .fetchAppSettings(type: termsAndConditionType);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppSettingsBlocBuilder(
            appSettingsType: termsAndConditionType,
          ),
          CustomAppBar(
            title: Utils.getTranslatedLabel(termsAndConditionKey),
          )
        ],
      ),
    );
  }
}
