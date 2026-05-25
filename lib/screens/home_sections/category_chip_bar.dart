import 'package:active_ecommerce_cms_demo_app/data_model/category_response.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/category_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/sub_category_list_screen.dart';
import 'package:flutter/material.dart';

/// eBay-style horizontal chip filter bar.
///
/// Displays top-level categories as light-grey rounded pills under the home
/// search bar. Tapping a chip opens that category's product list via the
/// existing [CategoryProducts] screen.
class CategoryChipBar extends StatefulWidget {
  const CategoryChipBar({super.key});

  @override
  State<CategoryChipBar> createState() => _CategoryChipBarState();
}

class _CategoryChipBarState extends State<CategoryChipBar> {
  static const int _maxChips = 8;

  // Visual constants (raw pixels — intentionally not using ScreenUtil so the
  // chip dimensions match the spec exactly).
  static const Color _chipBg = Color(0xFFF3F4F6);
  static const Color _chipBorder = Color(0xFFE5E7EB);
  static const Color _chipText = Color(0xFF111827);
  static const double _chipRadius = 99.0;
  static const double _iconSize = 16.0;
  static const double _barHeight = 40.0;

  List<Category> _categories = const [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await CategoryRepository().getTopCategories();
      if (!mounted) return;
      final list = response.categories ?? const <Category>[];
      setState(() {
        _categories = list.take(_maxChips).toList();
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

  void _onChipTap(Category category) {
    // Two-level navigation: if this top-level category has children, show a
    // sub-category picker first; otherwise jump straight to the product list.
    final hasChildren = (category.numberOfChildren ?? 0) > 0;
    if (hasChildren) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoryListScreen(parent: category),
        ),
      );
      return;
    }

    final slug = category.slug ?? category.id?.toString();
    if (slug == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProducts(slug: slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return SizedBox(
        height: _barHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => _buildSkeletonChip(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _barHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => _buildChip(_categories[index]),
      ),
    );
  }

  Widget _buildChip(Category category) {
    final iconUrl = category.icon;
    final hasIcon = iconUrl != null && iconUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_chipRadius),
        onTap: () => _onChipTap(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _chipBg,
            borderRadius: BorderRadius.circular(_chipRadius),
            border: Border.all(color: _chipBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasIcon) ...[
                SizedBox(
                  width: _iconSize,
                  height: _iconSize,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: iconUrl,
                    fit: BoxFit.contain,
                    imageErrorBuilder: (_, __, ___) =>
                        const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                category.name ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _chipText,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonChip() {
    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(_chipRadius),
        border: Border.all(color: _chipBorder, width: 1),
      ),
    );
  }
}
