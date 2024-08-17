
import "package:company_studio/screens/login_screen.dart";
import "package:flutter/material.dart";


class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginPage = true ;

  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginScreen(onTap: togglePages);

    }else{
      // return RegistrationScreen(onTap: togglePages);
      return LoginScreen(onTap: togglePages);
    }
  }
}
