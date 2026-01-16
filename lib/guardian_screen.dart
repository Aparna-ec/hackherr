import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart'; // IMPORT THIS

class GuardianScreen extends StatefulWidget {
  const GuardianScreen({super.key});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('thanal_device');
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  
  // Blinking Logic
  bool _isRed = true;
  Timer? _blinkTimer;

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // --- FUNCTION TO OPEN GOOGLE MAPS ---
  Future<void> _openMap(double lat, double lng) async {
    // This URL format works on Android, iOS, and Web!
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    
    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch map');
    }
  }

  void _handleAlerts(String status) {
    if (status == "ALERT") {
      if (_blinkTimer == null || !_blinkTimer!.isActive) {
        _blinkTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
          setState(() { _isRed = !_isRed; });
        });
      }
      if (!_isPlaying) {
        _player.setReleaseMode(ReleaseMode.loop);
        _player.play(AssetSource('alarm.mp3'));
        _isPlaying = true;
      }
    } else {
      _blinkTimer?.cancel();
      _player.stop();
      _isPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
             return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          String status = data['status'].toString();
          
          // Get Location
          double lat = double.tryParse(data['lat'].toString()) ?? 10.0560;
          double lng = double.tryParse(data['lng'].toString()) ?? 76.6340;

          Future.microtask(() => _handleAlerts(status));

          if (status == "ALERT") {
            return _buildRedView(lat, lng);
          } else if (status == "HELP") {
            return _buildOrangeView(lat, lng);
          } else {
            return _buildGreenView();
          }
        },
      ),
    );
  }

  // --- 🚨 RED VIEW (FALL DETECTED) ---
  Widget _buildRedView(double lat, double lng) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: _isRed ? Colors.red.shade900 : Colors.red.shade500, // BLINKING
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.white),
          const SizedBox(height: 20),
          const Text("FALL DETECTED!", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Text("Loc: $lat, $lng", style: const TextStyle(fontSize: 18, color: Colors.white70)),
          
          const SizedBox(height: 50),
          
          // BUTTON 1: OPEN MAP
          ElevatedButton.icon(
            onPressed: () => _openMap(lat, lng), // <--- OPENS GOOGLE MAPS
            icon: const Icon(Icons.map, color: Colors.blue),
            label: const Text("TRACK LIVE LOCATION"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 20),

          // BUTTON 2: RESPOND
          ElevatedButton.icon(
            onPressed: () => _dbRef.child('status').set("SAFE"),
            icon: const Icon(Icons.check_circle, color: Colors.red),
            label: const Text("MARK AS RESOLVED"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          )
        ],
      ),
    );
  }

  // --- 🟠 ORANGE VIEW (NEED HELP) ---
  Widget _buildOrangeView(double lat, double lng) {
    return Container(
      color: Colors.orange.shade800,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.volunteer_activism, size: 100, color: Colors.white),
          const SizedBox(height: 20),
          const Text("ASSISTANCE NEEDED", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text("Grandma requested help", style: TextStyle(fontSize: 18, color: Colors.white70)),
          
          const SizedBox(height: 50),
          
          ElevatedButton.icon(
            onPressed: () => _openMap(lat, lng), // <--- OPENS MAP HERE TOO
            icon: const Icon(Icons.directions, color: Colors.orange),
            label: const Text("NAVIGATE TO HOUSE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
           const SizedBox(height: 20),
           TextButton(
             onPressed: () => _dbRef.child('status').set("SAFE"),
             child: const Text("Cancel Request", style: TextStyle(color: Colors.white70)),
           )
        ],
      ),
    );
  }
  
  Widget _buildGreenView() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text("Status: Normal", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("(Tap screen once to enable audio)", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}