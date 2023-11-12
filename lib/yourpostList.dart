import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:finalfrontproject/services/user_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;

TextEditingController profilePictureController = TextEditingController();
TextEditingController nameController = TextEditingController();

class yourpostList extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _yourpostListState createState() => _yourpostListState();
}

class _yourpostListState extends State<yourpostList> {
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

// Fetch posts for the specific email
    fetchPosts(UserServices.getEmail()).then((data) {
      setState(() {
        posts = data != null ? List<Map<String, dynamic>>.from(data) : [];
        // After fetching posts, fetch and update the like and comment counts for each post
        for (var post in posts) {
          fetchLikesCount(post['_id']).then((likeCount) {
            setState(() {
              post['likeCount'] = likeCount;
            });
          });
          fetchCommentCount(post['_id']).then((commentCount) {
            setState(() {
              post['commentCount'] = commentCount;
            });
          });
        }
      });
    });
  }

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

// Function to fetch posts
  Future<List<Map<String, dynamic>>?> fetchPosts(String email) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.112:3000/getPosts/$email'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> posts = [];

      for (dynamic item in data) {
        final Map<String, dynamic> post = Map<String, dynamic>.from(item);
        post['_id'] = post['_id'] as String;

        // Fetch likes for the post
        final likes = await fetchLikes(post['_id']);
        post['likeCount'] = likes!.length;

        // Fetch comments for the post and update the comment count
        final comments = await fetchComments(post['_id']);
        post['commentCount'] = comments.length;

        posts.add(post);
      }

      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

//likes count
  Future<int> fetchLikesCount(String postId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.112:3000/getLikesCount/$postId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final int likeCount = data['likeCount'];
      return likeCount;
    } else {
      throw Exception('Failed to load like count');
    }
  }

// Function to fetch post likes

  Future<List<Map<String, dynamic>>?> fetchLikes(String postId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.112:3000/getLikes/$postId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic>? likesData = data['likes'];

      if (likesData == null) {
        return <Map<String, dynamic>>[];
      }

      final List<Map<String, dynamic>> likes =
          likesData.cast<Map<String, dynamic>>();
      return likes;
    } else {
      throw Exception('Failed to load likes');
    }
  }

  // Function to fetch comments for a post
  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.112:3000/getComments/$postId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('comments')) {
          final List<dynamic> commentsData = data['comments'];
          final List<Map<String, dynamic>> comments =
              commentsData.map((dynamic item) {
            return Map<String, dynamic>.from(item);
          }).toList();

          return comments;
        } else {
          print('Invalid response format: $data');
          return <Map<String, dynamic>>[];
        }
      } else {
        throw Exception(
            'Failed to load comments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

// Function to fetch comment count for each post
  Future<int> fetchCommentCount(String postId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.112:3000/getcommentsCount/$postId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final int commentCount = data['commentCount'];
      return commentCount;
    } else {
      throw Exception('Failed to load comment count');
    }
  }

//delete post
  Future<bool> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.112:3000/deletePost/$postId'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  //fetch likes
  Future<void> showLikesDialog(String postId) async {
    List<Map<String, dynamic>>? likes = await fetchLikes(postId);

    TextStyle titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.pink),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('images/cover.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 7),
                child: likes!.isEmpty
                    ? Text(
                        '\n \t \t\t\t \t\t\t\t\t\t\t No one \n\n \t\t\t\t\thas liked this post yet!!',
                        style: titleStyle,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: likes.map((like) {
                          return Column(
                            children: [
                              Text('👤 ${like['username']}'),
                              SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 4),
              Text(
                'Likes List:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  //show comments
  Future<void> showCommentsDialog(
      String postId, Map<String, dynamic> post) async {
    // Fetch comments for the selected post
    final comments = await fetchComments(postId);

    TextStyle titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.pink),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('images/cover.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 7),
                child: comments.isEmpty
                    ? Text(
                        '\n \t \t\t\t \t\t\t\t\t\t\t No comments \n\n \t\t\t\t\thave been posted for this post yet!!',
                        style: titleStyle,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: comments.map((comment) {
                          return Column(
                            children: [
                              Text('👤 ${comment['username']}'),
                              if (comment['commentType'] == 'text')
                                Text(
                                  comment['comment'],
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              else if (comment['commentType'] == 'image')
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          FileImage(File(comment['comment'])),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.comment, color: Colors.blue),
              SizedBox(width: 4),
              Text(
                'Comments List:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 218, 218),
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
      body: SafeArea(
          child: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: AssetImage('images/post.jpg'),
                        fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient:
                          LinearGradient(begin: Alignment.bottomRight, colors: [
                        Colors.black.withOpacity(.4),
                        Colors.black.withOpacity(.2),
                      ])),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Your Post :",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: Center(
                            child: Text(
                          "Let's see What you Share :)",
                          style: TextStyle(
                              color: Color.fromARGB(255, 55, 164, 241),
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 40, 40, 41),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                      child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      print('Post: $post');

                      return Row(
                        children: [
                          Expanded(
                            flex: 8, // Takes 80% of the width
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PostContainer(
                                  post: post,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                final postId = post['_id'];

                                if (post['_id'] != null &&
                                    post['_id'] is String) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.WARNING,
                                    animType: AnimType.BOTTOMSLIDE,
                                    title: 'Confirm Deletion',
                                    desc:
                                        'Are you sure you want to delete this post?',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      // Call the deletePost function if the user confirms
                                      deletePost(postId).then((result) {
                                        if (result == true) {
                                          setState(() {
                                            posts.removeAt(index);
                                          });
                                        }
                                      });
                                    },
                                  )..show();
                                } else {
                                  print(
                                      'Invalid or missing Post ID: ${post['_id']}');
                                }
                              },
                              child: Icon(Icons.delete, color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                showLikesDialog(post['_id']);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.favorite, color: Colors.red),
                                  Text(
                                    post['likeCount'] != null
                                        ? post['likeCount'].toString()
                                        : '0',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1, // Takes 10% of the width
                            child: InkWell(
                              onTap: () {
                                showCommentsDialog(post['_id'], post);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.comment, color: Colors.blue),
                                  Text(
                                    post['commentCount'] != null
                                        ? post['commentCount'].toString()
                                        : '0',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  )))
            ],
          ),
        ),
      )),
    );
  }
}

///post

class PostContainer extends StatelessWidget {
  final Map<String, dynamic> post;

  PostContainer({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 9,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              // Align text to the left
              children: [
                if (post['Textcontent'] != null)
                  Text(
                    post['Textcontent'].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                if (post['imagecontent'] != null)
                  Image.network(
                      'http://192.168.1.112:3000/uploads/${post['imagecontent']}'),
                if (post['date'] != null)
                  Text(
                    formatDate(post['date']),
                    style: TextStyle(
                      fontSize: 10,
                      color: Color.fromARGB(255, 90, 163, 214),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String formatDate(String inputDate) {
    // Assuming the input date is in the format 'yyyy-MM-ddTHH:mm:ss'
    final DateTime dateTime = DateTime.parse(inputDate);

    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');

    final formattedDate = '$day-$month-$year $hour:$minute';

    return formattedDate;
  }
}
