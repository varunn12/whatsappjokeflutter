import 'dart:async';
import 'dart:convert';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'customStyle.dart';

 const whatsappJokeAPI="https://icanhazdadjoke.com/";
  const headers=const {
    'User-Agent': 'WhatsAppJokes(https://github.com/varunn12',
    'Accept':'application/json',
  };

void main()=>runApp(new MaterialApp(
  home: JokePage(),
  title: 'WhatsApp Jokes',
  theme: new ThemeData(
    primaryColor: Colors.orange,
  ),
));


class JokePage extends StatefulWidget {
 
  @override
  _JokePageState createState() => new _JokePageState();
}

class _JokePageState extends State<JokePage> {
  Future<String> _response;
  String _displayedJoke='';


  _aboutAction() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
              title: Text('WhatsApp Jokes'),
              content: Text(
                  'WhatsApp jokes is brought to you by varunn12'));
        });
  }

  

  _shareAction() {
  if (_displayedJoke != '') {
    share(_displayedJoke);
  }
}
  _refreshJokes(){
    print('pressed');
    setState(() {
           _response=http.read(whatsappJokeAPI, headers: headers);
        });
  }


  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      _refreshJokes();
      
    }

    FutureBuilder<String> _jokeBody() {
    return FutureBuilder<String>(
      future: _response,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const ListTile(
              leading: Icon(Icons.sync_problem),
              title: Text('No connection'),
            );
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return const Center(
                child: ListTile(
                  leading: Icon(Icons.error),
                  title: Text('Network error'),
                  subtitle: Text(
                      'Sorry - this isn\'t funny, we know, but something went '
                      'wrong when connecting to the Internet. Check your '
                      'network connection and try again.'),
                ),
              );
            } else {
              final decoded = json.decode(snapshot.data);
              if (decoded['status'] == 200) {
                _displayedJoke = decoded['joke'];
                return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Dismissible(
                      key: const Key("joke"),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        _refreshJokes();
                      },
                      child: Text(_displayedJoke, style: customStyle.jokeTextStyle),
                    ));
              } else {
                return ListTile(
                  leading: const Icon(Icons.sync_problem),
                  title: Text('Unexpected error: ${snapshot.data}'),
                );
              }
            }
        }
      },
    );
  }


    Widget build(BuildContext context){
  return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Jokes'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            tooltip: 'About WhatsApp Jokes',
            onPressed: _aboutAction,
          ),
          IconButton(
            icon: Icon(Icons.share),
            tooltip: 'Share joke',
            onPressed: _shareAction,
          )
        ],
      ),
      body: Center(
        child: _jokeBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        label: new Text('Get a new Joke'),
        elevation: 6.0,
        onPressed: _refreshJokes,
        tooltip: 'New joke',
        icon: Icon(Icons.refresh),
      ),
    );
  }
}