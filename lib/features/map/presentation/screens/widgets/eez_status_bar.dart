import 'package:flutter/material.dart';

class FishingAlertBottomBar extends StatelessWidget {
  final bool isInFishingZone;

  const FishingAlertBottomBar({super.key, required this.isInFishingZone});

  Widget fishingZoneText(){
    if(isInFishingZone){
      
      return Text("You are fishing within legal boundaries. Stay compliant and fish responsibly!");
    }
    else if(!isInFishingZone){
      return Text("Alert: You are moving outside legal fishing boundaries. Return to comply with regulations.");
    }
    return Text("ERROR OCCURED");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30), 
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
      child: Row(
        children:[
          Icon(
            isInFishingZone ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: isInFishingZone ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 9.0),
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
