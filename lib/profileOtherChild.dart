import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalfrontproject/childProfileEdit.dart';
import 'package:finalfrontproject/childPost.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:mime/mime.dart';

TextEditingController profilePictureController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController textFieldController = TextEditingController();
File? myfile;
Dio dio = new Dio();
bool isCommentSectionVisible = false;
String selectedImagepath = " ";
final picker = ImagePicker();

class CommentSectionWidget extends StatefulWidget {
  final String postId;
  final String email; // Add this line

  CommentSectionWidget({required this.postId, required this.email});

  @override
  _CommentSectionWidgetState createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  TextEditingController commentController = TextEditingController();

  selectimagefromGallery() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display Existing Comments
        Container(
          height: 200, // Adjust the height as needed
        ),
        // Input Field for Adding New Comment
        ElevatedButton(
          onPressed: () async {
            selectedImagepath = await selectimagefromGallery();
            print("image path");
            print(selectedImagepath);
            if (selectedImagepath != null) {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image selected')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('NO Image selected')),
              );
            }
          },
          child: Text('Choose Image'),
        ),
        if (selectedImagepath != null && selectedImagepath.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2.0),
            ),
            child: Image.file(
              File(selectedImagepath),
              height: 100,
              width: 100,
            ),
          ),

// Input Field for Adding New Comment
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                  ),
                  controller: commentController,
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final newComment = commentController.text;

                  if (newComment.isNotEmpty || selectedImagepath != '') {
                    print("Comment or Image detected");

                    if (selectedImagepath != null) {
                      print("Image detected");
                      await postImageComment(widget.email, widget.postId,
                          newComment, selectedImagepath);
                    } else {
                      await postTextComment(
                          widget.email, widget.postId, newComment);
                    }

                    commentController.clear();
                    setState(() {
                      selectedImagepath = '';
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> addTextCommentToPost(
      String userEmail, String postId, String textComment) async {
    try {
      Response response = await dio.post(
        "http://192.168.1.112:3000/addComment/$postId",
        data: {
          "Textcomment": textComment,
          "email": userEmail,
        },
        options: Options(
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );

      if (response.statusCode == 201) {
        print("Text comment added successfully");
      } else {
        print('Text comment failed.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addImageCommentToPost(String userEmail, String postId,
      String textComment, String selectedImagepath) async {
    final String apiurl = "http://192.168.1.112:3000/addComment/$postId";
    Map<String, String> requestBody = {
      "Textcomment": textComment,
      'email': userEmail,
      "imagecomment": selectedImagepath,
    };
    final response = await http.post(
      Uri.parse(apiurl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
    if (response.statusCode == 201) {
      print("Text comment added successfully");
    } else {
      print('Text comment failed.');
    }
  }

  Future<void> postTextComment(
      String userEmail, String postId, String textComment) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Posting comment...')),
    );

    await addTextCommentToPost(userEmail, postId, textComment);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comment posted successfully')),
    );
  }

// Call this function when posting an image comment
  Future<void> postImageComment(String userEmail, String postId,
      String textComment, String selectedImagepath) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Posting comment...')),
    );

    await addImageCommentToPost(
        userEmail, postId, textComment, selectedImagepath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comment posted successfully')),
    );
  }
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

class profileOtherChild extends StatefulWidget {
  final String name;
  final String email;
  final String profilePicture;

  profileOtherChild({
    required this.name,
    required this.email,
    required this.profilePicture,
  });
  @override
  _profileOtherChildState createState() => _profileOtherChildState();
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

class _profileOtherChildState extends State<profileOtherChild> {
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.email).then((data) {
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
    fetchPosts(widget.email).then((data) {
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

  //added Like

  Future<void> addLikeToPost(String postId, String email) async {
    final String apiUrl = 'http://192.168.1.112:3000/addLike/$postId';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Like added successfully, show success dialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Success',
          desc: 'Your like was added successfully.',
          btnOkOnPress: () {
            // You can define an action when the user clicks OK
          },
        ).show();
      } else {
        // Handle other status codes if needed
      }
    } catch (e) {
      // Handle exceptions if needed
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

  // Function to fetch comments for a post
  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.112:3000/getComments/$postId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('comments') && data['comments'] is List) {
        final List<dynamic> commentsData = data['comments'];
        final List<Map<String, dynamic>> comments =
            commentsData.map((dynamic item) {
          return Map<String, dynamic>.from(item);
        }).toList();

        return comments;
      } else {
        return <Map<String, dynamic>>[];
      }
    } else {
      throw Exception('Failed to load comments');
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

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: Colors.white,
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
              const SizedBox(
                height: 40,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 40, 40, 41),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    print('Post: $post');

                    return Column(
                      children: [
                        Row(
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
                                  addLikeToPost(post['_id'], widget.email);
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
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isCommentSectionVisible = true;
                                  });
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
                            ),
                          ],
                        ),

                        // Display the comment section using Visibility widget
                        Visibility(
                          visible: isCommentSectionVisible,
                          child: CommentSectionWidget(
                              postId: post['_id'], email: widget.email),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
