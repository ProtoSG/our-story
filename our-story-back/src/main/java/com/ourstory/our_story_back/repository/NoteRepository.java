package com.ourstory.our_story_back.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ourstory.our_story_back.entity.Note;

public interface NoteRepository extends JpaRepository<Note, Long> {
  List<Note> findByCoupleId(Long id);
  
  List<Note> findTop2ByCoupleIdAndIsPinnedTrueOrderByUpdatedAtDesc(Long coupleId);
}
