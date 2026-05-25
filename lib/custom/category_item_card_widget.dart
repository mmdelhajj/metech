import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data_model/category_response.dart';
import '../my_theme.dart';
import '../screens/category_list_n_product/category_products.dart';
import '../screens/category_list_n_product/sub_category_list_screen.dart';

import 'device_info.dart';

class CategoryItemCardWidget extends StatelessWidget {
  final CategoryResponse categoryResponse;
  final int index;

  const CategoryItemCardWidget({
    super.key,
    required this.categoryResponse,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var itemWidth = ((DeviceInfo(context).width! - 48) / 3);
    final category = categoryResponse.categories![index];
    final hasChildren = (category.numberOfChildren ?? 0) > 0;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => hasChildren
                ? SubCategoryListScreen(parent: category)
                : CategoryProducts(slug: category.slug ?? ""),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyTheme.white,
            ),
            width: itemWidth,
            height: itemWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: (category.coverImage == null ||
                      category.coverImage!.isEmpty)
                  ? Image.asset(
                      'assets/placeholder.png',
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: category.coverImage!,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      fadeInDuration: const Duration(milliseconds: 120),
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFEFEFEF),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: itemWidth,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              category.name ?? '',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                color: MyTheme.font_grey,
                fontSize: 10,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  final CategoryResponse categoryResponse;

  const CategoryGrid({super.key, required this.categoryResponse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        itemCount: categoryResponse.categories!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return CategoryItemCardWidget(
            categoryResponse: categoryResponse,
            index: index,
          );
        },
      ),
    );
  }
}
