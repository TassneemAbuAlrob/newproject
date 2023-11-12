import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:finalfrontproject/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserDetailsPage extends StatefulWidget {
  final User user;

  UserDetailsPage({required this.user});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: NetworkImage(widget.user.profilePicture),
            ),
            SizedBox(height: 20),
            Text(
              widget.user.name,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class userList extends StatefulWidget {
  const userList({Key? key}) : super(key: key);

  @override
  State<userList> createState() => _HomePageState();
}

class _HomePageState extends State<userList> {
  late List<User> userList;
  bool isDataLoaded = false;
  String errorMessage = '';
  List<User> filteredUserList = [];

  Future<List<User>> getUsersFromAPI() async {
    Uri uri = Uri.parse(
        'http://192.168.1.112:3000/ListOfusers/${UserServices.getEmail() ?? ''}');
    var response = await http.get(uri);
    print("Follow User API Response: ${response.statusCode}");
    print("Response Body: ${response.body}");
    if (response.statusCode == 200) {
      // Successful response
      List<User> users = (json.decode(response.body) as List)
          .map((data) => User.fromJson(data))
          .toList();

      setState(() {
        isDataLoaded = true;
        userList = users;
      });
      return users;
    } else {
      errorMessage = '${response.statusCode}: ${response.body}';
      return [];
    }
  }

  callAPIandAssignData() async {
    userList = await getUsersFromAPI();
  }

  @override
  void initState() {
    callAPIandAssignData();
    super.initState();
  }

  void onSearch(String search) {
    setState(() {
      filteredUserList = userList
          .where(
              (user) => user.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    });

    if (filteredUserList.isEmpty) {
      // Show an Awesome Dialog when no results are found
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.SCALE,
        title: 'No Results Found',
        desc: 'No users match your search criteria.',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          // Clear the search text field when the dialog is dismissed
          clearSearch();
        },
      )..show();
    }
  }

  void clearSearch() {
    setState(() {
      // Clear the search text
      filteredUserList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Image.asset(
          'images/cover2.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Your existing content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 245, 220, 233),
            title: Container(
              height: 38,
              child: TextField(
                onChanged: (value) => onSearch(value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromRGBO(205, 245, 250, 0.898),
                  contentPadding: EdgeInsets.all(0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 252, 50, 154),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 252, 50, 154),
                  ),
                  hintText: "Search users",
                ),
              ),
            ),
          ),
          body: isDataLoaded
              ? errorMessage.isNotEmpty
                  ? Text(errorMessage)
                  : userList.isEmpty
                      ? const Text('No Data')
                      : ListView.builder(
                          itemCount: filteredUserList.isNotEmpty
                              ? filteredUserList.length
                              : userList.length,
                          itemBuilder: (context, index) => getUserRow(
                              index,
                              filteredUserList.isNotEmpty
                                  ? filteredUserList[index]
                                  : userList[index]),
                        )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }

  Widget getUserRow(int index, User user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(user: user),
          ),
        );
      },
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.profilePicture),
          ),
          title: Text(user.name),
          subtitle: Text(
              '${user.email}, ${user.phoneNumber ?? ""}'), // Use string interpolation here

          trailing: ElevatedButton(
            onPressed: () {
              if (user.isFollowing) {
                unfollowUser(user);
              } else {
                followUser(user);
              }
            },
            style: ElevatedButton.styleFrom(
              primary: user.isFollowing
                  ? Color.fromARGB(255, 252, 50, 154)
                  : Color.fromARGB(255, 55, 164, 241),
            ),
            child: Text(user.isFollowing ? 'Unfollow' : 'Follow'),
          )),
    );
  }

  Future<void> followUser(User user) async {
    try {
      Uri uri = Uri.parse(
          'http://192.168.1.112:3000/usersfollow/${UserServices.getEmail() ?? ''}');
      final response = await http.post(
        uri,
        body: {
          'followUserEmail': user.email,
          'follow': (!user.isFollowing).toString(),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          user.isFollowing = !user.isFollowing;
        });
      } else {
        // Handle the error here
      }
    } catch (error) {
      print("Follow User Error: $error");
    }
  }

  Future<void> unfollowUser(User user) async {
    try {
      Uri uri = Uri.parse(
          'http://192.168.1.112:3000/usersunfollow/${UserServices.getEmail() ?? ''}');
      final response = await http.delete(
        uri,
        body: {
          'followUserEmail': user.email,
          'follow': user.isFollowing ? 'true' : 'false',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          user.isFollowing = !user.isFollowing;
        });
      } else {
        // Handle the error here
      }
    } catch (error) {
      print("Unfollow User Error: $error");
    }
  }
}

class User {
  final String name;
  final String email;
  final String profilePicture;
  bool isFollowing;
  final int? phoneNumber;

  User({
    required this.name,
    required this.email,
    required this.profilePicture,
    this.isFollowing = false,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] as int?,
      profilePicture: json['profilePicture'] ?? '',
      isFollowing: json['isFollowing'] ?? false,
    );
  }
}
