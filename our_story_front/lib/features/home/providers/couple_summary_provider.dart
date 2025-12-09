import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/features/home/data/repositories/couple_summary_repository.dart';

final coupleSummaryRepositoryProvider =
  Provider<CoupleSummaryRepository>((ref) {
    return CoupleSummaryRepository();
  }
);

final coupleSummaryProvider = 
  FutureProvider((ref) async {
    final repository = ref.refresh(coupleSummaryRepositoryProvider);
    return repository.getMyCoupleSummary();
  }
);
