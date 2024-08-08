import 'package:flutter/material.dart';
import 'package:talk_box/utils/constants.dart';

class CustomCircleButton extends StatelessWidget {
  const CustomCircleButton({
    super.key,
    required this.icon,
    required this.color,
    this.size,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final Function()? onTap;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        elevation: 2,
        color: color,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                icon,
                color: AppColors.white,
              )),
        ),
      ),
    );
  }
}
