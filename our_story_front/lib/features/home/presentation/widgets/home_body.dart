import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';
import 'package:our_story_front/features/dates/data/models/date_model.dart';
import 'package:our_story_front/features/dates/data/providers/date_provider.dart';
import 'package:our_story_front/features/notes/data/models/note_model.dart';
import 'package:our_story_front/features/home/presentation/widgets/card_last_date.dart';
import 'package:our_story_front/features/home/presentation/widgets/recent_dates_section.dart';
import 'package:our_story_front/features/home/presentation/widgets/pinned_notes_section.dart';
import 'package:our_story_front/features/notes/data/providers/note_provider.dart';
import 'package:our_story_front/features/notes/presentation/add_edit_note_screen.dart';

import '../../../dates/presentation/add_edit_date_screen.dart';
import '../../../dates/presentation/date_detail_screen.dart';

class HomeBody extends ConsumerStatefulWidget {

  const HomeBody({
    super.key, 
  });

  @override
  ConsumerState<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<HomeBody> {

  void _navigateToEditDate(DateModel date) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDateScreen(date: date),
      ),
    );

    ref.invalidate(latestUnrankedDateProvider);
    ref.invalidate(recentRatedDatesProvider);
  }

  void _navigateToDateDetail(DateModel date) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => DateDetailScreen(date: date),
        fullscreenDialog: true,
      ),
    );

    ref.invalidate(latestUnrankedDateProvider);
    ref.invalidate(recentRatedDatesProvider);
  }

  void _navigateToAddDate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDateScreen(),
      ),
    );

    ref.invalidate(latestUnrankedDateProvider);
    ref.invalidate(recentRatedDatesProvider);
  }

  void _navigateToEditNote(NoteModel note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(note: note),
      ),
    );

    ref.invalidate(pinnedNotesProvider);
  }

  void _navigateToAddNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(),
      ),
    );

    ref.invalidate(pinnedNotesProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardLastDate(
            navigateToAddDate: _navigateToAddDate,
            navigateToEditDate: _navigateToDateDetail
          ),

          const SizedBox(height: 16),

          Text("Citas Recientes",
            style: AppTheme.heading2,
          ),

          const SizedBox(height: 8),

          RecentDatesSection(
            onDateTap: _navigateToDateDetail,
            onAddDateTap: _navigateToAddDate,
          ),

          const SizedBox(height: 16),

          Text("Notas Destacadas",
            style: AppTheme.heading2,
          ),

          const SizedBox(height: 8),

          PinnedNotesSection(
            onNoteTap: _navigateToEditNote,
            onAddNoteTap: _navigateToAddNote,
          ),
        ],
      ),
    );
  }
}
