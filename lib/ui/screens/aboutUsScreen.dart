import 'package:bepop_ngu/cubits/appSettingsCubit.dart';
import 'package:bepop_ngu/data/repositories/systemInfoRepository.dart';
import 'package:bepop_ngu/ui/widgets/appSettingsBlocBuilder.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();

  static Widget routeInstance() {
    return BlocProvider<AppSettingsCubit>(
      create: (context) => AppSettingsCubit(SystemRepository()),
      child: const AboutUsScreen(),
    );
  }
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final String aboutUsType = "about_us";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().fetchAppSettings(type: aboutUsType);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppSettingsBlocBuilder(appSettingsType: aboutUsType),
          CustomAppBar(title: Utils.getTranslatedLabel(aboutUsKey))
        ],
      ),
    );
  }
}
