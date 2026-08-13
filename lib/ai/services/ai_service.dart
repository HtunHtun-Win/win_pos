import 'package:googleai_dart/googleai_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static const String _model = 'gemini-3.5-flash-lite';
  /*
  Gemini 3.5 Flash
  Gemini 3.5 Flash Lite :500
  Gemini 2.5 Flash
  Gemini 3.1 Flash Lite :500
  Gemini Embedding 1 : 1k
  Gemini Embedding 2 : 1k
  Gemma 4 26B : 14.4k
  Gemma 4 31B : 14.4k
  */

  Future<String> generateText(String prompt) async {
    await dotenv.load(fileName: ".env");
    String apiKey = dotenv.env['GOOGLE_GENAI_API_KEY']!;
    if (apiKey.isEmpty) {
      throw StateError(
        'Google AI API key is not configured. Pass '
        '--dart-define=GOOGLE_GENAI_API_KEY=YOUR_KEY when running the app.',
      );
    }

    final client = GoogleAIClient.withApiKey(apiKey);
    try {
      final response = await client.models.generateContent(
        model: _model,
        request: GenerateContentRequest(
          contents: [Content.text(prompt)],
        ),
      );
      final text = _extractText(response);
      return text.isEmpty ? 'No response generated.' : text;
    } finally {
      client.close();
    }
  }

  String _extractText(GenerateContentResponse response) {
    final candidates = response.candidates;
    if (candidates == null || candidates.isEmpty) {
      return '';
    }

    final content = candidates.first.content;
    if (content == null || content.parts.isEmpty) {
      return '';
    }

    return content.parts
        .whereType<TextPart>()
        .map((part) => part.text)
        .join(' ')
        .trim();
  }
}
