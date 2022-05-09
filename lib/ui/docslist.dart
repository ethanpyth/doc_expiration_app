import 'dart:async';
import 'package:flutter/material.dart' hide DateUtils;

import '../model/model.dart';
import '../utils/dbhelper.dart';
import '../utils/utils.dart';
import './docdetail.dart';

//menu items
const menuReset = "Reset Local Data";
List<String> menuOptions = const <String>[menuReset];

class DocList extends StatefulWidget {
  const DocList({Key? key}) : super(key: key);

  @override
  State<DocList> createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  DbHelper dbh = DbHelper();
  late List<Doc> docs;
  int count = 0;
  late DateTime cDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cDate = DateTime.now();

    if (docs == null) {
      docs = <Doc>[];
      getData();
    }

    _checkDate();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("DocExpire"),
        actions: <Widget>[
          PopupMenuButton(
              onSelected: _selectMenu,
              itemBuilder: (BuildContext context) {
                return menuOptions.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              })
        ],
      ),
      body: Center(
        child: Scaffold(
          body: Stack(
            children: <Widget>[docListItems()],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _navigateToDetail(Doc.withId(-1, "", "", 1, 1, 1, 1));
            },
            tooltip: "Add new doc",
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Future getData() async {
    final dbfuture = dbh.initializeDb();
    dbfuture.then((result) {
      final docsFuture = dbh.getDocs();
      docsFuture.then((result) {
        if (result.length >= 0) {
          List<Doc> docList = <Doc>[];
          var count = result.length;
          for (int i = 0; i < count - 1; i++) {
            docList.add(Doc.fromObject(result[i]));
          }
          setState(() {
            if (docs.isNotEmpty) {
              docs.clear();
            }
            docs = docList;
            this.count = count;
          });
        }
      });
    });
  }

  void _checkDate() {
    const secs = Duration(seconds: 10);

    Timer.periodic(secs, (Timer t) {
      DateTime nw = DateTime.now();

      if (cDate.day != nw.day ||
          cDate.month != nw.month ||
          cDate.year != nw.year) {
        getData();
        cDate = DateTime.now();
      }
    });
  }

  void _navigateToDetail(Doc doc) async {
    bool r = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DocDetail(doc)));
    if (r == true) {
      getData();
    }
  }

  void _showResetDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Reset"),
            content: const Text("Do you want to delete all local data?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                child: const Text("Ok"),
                onPressed: () {
                  Future f = _resetLocalData();
                  f.then((result) {
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        });
  }

  Future _resetLocalData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result) {
      setState(() {
        docs.clear();
        count = 0;
      });
    });
  }

  void _selectMenu(String value) async {
    switch (value) {
      case menuReset:
        _showResetDialog();
    }
  }

  ListView docListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        String dd = Val.getExpiryStr(docs[position].expiration);
        String dl = (dd != "1") ? " days left" : " day left";
        return Card(
          color: Colors.white,
          elevation: 1.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  (Val.getExpiryStr(docs[position].expiration) != "0")
                      ? Colors.blue
                      : Colors.red,
              child: Text(docs[position].id.toString()),
            ),
            title: Text(docs[position].title),
            subtitle: Text(Val.getExpiryStr(docs[position].expiration) +
                dl +
                "\nExp: " +
                DateUtils.convertToDateFull(docs[position].expiration)!),
            onTap: () {
              _navigateToDetail(docs[position]);
            },
          ),
        );
      },
    );
  }
}

// TODO Implement this library.

