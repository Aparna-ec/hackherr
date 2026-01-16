import 'package:flutter/material.dart';
import 'guardian_screen.dart';
import 'wisdom_chat_screen.dart'; // We will create this next

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Thanal Family App"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome, Volunteer", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            
            // CARD 1: GUARDIAN (Safety)
            _buildDashboardCard(
              context,
              title: "Guardian Monitor",
              subtitle: "Live Fall Detection & Location",
              icon: Icons.health_and_safety,
              color: Colors.red.shade100,
              iconColor: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianScreen())),
            ),
            
            const SizedBox(height: 20),

            // CARD 2: WISDOM (Connection)
            _buildDashboardCard(
              context,
              title: "Wisdom Connection",
              subtitle: "Voice Chat & Story Archives",
              icon: Icons.record_voice_over,
              color: Colors.green.shade100,
              iconColor: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WisdomChatScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required Color iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}