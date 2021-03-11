import 'dart:convert';

AccessToken accessTokenFromJson(String str) => AccessToken.fromJson(json.decode(str));

String accessTokenToJson(AccessToken data) => json.encode(data.toJson());

class AccessToken {
    AccessToken({
        this.tokenType,
        this.expiresIn,
        this.accessToken,
        this.refreshToken,
    });

    String tokenType;
    int expiresIn;
    String accessToken;
    String refreshToken;



    factory AccessToken.fromJson(Map<String, dynamic> json) => AccessToken(
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
        accessToken: json["access_token"],
        refreshToken: json["refresh_token"],
    );

    Map<String, dynamic> toJson() => {
        "token_type": tokenType,
        "expires_in": expiresIn,
        "access_token": accessToken,
        "refresh_token": refreshToken,
    };

    @override
  String toString() {
    return "tokenTŷpe : " + tokenType
    + "\n" + "expiredIn : " + expiresIn.toString() + "\n"
    + "accessToken : " + accessToken + "\n"
    + "refreshToken : " + refreshToken;
  }

}

