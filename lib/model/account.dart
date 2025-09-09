// To parse this JSON data, do
//
//     final account = accountFromJson(jsonString);

import 'dart:convert';

Account accountFromJson(String str) => Account.fromJson(json.decode(str));

String accountToJson(Account data) => json.encode(data.toJson());

class Account {
  final AccountMeta meta;
  final List<Item> items;

  Account({
    required this.meta,
    required this.items,
  });

  Account copyWith({
    AccountMeta? meta,
    List<Item>? items,
  }) =>
      Account(
        meta: meta ?? this.meta,
        items: items ?? this.items,
      );

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    meta: AccountMeta.fromJson(json["meta"]),
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "meta": meta.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  final int id;
  final ItemMeta meta;
  final String title;
  final Page page;
  final String accNum;
  final AccountImage accountImage;
  final bool rejected;
  final Branch branch;
  final String reason;

  Item({
    required this.id,
    required this.meta,
    required this.title,
    required this.page,
    required this.accNum,
    required this.accountImage,
    required this.rejected,
    required this.branch,
    required this.reason,
  });

  Item copyWith({
    int? id,
    ItemMeta? meta,
    String? title,
    Page? page,
    String? accNum,
    AccountImage? accountImage,
    bool? rejected,
    Branch? branch,
    String? reason,
  }) =>
      Item(
        id: id ?? this.id,
        meta: meta ?? this.meta,
        title: title ?? this.title,
        page: page ?? this.page,
        accNum: accNum ?? this.accNum,
        accountImage: accountImage ?? this.accountImage,
        rejected: rejected ?? this.rejected,
        branch: branch ?? this.branch,
        reason: reason ?? this.reason,
      );

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        meta: ItemMeta.fromJson(json["meta"]),
        title: json["title"],
        page: Page.fromJson(json["page"]),
        accNum: json["acc_num"],
        accountImage: AccountImage.fromJson(json["account_image"]),
        rejected: json["rejected"],
        branch: Branch.fromJson(json["branch"]),
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "meta": meta.toJson(),
        "title": title,
        "page": page.toJson(),
        "acc_num": accNum,
        "account_image": accountImage.toJson(),
        "rejected": rejected,
        "branch": branch.toJson(),
        "reason": reason,
      };
}

class AccountImage {
  final int id;
  final AccountImageMeta meta;
  final String title;

  AccountImage({
    required this.id,
    required this.meta,
    required this.title,
  });

  AccountImage copyWith({
    int? id,
    AccountImageMeta? meta,
    String? title,
  }) =>
      AccountImage(
        id: id ?? this.id,
        meta: meta ?? this.meta,
        title: title ?? this.title,
      );

  factory AccountImage.fromJson(Map<String, dynamic> json) => AccountImage(
        id: json["id"],
        meta: AccountImageMeta.fromJson(json["meta"]),
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "meta": meta.toJson(),
        "title": title,
      };
}

class AccountImageMeta {
  final String type;
  final String detailUrl;
  final String downloadUrl;

  AccountImageMeta({
    required this.type,
    required this.detailUrl,
    required this.downloadUrl,
  });

  AccountImageMeta copyWith({
    String? type,
    String? detailUrl,
    String? downloadUrl,
  }) =>
      AccountImageMeta(
        type: type ?? this.type,
        detailUrl: detailUrl ?? this.detailUrl,
        downloadUrl: downloadUrl ?? this.downloadUrl,
      );

  factory AccountImageMeta.fromJson(Map<String, dynamic> json) =>
      AccountImageMeta(
        type: json["type"],
        detailUrl: json["detail_url"],
        downloadUrl: json["download_url"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "detail_url": detailUrl,
        "download_url": downloadUrl,
      };
}

class Branch {
  final int id;
  final BranchMeta meta;

  Branch({
    required this.id,
    required this.meta,
  });

  Branch copyWith({
    int? id,
    BranchMeta? meta,
  }) =>
      Branch(
        id: id ?? this.id,
        meta: meta ?? this.meta,
      );

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["id"],
        meta: BranchMeta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "meta": meta.toJson(),
      };
}

class BranchMeta {
  final String type;

  BranchMeta({
    required this.type,
  });

  BranchMeta copyWith({
    String? type,
  }) =>
      BranchMeta(
        type: type ?? this.type,
      );

  factory BranchMeta.fromJson(Map<String, dynamic> json) => BranchMeta(
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
      };
}

class ItemMeta {
  final String type;
  final String detailUrl;
  final String htmlUrl;
  final String slug;
  final bool showInMenus;
  final String seoTitle;
  final String searchDescription;
  final DateTime? firstPublishedAt;
  final dynamic aliasOf;
  final String locale;

  ItemMeta({
    required this.type,
    required this.detailUrl,
    required this.htmlUrl,
    required this.slug,
    required this.showInMenus,
    required this.seoTitle,
    required this.searchDescription,
    required this.firstPublishedAt,
    required this.aliasOf,
    required this.locale,
  });

  ItemMeta copyWith({
    String? type,
    String? detailUrl,
    String? htmlUrl,
    String? slug,
    bool? showInMenus,
    String? seoTitle,
    String? searchDescription,
    DateTime? firstPublishedAt,
    dynamic aliasOf,
    String? locale,
  }) =>
      ItemMeta(
        type: type ?? this.type,
        detailUrl: detailUrl ?? this.detailUrl,
        htmlUrl: htmlUrl ?? this.htmlUrl,
        slug: slug ?? this.slug,
        showInMenus: showInMenus ?? this.showInMenus,
        seoTitle: seoTitle ?? this.seoTitle,
        searchDescription: searchDescription ?? this.searchDescription,
        firstPublishedAt: firstPublishedAt ?? this.firstPublishedAt,
        aliasOf: aliasOf ?? this.aliasOf,
        locale: locale ?? this.locale,
      );

  factory ItemMeta.fromJson(Map<String, dynamic> json) => ItemMeta(
    type: json["type"],
    detailUrl: json["detail_url"],
    htmlUrl: json["html_url"],
    slug: json["slug"],
    showInMenus: json["show_in_menus"],
    seoTitle: json["seo_title"],
    searchDescription: json["search_description"],
    firstPublishedAt: json["first_published_at"] == null ? null : DateTime.parse(json["first_published_at"]),
    aliasOf: json["alias_of"],
    locale: json["locale"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "detail_url": detailUrl,
    "html_url": htmlUrl,
    "slug": slug,
    "show_in_menus": showInMenus,
    "seo_title": seoTitle,
    "search_description": searchDescription,
    "first_published_at": firstPublishedAt?.toIso8601String(),
    "alias_of": aliasOf,
    "locale": locale,
  };
}

class Page {
  final int id;
  final PageMeta meta;
  final String title;

  Page({
    required this.id,
    required this.meta,
    required this.title,
  });

  Page copyWith({
    int? id,
    PageMeta? meta,
    String? title,
  }) =>
      Page(
        id: id ?? this.id,
        meta: meta ?? this.meta,
        title: title ?? this.title,
      );

  factory Page.fromJson(Map<String, dynamic> json) => Page(
        id: json["id"],
        meta: PageMeta.fromJson(json["meta"]),
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "meta": meta.toJson(),
        "title": title,
      };
}

class PageMeta {
  final String type;
  final String detailUrl;

  PageMeta({
    required this.type,
    required this.detailUrl,
  });

  PageMeta copyWith({
    String? type,
    String? detailUrl,
  }) =>
      PageMeta(
        type: type ?? this.type,
        detailUrl: detailUrl ?? this.detailUrl,
      );

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
        type: json["type"],
        detailUrl: json["detail_url"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "detail_url": detailUrl,
      };
}

class AccountMeta {
  final int totalCount;

  AccountMeta({
    required this.totalCount,
  });

  AccountMeta copyWith({
    int? totalCount,
  }) =>
      AccountMeta(
        totalCount: totalCount ?? this.totalCount,
      );

  factory AccountMeta.fromJson(Map<String, dynamic> json) => AccountMeta(
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
      };
}
