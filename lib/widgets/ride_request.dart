import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/utils/constants.dart';

class RideRequest extends StatefulWidget {
  const RideRequest(
      {Key? key,
      required this.requestRideContainerHeight,
      required this.cancelOnPressed,
      required this.resetOnpressed})
      : super(key: key);
  final double requestRideContainerHeight;
  final VoidCallback cancelOnPressed;
  final VoidCallback resetOnpressed;

  @override
  _RideRequestState createState() => _RideRequestState();
}

class _RideRequestState extends State<RideRequest> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 16.0,
              spreadRadius: 0.5,
              color: Colors.black,
              offset: Offset(0.7, 0.7),
            ),
          ],
        ),
        height: widget.requestRideContainerHeight,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(
                height: 12.0,
              ),
              SizedBox(
                width: double.infinity,
                child: AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Đang Yêu Cầu',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                      textAlign: TextAlign.center,
                    ),
                    ColorizeAnimatedText(
                      'Vui lòng đợi',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                      textAlign: TextAlign.center,
                    ),
                    ColorizeAnimatedText(
                      'Đang tìm tài xế',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  isRepeatingAnimation: true,
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
              const SizedBox(
                height: 22.0,
              ),
              GestureDetector(
                onTap: () {
                  widget.cancelOnPressed();
                  widget.resetOnpressed();
                },
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 2.0,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(26.0),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 26.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Ngừng tìm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
