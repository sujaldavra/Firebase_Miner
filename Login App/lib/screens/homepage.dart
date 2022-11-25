import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/helper/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    User? data = ModalRoute.of(context)!.settings.arguments as User?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FireBaseAuth.fireBaseAuth.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 60),
            (data?.photoURL != null)
                ? CircleAvatar(
                    backgroundImage: NetworkImage("${data?.photoURL}"),
                    radius: 60,
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 60,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
            const SizedBox(height: 20),
            (data?.displayName != null)
                ? Text(
                    "Name: ${data?.displayName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : const Text(
                    "________",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
            const Divider(),
            (data?.email != null)
                ? Text(
                    "Email: ${data?.email}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : const Text(
                    "________",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
