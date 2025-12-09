package com.ourstory.our_story_back.service;

import java.util.List;

import com.ourstory.our_story_back.dto.request.NoteRequestDTO;
import com.ourstory.our_story_back.dto.request.NoteUpdateRequestDTO;
import com.ourstory.our_story_back.dto.response.NoteResponseDTO;
import com.ourstory.our_story_back.entity.User;

public interface NoteService {
  List<NoteResponseDTO> findAll();
  NoteResponseDTO findById(Long id);
  NoteResponseDTO save(User currentUser, NoteRequestDTO noteRequestDTO);
  NoteResponseDTO update(Long id, NoteUpdateRequestDTO noteRequestDTO);
  void deleteById(Long id);

  List<NoteResponseDTO> findAllByCouple(User currentUser);
  void setPinned(Long id);
  List<NoteResponseDTO> findPinnedNotes(User currentUser);
}
