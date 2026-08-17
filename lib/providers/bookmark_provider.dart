import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/circular_model.dart';

class BookmarksNotifier extends StateNotifier<List<CircularModel>> {
  BookmarksNotifier() : super([]);

  void toggleBookmark(CircularModel circular) {
    if (state.any((item) => item.id == circular.id)) {
      state = state.where((item) => item.id != circular.id).toList();
    } else {
      state = [...state, circular];
    }
  }

  bool isBookmarked(String id) {
    return state.any((item) => item.id == id);
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<CircularModel>>((ref) {
  return BookmarksNotifier();
});
