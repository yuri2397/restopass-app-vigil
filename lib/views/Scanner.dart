import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:vigil/constants.dart';
import 'package:http/http.dart' as http;
import 'package:vigil/models/ApiResponse.dart';
import 'package:vigil/models/Information.dart';
import 'package:vigil/utils/SharedPref.dart';
import 'package:vigil/views/Normal.dart';
import 'package:vigil/views/Ramadan.dart';

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _isLoad = false, _setState = false;
  IconData _icon = Icons.check_box_rounded;
  Color _color = Colors.green;
  String _message = "Message d'erreur";
  final _default = Image.asset('assets/images/qrcode.png');
  Widget _other = Image.asset('assets/images/qrcode.png');
  Future<Information> _myFuture;

  bool _state = false;

  @override
  void initState() {
    super.initState();
    _myFuture = getInformation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _myFuture,
        builder: (BuildContext context, snapshot) {
          print("$snapshot");
          if (snapshot.hasData) {
            return _setMode(snapshot.data, context);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else {
            return Container(
              color: Colors.white,
              padding: EdgeInsets.all(5),
              alignment: Alignment.center,
              width: 50,
              height: 50,
              child: Center(
                child: progressBar(),
              ),
            );
          }
        });
  }

  // Mode normal
  _statWidget(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: size.height * .04),
      alignment: Alignment.topLeft,
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(bottom: 20),
              child: Text(
                "Scanneur de QR Code",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Poppin Light",
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Material(
              elevation: 8,
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              child: Container(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  alignment: Alignment.center,
                  width: size.width * .7,
                  height: size.width * .8,
                  child: _other),
            ),
          ],
        ),
        Positioned(
            bottom: 100,
            right: 0,
            height: 80,
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  topLeft: Radius.circular(50)),
              child: Container(
                alignment: Alignment.center,
                color: kPrimaryColor,
                child: MaterialButton(
                  elevation: 5,
                  onPressed: () async {
                    try {
                      String number = await BarcodeScanner.scan();
                      print("USER NUMBER : " + number);
                      if (number.length != 11) {
                        // montant insuffisant
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _other = _onInfo(
                              context, Colors.redAccent, "QR code invalide");
                        });
                        return;
                      }
                      setState(() {
                        _isLoad = true;
                        _setState = false;
                        _other = progressBar();
                      });

                      ApiResponse res = await scan(number);
                      print("RES : " + res.message);

                      if (res.error == false) {
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _other = _onSuccess(context, "Okay", Colors.green);
                        });
                      } else if (res.error == true) {
                        if (res.message == "409") {
                          // pas encore l'heure
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other = _onWarning(
                                context,
                                "Impossible de faire un scan endehors des heures d'ouvérture.",
                                Colors.orangeAccent);
                          });
                        } else if (res.message == "406") {
                          // deja passe
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other =
                                _onError(context, "L'étudiant est déjà passé.");
                          });
                        } else if (res.message == "400") {
                          // montant insuffisant
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other = _onInfo(context, Colors.orangeAccent,
                                "Montant insuffisant");
                          });
                        } else if (res.message == "422") {
                          // montant insuffisant
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other = _onInfo(
                                context, Colors.redAccent, "QR code invalide");
                          });
                        } else if (res.message == "500") {
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _message = "Vérifier votre connexion internet.";
                            _icon = Icons.wifi_off_rounded;
                            _color = kPrimaryColor;
                          });
                        }
                      }
                    } catch (e) {
                      print("SCAN CATCH $e");
                    }
                  },
                  color: Colors.white,
                  textColor: kPrimaryColor,
                  child: Icon(
                    Icons.qr_code_rounded,
                    size: 24,
                  ),
                  padding: EdgeInsets.all(16),
                  shape: CircleBorder(),
                ),
              ),
            ))
      ]),
    );
  }

  // Mode ramadan
  _ramadanWidget(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: size.height * .04),
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
                child: Container(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    alignment: Alignment.center,
                    width: size.width * .7,
                    height: size.width * .8,
                    child: _other),
              ),
            ),
            SizedBox(height: 20),
            ToggleSwitch(
              minWidth: 100,
              cornerRadius: 20.0,
              activeBgColor: kPrimaryColor,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.white,
              inactiveFgColor: kPrimaryColor,
              labels: ['50 F', '100 F'],
              onToggle: (index) {
                _state = index == 0 ? false : true;
                print("STATE : " + _state.toString());
              },
            ),
          ],
        ),
        Positioned(
            bottom: 100,
            right: 0,
            height: 80,
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  topLeft: Radius.circular(50)),
              child: Container(
                alignment: Alignment.center,
                color: kPrimaryColor,
                child: MaterialButton(
                  elevation: 5,
                  onPressed: () async {
                    try {
                      String number = await BarcodeScanner.scan();
                      print("USER NUMBER : " + number);
                      print("STATE : " + _state.toString());
                      if (number.length != 11) {
                        // montant insuffisant
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _other = _onInfo(
                              context, Colors.redAccent, "QR code invalide");
                        });
                        return;
                      }
                      setState(() {
                        _isLoad = true;
                        _setState = false;
                        _other = progressBar();
                      });
                      int amount;
                      if (!_state) {
                        amount = 50;
                      } else {
                        amount = 100;
                      }

                      ApiResponse res = await ramadanScan(number, amount);
                      print("RES : " + res.message);

                      if (res.error == false) {
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _other = _onSuccess(context, "Okay", Colors.green);
                        });
                      } else if (res.error == true) {
                        if (res.message == "409") {
                          // pas encore l'heure
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other = _onWarning(
                                context,
                                "Impossible de faire un scan endehors des heures d'ouvérture.",
                                Colors.orangeAccent);
                          });
                        } else if (res.message == "406") {
                          // deja passe
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other =
                                _onError(context, "L'étudiant est déjà passé.");
                          });
                        } else if (res.message == "400") {
                          // montant insuffisant
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other = _onInfo(context, Colors.orangeAccent,
                                "Montant insuffisant");
                          });
                        } else if (res.message == "422") {
                          // montant insuffisant
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _other = _onInfo(
                                context, Colors.redAccent, "QR code invalide");
                          });
                        } else if (res.message == "500") {
                          setState(() {
                            _isLoad = false;
                            _setState = true;
                            _message = "Vérifier votre connexion internet.";
                            _icon = Icons.wifi_off_rounded;
                            _color = kPrimaryColor;
                          });
                        }
                      }
                    } catch (e) {
                      print("SCAN CATCH $e");
                    }
                  },
                  color: Colors.white,
                  textColor: kPrimaryColor,
                  child: Icon(
                    Icons.qr_code_rounded,
                    size: 24,
                  ),
                  padding: EdgeInsets.all(16),
                  shape: CircleBorder(),
                ),
              ),
            )),
      ]),
    );
  }

  Widget _onSuccess(BuildContext context, String message, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline_outlined, color: color, size: 100),
        Text(message,
            style: TextStyle(
              color: color,
              fontSize: 15,
            ),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _onWarning(BuildContext context, String message, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 100),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Text(message,
              style: TextStyle(
                color: color,
                fontSize: 15,
              ),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _onError(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Colors.red,
          size: 50,
        ),
        Text(message,
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
            ),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _onInfo(BuildContext context, Color color, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded, color: color, size: 100),
        Text(message,
            style: TextStyle(
              color: color,
              fontSize: 15,
            ),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget progressBar() {
    return Container(
      alignment: Alignment.center,
      child: SleekCircularSlider(
        initialValue: 10,
        max: 100,
        appearance: CircularSliderAppearance(
            angleRange: 360,
            spinnerMode: true,
            startAngle: 90,
            size: 100,
            customColors: CustomSliderColors(
              hideShadow: true,
              progressBarColor: kPrimaryColor,
            )),
      ),
    );
  }

  void _logoutIcon() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Confirmation"),
              content: Text("Voulez-vous vous déconnecter?"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Non"),
                ),
                FlatButton(
                  onPressed: () {
                    SharedPref shar = new SharedPref();
                    shar.removeSharedPrefs();
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> route) => false);
                  },
                  child: Text("Oui"),
                )
              ],
              elevation: 25.0,
            ));
  }

  Widget _setMode(Information data, BuildContext context) {
    if (data.mode == 0) {
      return Normal(
        price1: data.price1,
        price2: data.price2,
        price3: data.price3,
      );
    } else {
      return Ramadan();
    }
  }

  // REQUEST METHODE
  Future<ApiResponse> scan(
    String number,
  ) async {
    String url = BASE_URL + '/api/vigilant/scan';

    String accessToken = await new SharedPref().getUserAccessToken();

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = jsonEncode({
      "number": number,
    });

    try {
      final response =
          await http.post(url, body: body, headers: requestHeaders);
      print("RESPONSE : " + response.body);
      if (response.statusCode == 200) {
        final String responseString = response.body;
        return apiResponseFromJson(responseString);
      } else {
        return ApiResponse(
            error: true, message: response.statusCode.toString());
      }
    } catch (e) {
      return ApiResponse(error: true, message: "500");
    }
  }

  Future<Information> getInformation() async {
    String url = BASE_URL + '/api/vigil/mode';

    SharedPref sharedPref = new SharedPref();
    String accessToken = await sharedPref.getUserAccessToken();

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(url, headers: requestHeaders);
      print("INFO : " + response.body);
      if (response.statusCode == 200) {
        String res = response.body;
        Information information = informationFromJson(res);
        return information;
      } else {
        return new Information(error: true, message: response.body, mode: -1);
      }
    } catch (e) {
      print("$e");
      return new Information(
          error: true, message: "Vérifier votre connexion.", mode: 500);
    }
  }

  Future<ApiResponse> ramadanScan(String number, int state) async {
    String url = BASE_URL + '/api/vigilant/scan';

    String accessToken = await new SharedPref().getUserAccessToken();

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = jsonEncode({"number": number, "amount": state});

    try {
      final response =
          await http.post(url, body: body, headers: requestHeaders);
      print("RESPONSE : " + response.body);
      if (response.statusCode == 200) {
        final String responseString = response.body;
        return apiResponseFromJson(responseString);
      } else {
        return ApiResponse(
            error: true, message: response.statusCode.toString());
      }
    } catch (e) {
      return ApiResponse(error: true, message: "500");
    }
  }
}
