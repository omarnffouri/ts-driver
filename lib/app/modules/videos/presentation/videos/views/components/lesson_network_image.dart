import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/gen/assets.gen.dart';
import '../../../../../../theme/theme_extensions.dart';

/// Lesson artwork loader — shimmer while loading, the default training image on
/// error. Shared by the hero card and the lesson thumbnails.
class LessonNetworkImage extends StatelessWidget {
  const LessonNetworkImage(
      {super.key,
      required this.url,
      this.fit = BoxFit.cover,
      this.cacheWidth,
      this.cacheHeight});

  final String? url;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url ?? '',
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: context.shimmerBaseColor,
        highlightColor: context.shimmerHighlightColor,
        child: ColoredBox(color: context.shimmerBaseColor),
      ),
      errorWidget: (_, __, ___) => Image.asset(
        Assets.images.defaultTraining.path,
        fit: fit,
      ),
    );
  }
}
