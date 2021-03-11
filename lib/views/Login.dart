import 'dart:convert';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:toast/toast.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vigil/constants.dart';
import 'package:vigil/models/AccessToken.dart';
import 'package:vigil/utils/SharedPref.dart';
import 'package:vigil/views/Scanner.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _code, _password;
  SharedPref _sharedPref;
  bool _isLoad = false;
  bool _hasError = false;
  String _errorMessage = "Message d'erreur";
  IconData _errorIcon = Icons.error_outline_rounded;

  final Widget _default = Image.asset(
    "assets/images/app_icon.png",
    width: 100,
    scale: 3,
    height: 100,
  );

  Widget _widget = Image.asset(
    "assets/images/app_icon.png",
    width: 100,
    scale: 3,
    height: 100,
  );
  @override
  void initState() {
    super.initState();
    _sharedPref = SharedPref();
  }

  Color _qr_color = Colors.black45;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "RestoPass",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Poppins Light",
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Stack(children: [
        Positioned(
          top: 0,
          height: 130,
          width: size.width,
          child: Material(
            color: kPrimaryColor,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50)),
          ),
        ),
        Positioned(
          top: 80,
          left: 10,
          right: 10,
          child: Material(
            elevation: 0,
            color: Colors.white,
            child: _widget,
            shape: CircleBorder(),
          ),
        ),
        Positioned(
          top: 170,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.only(top: 25),
                child: Text(
                  'Connectez vous',
                  style: TextStyle(fontFamily: 'Poppins Meduim', fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Material(
                elevation: 2,
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
                child: Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    padding: EdgeInsets.all(25),
                    alignment: Alignment.center,
                    child: PrettyQr(
                      data: "resto pass",
                      typeNumber: 3,
                      roundEdges: true,
                      size: 200,
                    )),
              ),
              Container(
                padding: EdgeInsets.all(30),
                child: MaterialButton(
                  elevation: 5,
                  onPressed: () async {
                    try {
                      String qrcode = await BarcodeScanner.scan();
                      if (qrcode.length == 25) {
                        _code = qrcode.substring(0, 8);
                        _password = qrcode.substring(9, qrcode.length);
                        setState(() {
                          _isLoad = true;
                          _widget = progressBar();
                        });
                        AccessToken accessToken =
                            await loginRequest(_code, _password);
                        if (accessToken.tokenType == "Bearer") {
                          // tout est Okay :)
                          _sharedPref
                              .addUserAccessToken(accessToken.accessToken);
                          _sharedPref
                              .addUserRefreshToken(accessToken.refreshToken);
                          _sharedPref.addUserExpireIn(accessToken.expiresIn);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Scanner()));
                        } else if (accessToken.tokenType == "422" ||
                            accessToken.tokenType == "400") {
                          Toast.show("QR code invalide.", context,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              gravity: Toast.BOTTOM);
                        } else if (accessToken.tokenType == "error") {
                          // toast vérifier votre connexion
                          Toast.show("vérifier votre connexion", context,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              gravity: Toast.BOTTOM);
                        }
                      } else {
                        Toast.show("QR code invalide", context,
                            duration: Toast.LENGTH_LONG,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            gravity: Toast.BOTTOM);
                      }
                    } catch (e) {
                      print("$e");
                    }
                    setState(() {
                      _qr_color = Colors.red;
                      _isLoad = false;
                      _widget = _default;
                    });
                  },
                  color: Colors.white,
                  textColor: kPrimaryColor,
                  child: Icon(
                    Icons.login,
                    size: 24,
                  ),
                  padding: EdgeInsets.all(16),
                  shape: CircleBorder(),
                ),
              ),
            ],
          ))),
        ),
      ]),
    );
  }

  Widget progressBar() {
    return Container(
      alignment: Alignment.center,
      child: SleekCircularSlider(
        initialValue: 30,
        max: 100,
        appearance: CircularSliderAppearance(
            angleRange: 360,
            spinnerMode: true,
            startAngle: 90,
            size: 50,
            customColors: CustomSliderColors(
              hideShadow: true,
              trackColor: kPrimaryColor,
              progressBarColor: Colors.white,
            )),
      ),
    );
  }

  Future<AccessToken> loginRequest(String code, String password) async {
    String url = BASE_URL + '/api/vigilant/login';

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final body = jsonEncode({
      "code": code,
      "password": password,
    });

    try {
      final response =
          await http.post(url, body: body, headers: requestHeaders);
      if (response.statusCode == 200) {
        final String responseString = response.body;
        return accessTokenFromJson(responseString);
      } else {
        return AccessToken(
            tokenType: response.statusCode.toString(),
            expiresIn: -1,
            accessToken: response.statusCode.toString(),
            refreshToken: response.statusCode.toString());
      }
    } catch (e) {
      return AccessToken(
          tokenType: "error",
          expiresIn: -2,
          accessToken: "500",
          refreshToken: "500");
    }
  }
}
