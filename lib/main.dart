import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLightMode = true;

  void toggleTheme(bool value) {
    setState(() {
      isLightMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: isLightMode ? Brightness.light : Brightness.dark,
      ),
      home: Homepage(onThemeChanged: toggleTheme, isLightMode: isLightMode),
    );
  }
}

class Homepage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isLightMode;
  const Homepage({required this.onThemeChanged, required this.isLightMode});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String location = "Sta Ana";
  String temp = "";
  IconData? weatherStatus;
  String weather = "";
  String humidity = "";
  String windSpeed = "";
  Map<String, dynamic> weatherData = {};

  Future<void> getWeatherData() async {
    try {
      String link =
          "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=1076fec86f02f1c81aca4efa85103145";
      final response = await http.get(Uri.parse(link));
      weatherData = jsonDecode(response.body);

      setState(() {
        temp = (weatherData["main"]["temp"] - 273.15).toStringAsFixed(0) + "°";
        humidity = (weatherData["main"]["humidity"]).toString() + "%";
        windSpeed = weatherData["wind"]["speed"].toString() + " kph";
        weather = weatherData["weather"][0]["description"];

        if (weather.contains("clear")) {
          weatherStatus = CupertinoIcons.sun_max;
        } else if (weather.contains("rain")) {
          weatherStatus = CupertinoIcons.cloud_bolt_rain;
        } else if (weather.contains("cloud")) {
          weatherStatus = CupertinoIcons.cloud;
        } else if (weather.contains("haze")) {
          weatherStatus = CupertinoIcons.sun_haze;
        }
      });
    } catch (e) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Message'),
              content: Text("No Internet Connection or Invalid Location"),
              actions: [
                CupertinoButton(
                    child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                CupertinoButton(
                    child: Text('Retry', style: TextStyle(color: CupertinoColors.systemGreen)),
                    onPressed: () {
                      Navigator.pop(context);
                      getWeatherData();
                    }),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    getWeatherData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: widget.isLightMode ? CupertinoColors.white : CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        middle: Text("iWeather", style: TextStyle(color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.settings, color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SettingsPage(
                  onLocationChanged: (newLocation) {
                    setState(() {
                      location = newLocation;
                    });
                    getWeatherData();
                  },
                  onThemeChanged: widget.onThemeChanged,
                  isLightMode: widget.isLightMode,
                ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: temp != ""
            ? Center(
          child: Column(
            children: [
              SizedBox(height: 50),
              Text('My Location', style: TextStyle(fontSize: 35, color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white)),
              SizedBox(height: 10),
              Text('$location', style: TextStyle(color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white)),
              SizedBox(height: 10),
              Text("$temp", style: TextStyle(fontSize: 80, color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white)),
              Icon(weatherStatus, color: CupertinoColors.systemOrange, size: 100),
              SizedBox(height: 10),
              Text('$weather', style: TextStyle(color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('H: $humidity ', style: TextStyle(color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white)),
                  SizedBox(width: 10),
                  Text('W: $windSpeed ', style: TextStyle(color: widget.isLightMode ? CupertinoColors.black : CupertinoColors.white)),
                ],
              )
            ],
          ),
        )
            : Center(child: CupertinoActivityIndicator()),
      ),
    );
  }
}
class SettingsPage extends StatefulWidget {
  final Function(String) onLocationChanged;
  final Function(bool) onThemeChanged;
  final bool isLightMode;

  SettingsPage({
    required this.onLocationChanged,
    required this.onThemeChanged,
    required this.isLightMode,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool iconEnabled = true;
  bool metricSystem = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController locationController = TextEditingController();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Settings"),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoListSection(
              children: [
                // 🔹 Location Setting
                CupertinoListTile(
                  title: Text("Location"),
                  trailing: Text("Tap to change"),
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text("Change Location"),
                          content: CupertinoTextField(
                            controller: locationController,
                            placeholder: "Enter new location",
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text("Save"),
                              onPressed: () {
                                if (locationController.text.isNotEmpty) {
                                  widget.onLocationChanged(locationController.text);
                                }
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                // 🔹 Icon Toggle
                CupertinoListTile(
                  title: Text("Icon"),
                  trailing: CupertinoSwitch(
                    value: iconEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        iconEnabled = value;
                      });
                    },
                  ),
                ),

                // 🔹 Metric System Toggle
                CupertinoListTile(
                  title: Text("Metric System"),
                  trailing: CupertinoSwitch(
                    value: metricSystem,
                    onChanged: (bool value) {
                      setState(() {
                        metricSystem = value;
                      });
                    },
                  ),
                ),

                // 🔹 Light Mode Toggle
                CupertinoListTile(
                  title: Text("Light Mode"),
                  trailing: CupertinoSwitch(
                    value: widget.isLightMode,
                    onChanged: widget.onThemeChanged,
                  ),
                ),

                // 🔹 About Section
                CupertinoListTile(
                  title: Text("About"),
                  trailing: Text("Tap to view"),
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text("Group Members"),
                          content: Column(
                            children: [
                              Text("1. Darren G. Simbulan"),
                              Text("2. Angilyn H. Borja"),
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("Close"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}