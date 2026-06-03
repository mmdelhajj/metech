import 'package:active_ecommerce_cms_demo_app/data_model/category_response.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/sub_category_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';
import '../presenter/home_presenter.dart';

/// Horizontal hero slider for the home page's category section.
///
/// Wireframe brief from Muhammad (2026-05-20): swipeable category cards that
/// fill most of the row width — big photo, bold name overlay — instead of
/// the cramped 4-up grid `_buildFeaturedCategoriesSection` used. Tap honours
/// the two-level navigation (sub-category list if children exist, otherwise
/// the products listing).
///
/// Reuses `homeData.featuredCategoryList` so backend curation is unchanged.
class HeroCategorySlider extends StatelessWidget {
  final HomePresenter homeData;

  const HeroCategorySlider({super.key, required this.homeData});

  @override
  Widget build(BuildContext context) {
    final loading = homeData.isCategoryInitial &&
        homeData.featuredCategoryList.isEmpty;

    if (loading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: ShimmerHelper().buildBasicShimmer(height: 150.h),
      );
    }

    final list = homeData.featuredCategoryList;
    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            child: Text(
              'Shop by category',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: MyTheme.dark_font_grey,
              ),
            ),
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: 150.h,
              // 0.78 = the next card peeks on the right edge, signalling
              // that the row is swipeable. Bigger than the 4-up grid's
              // ~0.25 share but smaller than full-bleed so it reads as a
              // *list* of categories rather than one banner per page.
              viewportFraction: 0.78,
              enableInfiniteScroll: list.length > 1,
              padEnds: false,
              autoPlay: false,
              onPageChanged: (_, __) {},
            ),
            items: list.map((category) {
              return _CategoryCard(category: category);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  void _onTap(BuildContext context) {
    // Two-level navigation: parent with children → sub-list, otherwise
    // jump straight to the products grid.
    final hasChildren = (category.numberOfChildren ?? 0) > 0;
    if (hasChildren) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubCategoryListScreen(parent: category),
        ),
      );
      return;
    }
    final slug = category.slug ?? category.id?.toString();
    if (slug == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProducts(slug: slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.coverImage?.isNotEmpty == true
        ? category.coverImage!
        : (category.banner?.isNotEmpty == true
            ? category.banner!
            : category.icon ?? '');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(12.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: MyTheme.light_grey),
              if (imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, __) => Container(color: MyTheme.light_grey),
                  errorWidget: (_, __, ___) => Container(
                    color: MyTheme.light_grey,
                    child: Icon(
                      Icons.category_outlined,
                      size: 40.r,
                      color: MyTheme.font_grey,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.category_outlined,
                  size: 40.r,
                  color: MyTheme.font_grey,
                ),
              // Bottom gradient → label legibility on any photo.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      MyTheme.blackColour.withValues(alpha: 0.55),
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 10.h,
                child: Text(
                  category.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
