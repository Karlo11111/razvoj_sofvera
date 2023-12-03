// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unnecessary_string_escapes, unused_element, dead_code, avoid_print, non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:razvoj_sofvera/Utilities/buttons.dart';
import 'package:razvoj_sofvera/Utilities/forward_button.dart';
import 'package:razvoj_sofvera/Utilities/setting_item.dart';
import 'package:razvoj_sofvera/Utilities/setting_switch.dart';
import 'package:razvoj_sofvera/pages/Edit_account_screen.dart';
import 'package:razvoj_sofvera/pages/help.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  //include hive
  final myBox = Hive.box('UserInfo');

  void NavigateToAccPage() {
    setState(() {});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditAccountScreen(refreshSettingsPage: NavigateToAccPage),
      ),
    );
  }

  bool isDarkMode = false;
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  //variables for fetching data
  String userName = ''; // Set an initial value until the data is fetched
  String userEmail = '';

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
          String email = userDoc['UserEmail'] as String;
          setState(() {
            myBox.put('username', name);
            myBox.put('email', email);
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

  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(isDarkMode
                    ? 'lib/assets/darkBackground.jpg'
                    : 'lib/assets/lightBackground.jpg'),
                fit: BoxFit.cover)),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Acc part

                  Text(
                    AppLocalizations.of(context)!.account,
                    style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary),
                  ),

                  Divider(
                    thickness: 1,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Image.asset(
                          "lib/assets/avatar.png",
                          width: 70,
                          height: 70,
                        ),
                        const SizedBox(
                          width: 20,
                        ),

                        //username&bio
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              myBox.get('username'),
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SingleChildScrollView(
                              child: Text(
                                myBox.get('email'),
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            )
                          ],
                        ),

                        //Acc button
                        const Spacer(),
                        ForwardButton(
                          onTap: NavigateToAccPage,
                        )
                      ],
                    ),
                  ),
                  //settings

                  const SizedBox(
                    height: 40,
                  ),

                  Text(AppLocalizations.of(context)!.app_settings,
                      style: GoogleFonts.inter(
                          fontSize: 30, fontWeight: FontWeight.w500)),

                  Divider(
                    thickness: 1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  //language

                  SettingItem(
                    title: AppLocalizations.of(context)!.language,
                    icon: Ionicons.earth,
                    bgColor: Colors.orange.shade100,
                    iconColor: Colors.orange,
                    value: "English",
                    onTap: () {},
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //notifications

                  SettingItem(
                    title: AppLocalizations.of(context)!.notifications,
                    icon: Ionicons.notifications,
                    bgColor: Colors.blue.shade100,
                    iconColor: Colors.blue,
                    onTap: () {},
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //dark theme

                  SettingSwitch(
                    title: AppLocalizations.of(context)!.dark_mode,
                    icon: Ionicons.moon_sharp,
                    bgColor: Colors.purple.shade100,
                    iconColor: Colors.purple,
                    value: isDarkMode,
                    onTap: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    AppLocalizations.of(context)!.support,
                    style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary),
                  ),

                  Divider(
                    thickness: 1,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  //help

                  SettingItem(
                    title: AppLocalizations.of(context)!.help,
                    icon: Ionicons.help,
                    bgColor: Colors.red.shade100,
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HelpPage()));
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SettingItem(
                    title: AppLocalizations.of(context)!.about,
                    icon: Ionicons.information_circle,
                    bgColor: Colors.green.shade100,
                    iconColor: Colors.green,
                    onTap: () {},
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  MyButton(
                      buttonText: AppLocalizations.of(context)!.sign_out,
                      ontap: signOut,
                      height: 55),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
