import 'dart:convert';
import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:finalfrontproject/followersList.dart';
import 'package:finalfrontproject/followingList.dart';
import 'package:finalfrontproject/mainChild.dart';
import 'package:finalfrontproject/services/user_services.dart';
import 'package:finalfrontproject/yourpostList.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalfrontproject/childProfileEdit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finalfrontproject/childPost.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

TextEditingController profilePictureController = TextEditingController();
TextEditingController nameController = TextEditingController();

//to fetch photo&name
Future<Map<String, dynamic>> fetchUserData(String email) async {
  final response = await http
      .get(Uri.parse('http://192.168.1.112:3000/showchildprofile/$email'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user data');
  }
}

class childProfile extends StatefulWidget {
  @override
  _childProfileState createState() => _childProfileState();
}

Widget actionButton(
  IconData icon,
  String actionTitle,
  Color iconColor,
  VoidCallback onPressedCallback,
) {
  return Expanded(
    child: IconButton(
      onPressed: onPressedCallback,
      icon: Icon(
        icon,
        color: iconColor,
      ),
      tooltip: actionTitle,
    ),
  );
}

class _childProfileState extends State<childProfile> {
  File? myfile;
  File? myfile2;
  Emoji? selectedEmoji;
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    fetchUserData(UserServices.getEmail()).then((data) {
      setState(() {
        userData = data;
        String baseUrl = "http://192.168.1.112:3000";
        String imagePath = "uploads";
        String imageUrl =
            baseUrl + "/" + imagePath + "/" + userData['profilePicture'];
        nameController.text =
            userData.containsKey('name') ? userData['name'] : '';
        profilePictureController.text =
            userData.containsKey('profilePicture') ? imageUrl : '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 243, 192, 218),
                  Color.fromRGBO(205, 245, 250, 0.898),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Text(
            "BrainyBaddies",
            style: GoogleFonts.oswald(
              textStyle: TextStyle(
                color: Color.fromARGB(255, 55, 164, 241),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu),
              color: Color.fromARGB(255, 252, 50, 154),
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: selectedIndex,
          color: Color.fromARGB(255, 55, 164, 241),
          backgroundColor: Color.fromRGBO(205, 245, 250, 0.898),
          items: [
            Icon(
              Icons.home,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.message,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.logout,
              size: 30,
              color: Colors.white,
            )
          ],
          onTap: (value) {
            if (value == 0) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: mainChild(),
                ),
              );
            } else if (value == 1) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: childProfile(),
                ),
              );
            } else if (value == 2) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: childProfile(),
                ),
              );
            } else if (value == 3) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: childProfile(),
                ),
              );
            }
          },
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.white,
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 245, 245, 0.886),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: CircleAvatar(
                            radius: 74.0,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 60.0,
                              backgroundImage: myfile != null
                                  ? FileImage(myfile!)
                                  : profilePictureController.text.isNotEmpty
                                      ? NetworkImage(
                                              profilePictureController.text)
                                          as ImageProvider
                                      : AssetImage('images/background.gif')
                                          as ImageProvider,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 114, left: 70),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 55, 164, 241),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                              205, 245, 250, 0.898),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 55, 164, 241),
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                XFile? xfile =
                                                    await ImagePicker()
                                                        .pickImage(
                                                  source: ImageSource.gallery,
                                                );
                                                if (xfile != null) {
                                                  setState(() {
                                                    myfile = File(xfile.path);
                                                  });
                                                }
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "Choose Image From Gallery",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 55, 164, 241),
                                                    fontWeight: FontWeight
                                                        .bold, // Make the font style bold
                                                    fontFamily:
                                                        "MyCustomFont", // Set the custom font family
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                XFile? xfile =
                                                    await ImagePicker()
                                                        .pickImage(
                                                  source: ImageSource.camera,
                                                );
                                                if (xfile != null) {
                                                  setState(() {
                                                    myfile = File(xfile.path);
                                                  });
                                                }
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "Choose Image From Camera",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 55, 164, 241),
                                                    fontWeight: FontWeight
                                                        .bold, // Make the font style bold
                                                    fontFamily:
                                                        "MyCustomFont", // Set the custom font family
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 100,
                        right: 20,
                      ),
                      child: Text(
                        nameController
                            .text, // Display the text from nameController
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 55, 164, 241),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => childPost()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue[800],
                        minimumSize: Size(100, 40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_circle_rounded),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Add Post')
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => childProfileEdit()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        minimumSize: Size(100, 40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.edit),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Edit Your Profile')
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 250, // Adjust the height as needed
              child: SnappingList(),
            ),
          ])),
        ));
  }
}

//// Horizantal viewList
class listhorizant {
  final String imagePath;
  final String title;
  listhorizant(this.imagePath, this.title);
}

class SnappingList extends StatefulWidget {
  const SnappingList({Key? key}) : super(key: key);

  @override
  _SnappingListState createState() => _SnappingListState();
}

class _SnappingListState extends State<SnappingList> {
  List<listhorizant> productList = [
    listhorizant('images/post.jpg', 'Your Posts?'),
    listhorizant('images/followers.jpg', 'Your Followers?'),
    listhorizant('images/following.jpg', 'Who are you following?'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: 250,
      child: ScrollSnapList(
        itemBuilder: _buildListItem,
        itemCount: productList.length,
        itemSize: 150,
        onItemFocus: (index) {},
        dynamicItemSize: true,
      ),
    ));
  }

  Widget _buildListItem(BuildContext context, int index) {
    listhorizant product = productList[index];

    // Define routes for each item
    Map<String, Widget> itemRoutes = {
      'Your Posts?': yourpostList(),
      'Your Followers?': followersList(),
      'Who are you following?': followingList(),
    };

    return GestureDetector(
      onTap: () {
        String title = product.title;
        if (itemRoutes.containsKey(title)) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => itemRoutes[title]!));
        }
      },
      child: SizedBox(
        width: 150,
        height: 300,
        child: Card(
          elevation: 12,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Column(
              children: [
                Image.asset(
                  product.imagePath,
                  fit: BoxFit.cover,
                  width: 150,
                  height: 180,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
