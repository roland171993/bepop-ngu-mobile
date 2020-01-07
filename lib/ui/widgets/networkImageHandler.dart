import 'package:cached_network_image/cached_network_image.dart';
import 'package:bepop_ngu/utils/stringExtensions.dart';

import 'package:bepop_ngu/utils/svgNetworkImage.dart';
import 'package:flutter/material.dart';

/// A widget that properly handles different types of network images (including SVGs)
/// This prevents errors when trying to load SVG images with CachedNetworkImageProvider
class NetworkImageHandler extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const NetworkImageHandler({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the URL is empty
    if (imageUrl.isEmpty) {
      return errorWidget ?? const SizedBox();
    }

    // Handle SVG images differently than regular images
    final isSvg = imageUrl.isSvgUrl();

    final imageWidget = isSvg
        ? SvgNetworkImage(
            url: imageUrl,
            fit: fit,
            width: width,
            height: height,
            placeholder: placeholder,
            errorWidget: errorWidget,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            width: width,
            height: height,
            placeholder: (context, url) =>
                placeholder ?? const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                errorWidget ?? const Icon(Icons.error),
          );

    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
