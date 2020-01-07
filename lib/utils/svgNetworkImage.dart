import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A widget that displays an SVG image from a network URL
/// This helps handle SVG images correctly instead of using CachedNetworkImageProvider
class SvgNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;

  const SvgNetworkImage({
    Key? key,
    required this.url,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      url,
      fit: fit,
      width: width,
      height: height,
      placeholderBuilder: placeholder != null ? (_) => placeholder! : null,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
