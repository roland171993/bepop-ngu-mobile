import 'package:bepop_ngu/data/models/subject.dart';
import 'package:bepop_ngu/ui/widgets/networkImageHandler.dart';
import 'package:bepop_ngu/ui/widgets/subjectFirstLetterContainer.dart';
import 'package:bepop_ngu/utils/animationConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SubjectImageContainer extends StatelessWidget {
  final Subject subject;
  final double height;
  final double width;
  final double radius;
  final BoxBorder? border;
  final bool showShadow;
  final bool animate;
  const SubjectImageContainer({
    Key? key,
    this.border,
    required this.showShadow,
    required this.height,
    required this.radius,
    required this.subject,
    required this.width,
    this.animate = true,
  }) : super(key: key);

  Color _parseHexColor(String hexColor) {
    String cleanHex = hexColor.replaceFirst('#', '');

    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }

    return Color(int.parse(cleanHex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: animate ? customItemFadeAppearanceEffects() : null,
      child: Container(
        decoration: BoxDecoration(
          border: border,
          color: subject.bgColor != null
              ? _parseHexColor(subject.bgColor!)
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(radius),
        ),
        height: height,
        width: width,
        child: (subject.image ?? "").isEmpty
            ? SubjectCodeContainer(
                subjectCode: subject.code ?? "",
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: NetworkImageHandler(
                  imageUrl: subject.image ?? "",
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
