import 'package:cached_network_image/cached_network_image.dart';
import 'package:bepop_ngu/utils/stringExtensions.dart';
import 'package:bepop_ngu/utils/utils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

//This widget will return curicular or rectengular profile image or default image on error with cached network image for general usage
class CustomUserProfileImageWidget extends StatelessWidget {
  final String profileUrl;
  final Color? color;
  final BorderRadius? radius;
  const CustomUserProfileImageWidget(
      {super.key, required this.profileUrl, this.color, this.radius});

  _imageOrDefaultProfileImage() {
    // Check if the profile URL is an SVG
    if (profileUrl.isSvgUrl()) {
      return SvgPicture.network(
        profileUrl,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        fit: BoxFit.cover,
        placeholderBuilder: (context) => SvgPicture.asset(
          Utils.getImagePath("default_profile.svg"),
          colorFilter:
              color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
          fit: BoxFit.contain,
        ),
      );
    }

    // For non-SVG images, use CachedNetworkImage
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: profileUrl,
      errorWidget: (context, url, error) {
        return SvgPicture.asset(
          Utils.getImagePath("default_profile.svg"),
          colorFilter:
              color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
          fit: BoxFit.contain,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return radius != null
        ? ClipRRect(
            borderRadius: radius!,
            child: _imageOrDefaultProfileImage(),
          )
        : ClipOval(
            child: _imageOrDefaultProfileImage(),
          );
  }
}
