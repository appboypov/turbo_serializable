import 'package:change_case/change_case.dart';

import 'package:turbo_serializable/enums/case_style.dart';

/// Converts a string to the specified case style.
///
/// Uses the `change_case` package for reliable case transformations.
/// Handles various input formats including camelCase, PascalCase, snake_case,
/// kebab-case, and mixed formats.
///
/// [input] - The string to convert
/// [caseStyle] - The target case style
///
/// Returns the converted string, or the original string if [caseStyle] is [CaseStyle.none].
String convertCase(String input, CaseStyle caseStyle) {
  if (input.isEmpty || caseStyle == CaseStyle.none) {
    return input;
  }

  switch (caseStyle) {
    case CaseStyle.none:
      return input;
    case CaseStyle.camelCase:
      return input.toCamelCase();
    case CaseStyle.pascalCase:
      return input.toPascalCase();
    case CaseStyle.snakeCase:
      return input.toSnakeCase();
    case CaseStyle.kebabCase:
      return input.toParamCase();
  }
}
