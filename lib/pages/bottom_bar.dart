import 'package:flutter/material.dart';

class FishingAlertBottomBar extends StatelessWidget {
  final bool isInFishingZone;

  const FishingAlertBottomBar({Key? key, required this.isInFishingZone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Fishing Zone Status",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),

          // Display warning or confirmation based on the fishing zone status
          Row(
            children: [
              Icon(
                isInFishingZone ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                color: isInFishingZone ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  isInFishingZone
                      ? "You are in an accessible fishing area."
                      : "⚠️ Warning: You are leaving the allowed fishing zone!",
                  style: TextStyle(
                    color: isInFishingZone ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12.0),

          // Confirm button (disabled if outside allowed fishing zone)
          ElevatedButton(
            onPressed: isInFishingZone ? () {
              // TODO: Handle location confirmation logic
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isInFishingZone ? Colors.blue : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              "Confirm Location",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
