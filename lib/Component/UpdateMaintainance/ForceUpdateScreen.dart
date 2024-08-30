import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:savemax_flutter/Utils/constants.dart';

import '../buttons/socal_button.dart';

class ForceUpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0), // Equivalent to @dimen/activity_vertical_margin
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 28.0),
                child: Column(
                  children: [

                    SizedBox(height: 30,),
                    Image.asset(
                      width: 40,
                      height: 40,
                      'assets/icons/savemaxdoller.png', // Update this to your actual image path
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: 6,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Save Max',style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),),
                        Text(' Canada',style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),),
                      ],
                    ),

                  ],
                ),
              ),
            ),
           Expanded(
             flex: 1,
             child: Container(
               child: Lottie.asset(
                      'assets/lottie/force_update.json', // Update this to your actual Lottie file path
                      repeat: true,
                      animate: true,
                    ),
             ),
           ),

            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 14.0), // Equivalent to @dimen/_14sdp
                    child: Text(
                      'Update is available for Save Max', // Update this to your actual string resource
                      style: TextStyle(
                        fontSize: 20.0, // Equivalent to @dimen/_20sdp
                        color: Color(0xFF000000), // Equivalent to @color/dark
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Equivalent to @dimen/_8sdp
                    padding: EdgeInsets.all(8.0), // Equivalent to @dimen/_8sdp
                    child: Text(
                      'Newer, Better & Faster! Update now for improved performance, enhanced security, and exciting new features with the latest app version', // Update this to your actual string resource
                      style: TextStyle(
                        fontSize: 16.0, // Equivalent to @dimen/_16sdp
                        color: Color(0xFF000000), // Equivalent to @color/dark
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ],
              ),
            ),

            Container(
                margin: EdgeInsets.all(16.0), // Equivalent to @dimen/_16sdp
                child: SocalButton(
                  color: Colors.red.shade800,
                  icon: Icon(Icons.download,
                      color: Colors.white, size: 16),
                  press: () {
                   launchAppStore(context);
                  },
                  text: "UPDATE NOW".toUpperCase(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
