package com.ourstory.our_story_back.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ourstory.our_story_back.dto.request.NoteRequestDTO;
import com.ourstory.our_story_back.dto.request.NoteUpdateRequestDTO;
import com.ourstory.our_story_back.dto.response.NoteResponseDTO;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.service.NoteService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/notes")
@RequiredArgsConstructor
public class NoteController {
  private final NoteService noteService;

  @GetMapping
  public ResponseEntity<List<NoteResponseDTO>> getAllNotes() {
    List<NoteResponseDTO> notes = noteService.findAll();

    return ResponseEntity.ok(notes);
  }

  @GetMapping("/{id}")
  public ResponseEntity<NoteResponseDTO> getNoteById(@PathVariable Long id) {
    NoteResponseDTO note = noteService.findById(id);
    return ResponseEntity.ok(note);
  }

  @PostMapping
  public ResponseEntity<NoteResponseDTO> createNote(
      @AuthenticationPrincipal User currentUser,
      @Valid @RequestBody NoteRequestDTO noteRequestDTO
  ) {
    NoteResponseDTO note = noteService.save(currentUser, noteRequestDTO);
    return ResponseEntity.status(HttpStatus.CREATED).body(note);
  }

  @PutMapping("/{id}")
  public ResponseEntity<NoteResponseDTO> updateNote(@PathVariable Long id, @Valid @RequestBody NoteUpdateRequestDTO noteRequestDTO) {
    NoteResponseDTO note = noteService.update(id, noteRequestDTO);
    return ResponseEntity.ok(note);
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteNote(@PathVariable Long id) {
    noteService.deleteById(id);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/couples")
  public ResponseEntity<List<NoteResponseDTO>> getAllNotesByCouple(
    @AuthenticationPrincipal User currentUser
  ) {
    List<NoteResponseDTO> notes = noteService.findAllByCouple(currentUser);
    return ResponseEntity.ok(notes);
  }

  @PutMapping("/{id}/pinned")
  public ResponseEntity<Void> updatePinned(@PathVariable Long id) {
    noteService.setPinned(id);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/pinned")
  public ResponseEntity<List<NoteResponseDTO>> getPinnedNotes(
    @AuthenticationPrincipal User currentUser
  ) {
    List<NoteResponseDTO> notes = noteService.findPinnedNotes(currentUser);
    return ResponseEntity.ok(notes);
  }
}
