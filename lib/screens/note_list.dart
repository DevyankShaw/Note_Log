import 'dart:async';

import 'package:email_launcher/email_launcher.dart';
import 'package:flutter/material.dart';
import 'package:note_log/models/note.dart';
import 'package:note_log/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'note_detail.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NoteListState();
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  List<Note> copyNoteList = [];
  int count;
  final TextEditingController _searchQuery = new TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  void filterSearchResults(String query) {
    List<Note> dummySearchList = List<Note>();
    dummySearchList.addAll(noteList);
    if (query.isNotEmpty) {
      List<Note> dummyListData = List<Note>();
      dummySearchList.forEach((item) {
        if (item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        copyNoteList.clear();
        copyNoteList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        copyNoteList.clear();
        copyNoteList.addAll(noteList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              leading: IconButton(
                tooltip: 'Close',
                icon: Hero(
                  tag: 'icon',
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    copyNoteList.clear();
                    copyNoteList.addAll(noteList);
                    _searchQuery.clear();
                  });
                },
              ),
              titleSpacing: 0.0,
              title: TextField(
                autofocus: true,
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: _searchQuery,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                ),
                decoration: InputDecoration(
                  hintText: "Search by title or description",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusColor: Colors.white,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Clear',
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery.clear();
                      copyNoteList.clear();
                      copyNoteList.addAll(noteList);
                    });
                  },
                )
              ],
            )
          : AppBar(
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              title: Text(
                'Note Log',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Search',
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      if (noteList.isNotEmpty) {
                        _isSearching = true;
                        copyNoteList.clear();
                        copyNoteList.addAll(noteList);
                      }
                    });
                  },
                ),
              ],
            ),
      body: _checkNotesAvailable()
          ? copyNoteList.length > 0
              ? getNoteListView()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'images/no_notes.png',
                        width: 100,
                        height: 80,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'No Notes',
                        textScaleFactor: 1.3,
                      ),
                    ],
                  ),
                )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20.0),
                  Text('Fetching Notes', maxLines: 1, textScaleFactor: 1.3),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'icon',
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      itemCount: copyNoteList.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 4.0,
          margin: EdgeInsets.only(bottom: 10.0),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            leading: CircleAvatar(
              backgroundColor:
                  getPriorityColor(this.copyNoteList[position].priority),
              child: Icon(Icons.note_add, color: Colors.white),
            ),
            title: Text(
              this.copyNoteList[position].title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(this.copyNoteList[position].description,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range,
                            color: Colors.grey.shade700, size: 20.0),
                        SizedBox(width: 5.0),
                        Text(this
                            .copyNoteList[position]
                            .date
                            .split('at')
                            .first
                            .trim()),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.grey.shade700, size: 20.0),
                        SizedBox(width: 5.0),
                        Text(this
                            .copyNoteList[position]
                            .date
                            .split('at')
                            .last
                            .trim()),
                      ],
                    )
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    _delete(context, copyNoteList[position]);
                  },
                ),
                SizedBox(height: 8.0),
                InkWell(
                  child: Icon(
                    Icons.share,
                    color: Colors.grey,
                  ),
                  onTap: () async {
                    Email email = Email(
                        to: ['devyankshaw68@gmail.com'],
                        subject: copyNoteList[position].title,
                        body: copyNoteList[position].description);
                    await EmailLauncher.launch(email);
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.copyNoteList[position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow.shade800;
        break;

      default:
        return Colors.yellow.shade800;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully', note);
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message, Note deletedNote) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.deepPurple.shade400,
        onPressed: () => _save(deletedNote),
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
          copyNoteList.clear();
          copyNoteList.addAll(noteList);
        });
      });
    });
  }

  void _save(Note note) async {
    await databaseHelper.insertNote(note);
    updateListView();
  }

  bool _checkNotesAvailable() {
    if (count != null) {
      return true;
    } else {
      return false;
    }
  }
}
