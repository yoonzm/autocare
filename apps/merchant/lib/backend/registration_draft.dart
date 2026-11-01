/// Holds input from the existing generated registration screens without
/// changing their layout or modifying generated page source.
class RegistrationDraft {
  static final Map<String, String> _fields = {};

  static void remember(String route, String hint, String initial) {
    if (route == 'RegPhone' || route == 'RegShop') {
      _fields.putIfAbsent('$route:$hint', () => initial);
    }
  }

  static void set(String route, String hint, String value) {
    if (route == 'RegPhone' || route == 'RegShop') {
      _fields['$route:$hint'] = value;
    }
  }

  static String get(String route, String hint) =>
      _fields['$route:$hint']?.trim() ?? '';

  static void clear() => _fields.clear();
}
