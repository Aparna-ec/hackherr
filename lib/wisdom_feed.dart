import 'package:flutter/material.dart';
import 'global_data.dart'; // <--- IMPORT SHARED DATA

class WisdomFeedScreen extends StatefulWidget {
  const WisdomFeedScreen({super.key});

  @override
  State<WisdomFeedScreen> createState() => _WisdomFeedScreenState();
}

class _WisdomFeedScreenState extends State<WisdomFeedScreen> {
  // We don't need the "Grandma Toggle" here anymore because 
  // the Grandma recording happens in the Chat Screen now.
  // This screen is JUST for viewing the Archive.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wisdom Archive"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey.shade50,
      
      // BUILD THE LIST FROM GLOBAL DATA
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        // Use globalStories instead of _stories
        itemCount: globalStories.length, 
        itemBuilder: (context, index) {
          final story = globalStories[index];
          bool isNew = story['status'] == "new";

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isNew ? Colors.blue.shade100 : Colors.grey.shade200,
                child: Icon(Icons.play_arrow, color: isNew ? Colors.blue : Colors.grey),
              ),
              title: Text(story['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${story['date']} • ${story['duration']}"),
              trailing: isNew 
                  ? const Chip(label: Text("New"), backgroundColor: Colors.orange, labelStyle: TextStyle(color: Colors.white, fontSize: 10))
                  : const Icon(Icons.check_circle, color: Colors.green, size: 16),
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Playing Audio...")));
              },
            ),
          );
        },
      ),
    );
  }
}