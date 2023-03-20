import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/moodentry.dart';

import 'model/mood.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final descriptionUpdateController = TextEditingController();
  final moodValueUpdateController = TextEditingController();
  final entryDateUpdateController = TextEditingController();

  @override
  void initState() {
    entryDateUpdateController.text = "";
    descriptionUpdateController.text = "";
    moodValueUpdateController.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<Mood>> readMoodEntries() => FirebaseFirestore.instance
        .collection('moodentries')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Mood.fromJson(doc.data())).toList());

    Future<Mood?> readMoodEntry() async {
      final docUser = FirebaseFirestore.instance
          .collection('moodentries')
          .doc('8Wo4lIexLEbYg7oG3tn4');
      final snapshot = await docUser.get();

      if (snapshot.exists) {
        return Mood.fromJson(snapshot.data()!);
      }
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 244, 255),
      appBar: AppBar(
        title: Text("Mood Entries"),
      ),
      body:
          // FutureBuilder<Mood?>(
          //StreamBuilder<List<User>>(stream:readUsers(),)
          // FutureBuilder<List<User>>(
          // future: readUsers().first,
          // future: readMoodEntry(),
          // builder: (context, snapshot) {
          //   if (snapshot.hasError) {
          //     return Text("something went wrong $snapshot");
          //   } else if (snapshot.hasData) {
          //     final user = snapshot.data;
          //     return user == null
          //         ? Center(child: Text("no user"))
          //         : buildMoodTile(user);
          //   }
          StreamBuilder<List<Mood>>(
        stream: readMoodEntries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          } else if (snapshot.hasData) {
            final moods = snapshot.data!;
            return ListView(
              children: moods.map(buildMoodTile).toList(),
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => MoodEntry()));
        },
      ),
    );
  }

  Widget buildMoodTile(Mood mood) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          tileColor: Color.fromARGB(255, 115, 206, 255),

          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage(
                  mood.moodValue! >= 3 ? "assets/happy.png" : "assets/sad.png"),
            ),
          ),
          // CircleAvatar(backgroundImage: AssetImage(user.age > 1 ? "" : "")),
          title: Text(mood.description!),
          subtitle: Text(
            DateFormat("yyyy-MM-dd").format(
              (mood.entryDate!),
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              final snackBar = SnackBar(
                content: const Text('Deleted the mood entry'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              final docUser = FirebaseFirestore.instance
                  .collection('moodentries')
                  .doc(mood.id);
              docUser.delete();
            },
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Update Mood Entry'),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: descriptionUpdateController,
                        decoration: InputDecoration(
                          labelText: mood.description,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Getting mood value
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: moodValueUpdateController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: mood.moodValue.toString(),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: entryDateUpdateController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: DateFormat("yyyy-MM-dd").format(
                            (mood.entryDate!),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            print(pickedDate);
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(
                              () {
                                entryDateUpdateController.text = formattedDate;
                              },
                            );
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('Update'),
                          onPressed: () {
                            final docUser = FirebaseFirestore.instance
                                .collection('moodentries')
                                .doc(mood.id);
                            dynamic moodValue;
                            dynamic entryDate;
                            if (moodValueUpdateController.text.isEmpty) {
                              moodValue = mood.moodValue;
                            } else {
                              moodValue = moodValueUpdateController.text;
                            }
                            if (entryDateUpdateController.text.isEmpty) {
                              entryDate = mood.entryDate;
                            } else {
                              entryDate = entryDateUpdateController.text;
                            }
                            docUser.update(
                              {
                                'description':
                                    descriptionUpdateController.text.isEmpty
                                        ? mood.description
                                        : descriptionUpdateController.text,
                                'moodValue': int.parse(moodValue),
                                'entryDate': DateTime.parse(entryDate),
                              },
                            );
                            setState(() {
                              descriptionUpdateController.clear();
                              moodValueUpdateController.clear();
                              entryDateUpdateController.clear();
                            });
                            final snackBar = SnackBar(
                              content: const Text('Updated the value'),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
}
