// ignore_for_file: prefer_const_constructors

//blue low color: Color.fromARGB(228, 205, 245, 250),
//pinklow Color.fromARGB(255, 253, 169, 213)
//pinkhigh Color.fromARGB(255, 252, 50, 154),
//blue high Color.fromARGB(255, 55, 164, 241)
//grey Color.fromARGB(255, 230, 230, 230)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

final TextEditingController fullNameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController phoneNumberController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();

String selectedProfileType = 'child'; // Initialize with a default value

class RegScreen extends StatefulWidget {
  const RegScreen({Key? key}) : super(key: key);

  @override
  _RegScreenState createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000), // Adjust the duration as needed
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Trigger the animation after a delay (e.g., 1 second)
    Future.delayed(Duration(seconds: 1), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showRegistrationSnackbar(String message, Color backgroundColor) {
    Get.snackbar(
      "Registration",
      message,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Positioned(
                    // top: 50.0,
                    left: 12, right: 12,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 25),
                        height: 85,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(255, 55, 164, 241),
                              width: 2,
                            ),
                            color: Color.fromARGB(228, 205, 245, 250),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            )),
                        child: Text(
                          'Create Your Account',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.paprika(
                            fontSize: 23,
                            color: Color.fromARGB(255, 55, 164, 241),
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(
                                color: Color.fromARGB(191, 158, 158, 158),
                                offset: Offset(2, 2),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        )),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: _animation.value * 100.0,
                          bottom: _animation.value * 60.0,
                          left: _animation.value * 25.0,
                          right: _animation.value * 25.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color.fromARGB(228, 205, 245, 250),
                              border: Border.all(
                                color: Color.fromARGB(255, 55, 164, 241),
                                width: 2,
                              )),
                          // height: double.infinity,
                          // width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            // child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: fullNameController,
                                  style: GoogleFonts.mada(
                                    color: Colors.grey,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    labelStyle: GoogleFonts.mada(
                                      color: Color.fromARGB(191, 158, 158, 158),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Color.fromARGB(191, 158, 158, 158),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(191, 158, 158, 158),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    fillColor:
                                        Color.fromARGB(255, 230, 230, 230),
                                    filled: true,
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: emailController,
                                  style: GoogleFonts.mada(
                                    color: Color.fromARGB(191, 158, 158, 158),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: GoogleFonts.mada(
                                      color: Color.fromARGB(191, 158, 158, 158),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email, // Add your email icon here
                                      color: Color.fromARGB(191, 158, 158, 158),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(191, 158, 158, 158),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    fillColor:
                                        Color.fromARGB(255, 230, 230, 230),
                                    filled: true,
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: phoneNumberController,
                                  style: GoogleFonts.mada(
                                    color: Color.fromARGB(191, 158, 158, 158),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    labelStyle: GoogleFonts.mada(
                                      color: Color.fromARGB(191, 158, 158, 158),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Color.fromARGB(191, 158, 158, 158),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(191, 158, 158, 158),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    fillColor:
                                        Color.fromARGB(255, 230, 230, 230),
                                    filled: true,
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: passwordController,
                                  style: GoogleFonts.mada(
                                    color: Color.fromARGB(191, 158, 158, 158),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    labelText: 'Password',
                                    labelStyle: GoogleFonts.mada(
                                      color: Color.fromARGB(191, 158, 158, 158),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock, // Add your password icon here
                                      color: Color.fromARGB(191, 158, 158, 158),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(191, 158, 158, 158),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    fillColor:
                                        Color.fromARGB(255, 230, 230, 230),
                                    filled: true,
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: confirmPasswordController,
                                  style: GoogleFonts.mada(
                                    color: Color.fromARGB(191, 158, 158, 158),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    labelText: 'Confirm Password',
                                    labelStyle: GoogleFonts.mada(
                                      color: Color.fromARGB(191, 158, 158, 158),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    prefixIcon: Icon(
                                      Icons
                                          .lock, // Add your confirm password icon here
                                      color: Color.fromARGB(191, 158, 158, 158),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(191, 158, 158, 158),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    fillColor:
                                        Color.fromARGB(255, 230, 230, 230),
                                    filled: true,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top:
                                                15.0), // Adjust the padding as needed
                                        child: Text(
                                          'Profile Type:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 55, 164, 241),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Radio<String>(
                                      activeColor:
                                          Color.fromARGB(191, 158, 158, 158),
                                      value: 'child',
                                      groupValue: selectedProfileType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedProfileType = value!;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Child',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromARGB(255, 55, 164, 241),
                                        fontSize: 15,
                                      ),
                                    ),
                                    Radio<String>(
                                      activeColor:
                                          Color.fromARGB(191, 158, 158, 158),
                                      value: 'parent',
                                      groupValue: selectedProfileType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedProfileType = value!;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Parent',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromARGB(255, 55, 164, 241),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Container(
                                    width: 100,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 230, 230, 230),
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(35),
                                          topRight: Radius.circular(35),
                                          bottomLeft: Radius.circular(35),
                                          bottomRight: Radius.circular(35)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                                  116, 134, 100, 136)
                                              .withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(10,
                                              10), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    margin: const EdgeInsets.only(
                                        left: 60, right: 60, bottom: 20),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final fullName =
                                            fullNameController.text;
                                        final email = emailController.text;
                                        final phoneNumber =
                                            phoneNumberController.text;
                                        final password =
                                            passwordController.text;
                                        final confirmPassword =
                                            confirmPasswordController.text;

                                        // Regular expression to check for a valid email format
                                        final emailRegExp = RegExp(
                                            r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

                                        if (fullName.isEmpty ||
                                            !emailRegExp.hasMatch(
                                                email) || // Check email format
                                            phoneNumber.isEmpty ||
                                            password.isEmpty ||
                                            confirmPassword.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Please fill in all fields with valid data'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        // Check if the passwords match
                                        if (password != confirmPassword) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Passwords do not match'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        final response = await http.post(
                                          Uri.parse(
                                              'http://192.168.1.112:3000/signup'),
                                          headers: {
                                            'Content-Type': 'application/json'
                                          },
                                          body: jsonEncode({
                                            'name': fullName,
                                            'email': email,
                                            'phoneNumber': phoneNumber,
                                            'password': password,
                                            'confirmPassword': confirmPassword,
                                            'profileType': selectedProfileType,
                                          }),
                                        );

                                        if (response.statusCode == 201) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Registration successful'),
                                              backgroundColor: Color.fromARGB(
                                                  213, 46, 247, 76),
                                            ),
                                          );

                                          // Clear the text fields
                                          fullNameController.text = '';
                                          emailController.text = '';
                                          phoneNumberController.text = '';
                                          passwordController.text = '';
                                          confirmPasswordController.text = '';
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Registration failed'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary:
                                            Color.fromARGB(255, 192, 234, 248),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 55, 164, 241),
                                              width: 1.5),
                                        ),
                                      ),
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color:
                                              Color.fromARGB(255, 55, 164, 241),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )));
  }
}
