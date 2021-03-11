import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:vigil/constants.dart';
import 'package:http/http.dart' as http;
import 'package:vigil/models/Information.dart';
import 'package:vigil/utils/SharedPref.dart';
import 'package:vigil/views/Normal.dart';

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  Future<Information> _myFuture;

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

  Widget progressBar() {
    return Container(
      alignment: Alignment.center,
      child: SleekCircularSlider(
        initialValue: 10,
        max: 100,
        appearance: CircularSliderAppearance(
            angleRange: 350,
            spinnerMode: true,
            startAngle: 50,
            size: 50,
            customColors: CustomSliderColors(
              hideShadow: true,
              progressBarColor: kPrimaryColor,
            )),
      ),
    );
  }

  Widget _setMode(Information data, BuildContext context) {
    return Normal(
      price1: data.price1,
      price2: data.price2,
      price3: data.price3,
    );
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
}
