// To parse this JSON data, do
//
//     final collateral = collateralFromJson(jsonString);

import 'dart:convert';

List<Collateral> collateralFromJson(String str) => List<Collateral>.from(json.decode(str).map((x) => Collateral.fromJson(x)));

String collateralToJson(List<Collateral> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Collateral {
    Page page;
    String goldWeight;
    GoldStandard goldStandard;
    GoldType goldType;
    bool preciousStones;
    String remarks;
    List<dynamic> images;
    double fullPrice;
    double discount;
    double priceAfterDiscount;

    Collateral({
        required this.page,
        required this.goldWeight,
        required this.goldStandard,
        required this.goldType,
        required this.preciousStones,
        required this.remarks,
        required this.images,
        required this.fullPrice,
        required this.discount,
        required this.priceAfterDiscount,
    });

    factory Collateral.fromJson(Map<String, dynamic> json) => Collateral(
        page: Page.fromJson(json["page"]),
        goldWeight: json["gold_weight"],
        goldStandard: GoldStandard.fromJson(json["gold_standard"]),
        goldType: GoldType.fromJson(json["gold_type"]),
        preciousStones: json["precious_stones"],
        remarks: json["remarks"],
        images: List<dynamic>.from(json["images"].map((x) => x)),
        fullPrice: json["fullPrice"]?.toDouble(),
        discount: json["discount"]?.toDouble(),
        priceAfterDiscount: json["priceAfterDiscount"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "page": page.toJson(),
        "gold_weight": goldWeight,
        "gold_standard": goldStandard.toJson(),
        "gold_type": goldType.toJson(),
        "precious_stones": preciousStones,
        "remarks": remarks,
        "images": List<dynamic>.from(images.map((x) => x)),
        "fullPrice": fullPrice,
        "discount": discount,
        "priceAfterDiscount": priceAfterDiscount,
    };
}

class GoldStandard {
    int id;
    String title;
    String goldPrice;

    GoldStandard({
        required this.id,
        required this.title,
        required this.goldPrice,
    });

    factory GoldStandard.fromJson(Map<String, dynamic> json) => GoldStandard(
        id: json["id"],
        title: json["title"],
        goldPrice: json["gold_price"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "gold_price": goldPrice,
    };
}

class GoldType {
    int id;
    String title;

    GoldType({
        required this.id,
        required this.title,
    });

    factory GoldType.fromJson(Map<String, dynamic> json) => GoldType(
        id: json["id"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
    };
}

class Page {
    int id;
    Branch branch;
    String title;
    String accNum;
    AccountImage accountImage;

    Page({
        required this.id,
        required this.branch,
        required this.title,
        required this.accNum,
        required this.accountImage,
    });

    factory Page.fromJson(Map<String, dynamic> json) => Page(
        id: json["id"],
        branch: Branch.fromJson(json["branch"]),
        title: json["title"],
        accNum: json["acc_num"],
        accountImage: AccountImage.fromJson(json["account_image"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "branch": branch.toJson(),
        "title": title,
        "acc_num": accNum,
        "account_image": accountImage.toJson(),
    };
}

class AccountImage {
    String url;

    AccountImage({
        required this.url,
    });

    factory AccountImage.fromJson(Map<String, dynamic> json) => AccountImage(
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
    };
}

class Branch {
    int id;
    String title;
    String shortName;
    String branchCode;

    Branch({
        required this.id,
        required this.title,
        required this.shortName,
        required this.branchCode,
    });

    factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["id"],
        title: json["title"],
        shortName: json["short_name"],
        branchCode: json["branch_code"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "short_name": shortName,
        "branch_code": branchCode,
    };
}
