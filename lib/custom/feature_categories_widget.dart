import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_presenter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/sub_category_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../my_theme.dart';

class FeaturedCategoriesWidget extends StatelessWidget {
  final HomePresenter homeData;
  const FeaturedCategoriesWidget({super.key, required this.homeData});

  @override
  Widget build(BuildContext context) {
    if (homeData.isCategoryInitial && homeData.featuredCategoryList.isEmpty) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
        crossAxisSpacing: 12.h,
        mainAxisSpacing: 12.w,
        itemCount: 10,
        mainAxisExtent: 160.w,
        controller: homeData.featuredCategoryScrollController,
      );
    } else if (homeData.featuredCategoryList.isNotEmpty) {
      return GridView.builder(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 11.h,
          bottom: 24.h,
        ),
        scrollDirection: Axis.horizontal,
        controller: homeData.featuredCategoryScrollController,
        itemCount: homeData.featuredCategoryList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12.h,
          mainAxisSpacing: 12.w,

          mainAxisExtent: 160.w,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              final category = homeData.featuredCategoryList[index];
              // Two-level navigation: if this category has children, show the
              // sub-category list; otherwise fall through to its products.
              final hasChildren = (category.numberOfChildren ?? 0) > 0;
              if (hasChildren) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SubCategoryListScreen(parent: category),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CategoryProducts(
                      slug: category.slug ?? category.id.toString(),
                    );
                  },
                ),
              );
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  // Image Section
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xff000000,
                            ).withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: (homeData.featuredCategoryList[index]
                                        .coverImage ==
                                    null ||
                                homeData.featuredCategoryList[index]
                                    .coverImage!.isEmpty)
                            ? Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: homeData
                                    .featuredCategoryList[index].coverImage!,
                                fit: BoxFit.cover,
                                memCacheWidth: 320,
                                fadeInDuration:
                                    const Duration(milliseconds: 120),
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFEFEFEF),
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Text Section
                  Expanded(
                    child: Text(
                      homeData.featuredCategoryList[index].name??'',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: MyTheme.font_grey,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (!homeData.isCategoryInitial &&
        homeData.featuredCategoryList.isEmpty) {
      // Hide section when admin hasn't marked any categories as featured.
      return const SizedBox.shrink();
    } else {
      return SizedBox(height: 100.h);
    }
  }
}
