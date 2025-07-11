class CircularListNavigator {
  final List<dynamic> list;
  int currentIndex;

  CircularListNavigator(this.list, {this.currentIndex = 0}) {
    if (list.isEmpty) {
      throw ArgumentError('List cannot be empty');
    }
    if (currentIndex < 0 || currentIndex >= list.length) {
      throw RangeError('currentIndex out of range');
    }
  }

  /// Get current element
  dynamic get current => list[currentIndex];

  /// Move forward circularly and return the new element
  dynamic next() {
    currentIndex = (currentIndex + 1) % list.length;
    return current;
  }

  /// Move backward circularly and return the new element
  dynamic previous() {
    currentIndex = (currentIndex - 1 + list.length) % list.length;
    return current;
  }
}
