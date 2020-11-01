import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_log/models/note.dart';
import 'package:note_log/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() =>
      NoteDetailState(this.note, this.appBarTitle);
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  var _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                  tooltip: 'Back',
                  icon: Hero(
                    tag: 'icon',
                    child: Icon(Icons.arrow_back),
                  ),
                  onPressed: () {
                    // Write some code to control things, when user press back button in AppBar
                    moveToLastScreen();
                  }),
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      // First element
                      Row(
                        children: [
                          Text('Priority:', style: textStyle),
                          SizedBox(width: 15.0),
                          Expanded(
                            child: DropdownButton(
                                items: _priorities
                                    .map((String dropDownStringItem) {
                                  return DropdownMenuItem<String>(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  );
                                }).toList(),
                                style: Theme.of(context).textTheme.subtitle1,
                                isExpanded: true,
                                value: getPriorityAsString(note.priority),
                                onChanged: (valueSelectedByUser) {
                                  setState(() {
                                    debugPrint(
                                        'User selected $valueSelectedByUser');
                                    updatePriorityAsInt(valueSelectedByUser);
                                  });
                                }),
                          ),
                        ],
                      ),

                      // Second Element
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextFormField(
                          controller: titleController,
                          style: Theme.of(context).textTheme.subtitle1,
                          cursorColor: Colors.deepPurple,
                          // ignore: missing_return
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Please enter title';
                            }
                          },
                          onChanged: (value) {
                            debugPrint('Something changed in Title Text Field');
                            updateTitle();
                          },
                          decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: textStyle,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      // Third Element
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextFormField(
                          controller: descriptionController,
                          style: Theme.of(context).textTheme.subtitle1,
                          cursorColor: Colors.deepPurple,
                          onChanged: (value) {
                            debugPrint(
                                'Something changed in Description Text Field');
                            updateDescription();
                          },
                          // ignore: missing_return
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Please enter description';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: textStyle,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      // Fourth Element
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                color: Theme.of(context).primaryColorDark,
                                textColor: Theme.of(context).primaryColorLight,
                                child: Text(
                                  widget.appBarTitle == 'Add Note'
                                      ? 'Save'
                                      : 'Edit',
                                  textScaleFactor: 1.4,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_formKey.currentState.validate()) {
                                      debugPrint("Save button clicked");
                                      _save();
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Expanded(
                              child: RaisedButton(
                                color: Theme.of(context).primaryColorDark,
                                textColor: Theme.of(context).primaryColorLight,
                                child: Text(
                                  widget.appBarTitle == 'Add Note'
                                      ? 'Cancel'
                                      : 'Delete',
                                  textScaleFactor: 1.4,
                                ),
                                onPressed: () => widget.appBarTitle ==
                                        'Add Note'
                                    ? moveToLastScreen()
                                    : setState(() {
                                        if (_formKey.currentState.validate()) {
                                          debugPrint("Delete button clicked");
                                          _delete();
                                        }
                                      }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text.trim();
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text.trim();
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat('MMM dd, yyyy ').format(DateTime.now()) +
        'at ' +
        DateFormat('hh:mm a').format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status',
          'Note ${widget.appBarTitle == 'Add Note' ? 'Saved' : 'Edited'} Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: true,
      dialogType: DialogType.SUCCES,
      animType: AnimType.SCALE,
      title: title,
      desc: message,
    )..show();
  }
}
