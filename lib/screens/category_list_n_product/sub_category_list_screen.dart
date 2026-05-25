import 'package:active_ecommerce_cms_demo_app/data_model/category_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/category_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Intermediate screen between a top-level category and its product list.
///
/// Displays the children of [parent] as a simple list. Tapping a child opens
/// the existing [CategoryProducts] screen for that child's slug. If the parent
/// turns out to have no children (e.g. the API returns an empty list), a
/// "Browse all in [parent]" fallback button is shown so the user is never
/// dead-ended.
class SubCategoryListScreen extends StatefulWidget {
  final Category parent;

  const SubCategoryListScreen({super.key, required this.parent});

  @override
  State<SubCategoryListScreen> createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  List<Category> _subCategories = const [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    try {
      // CategoryRepository.getCategories accepts the parent's id (and is used
      // throughout the app with both ids and slugs); we pass the id since it
      // matches the API's parent_id contract exactly.
      final parentId = widget.parent.id ?? widget.parent.slug ?? 0;
      final response = await CategoryRepository().getCategories(
        parentId: parentId,
      );
      if (!mounted) return;
      setState(() {
        _subCategories = response.categories ?? const <Category>[];
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _openCategoryProducts(String slug) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryProducts(slug: slug)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$!
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      elevation: 0.0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_font_grey),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.parent.name ?? '',
        style: TextStyle(
          fontSize: 16,
          color: MyTheme.dark_font_grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return SingleChildScrollView(
        child: ShimmerHelper().buildCategoryCardShimmer(isBaseCategory: true),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: MyTheme.font_grey,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.no_subcategories_available,
                style: TextStyle(color: MyTheme.font_grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildBrowseAllButton(context),
            ],
          ),
        ),
      );
    }

    if (_subCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.no_subcategories_available,
                style: TextStyle(color: MyTheme.font_grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildBrowseAllButton(context),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _subCategories.length + 1,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.5,
        color: MyTheme.font_grey.withValues(alpha: 0.2),
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        if (index == _subCategories.length) {
          // Trailing "browse all" row so users can still reach the parent
          // category's product list even when it has children.
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: _buildBrowseAllButton(context),
          );
        }
        return _buildSubCategoryTile(_subCategories[index]);
      },
    );
  }

  Widget _buildSubCategoryTile(Category subCategory) {
    // Otto-style sub-category row (Muhammad 2026-05-20):
    //   - large square thumbnail on the leading side (uses cover_image when
    //     present, falls back to icon, then a placeholder)
    //   - bold category name centred vertically
    //   - chevron trailing
    //   - generous vertical padding so rows look like Otto's Baumarkt list
    final coverUrl = subCategory.coverImage;
    final iconUrl = subCategory.icon;
    final imageUrl =
        (coverUrl != null && coverUrl.isNotEmpty) ? coverUrl : iconUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return InkWell(
      onTap: () {
        final slug = subCategory.slug ?? subCategory.id?.toString();
        if (slug == null) return;
        _openCategoryProducts(slug);
      },
      child: Container(
        color: MyTheme.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: imageUrl,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (_, __, ___) => Image.asset(
                          'assets/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: MyTheme.light_grey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.category_outlined,
                        size: 24,
                        color: MyTheme.font_grey,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                subCategory.name ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: MyTheme.dark_font_grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: MyTheme.font_grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseAllButton(BuildContext context) {
    final parentName = widget.parent.name ?? '';
    final parentSlug = widget.parent.slug ?? widget.parent.id?.toString();
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyTheme.accent_color,
          foregroundColor: MyTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: parentSlug == null
            ? null
            : () => _openCategoryProducts(parentSlug),
        child: Text(
          '${AppLocalizations.of(context)!.all_products_of_ucf} $parentName',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
