import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MPriceInfoTextWithIcon extends StatelessWidget {
  const MPriceInfoTextWithIcon({
    super.key,
    required this.title,
    required this.amount,
    this.icon = CupertinoIcons.arrow_down,
  });

  final String title, amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white30,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 12,
              color: Colors.greenAccent,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),

            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
