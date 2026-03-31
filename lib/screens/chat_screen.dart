import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ChatScreen({super.key, this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  bool loading = false;

  // ---------------------------
  // ✅ Send Message Function
  // ---------------------------
  Future<void> sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    setState(() => loading = true);

    final chatRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("chatMessages");

    // ✅ Save User Message
    await chatRef.add({
      "sender": "user",
      "text": text,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // ✅ Get Gemini Reply from Backend
    final api = Provider.of<ApiService>(context, listen: false);
    final reply = await api.chat(text);

    // ✅ Save Bot Reply
    await chatRef.add({
      "sender": "bot",
      "text": reply,
      "timestamp": FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);
  }

  // ---------------------------
  // ✅ Chat Stream
  // ---------------------------
  Stream<QuerySnapshot> chatStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("chatMessages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // ---------------------------
  // ✅ UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEFF),
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text("Support Companion "),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // ---------------------------
          // Messages List
          // ---------------------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index];
                    final isUser = msg["sender"] == "user";

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.deepPurple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          msg["text"],
                          style: TextStyle(
                            fontSize: 16,
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ---------------------------
          // Typing Indicator
          // ---------------------------
          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Companion is typing...",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),

          // ---------------------------
          // Input Box
          // ---------------------------
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Talk to your companion...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                loading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.deepPurple),
                        onPressed: sendMessage,
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
