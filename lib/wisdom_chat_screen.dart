import 'package:flutter/material.dart';
import 'dart:async';
import 'global_data.dart'; // Import shared data
import 'wisdom_feed.dart'; // Import feed to navigate there

class WisdomChatScreen extends StatefulWidget {
  const WisdomChatScreen({super.key});

  @override
  State<WisdomChatScreen> createState() => _WisdomChatScreenState();
}

class _WisdomChatScreenState extends State<WisdomChatScreen> {
  // Chat History
  List<Map<String, dynamic>> _messages = [
    {"isMe": true, "type": "text", "text": "Grandma, I'd love to hear about the harvest festival.", "time": "10:05 AM"},
  ];

  // State
  TimeOfDay? _scheduledTime;
  bool _isRecording = false; // Tracks if we are currently recording
  bool _showGrandmaInterface = false; // THE MAGIC SWITCH
  Timer? _recordingTimer; // Timer to animate/stop recording

  // 1. SCHEDULE THE QUESTION
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() { _scheduledTime = picked; });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question Scheduled for ${picked.format(context)}"))
      );

      // DEMO HACK: Trigger the "Incoming Message" after 3 seconds
      Timer(const Duration(seconds: 3), () {
        _triggerIncomingQuestion();
      });
    }
  }

  // 2. SIMULATE THE "TIME ARRIVING"
  void _triggerIncomingQuestion() {
    setState(() {
      _showGrandmaInterface = true; // Switch UI to "Grandma Mode"
      _messages.add({
        "isMe": true, 
        "type": "audio_question", 
        "text": "Incoming Question: 'Tell me about Onam'", 
        "time": "Just Now"
      });
    });
  }

  // 3. START RECORDING (Tap 1)
  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    // Optional: Auto-stop after 10 seconds if they forget
    _recordingTimer = Timer(const Duration(seconds: 10), () => _stopAndSaveRecording());
  }

  // 4. STOP & SAVE (Tap 2)
  void _stopAndSaveRecording() {
    if (!_isRecording) return; // Already stopped

    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _showGrandmaInterface = false; // Close the panel
    });

    // Add to the Global List (The Simulation)
    setState(() {
      globalStories.insert(0, {
        "title": "Memories of Onam",
        "date": "Just Now",
        "duration": "1:20",
        "status": "new"
      });
    });

    // Show Success Dialog
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text("Story Saved!")]),
        content: const Text("Grandma's reply has been archived in the Wisdom Feed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              // Navigate to Archive to prove it!
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WisdomFeedScreen()));
            },
            child: const Text("Go to Archive", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showGrandmaInterface ? "🔴 Grandma's View" : "Volunteer Chat"),
        backgroundColor: _showGrandmaInterface ? Colors.red.shade100 : Colors.white,
        elevation: 0,
        actions: [
          if (!_showGrandmaInterface)
             IconButton(
              icon: const Icon(Icons.alarm_add, color: Colors.blue),
              onPressed: _pickTime,
              tooltip: "Schedule Question",
            )
        ],
      ),
      body: Column(
        children: [
          // CHAT AREA
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.record_voice_over, color: Colors.green),
                        const SizedBox(width: 10),
                        Flexible(child: Text(msg['text'])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INTERFACE SWITCHER
          if (_showGrandmaInterface) _buildGrandmaRecordingUI() else _buildVolunteerPlaceholder(),
        ],
      ),
    );
  }

  // --- THE UPDATED GRANDMA UI (TAP TO RECORD) ---
  Widget _buildGrandmaRecordingUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Incoming Question:", style: TextStyle(color: Colors.grey)),
          const Text("What is your favorite Onam Memory?", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          
          // --- NEW TAP-BASED MIC BUTTON ---
          GestureDetector(
            onTap: () {
              if (_isRecording) {
                _stopAndSaveRecording(); // Stop if running
              } else {
                _startRecording(); // Start if stopped
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isRecording ? 100 : 80, // Grows when recording
              width: _isRecording ? 100 : 80,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : Colors.green).withOpacity(0.5), 
                    blurRadius: _isRecording ? 30 : 10, // Glows when recording
                    spreadRadius: _isRecording ? 10 : 2
                  )
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic, // Icon changes
                color: Colors.white, 
                size: 40
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isRecording ? "Recording... (Tap to Stop)" : "Tap Mic to Reply", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: _isRecording ? Colors.red : Colors.black
            )
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text("Schedule a question above to start the demo.", style: TextStyle(color: Colors.grey)),
    );
  }
}