class InputSanitizer {
  /// Sanitize text by removing potentially harmful characters
  static String sanitize(String input) {
    // Basic trimming
    String result = input.trim();
    
    // Remove null bytes
    result = result.replaceAll(RegExp(r'\x00'), '');
    
    // Simple XSS prevention (escaping HTML-like characters if they shouldn't be there)
    // Note: In Flutter/Dart, this is mostly relevant if the data is sent to a web backend
    // or displayed in a WebView.
    result = result.replaceAll('<', '&lt;')
                   .replaceAll('>', '&gt;')
                   .replaceAll('"', '&quot;')
                   .replaceAll("'", '&#x27;')
                   .replaceAll('/', '&#x2F;');
                   
    return result;
  }

  /// Sanitize for a specific purpose (e.g. numeric only)
  static String sanitizeNumeric(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Sanitize for a specific purpose (e.g. alphabetic only)
  static String sanitizeAlpha(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }
}
