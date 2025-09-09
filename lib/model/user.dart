class User {
    User({
        required this.id,
        required this.fullName,
        required this.idNum,
        required this.address,
        required this.postalCode,
        required this.city,
        required this.state,
        required this.country,
        required this.hpNumber,
        required this.user,
    });

    final int id;
    final String fullName;
    final String idNum;
    final String address;
    final int postalCode;
    final String city;
    final String state;
    final String country;
    final int hpNumber;
    final int user;

    User copyWith({
        int? id,
        String? fullName,
        String? idNum,
        String? address,
        int? postalCode,
        String? city,
        String? state,
        String? country,
        int? hpNumber,
        int? user,
    }) {
        return User(
            id: id ?? this.id,
            fullName: fullName ?? this.fullName,
            idNum: idNum ?? this.idNum,
            address: address ?? this.address,
            postalCode: postalCode ?? this.postalCode,
            city: city ?? this.city,
            state: state ?? this.state,
            country: country ?? this.country,
            hpNumber: hpNumber ?? this.hpNumber,
            user: user ?? this.user,
        );
    }

    factory User.fromJson(Map<String, dynamic> json){ 
        return User(
            id: json["id"] ?? 0,
            fullName: json["full_name"] ?? "",
            idNum: json["id_num"] ?? "",
            address: json["address"] ?? "",
            postalCode: json["postal_code"] ?? 0,
            city: json["city"] ?? "",
            state: json["state"] ?? "",
            country: json["country"] ?? "",
            hpNumber: json["hp_number"] ?? 0,
            user: json["user"] ?? 0,
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "id_num": idNum,
        "address": address,
        "postal_code": postalCode,
        "city": city,
        "state": state,
        "country": country,
        "hp_number": hpNumber,
        "user": user,
    };

}