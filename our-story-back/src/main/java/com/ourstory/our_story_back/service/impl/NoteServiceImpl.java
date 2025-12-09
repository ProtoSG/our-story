package com.ourstory.our_story_back.service.impl;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.ourstory.our_story_back.dto.request.NoteRequestDTO;
import com.ourstory.our_story_back.dto.request.NoteUpdateRequestDTO;
import com.ourstory.our_story_back.dto.response.NoteResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.Note;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.mapper.NoteMapper;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.NoteRepository;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.NoteService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class NoteServiceImpl implements NoteService {
  private final NoteRepository noteRepository;
  private final NoteMapper noteMapper;
  private final CoupleRepository coupleRepository;
  private final UserRepository userRepository;

  @Override
  public List<NoteResponseDTO> findAll() {
    return noteRepository.findAll().stream()
      .map(noteMapper::toResponseDTO)
      .collect(Collectors.toList());
  }

  @Override
  public NoteResponseDTO findById(Long id) {
    Note note = noteRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
    return noteMapper.toResponseDTO(note);
  }

  @Override
  public NoteResponseDTO save(User currentUser, NoteRequestDTO noteRequestDTO) {
    User user = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    Couple couple = coupleRepository.findByUserId(user.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Note not found"));

    Note note = noteMapper.toEntity(noteRequestDTO);
    note.setCouple(couple);
    note.setCreatedBy(user);

    Note savedNote = noteRepository.save(note);
    return noteMapper.toResponseDTO(savedNote);
  }

  @Override
  public NoteResponseDTO update(Long id, NoteUpdateRequestDTO noteRequestDTO) {
    Note existingNote = noteRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
    existingNote.setTitle(noteRequestDTO.getTitle());
    existingNote.setColor(noteRequestDTO.getColor());
    existingNote.setContent(noteRequestDTO.getContent());
    existingNote.setIsPinned(noteRequestDTO.getIsPinned());
    existingNote.setSticker(noteRequestDTO.getSticker());
    Note updatedNote = noteRepository.save(existingNote);
    return noteMapper.toResponseDTO(updatedNote);
  }

  @Override
  public void deleteById(Long id) {
    noteRepository.deleteById(id);
  }

  @Override
  public List<NoteResponseDTO> findAllByCouple(User currentUser) {
    User user = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    Couple couple = coupleRepository.findByUserId(user.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Note not found"));

    List<Note> notes = noteRepository.findByCoupleId(couple.getId());
    return notes.stream()
      .map(noteMapper::toResponseDTO)
      .toList();
  }

  @Override
  public void setPinned(Long id) {
    Note note = noteRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Note not found"));

    Boolean isPinned = note.getIsPinned();
    note.setIsPinned(isPinned == null || !isPinned);
    noteRepository.save(note);
  }

  @Override
  public List<NoteResponseDTO> findPinnedNotes(User currentUser) {
    User user = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    Couple couple = coupleRepository.findByUserId(user.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Couple not found"));

    List<Note> notes = noteRepository
      .findTop2ByCoupleIdAndIsPinnedTrueOrderByUpdatedAtDesc(couple.getId());

    return notes.stream()
      .map(noteMapper::toResponseDTO)
      .toList();
  }

}
