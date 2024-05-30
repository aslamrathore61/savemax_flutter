import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircleAvatarWithDefaultImage extends StatelessWidget {
  final String imageUrl;
  final String defaultImageUrl;
  final double radius;
  final double borderWidth;
  final Color borderColor;

  CircleAvatarWithDefaultImage({
    required this.imageUrl,
    required this.defaultImageUrl,
    required this.radius,
    this.borderWidth = 2.0,
    this.borderColor = Colors.black45,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: imageUrl != '' ? CircleAvatar(
        radius: radius - borderWidth, // adjust for border width
        backgroundImage: NetworkImage(imageUrl),
      ) :  CircleAvatar(
        radius: radius - borderWidth, // adjust for border width
        backgroundImage: AssetImage(defaultImageUrl),
      ),
    );
  }
}
