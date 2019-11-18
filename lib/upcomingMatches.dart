import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

final String token = 'c2928278d71247c3bcb7c4ccc89cc2c6';

class match {
  String homeTeam;
  String awayTeam;
  String matchDay;
  String matchTime;

  match(this.homeTeam, this.awayTeam, this.matchDay, this.matchTime);
}

class upcomingMatches extends StatefulWidget {
  String leagueCode;
  Color leagueColor;

  upcomingMatches(this.leagueCode, this.leagueColor);
  createState() => upcomingMatchesState(leagueCode, leagueColor);
}

class upcomingMatchesState extends State<upcomingMatches> {
  String leagueCode;
  Color leagueColor;

  upcomingMatchesState(this.leagueCode, this.leagueColor);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: leagueColor,
        child: FutureBuilder(
          future: getMatches(leagueCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: <Widget>[
                            //first part of match details
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FittedBox(
                                      child: Text(snapshot.data[i].homeTeam,
                                          style: teamStyle),
                                      fit: BoxFit.fitWidth
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(50,0,50,0),
                                    child: Divider(
                                      color: Colors.black,
                                    ),
                                  ),
                                  FittedBox(
                                      child: Text(snapshot.data[i].awayTeam,
                                          style: teamStyle),
                                      fit: BoxFit.fitWidth
                                  )
                                ],
                              ),
                            ),

                            //second part of match details
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  FittedBox(
                                      child: timeFormatter(snapshot.data[i]),
                                      fit: BoxFit.fitWidth
                                  ),
                                  FittedBox(
                                      child: dayFormatter(snapshot.data[i]),
                                      fit: BoxFit.fitWidth
                                  ),
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }
          },
        ));
  }
}

Future<List<match>> getMatches(String code) async {
  Response r = await get(
      Uri.encodeFull(
          'https://api.football-data.org/v2/competitions/$code/matches?status=SCHEDULED'),
      headers: {"X-Auth-Token": token});

  Map<String, dynamic> x = jsonDecode(r.body);
  List y = x['matches'];

  List<match> extractedMatches = [];

  print(x.keys);
  for (var i in y) {
    extractedMatches.add(new match(
        i['homeTeam']['name'],
        i['awayTeam']['name'],
        i['utcDate'].toString().substring(5, 10),
        DateTime.parse(i['utcDate'])
            .toLocal()
            .toIso8601String()
            .substring(11, 16)));
  }

  return extractedMatches;
}

TextStyle teamStyle =
    TextStyle(color: Colors.black, fontSize: 20, fontStyle: FontStyle.italic);

timeFormatter(match m) {
  String convertedTime = m.matchTime;
  print(m.matchTime);
  int time = int.parse(m.matchTime.substring(0, 2));
  //print(m.matchTime);
  //print(time);
  if (time > 12) {
    time = time - 12;
    convertedTime = time.toString() + m.matchTime.substring(2) + ' PM';
  }
  print(convertedTime);
  return Text(convertedTime);
}

dayFormatter(match m){
  String d = m.matchDay;
  List splitD = d.split('-');
  if(splitD[0].toString().startsWith('0'))
    splitD[0] = splitD[0].toString().substring(1);

  if(splitD[1].toString().startsWith('0'))
    splitD[1] = splitD[1].toString().substring(1);

  d = splitD[0] + '/' + splitD[1];
  return Text(d);
}
