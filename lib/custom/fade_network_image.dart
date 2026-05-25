import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyImage{
  static Widget imageNetworkPlaceholder(
      {String? url,
        double height = 0.0,
        double elevation = 0.0,
        width = 0.0,
        BorderRadiusGeometry radius = BorderRadius.zero,
        BoxFit fit = BoxFit.cover,
        Color backgroundColor  = const Color.fromRGBO(255, 255, 255, 1),
        int? memCacheWidth,
      }) {
    // Pick a sensible decode width if the caller didn't provide one.
    // Use 2x retina based on the displayed width; fall back to 600 (medium thumb).
    final int decodeWidth = memCacheWidth ??
        (width is double && width > 0
            ? (width * 2).toInt()
            : (height > 0 ? (height * 2).toInt() : 600));

    return Material(
      color: backgroundColor,
      elevation: elevation,
      borderRadius: radius,

      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            borderRadius: radius
        ),
        child: url != null && url.isNotEmpty
            ? ClipRRect(
          borderRadius: radius,
          child: CachedNetworkImage(
            imageUrl: url,
            height: height > 0 ? height : null,
            width: width is double && width > 0 ? width : null,
            fit: fit,
            memCacheWidth: decodeWidth,
            fadeInDuration: const Duration(milliseconds: 120),
            placeholder: (context, _) => Container(
              height: height > 0 ? height : null,
              width: width is double && width > 0 ? width : null,
              color: const Color(0xFFEFEFEF),
            ),
            errorWidget: (context, _, __) => Container(
              height: height > 0 ? height : null,
              width: width is double && width > 0 ? width : null,
              decoration: BoxDecoration(
                  borderRadius: radius,
                  image: const DecorationImage(
                      image: AssetImage("assets/placeholder.png"),
                      fit: BoxFit.cover
                  )
              ),
            ),
          ),
        )
            : Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: radius,
              image: const DecorationImage(
                image: AssetImage("assets/placeholder.png"),
              ),
          ),
        ),
      ),
    );
  }



}
