import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:floorbot/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_API_KEY'),
    appId: dotenv.get('FIREBASE_APP_ID'),
    messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.get('FIREBASE_PROJECT_ID'),
  );

  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MyApp());
}
