/// Enumeration of supported string casing styles.
///
/// Used to specify how string identifiers (like XML element names, JSON keys, etc.)
/// should be transformed during serialization.
enum CaseStyle {
  /// No transformation - keep original casing
  /// Example: "userName" → "userName", "user_name" → "user_name"
  none,

  /// camelCase - first word lowercase, subsequent words capitalized
  /// Example: "user_name" → "userName", "User Name" → "userName"
  camelCase,

  /// PascalCase - first letter of each word capitalized
  /// Example: "user_name" → "UserName", "userName" → "UserName"
  pascalCase,

  /// snake_case - all lowercase with underscores
  /// Example: "userName" → "user_name", "User Name" → "user_name"
  snakeCase,

  /// kebab-case (param-case) - all lowercase with hyphens
  /// Example: "userName" → "user-name", "user_name" → "user-name"
  kebabCase;
}
