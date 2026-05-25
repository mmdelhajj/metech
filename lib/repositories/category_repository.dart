import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/category_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class CategoryRepository {
  Future<CategoryResponse> getCategories({parentId = 0}) async {
    // The `/categories?parent_id=…` shape used to work but 500s on the
    // current backend (Active eCommerce upstream changed the query handler).
    // The canonical endpoint exposed by the V2 API for child categories is
    // `/sub-categories/{parent_id}` — both the top-level categories listing
    // and the `links.sub_categories` URL on each category point at it.
    //
    // `parentId` arrives as int, String, or null from various call sites
    // (CategoryList passes `""` from the bottom-nav Categories tab to mean
    // "top level"). Treat any empty / zero / null value as "no parent" and
    // hit the top-level `/categories` listing.
    final pidStr = parentId?.toString().trim() ?? '';
    final isTopLevel = pidStr.isEmpty || pidStr == '0';
    final url = isTopLevel
        ? "${AppConfig.BASE_URL}/categories"
        : "${AppConfig.BASE_URL}/sub-categories/$pidStr";
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFeturedCategories() async {
    String url = ("${AppConfig.BASE_URL}/categories/featured");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );

    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getCategoryInfo(slug) async {
    String url = ("${AppConfig.BASE_URL}/category/info/$slug");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getTopCategories() async {
    String url = ("${AppConfig.BASE_URL}/categories/top");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFilterPageCategories() async {
    String url = ("${AppConfig.BASE_URL}/filter/categories");
    final response = await ApiRequest.get(
      url: url,
      headers: {"App-Language": app_language.$!},
    );
    return categoryResponseFromJson(response.body);
  }
}
