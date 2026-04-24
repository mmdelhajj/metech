// To parse this JSON data, do
//
//     final orderCreateResponse = orderCreateResponseFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

OrderCreateResponse orderCreateResponseFromJson(String str) =>
    OrderCreateResponse.fromJson(json.decode(str));

String orderCreateResponseToJson(OrderCreateResponse data) =>
    json.encode(data.toJson());

class OrderCreateResponse {
  OrderCreateResponse({
    this.combined_order_id,
    this.result,
    this.message,
    this.action,
  });

  int? combined_order_id;
  bool? result;
  String? message;
  String? action;

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) =>
      OrderCreateResponse(
        combined_order_id: json["combined_order_id"],
        result: json["result"],
        message: json["message"],
        action: json["action"],
      );

  Map<String, dynamic> toJson() => {
    "combined_order_id": combined_order_id,
    "result": result,
    "message": message,
    "action": action,
  };
}
