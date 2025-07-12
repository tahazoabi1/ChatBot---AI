import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple wrapper that talks to the local Ollama server on Windows.
class LocalLlmService {
  static const _url = 'http://127.0.0.1:11434/api/chat';
  static const _model = 'phi3'; // pulled earlier with `ollama pull phi3`

  Future<String> ask({
    required String question,
    required bool examMode,
  }) async {
    // Build the system prompt based on mode
    final systemPrompt = examMode
        ? 'You are a strict exam assistant. Only give minimal guidance. Do not give away answers, just clarify and guide.'
        : 'You are a helpful and friendly tutor bot for students. Answer naturally and clearly, in the same language as the user.';

    final res = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': _model,
        'stream': false,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': question}
        ]
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('LLM error ${res.statusCode}: ${res.body}');
    }
    return (jsonDecode(res.body)['message']['content'] as String).trim();
  }

  String _buildPrompt(String q, bool exam) => q;

//   String _buildPrompt(String q, bool exam) => exam
//       ? '''
// You are ExamHelperBot.
// - Do NOT reveal the full answer.
// - Break down what the question asks.
// - Give hints only.

// Question: $q
// '''
//       : '''
// You are TutorBot.
// 1. Explain clearly in simple words.
// 2. Break the reasoning into stages.
// 3. Provide a concrete worked example.

// Question: $q
// ''';
// }
}
