import 'package:flutter/material.dart';

class NoInternetConnectionPage extends StatefulWidget {
  final VoidCallback tryAgain;

  const NoInternetConnectionPage({
    Key? key,
    required this.tryAgain,
  }) : super(key: key);

  @override
  State<NoInternetConnectionPage> createState() => _NoInternetConnectionPageState();
}

class _NoInternetConnectionPageState extends State<NoInternetConnectionPage> {

  List<String> assetPaths = [
    'assets/images/dog_one.png',
    'assets/images/dog_two.png',
    'assets/images/dog_three.png',
  ];

  int count = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(top: 90),
              alignment: Alignment.center,
              child: Image.asset(
                assetPaths[count == 0 ? count : count-1], // Use count - 1 as index to access the correct asset path
                width: size.width - 110,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'OOPS!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                Text(
                  textAlign: TextAlign.center,
                  'NO INTERNET!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  textAlign: TextAlign.center,
                  'Please check your network connection',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      fixedSize: Size(size.width - 80, 45),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                    onPressed: () {

                      setState(() {
                        if (count == 3) {
                          count = 1; // Reset count to 1 when it reaches 3
                        } else {
                          count++;
                        }
                      });

                      widget.tryAgain();
                    },
                    child: const Text(
                      'TRY AGAIN',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
