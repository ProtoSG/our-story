import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/features/dates/data/models/date_model.dart';
import 'package:our_story_front/features/dates/data/repositories/date_repository.dart';

final dateRepositoryProvider =
  Provider<DateRepository>((ref) {
    return DateRepository();
  }
);

final latestUnrankedDateProvider =
  FutureProvider.autoDispose<DateModel?>((ref) async {
    final repository = ref.read(dateRepositoryProvider);
    return repository.getLatestUnrankedDate();
  }
);

final recentRatedDatesProvider =
  FutureProvider.autoDispose<List<DateModel>>((ref) async {
    final repository = ref.read(dateRepositoryProvider);
    return repository.getRecentRatedDates();
  }
);
