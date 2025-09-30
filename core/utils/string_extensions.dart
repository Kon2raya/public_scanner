extension PascalCaseExtension on String {
  String toPascalCase() {
    return split(RegExp(r'\s+|_+|-+'))
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()} ',
        )
        .join();
  }
}
