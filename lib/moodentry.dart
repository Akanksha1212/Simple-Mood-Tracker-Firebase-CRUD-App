import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'model/mood.dart';

class MoodEntry extends StatefulWidget {
  const MoodEntry({super.key});

  @override
  State<MoodEntry> createState() => _MoodEntryState();
}

class _MoodEntryState extends State<MoodEntry> {
  final descriptionController = TextEditingController();
  final moodValueController = TextEditingController();
  final entryDateController = TextEditingController();

  Future createMoodEntry(Mood mood) async {
    final docMood = FirebaseFirestore.instance.collection('moodentries').doc();
    mood.id = docMood.id;
    final json = mood.toJson();
    await docMood.set(json);
  }

  @override
  void initState() {
    entryDateController.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 244, 255),
      appBar: AppBar(
        title: Text("Mood Entry"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              //Entering how the user is feeling
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "How are you feeling?"),
              ),
              SizedBox(
                height: 20,
              ),
              // Getting mood value
              TextField(
                controller: moodValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter mood value(1-5) 1:Sad 5:Happy"),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: entryDateController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.calendar_today),
                    labelText: "Enter date"),
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
                    setState(() {
                      print(formattedDate);
                      entryDateController.text = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  final mood = Mood(
                    moodValue: int.parse(moodValueController.text),
                    description: descriptionController.text,
                    entryDate: DateTime.parse(entryDateController.text),
                  );
                  createMoodEntry(mood);
                  final snackBar = SnackBar(
                    content: const Text('Created the mood entry'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Text("Add mood entry"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
