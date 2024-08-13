import 'dart:ffi';

import 'package:doorbell/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/button.dart'; // Import your custom button component
import 'package:flutter/cupertino.dart';
import '../components/splashSmallText.dart';
import '../components/textField.dart';
import 'startNeighbourhood.dart';


class StartPage extends StatefulWidget {
  StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();

}

class _StartPageState extends State<StartPage> {
  
  // Login textfield controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Signup textfield controllers
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();
  final TextEditingController signupPasswordConfirmController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  int _showWidgets = 1;
  bool _nextLogin = false;
  String _error = "";
  String _email = "";
  bool _isLoading = false;

  // username
  // password
  // password again

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32), // 16 is apple HIGs standard, lets do 32 for onboarding screens.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              const SizedBox(width: 44, height: 44, child: DecoratedBox(decoration: BoxDecoration( color: Colors.red),)), // ICON
              const SizedBox(height: 24),
              const Text('Stay Connected', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600, letterSpacing: -0.26)),
              const Text('Find your family\'s Neighbourhood', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600, letterSpacing: -0.26, height: 1.2, color: CupertinoColors.systemGrey)),
              const SizedBox(height: 24),
              const SizedBox( // Image
                width: double.infinity,
                height: 200,
                child: DecoratedBox(decoration: BoxDecoration( color: Colors.red))
              ),
              const SizedBox(height: 32),
              getWidgets(),
              const Spacer(flex: 3),
              
            ],
          ),
        ),
      ),
    );
  }

  // This function determines which controls are shown on the homepage, depending on wether the user wants to login or signup.
  Widget getWidgets() {
    if (_showWidgets == 1) { // Login and Sign Up Button
      return Column(
        children: [
          Button(
            text: 'Login',
            onPressed: () {
              setState(() {
                _showWidgets = 2;
              });
            },
          ),
          const SizedBox(height: 8),
          Button(
            text: 'Sign Up',
            onPressed: () {
              setState(() {
                _showWidgets = 3;
              });
            },
          ),
        ],
      );
    }
    else if (_showWidgets == 2) { // Login buttons
      return Form(
        key: _formKey,
        child: getLoginWidgets() // This function encapsulates the check username, check password, and authenticate functionality
      );
    }
    else if (_showWidgets == 3) { // Signup details
      return Form(
        key: _formKey,
        child: Column(
            children: [
              CustomTextField(placeholder: 'Enter your email address', controller: signupEmailController, isError: (_error != "")),
              const SizedBox(height: 8),
              CustomTextField(placeholder: 'Enter your password', controller: signupPasswordController, isPassword: true, isError: (_error != "")),
              const SizedBox(height: 8),
              CustomTextField(placeholder: 'Confirm your password', controller: signupPasswordConfirmController, isPassword: true, isError: (_error != "")),
              const SizedBox(height: 8),
              Button(
                text: 'Sign Up',
                isLoading: _isLoading,
                onPressed: () async {
                  activateLoading();

                  // is email address empty
                  if (signupEmailController.text.isEmpty) {
                    showError("Email address cannot be empty.");
                    deActivateLoading();
                  // is email a valid format
                  } else if (!isValidEmail(signupEmailController.text)) {
                    showError("That email doesn't look quite right, please try again.");
                    deActivateLoading();
                  // check passwords are not empty
                  } else if ( (signupPasswordController.text == "") | (signupPasswordConfirmController.text == "") ) {
                    showError('Password field is empty.');
                    deActivateLoading();
                  // check if passwords match
                  } else if (signupPasswordController.text != signupPasswordConfirmController.text) {
                    showError('Passwords do not match.');
                    deActivateLoading();
                  }
                  else {
                    bool result = await signup(signupEmailController.text, signupPasswordController.text);
                    deActivateLoading();

                    if (result == true) {
                      clearControllers();
                      clearError();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => StartNeighbourhoodPage())
                      );
                    } 
                  }
                  
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(width: double.infinity, height: 0.5, child: DecoratedBox(decoration: BoxDecoration( color: Colors.grey))),
              getSmallText(message: 'Already have an account?', widgetNumber: 1)
            ],
          )
      );
    }
    else if (_showWidgets == 5) { // Might need loading variants
      return const SizedBox(height: 16);
    } else {
      return const SizedBox(height: 16);
    }
  }

  // This function encapsulates the check username, check password, and authenticate functionality
  Widget getLoginWidgets() {
    if (_nextLogin == false) {
      return Column(
        children: [
          CustomTextField(placeholder: 'Enter your email address...', controller: loginEmailController, isError: (_error != ""),),
          const SizedBox(height: 8),
          Button(
            text: 'Next',
            isLoading: _isLoading,
            onPressed: () async {
              activateLoading();
              
              // is email address empty
              if (loginEmailController.text.isEmpty) {
                showError("Email address cannot be empty.");
                deActivateLoading();
              // is email a valid format
              } else if (!isValidEmail(loginEmailController.text)) {
                showError("That doesn't look quite right, please try again.");
                deActivateLoading();
              // if not, save email to a temp variable, clear the controller and go to next screen
              } else {
                //bool result = await checkUserExists(loginEmailController.text); TODO: add this function
                deActivateLoading();
                //if (result == true) {
                  _email = loginEmailController.text;
                  clearControllers();
                  clearError();
                  setState(() {
                    _nextLogin = true;
                  });
                //}
              }
            },
          ),
          const SizedBox(height: 16),
          const SizedBox(width: double.infinity, height: 0.5, child: DecoratedBox(decoration: BoxDecoration( color: Colors.grey))),
          getSmallText(message: 'Need to make an account?', widgetNumber: 1)
        ],
      );
    } else if (_nextLogin == true) {
      return Column(
          children: [
            CustomTextField(placeholder: 'Enter your password...', controller: loginPasswordController, isPassword: true, isError: (_error != "")),
            const SizedBox(height: 8),
            
            Button(
              text: 'Login',
              isLoading: _isLoading,
              onPressed: () async {
                activateLoading();

                // is password is empty
                if (loginPasswordController.text.isEmpty) {
                  showError("Password cannot be empty.");
                  deActivateLoading();
                // if not, try to login user
                } else {
                  bool result = await login(_email, loginPasswordController.text);
                  deActivateLoading();
                  
                  if (result == true) {
                    clearControllers();
                    clearError();
                    // If login is successful, navigate to the next page
                    // TODO: do checks here on user to make sure user has neighbourhood and house already
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => StartNeighbourhoodPage()),
                    );
                  }
                }
                },
            ),
            const SizedBox(height: 16),
            const SizedBox(width: double.infinity, height: 0.5, child: DecoratedBox(decoration: BoxDecoration( color: Colors.grey))),
            if (_error != "") // Error message
              SplashSmallText(
                text: _error,
                backOption: false,
                isError: true,
              ),
            SplashSmallText(
              text: 'Made a mistake?',
              onPressed: () {
                clearControllers();
                clearError();
                setState(() {
                  _nextLogin = false;
                });
              }
            ),
          ],
        );
    } else {
      return SizedBox();
    }
  }

  void showError(String message) {
    // Show an error message to the user
    setState(() {
      _error = message;
    });
  }

  void clearError() {
    setState(() {
      _error = "";
    });
  }

  void clearControllers() {
    loginEmailController.text = "";
    loginPasswordController.text = "";
    signupEmailController.text = "";
    signupPasswordController.text = "";
    signupPasswordConfirmController.text = "";
  }

  void activateLoading(){
    setState(() { 
      _isLoading = true;
    });
  }

  void deActivateLoading(){
    setState(() { 
      _isLoading = false;
    });
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  checkUserExists(String email) async { // TODO: Pending integration with FirebaseFirestore
    /*
    try {
    // if the size of value is greater then 0 then that doc exist. 
      await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get()
          .then((value) => value.size > 0 ? true : false);
    } catch (e) {
      debugPrint(e.toString());
     
    }
  */

  }

  // This function calls FirebaseAuth to authenticate the user
  login(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showError('No user found for that email.');
        return false;
      } else if (e.code == 'wrong-password') {
        showError('Wrong password provided.');
        return false;
      } 
      showError('An error occurred. Please try again.');
      return false;
    } catch (e) {
      showError('An error occurred. Please try again.');
      return false;
    }
  }


  // This function calls FirebaseAuth to create a new user
  signup(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showError('The password provided is too weak.');
        return false;
      } else if (e.code == 'email-already-in-use') {
        showError('The account already exists for that email.');
        return false;
      }
      showError('An error occurred. Please try again.');
      return false;
    } catch (e) {
      showError('An error occurred. Please try again.');
      return false;
    }
  }

  Widget getSmallText({required String message, int widgetNumber = 0}) {
    return Column(
      children: [
        if (_error != "") // Error message
          SplashSmallText(
            text: _error,
            backOption: false,
            isError: true,
          ),
        if (widgetNumber != 0)
          SplashSmallText( // Text at the bottom
            text: message,
            onPressed: () {
              clearControllers();
              clearError();
              setState(() {
                _showWidgets = widgetNumber;
              });
            }
          )
          else if (widgetNumber == 0)
            SplashSmallText( // Text at the bottom
              text: message,
              backOption: false,
            )
      ],
    );
  }
    

}

