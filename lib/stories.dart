import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:finalfrontproject/mainchild.dart';
import 'package:finalfrontproject/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:finalfrontproject/childProfile.dart';
import 'package:finalfrontproject/childScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Map<String, dynamic> userData = {};
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

class stories extends StatefulWidget {
  @override
  _storiesState createState() => _storiesState();
}

class _storiesState extends State<stories> {
  File? myfile;

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
    var size = MediaQuery.of(context).size;

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
        leading: CircleAvatar(
          backgroundImage: myfile != null
              ? FileImage(myfile!)
              : profilePictureController.text.isNotEmpty
                  ? NetworkImage(profilePictureController.text) as ImageProvider
                  : AssetImage('images/background.gif') as ImageProvider,
          radius: 20,
          backgroundColor: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => childProfile()),
              );
            },
          ),
        ),
        title: Text(
          "BrainyBaddies",
          style: GoogleFonts.oswald(
            textStyle: TextStyle(
              color: Color.fromARGB(255, 55, 164, 241),
              fontSize: 25,
            ),
          ),
        ),
        centerTitle: true,
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
            Icons.notifications,
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
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/mainpage.jpg"),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: size.height * .1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headline4,
                        children: [
                          TextSpan(text: "What will we \nread "),
                          TextSpan(
                              text: "today?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        ReadingListCard(
                          image: "images/story1.jpg",
                          title: "Back To School",
                          rating: 4.9,
                          pressDetails: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) {
                            //        return DetailsScreen();
                            //     },
                            //   ),
                            // );
                          },
                          pressRead: () {},
                        ),
                        ReadingListCard(
                          image: "images/story2.jpg",
                          title: "Once Upon A Time",
                          rating: 4.8,
                          pressDetails: () {},
                          pressRead: () {},
                        ),
                        SizedBox(width: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//rating

class BookRating extends StatelessWidget {
  final double score;
  const BookRating({
    Key? key,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: Offset(3, 7),
            blurRadius: 20,
            color: Color(0xFD3D3D3).withOpacity(.5),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.star,
            color: Color(0xFFF48A37),
            size: 15,
          ),
          SizedBox(height: 5),
          Text(
            "$score",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

//rounded button

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final double verticalPadding;
  final double horizontalPadding;
  final double fontSize;

  RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.verticalPadding = 16,
    this.horizontalPadding = 30,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 16),
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 15),
              blurRadius: 30,
              color: Color(0xFF666666).withOpacity(.11),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

//cardList

class ReadingListCard extends StatelessWidget {
  final String image;
  final String title;
  final double rating;
  final VoidCallback pressDetails;
  final VoidCallback pressRead;

  const ReadingListCard({
    Key? key,
    required this.image,
    required this.title,
    required this.rating,
    required this.pressDetails,
    required this.pressRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 24, bottom: 40),
      height: 245,
      width: 202,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 221,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(29),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 33,
                    color: Color(0xFFD3D3D3).withOpacity(.84),
                  ),
                ],
              ),
            ),
          ),
          Image.asset(
            image,
            width: 150,
          ),
          Positioned(
            top: 35,
            right: 10,
            child: Column(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                  ),
                  onPressed: () {},
                ),
                BookRating(score: rating),
                IconButton(
                  icon: Icon(
                    Icons.info,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Positioned(
            top: 160,
            child: Container(
              height: 85,
              width: 202,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Row(children: <Widget>[
                    GestureDetector(
                      onTap: pressDetails,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 0),
                        width: 101,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                      ),
                    ),
                  ]),
                  Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: RichText(
                      maxLines: 2,
                      text: TextSpan(
                        style: TextStyle(color: Color(0xFF393939)),
                        children: [
                          TextSpan(
                            text: "$title\n",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
