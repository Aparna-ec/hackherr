import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // Needed for the listener
import 'home_screen.dart'; 
import 'guardian_screen.dart'; // Needed for the overlay

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // YOUR FIREBASE CONFIG
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBmaiOH5qBnvWf-LVNWFLCpRojH1KOuh3U",
      appId: "1:81222908587:web:9944bae597ed8d857415ee",
      messagingSenderId: "81222908587",
      projectId: "chethana-55ad9",
      databaseURL: "https://chethana-55ad9-default-rtdb.firebaseio.com",
      storageBucket: "chethana-55ad9.firebasestorage.app",
    ),
  );

  runApp(const ThanalApp());
}

class ThanalApp extends StatelessWidget {
  const ThanalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thanal Guardian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // 1. THIS IS THE MAGIC TRICK 🪄
      // The 'builder' allows us to wrap the ENTIRE app in a Stack.
      // 'child' is the normal screen you are looking at (Home, Chat, etc.)
      builder: (context, child) {
        return Stack(
          children: [
            // Layer 1: The Normal App
            if (child != null) child,

            // Layer 2: The Emergency Overlay (Always on top)
            const EmergencyOverlayLayer(), 
          ],
        );
      },
      home: const HomeScreen(), 
    );
  }
}

// 2. THE WATCHER WIDGET 👀
class EmergencyOverlayLayer extends StatefulWidget {
  const EmergencyOverlayLayer({super.key});

  @override
  State<EmergencyOverlayLayer> createState() => _EmergencyOverlayLayerState();
}

class _EmergencyOverlayLayerState extends State<EmergencyOverlayLayer> {
  // Listen to the status node directly
  final DatabaseReference _statusRef = FirebaseDatabase.instance.ref('thanal_device/status');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _statusRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        // If loading or error, hide the overlay (return nothing)
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const SizedBox.shrink();
        }

        String status = snapshot.data!.snapshot.value.toString();

        // 3. THE LOGIC
        // If SAFE, show NOTHING (SizedBox.shrink) so the user can use the app.
        // If ALERT or HELP, show the GuardianScreen on top of everything.
        if (status == "SAFE") {
          return const SizedBox.shrink(); 
        } else {
          // We wrap it in a Material widget because it sits above the Navigator
          return const Material(
            child: GuardianScreen(), 
          );
        }
      },
    );
  }
}