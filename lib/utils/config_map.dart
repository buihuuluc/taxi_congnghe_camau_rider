import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/models/users.dart';

const apiKey = 'AIzaSyAms2bL5rKEOjZRRiSPyIzUIJbjA7TndEs';

User? firebaseUser;

Users? userCurrentInfo;

int driverRequestTimeout = 30;

String statusRide = "";

String rideStatus = "Xe dang toi";

String carDetailsDriver = "";

String driverName = "";

String driverphone = "";

double starCounter = 0.0;
String title = "";

String carRideType = "";

String serverToken ="key=AAAAv1LXKew:APA91bGsP-458FhIs-EGL9F91YyfD7tUKxXaUAA5VveRGFKF3npu2xgUkqghd8fq7sG5kYoS3kDpB5QEgDYST5OMGQJSae2zScXQdPUlrxMHG7fsV9KhNv2wqsyWZmUGZbcbzzwpWAyq";