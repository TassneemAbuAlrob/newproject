//p2
import 'package:finalfrontproject/mainChild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finalfrontproject/Dashboard.dart';
import 'package:finalfrontproject/components/rounded_button.dart';
import 'package:finalfrontproject/constants.dart';
import 'package:finalfrontproject/screens/login/components/alreadyHaveAccout.dart';
import 'package:finalfrontproject/screens/login/components/background.dart';
import 'package:finalfrontproject/screens/login/components/roundedPassField.dart';
import 'package:finalfrontproject/screens/login/components/rounded_input_field.dart';
import 'package:finalfrontproject/screens/login/components/text_field_container.dart';
import 'package:finalfrontproject/services/user_services.dart';
import 'package:finalfrontproject/user.dart';
import 'package:http/http.dart' as http;

GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class body extends StatelessWidget {
  body({
    super.key,
  });
  User user = User('', ''); // Declare the user object here

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    User user = User('', '');
    return background(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 55, 164, 241),
                ),
              ),

              SvgPicture.asset(
                "android/icons/log1.svg",
                height: size.height * 0.5,
              ),

              RoundedInputField(
                hintText: "Your Email",
                onChanged: (value) {},
                user: user, // Pass the user object here
              ),

              RoundedPasswordField(
                onChanged: (value) {},
                user: user, // Pass the user object here
              ),
//--------------------------------------------
              RoundedButton(
                text: "LOG IN",
                color: Color.fromARGB(255, 141, 199, 241),
                press: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await UserServices.login(
                          email: user.email, password: user.password);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => mainChild()));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())));
                    }
                  } else {
                    print("not ok");
                  }
                },
              ),

//-----------------------------------
              AlreadyHaveAnAccountChecked(
                press: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
