import 'dart:convert';
import 'dart:io';
import 'package:author_registration_app/global.dart';
import 'package:author_registration_app/helpers/cloud_firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  TextEditingController authorController = TextEditingController();
  TextEditingController bookController = TextEditingController();

  String? author;
  String? book;
  Uint8List? image;
  Uint8List? decodedImage;
  String encodedImage = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Author Registration"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: CloudFireStoreDBHelper.cloudFireStoreDBHelper.selectRecord(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("ERROR : ${snapShot.error}"),
            );
          } else if (snapShot.hasData) {
            QuerySnapshot? data = snapShot.data;
            List<QueryDocumentSnapshot> documents = data!.docs;

            if (documents.isEmpty) {
              Global.noteId = '1';
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/nobooks.png",
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Books Not Available..",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, i) {
                  if (documents[i]['image'] != null) {
                    decodedImage = base64Decode(documents[i]['image']);
                  } else {
                    decodedImage == null;
                  }

                  return Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    child: ListTile(
                      isThreeLine: true,
                      leading: (decodedImage == null)
                          ? const Text(
                              "NO IMAGE",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            )
                          : Container(
                              height: 65,
                              width: 65,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.memory(
                                  decodedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      title: Row(
                        children: [
                          const Text(
                            "Author : ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${documents[i]['author']} ",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Row(
                          children: [
                            const Text(
                              "Book Name: \n",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${documents[i]['book']} \n ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Update Records"),
                                  content: Form(
                                    key: updateKey,
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
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            labelText: "Title",
                                            border: OutlineInputBorder(),
                                          ),
                                          controller: authorController,
                                          onSaved: (val) {
                                            setState(() {
                                              author = val;
                                            });
                                          },
                                          validator: (val) => (val!.isEmpty)
                                              ? "Enter your name first"
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          keyboardType: TextInputType.name,
                                          decoration: const InputDecoration(
                                            hintText: "Enter Books Name",
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black,
                                              ),
                                            ),
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            labelText: "Books",
                                          ),
                                          controller: bookController,
                                          onSaved: (val) {
                                            setState(() {
                                              book = val;
                                            });
                                          },
                                          validator: (val) => (val!.isEmpty)
                                              ? "Enter your Books name first"
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                      ),
                                      child: const Text("Update"),
                                      onPressed: () {
                                        if (updateKey.currentState!
                                            .validate()) {
                                          updateKey.currentState!.save();

                                          Map<String, dynamic> data = {
                                            'author': author,
                                            'book': book,
                                          };
                                          CloudFireStoreDBHelper
                                              .cloudFireStoreDBHelper
                                              .updateRecord(
                                                  id: documents[i].id,
                                                  data: data);
                                        }
                                        authorController.clear();
                                        bookController.clear();

                                        author = "";
                                        book = "";
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        authorController.clear();
                                        bookController.clear();

                                        author = null;
                                        book = null;

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
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
                                  .deleteRecord(id: "${documents[i].id}");
                            },
                          ),
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
              color: Colors.black,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Center(
                child: Text("Enter book details"),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: insertKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          XFile? img = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (img != null) {
                            File compressedImage =
                                await FlutterNativeImage.compressImage(
                                    img.path);
                            image = await compressedImage.readAsBytes();
                            encodedImage = base64Encode(image!);
                          }
                          setState(() async {});
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 70,
                          child: Center(
                            child: image == null
                                ? const Text(
                                    "ADD IMAGE",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  )
                                : Container(
                                    height: 20,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.memory(
                                        image!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                        controller: authorController,
                        onSaved: (val) {
                          setState(() {
                            author = val;
                          });
                        },
                        validator: (val) =>
                            (val!.isEmpty) ? "Enter your name first" : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          hintText: "Enter Books Name",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: TextStyle(color: Colors.black),
                          labelText: "Books",
                        ),
                        controller: bookController,
                        onSaved: (val) {
                          setState(() {
                            book = val;
                          });
                        },
                        validator: (val) => (val!.isEmpty)
                            ? "Enter your Books name first"
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Submit"),
                  onPressed: () async {
                    if (insertKey.currentState!.validate()) {
                      insertKey.currentState!.save();

                      Map<String, dynamic> data = {
                        'author': author,
                        'book': book,
                        'image': encodedImage,
                      };

                      await CloudFireStoreDBHelper.cloudFireStoreDBHelper
                          .insertRecord(data: data);

                      Navigator.of(context).pop();
                      authorController.clear();
                      bookController.clear();
                      setState(() {
                        author = null;
                        book = null;
                        decodedImage = null;
                      });
                    }
                  },
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    authorController.clear();
                    bookController.clear();
                    setState(() {
                      author = null;
                      book = null;
                      decodedImage = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
