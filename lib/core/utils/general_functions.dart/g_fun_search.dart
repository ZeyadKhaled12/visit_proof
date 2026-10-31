class GFunSearch {
  /// True when [query] is empty or appears in any of [fields] (case-insensitive).
  static bool matches(String query, List<String?> fields) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    return fields.any((field) => (field ?? '').toLowerCase().contains(text));
  }
}
