// ignore_for_file: avoid_print, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import 'package:razvoj_sofvera/Utilities/key_card.dart';
import 'package:razvoj_sofvera/Utilities/key_card_dialog.dart';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:razvoj_sofvera/Utilities/room_card.dart';
import 'package:razvoj_sofvera/pages/controller_pages/bathroom_controler.dart';
import 'package:razvoj_sofvera/pages/controller_pages/bedroom_controler.dart';
import 'package:razvoj_sofvera/pages/controller_pages/living_room_controler.dart';
import 'package:razvoj_sofvera/theme/theme_provider.dart';

class MyRoom extends StatefulWidget {
  const MyRoom({super.key});

  @override
  State<MyRoom> createState() => _MyRoomState();
}

class _MyRoomState extends State<MyRoom> {
  ValueNotifier<String> result = ValueNotifier<String>(
      ''); // Declare and initialize a ValueNotifier to hold a string value

  void customNfcWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      if (!isTagWritable(tag)) {
        print('Tag is not writable with custom method');
        NfcManager.instance.stopSession(errorMessage: "Tag is not writable");
        return;
      }

      try {
        await writeCustomDataToTag(tag);
        print('Success with custom write');
        NfcManager.instance.stopSession();
      } catch (e) {
        print('Error during custom write: $e');
        NfcManager.instance.stopSession(errorMessage: e.toString());
      }
    });
  }

  bool isTagWritable(NfcTag tag) {
    // Here you should implement the logic to verify if the tag is writable and supports NDEF
    return true; // Placeholder return value
  }

  Future<void> writeCustomDataToTag(NfcTag tag) async {
    // Check if the tag supports NDEF
    var ndef = Ndef.from(tag);
    if (ndef == null || !ndef.isWritable) {
      throw Exception('NDEF not supported or not writable');
    }

    var record = NdefRecord.createText('radi ');

    // Wrap the record in an NDEF message
    var message = NdefMessage([record]);

    // Write the message to the tag
    await ndef.write(message);
  }

  //include hive
  final myBox = Hive.box('UserInfo');

  //variables for fetching data
  String userName = ''; // Set an initial value until the data is fetched

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  //trying to fetch user data (in this case their name)
  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //trying to get the user uid from User Email collection and returns it as a string called userName
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('User Email')
            .doc(user.uid)
            .get();
        //if userDoc (document specific to each user) exists it sets the Name field as a string called name
        if (userDoc.exists) {
          String name = userDoc['Name'] as String;
          setState(() {
            userName = name;
          });
        } else {
          print('User document does not exist.');
        }
      } catch (error) {
        print('Error fetching user name: $error');
      }
    } else {
      print('No user is logged in.');
    }
  }

  bool usingKey = false;

  Future<void> toggleUsingKey() async {
    setState(() {
      usingKey = true;
    });

    openKeyCardDialog(
      context,
      onComplete: () {
        setState(() {
          usingKey = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.background,
        child: SingleChildScrollView(
          child: SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                //room key container
                InkWell(
                  onTap: () {
                    funckije() {
                      toggleUsingKey();
                      customNfcWrite();
                    }

                    funckije();
                  },
                  child: Opacity(
                    opacity: usingKey ? 0 : 1,
                    child: Container(
                      child: KeyCard(
                        height: 440,
                        topView: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // your room text
                            Text(
                              "Your Room",
                              style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),

                            //sized box
                            SizedBox(height: 20),

                            //room key text
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Container(
                                height: 75,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: isDarkMode
                                        ? Color.fromARGB(255, 15, 59, 100)
                                        : Colors.white),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Room Key",
                                        style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                      Text(
                                          "Touch the NFC sign with your mobile phone",
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                //sized box

                SizedBox(height: 20),

                //your rooms container
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    height: 75,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: isDarkMode
                            ? Color.fromARGB(255, 15, 59, 100)
                            : Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Rooms",
                            style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          Text("Select room to control smart devices",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                //your rooms container
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      //bedroom
                      RoomCard(
                        title: "Bedroom",
                        picture: "lib/assets/bedroom.jpg",
                        icon: Ionicons.bed,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BedroomController()));
                        },
                      ),

                      SizedBox(width: 20),

                      //bathroom
                      RoomCard(
                        title: "Bathroom",
                        picture: "lib/assets/bathroom.jpg",
                        icon: Icons.shower,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BathroomController(),
                              ));
                        },
                      ),

                      SizedBox(width: 20),

                      //living room

                      RoomCard(
                        title: "Living Room",
                        picture: "lib/assets/living_room.jpg",
                        icon: Ionicons.tv,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LivingRoomController()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
