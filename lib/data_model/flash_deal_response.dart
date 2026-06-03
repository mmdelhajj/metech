// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

FlashDealResponse flashDealResponseFromJson(String str) =>
    FlashDealResponse.fromJson(json.decode(str));

String flashDealResponseToJson(FlashDealResponse data) =>
    json.encode(data.toJson());

class FlashDealResponse {
  FlashDealResponse({this.flashDeals, this.success, this.status});

  List<FlashDealResponseDatum>? flashDeals;
  bool? success;
  int? status;

  factory FlashDealResponse.fromJson(Map<String, dynamic> json) =>
      FlashDealResponse(
        flashDeals: json["data"] != null
            ? List<FlashDealResponseDatum>.from(
                json["data"].map((x) => FlashDealResponseDatum.fromJson(x)),
              )
            : [],
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": flashDeals != null
        ? List<dynamic>.from(flashDeals!.map((x) => x.toJson()))
        : [],
    "success": success,
    "status": status,
  };
}

class FlashDealResponseDatum {
  FlashDealResponseDatum({
    this.id,
    this.slug,
    this.title,
    this.isFeatured,
    this.date,
    this.banner,
    this.backgroundColor,
    this.textColor,
    this.products,
  });

  int? id;
  String? slug;
  int? isFeatured;

  String? title;
  int? date;
  String? banner;
  // Admin-managed colors (Active eCommerce flash_deals.background_color /
  // text_color). Null when the admin left them blank — the UI falls back to
  // the logo blue. Added 2026-06-02 (Muhammad's flash-deal redesign).
  String? backgroundColor;
  String? textColor;
  Products? products;

  factory FlashDealResponseDatum.fromJson(Map<String, dynamic> json) =>
      FlashDealResponseDatum(
        id: json["id"],
        slug: json["slug"],
        isFeatured: json["featured"] == null
            ? 0
            : int.tryParse(json["featured"].toString()),

        title: json["title"],
        date: json["date"],
        banner: json["banner"],
        backgroundColor: json["background_color"],
        textColor: json["text_color"],
        products: json["products"] != null
            ? Products.fromJson(json["products"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "featured": isFeatured,
    "title": title,
    "date": date,
    "banner": banner,
    "background_color": backgroundColor,
    "text_color": textColor,
    "products": products?.toJson(),
  };
}

class Products {
  Products({this.products});

  List<Product>? products;

  factory Products.fromJson(Map<String, dynamic> json) => Products(
    products: json["data"] != null
        ? List<Product>.from(json["data"].map((x) => Product.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "data": products != null
        ? List<dynamic>.from(products!.map((x) => x.toJson()))
        : [],
  };
}

class Product {
  Product({
    this.id,
    this.name,
    this.price,
    this.image,
    this.discount,
    this.discountType,
    this.links,
  });

  var id;
  String? name;
  String? price;
  String? image;
  // Per-product flash-deal discount from the pivot (backend exposes these as
  // of 2026-06-03). Drives the blue % badge on the home flash-deal card.
  num? discount;
  String? discountType; // "percent" | "amount"
  Links? links;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    price: json["price"],
    image: json["image"],
    discount: json["discount"] is num
        ? json["discount"]
        : num.tryParse(json["discount"]?.toString() ?? ''),
    discountType: json["discount_type"]?.toString(),
    links: json["links"] != null ? Links.fromJson(json["links"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "image": image,
    "discount": discount,
    "discount_type": discountType,
    "links": links?.toJson(),
  };
}

class Links {
  Links({this.details});

  String? details;

  factory Links.fromJson(Map<String, dynamic> json) =>
      Links(details: json["details"]);

  Map<String, dynamic> toJson() => {"details": details};
}
