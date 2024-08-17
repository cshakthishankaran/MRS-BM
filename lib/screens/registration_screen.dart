// import "package:company_studio/components/my_button.dart";
// import "package:company_studio/components/my_textfield.dart";
// import "package:flutter/material.dart";
//
// class RegistrationScreen extends StatefulWidget {
//
//   final void Function()? onTap;
//
//   const RegistrationScreen({super.key,required this.onTap});
//
//   @override
//   State<StatefulWidget> createState()=> _RegistrationScreenState();
// }
//
// class _RegistrationScreenState extends State<RegistrationScreen>{
//
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         body: Center(
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   //logo
//                   Icon(
//                     Icons.lock_open_rounded,
//                     size:100,
//                     color: Theme.of(context).colorScheme.inversePrimary,
//                   ),
//
//                   const SizedBox(height: 25,),
//
//                   Text(
//                     "Let's create an account for you",
//                     style: TextStyle(
//                         fontSize: 16,
//                         color: Theme.of(context).colorScheme.inversePrimary
//                     ),),
//
//                   //message , app slogan
//
//                   const SizedBox(height: 25,),
//
//
//                   MyTextField(
//                     controller: emailController,
//                     hintText: "Email",
//                     obscureText: false,
//                   ),
//                   // email textfield
//
//                   //password textfield
//                   //6:15
//                   //sign in button
//
//                   // not a member ? register now
//
//                   const SizedBox(height: 10,),
//
//                   MyTextField(
//                     controller: passwordController,
//                     hintText: "Password",
//                     obscureText: true,
//                   ),
//
//
//                   const SizedBox(height: 10,),
//
//                   MyTextField(
//                     controller: confirmPasswordController,
//                     hintText: "Confirm password",
//                     obscureText: false,
//                   ),
//
//                   const SizedBox(height: 10,),
//
//                   MyButton(text: "Sign Up",onTap: () {},),
//
//                   const SizedBox(height: 25,),
//
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Already have an account? ",
//                         style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
//                       ),
//                       const SizedBox(width: 4),
//                       GestureDetector(
//                         onTap: widget.onTap ,
//                         child :Text(
//                           "Login now",
//                           style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//
//                     ],
//                   )
//
//                 ]
//             )
//
//         )
//
//
//
//
//     );
//
//   }
// }