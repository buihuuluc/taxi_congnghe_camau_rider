import 'package:flutter/material.dart';

class ProgressDialogue extends StatelessWidget {
  final String message;

  const ProgressDialogue({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const SizedBox(
                width: 6.0,
              ),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(
                width: 26.0,
              ),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
