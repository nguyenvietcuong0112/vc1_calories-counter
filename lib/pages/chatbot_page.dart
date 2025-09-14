
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_api_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;
  late final AiApiService _aiApiService;

  @override
  void initState() {
    super.initState();
    final generativeModel = FirebaseAI.vertexAI(auth: FirebaseAuth.instance)
        .generativeModel(model: 'gemini-1.5-flash');
    _aiApiService = AiApiService(generativeModel);
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _chatHistory.add({'user': userMessage});
        _isLoading = true;
      });

      final botResponse = await _aiApiService.getChatResponse(userMessage);

      setState(() {
        _chatHistory.add({'bot': botResponse});
        _isLoading = false;
      });

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                final isUserMessage = message.containsKey('user');
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Theme.of(context).primaryColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      isUserMessage ? message['user']! : message['bot']!,
                      style: GoogleFonts.poppins(
                        color: isUserMessage ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
