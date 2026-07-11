import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
class MHomeAppbar extends StatelessWidget {
  const MHomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return MAppBar(
      centerTitle: false,
      titleSpacing: 8,
      leadingWidget: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow[700],
            ),
          ),
          Icon(
            CupertinoIcons.person_fill,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MColors.outline,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Jasir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            CupertinoIcons.settings,
            size: 35,
          ),
        ),
      ],
    );
  }
}
