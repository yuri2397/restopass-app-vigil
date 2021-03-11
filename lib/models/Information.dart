import 'dart:convert';

Information informationFromJson(String str) =>
    Information.fromJson(json.decode(str));

String informationToJson(Information data) => json.encode(data.toJson());

class Information {
  Information({
    this.error,
    this.message,
    this.mode,
    this.price1,
    this.price2,
    this.price3,
  });

  bool error;
  String message;
  int mode;
  int price1;
  int price2;
  int price3;

  factory Information.fromJson(Map<String, dynamic> json) => Information(
        error: json["error"],
        message: json["message"],
        mode: json["mode"],
        price1: json["price_1"],
        price2: json["price_2"],
        price3: json["price_3"],
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "mode": mode,
      };
}
