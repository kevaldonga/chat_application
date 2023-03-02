extension CheckifEmpty on Map<String, List<String>> {
  bool get isReactionEmpty {
    bool result = true;
    forEach((key, value) {
      if (this[key]!.isNotEmpty) {
        result = false;
      }
    });
    return result;
  }

  bool get isReactionNotEmpty {
    bool result = false;
    forEach((key, value) {
      if (this[key]!.isNotEmpty) {
        result = true;
      }
    });
    return result;
  }
}
