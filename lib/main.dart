import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:live_scores/firebase_config.dart';
import 'package:logger/logger.dart';

import 'standings.dart';
import 'topScorers.dart';
import 'upcomingMatches.dart';

//Acquire token from https://www.football-data.org and insert it here
final String token = '';
var logger = Logger();

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
    theme: ThemeData(
      primaryColor: Colors.green,
    ),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

Widget builder(BuildContext context) {
  return FutureBuilder(
    future: Config().setupRemoteConfig(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      return snapshot.hasData || snapshot.hasError
          ? listLeagues(context)
          : Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
    },
  );
}

Widget listLeagues(BuildContext context){
  return Scaffold(
      appBar: AppBar(
        title: Text('Hãy Chọn Trận Đấu'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  itemListView(
                      'assets/images/ic_premier_league.png',
                      context,
                      MainScreen('Premier League', 'PL',
                          Color.fromRGBO(63, 16, 82, 1))),
                  itemListView(
                      'assets/images/ic_laliga.jpg',
                      context,
                      MainScreen(
                          'La Liga', 'PD', Color.fromRGBO(0, 52, 114, 1))),
                  itemListView(
                      'assets/images/ic_serie_a.jpg',
                      context,
                      MainScreen(
                          'Serie A', 'SA', Color.fromRGBO(29, 150, 71, 1))),
                  itemListView(
                      'assets/images/ic_bund.png',
                      context,
                      MainScreen('Bundesliga', 'BL1',
                          Color.fromRGBO(177, 40, 41, 1))),
                  itemListView(
                      'assets/images/ic_ligue1.jpg',
                      context,
                      MainScreen(
                          'Ligue 1', 'FL1', Color.fromRGBO(227, 76, 38, 1))),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                  color: Colors.green,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Đăng ký tài khoản KuBet?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: SizedBox(
                              width: 120.0,
                              height: 50.0,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                onPressed: () {},
                                color: Colors.white,
                                child: Text(
                                  "Đăng Nhập",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: SizedBox(
                              width: 120.0,
                              height: 50.0,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                onPressed: () {},
                                color: Colors.white,
                                child: Text(
                                  "Đăng Ký",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ));
}

Widget itemListView(
    String imgPath, BuildContext context, StatefulWidget newScreen) {
  return InkWell(
    highlightColor: Colors.green,
    onTap: () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => newScreen));
    },
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
      child: Card(
        elevation: 20,
        color: Colors.white,
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Image.asset(imgPath),
              ),
            ],
          ),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    ),
  );
}

class MainScreen extends StatefulWidget {
  String leagueName;
  String leagueCode;
  Color leagueColor;

  MainScreen(this.leagueName, this.leagueCode, this.leagueColor);

  createState() => MainScreenState(leagueName, leagueCode, leagueColor);
}

class MainScreenState extends State<MainScreen> {
  String leagueName;
  String leagueCode;
  Color leagueColor;

  MainScreenState(this.leagueName, this.leagueCode, this.leagueColor);

  Widget screenContent = Container();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: Text(leagueName),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  text: 'Trận Đấu',
                ),
                Tab(
                  text: 'Sếp Hạng',
                ),
                Tab(
                  text: 'Điểm Số',
                )
              ],
            ),
            backgroundColor: leagueColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body: TabBarView(
          children: <Widget>[
            upcomingMatches(leagueCode, leagueColor),
            leagueStanding(leagueCode, leagueName, leagueColor),
            topScorers(leagueCode, leagueColor)
          ],
        ),
      ),
    );
  }

  void displayStandings() {
    setState(() {
      screenContent = leagueStanding('PL', leagueName, leagueColor);
    });
  }

  void displayMatches() {
    setState(() {
      screenContent = upcomingMatches(leagueCode, leagueColor);
    });
  }
}