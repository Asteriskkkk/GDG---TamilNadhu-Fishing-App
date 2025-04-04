import 'package:flutter/material.dart';

class FishingAlertBottomBar extends StatelessWidget {
  final bool isInFishingZone;

  const FishingAlertBottomBar({super.key, required this.isInFishingZone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30), 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Row(
        children:[
          Icon(
            isInFishingZone ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: isInFishingZone ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              isInFishingZone
                  ? "You are in a safe fishing zone."
                  : "⚠️ Warning: You are leaving the allowed fishing zone!",
              style: TextStyle(
                color: isInFishingZone ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
