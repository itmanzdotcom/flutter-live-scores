import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

final String token = 'c2928278d71247c3bcb7c4ccc89cc2c6';

//Top scorers in league object and handling

class topScorer{
  String name;
  String teamName;
  String goalNum;
  topScorer(this.name, this.teamName, this.goalNum);
}

Future<List<topScorer>> getScorers(String code) async{
  Response r = await get(Uri.encodeFull('https://api.football-data.org/v2/competitions/$code/scorers'),
    headers: {
      'X-Auth-Token' : token
    }
  );
  Map<String, dynamic> x = jsonDecode(r.body);
  List y = x['scorers'];
  List<topScorer> topScorersList = [];
  for(var i in y){
    topScorersList.add(new topScorer(i['player']['name'], i['team']['name'], i['numberOfGoals'].toString()));
  }

  return topScorersList;
}

class topScorers extends StatefulWidget{
  String leagueCode;
  Color leagueColor;
  topScorers(this.leagueCode, this.leagueColor);
  createState() => topScorersState(leagueCode, leagueColor);
}

class topScorersState extends State<topScorers>{

  String leagueCode;
  Color leagueColor;
  topScorersState(this.leagueCode, this.leagueColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: leagueColor,
      child: FutureBuilder(
        future: getScorers(leagueCode),
        builder: (context, snapshot){
          if(snapshot.data == null)
            return Center(child: CircularProgressIndicator());
          else{
            return Column(
              children: <Widget>[
                Padding(child: rankingRow(''), padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                Divider(color: Colors.white),
                Expanded(child:

                ListView.separated(
                  itemCount: snapshot.data.length,
                  separatorBuilder: (context, i){
                    return Padding(
                      padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Divider(color: Colors.white,),
                    );
                  },

                  itemBuilder: (context, i){
                    int playerRank = i +1;
                    return Container(
                      decoration: BoxDecoration(
                        color: leagueColor.withOpacity(0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: rankingRow(
                        playerRank.toString(),
                        snapshot.data[i].name,
                        snapshot.data[i].teamName,
                        snapshot.data[i].goalNum
                      ),
                    );
                  },
                ))
              ],
            );
          }
        },
      ),
    );
  }
}

Widget rankingRow([String pos = '', String name = 'Player', String team = 'Team',String goalNum = 'Goals']){
  return Row(
    children: <Widget>[
      Expanded(child: Center(child:Text(pos, style: plStyle)), flex: 1),
      Expanded(child: Padding(child:Text(name, style: plStyle),padding: EdgeInsets.fromLTRB(5, 0, 5, 0),), flex: 4),
      Expanded(child: Padding(child:Text(team, style: plStyle),padding: EdgeInsets.fromLTRB(5, 0, 5, 0),), flex: 4),
      Expanded(child: Text(goalNum, style: plStyle), flex: 2,)
    ],
  );
}

final plStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600
);