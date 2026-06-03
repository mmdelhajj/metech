import 'package:active_ecommerce_cms_demo_app/custom/aiz_image.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_presenter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';

/// Full-bleed home action banner.
///
/// Wireframe brief from Muhammad (2026-05-20): one big swipeable card that
/// fills the row, holds the promo photo, and offers a clear tap target into
/// the linked product list / category / brand. Replaces the cramped
/// 0.43-viewportFraction `HomeBannerOne` carousel that showed 2.3 banners at
/// once and left ~half the row visually empty.
///
/// Data source is unchanged — `homeData.bannerOneImageList` — so backend
/// banners curated in the Active eCommerce admin keep working without any
/// migration.
class HeroActionBanner extends StatelessWidget {
  final HomePresenter? homeData;

  const HeroActionBanner({super.key, this.homeData});

  @override
  Widget build(BuildContext context) {
    if (homeData == null) return const SizedBox.shrink();

    final loading = homeData!.isBannerOneInitial &&
        homeData!.bannerOneImageList.isEmpty;

    if (loading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: ShimmerHelper().buildBasicShimmer(height: 180.h),
      );
    }

    if (homeData!.bannerOneImageList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 180.h,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            autoPlay: homeData!.bannerOneImageList.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            onPageChanged: (_, __) {},
          ),
          items: homeData!.bannerOneImageList.map((banner) {
            return _BannerTile(
              imagePath: banner.photo,
              targetUrl: banner.url,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  final String? imagePath;
  final String? targetUrl;

  const _BannerTile({required this.imagePath, required this.targetUrl});

  void _onTap(BuildContext context) {
    final raw = targetUrl;
    if (raw == null || raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No link available')),
      );
      return;
    }

    try {
      final uri = Uri.parse(raw);
      if (uri.pathSegments.isEmpty) return;
      final slug = uri.pathSegments.last;
      if (uri.path.contains('/category/')) {
        GoRouter.of(context).push('/category/$slug');
      } else if (uri.path.contains('/product/')) {
        GoRouter.of(context).push('/product/$slug');
      } else if (uri.path.contains('/brand/')) {
        GoRouter.of(context).push('/brand/$slug');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown link type')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid link: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onTap(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: MyTheme.light_grey),
          AIZImage.radiusImage(imagePath ?? '', 0),
          // Subtle bottom-gradient overlay so any overlaid text (added by
          // admin via the banner image itself) stays legible — and so the
          // banner reads as a "card" rather than a flat photo.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  MyTheme.blackColour.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
