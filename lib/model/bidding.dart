// To parse this JSON data, do
//
//     final bidding = biddingFromJson(jsonString);

import 'dart:convert';

List<Bidding> biddingFromJson(String str) =>
    List<Bidding>.from(json.decode(str).map((x) => Bidding.fromJson(x)));

String biddingToJson(List<Bidding> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Bidding {
  final int id;
  final String reservedPrice;
  final String bidOffer;
  final DateTime createdAt;
  final int user;
  final int product;

  Bidding({
    required this.id,
    required this.reservedPrice,
    required this.bidOffer,
    required this.createdAt,
    required this.user,
    required this.product,
  });

  Bidding copyWith({
    int? id,
    String? reservedPrice,
    String? bidOffer,
    DateTime? createdAt,
    int? user,
    int? product,
  }) =>
      Bidding(
        id: id ?? this.id,
        reservedPrice: reservedPrice ?? this.reservedPrice,
        bidOffer: bidOffer ?? this.bidOffer,
        createdAt: createdAt ?? this.createdAt,
        user: user ?? this.user,
        product: product ?? this.product,
      );

  factory Bidding.fromJson(Map<String, dynamic> json) {
    return Bidding(
      id: json["id"],
      reservedPrice: json["reserved_price"],
      bidOffer: json["bid_offer"],
      createdAt: DateTime.parse(json["created_at"]),
      user: json["user"],
      product: json["product"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "reserved_price": reservedPrice,
    "bid_offer": bidOffer,
    "created_at": createdAt.toIso8601String(),
    "user": user,
    "product": product,
  };
}
