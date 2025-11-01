import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Replace with your OpenAI API key or leave empty for offline mode
  static const String _apiKey = ''; // Add your API key here (never commit this to Git!)
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Get AI suggestions for QR code content
  /// Returns null if API key is not configured or on error
  Future<String?> getAISuggestion(String prompt) async {
    if (_apiKey.isEmpty) {
      // Return offline suggestions
      return _getOfflineSuggestion(prompt);
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that suggests QR code content based on user prompts. Keep responses concise and practical.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return _getOfflineSuggestion(prompt);
      }
    } catch (e) {
      // Fallback to offline suggestions on error
      return _getOfflineSuggestion(prompt);
    }
  }

  /// Offline suggestions when API is not available
  String? _getOfflineSuggestion(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains('business') || lowerPrompt.contains('contact')) {
      return '''BEGIN:VCARD
VERSION:3.0
FN:John Doe
ORG:Your Company
TEL:+1234567890
EMAIL:contact@example.com
URL:https://example.com
END:VCARD''';
    }
    
    if (lowerPrompt.contains('wifi') || lowerPrompt.contains('network')) {
      return 'WIFI:T:WPA;S:NetworkName;P:Password123;;';
    }
    
    if (lowerPrompt.contains('event') || lowerPrompt.contains('meeting')) {
      return '''BEGIN:VEVENT
SUMMARY:Event Name
DTSTART:20240101T120000
DTEND:20240101T140000
LOCATION:Event Location
DESCRIPTION:Event Description
END:VEVENT''';
    }
    
    if (lowerPrompt.contains('url') || lowerPrompt.contains('website')) {
      return 'https://example.com';
    }
    
    if (lowerPrompt.contains('phone') || lowerPrompt.contains('call')) {
      return 'tel:+1234567890';
    }
    
    if (lowerPrompt.contains('email')) {
      return 'mailto:contact@example.com?subject=Hello&body=Message';
    }
    
    // Default suggestion
    return 'Example QR Code Content - Replace with your text';
  }

  /// Format text intelligently based on content type
  String formatQRContent(String input) {
    final trimmed = input.trim();
    
    // URL detection
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    
    // Phone detection
    if (RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(trimmed)) {
      if (!trimmed.startsWith('tel:')) {
        return 'tel:$trimmed';
      }
    }
    
    // Email detection
    if (RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(trimmed)) {
      if (!trimmed.startsWith('mailto:')) {
        return 'mailto:$trimmed';
      }
    }
    
    return trimmed;
  }
}

