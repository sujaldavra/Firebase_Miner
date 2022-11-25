import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../global.dart';
import '../helpers/cloud_firestore_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final TextEditingController updateTitleController = TextEditingController();
  final TextEditingController updateNoteController = TextEditingController();

  String? title;
  String? note;
  String? time;

  String? updateTitle;
  String? updateNote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Note Keeper"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.note_alt,
            ),
          )
        ],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CloudFireStoreDBHelper.cloudFireStoreDBHelper.selectRecord(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error:${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot? documents = snapshot.data;

            List<QueryDocumentSnapshot> data = documents!.docs;

            if (data.isEmpty) {
              Global.noteId = '1';
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/note.png",
                      height: 70,
                      width: 70,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Notes Not Available..",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              int noteId = int.parse(data.last.id);
              noteId++;
              Global.noteId = noteId.toString();

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, i) {
                  return Card(
                    color: Colors.grey.shade200,
                    child: ListTile(
                      leading: Text(data[i].id),
                      title: Text("${data[i]['title']}"),
                      subtitle: Text("${data[i]['note']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  updateTitleController.text = data[i]['title'];
                                  updateNoteController.text = data[i]['note'];
                                  return AlertDialog(
                                    title: const Center(
                                      child: Text("UPDATE RECORD"),
                                    ),
                                    content: Form(
                                      key: updateFormKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              hintText: "Enter Title Name",
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              labelStyle: TextStyle(color: Colors.black),
                                              labelText: "Title",
                                            ),
                                            controller: updateTitleController,
                                            onSaved: (val) {
                                              setState(() {
                                                updateTitle = val;
                                              });
                                            },
                                            validator: (val) =>
                                            (val!.isEmpty) ? "Enter your Author Name first" : null,
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              hintText: "Enter Notes Name",
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              labelStyle: TextStyle(color: Colors.black),
                                              labelText: "Notes",
                                            ),
                                            controller: updateNoteController,
                                            onSaved: (val) {
                                              setState(() {
                                                updateNote = val;
                                              });
                                            },
                                            validator: (val) =>
                                            (val!.isEmpty) ? "Enter your Author Name first" : null,
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        onPressed: () async {
                                          if (updateFormKey.currentState!
                                              .validate()) {
                                            updateFormKey.currentState!.save();

                                            await CloudFireStoreDBHelper
                                                .cloudFireStoreDBHelper
                                                .updateRecord(
                                              id: data[i].id,
                                              title: updateTitle!,
                                              note: updateNote!,
                                            );

                                            updateTitleController.clear();
                                            updateNoteController.clear();

                                            setState(() {
                                              updateTitle = null;
                                              updateNote = null;
                                            });

                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Text("Update Note"),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.black),
                                        ),
                                        onPressed: () {
                                          updateTitleController.clear();
                                          updateNoteController.clear();

                                          setState(() {
                                            updateTitle = null;
                                            updateNote = null;
                                          });

                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await CloudFireStoreDBHelper
                                  .cloudFireStoreDBHelper
                                  .deleteRecord(id: data[i].id);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }

          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.black,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Center(
                  child: Text("ADD NEW NOTE"),
                ),
                content: Form(
                  key: insertFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Enter Title Name",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: TextStyle(color: Colors.black),
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                        controller: titleController,
                        onSaved: (val) {
                          setState(() {
                            title = val;
                          });
                        },
                        validator: (val) =>
                        (val!.isEmpty) ? "Enter your name first" : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          hintText: "Enter Notes Name",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: TextStyle(color: Colors.black),
                          labelText: "Notes",
                        ),
                        controller: noteController,
                        onSaved: (val) {
                          setState(() {
                            note = val;
                          });
                        },
                        validator: (val) =>
                        (val!.isEmpty) ? "Enter your Notes name first" : null,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
                actions: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                    ),
                    onPressed: () {
                      titleController.clear();
                      noteController.clear();

                      setState(() {
                        title = null;
                        note = null;
                        time = null;
                      });

                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      if (insertFormKey.currentState!.validate()) {
                        insertFormKey.currentState!.save();
                        time =
                            "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}";

                        await CloudFireStoreDBHelper.cloudFireStoreDBHelper
                            .insertRecord(
                          id: Global.noteId!,
                          title: title!,
                          note: note!,
                          time: time!,
                        );

                        titleController.clear();
                        noteController.clear();

                        setState(() {
                          title = null;
                          note = null;
                          time = null;
                        });

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Add Note"),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
