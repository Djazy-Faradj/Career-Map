import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:career_map/screens/map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if(kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: "AIzaSyB95XvyXnF9ixkICBZagjfM5D4XVycLsjc",
      authDomain: "career-map-496ae.firebaseapp.com",
      projectId: "career-map-496ae",
      storageBucket: "career-map-496ae.firebasestorage.app",
      messagingSenderId: "169826265343",
      appId: "1:169826265343:web:d6c991ab1742609bbf04ca",
      measurementId: "G-ZFJCPP4HW8"
    ));
} else {
    await Firebase.initializeApp();
}
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ('Career Map'),
      theme: ThemeData.light(),
      home: Map(),
    );
  }
}
