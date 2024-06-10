import 'package:flutter/material.dart';

import '../Utils/constants.dart';

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
          Container(
              height: 58,
              width: double.infinity,
              color: greyColor,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/icons/savemaxdoller.png',
                      width: 27,
                      height: 27,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(top: 8, bottom: 8),
                      height: double.infinity,
                      color: Colors.white,
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              Icons.location_on,
                              size: 17,
                            ),
                          ),
                          Text(
                            'Toronto',
                            style: TextStyle(fontSize: 13),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                      ),
                      height: double.infinity,
                      color: darkGreyColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                            EdgeInsets.only(left: 10.0, right: 6.0),
                            child: Icon(Icons.close, size: 16),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6.0, right: 10.0),
                            child: Icon(
                              Icons.search,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                      flex: 0,
                      child: SizedBox(
                        width: 33,
                      )),
                ],
              )),
          Expanded(
            flex: 2,
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 2.0,right: 2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'OOPS!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      'NO INTERNET!',
                      style: TextStyle(
                          fontSize: 19,
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
