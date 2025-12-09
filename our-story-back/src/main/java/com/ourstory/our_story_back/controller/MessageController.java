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

import com.ourstory.our_story_back.dto.request.MessageRequestDTO;
import com.ourstory.our_story_back.dto.response.MessageResponseDTO;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.service.MessageService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/messages")
@RequiredArgsConstructor
public class MessageController {
  private final MessageService messageService;

  @GetMapping
  public ResponseEntity<List<MessageResponseDTO>> getAllMessages() {
    return ResponseEntity.ok(messageService.findAll());
  }

  @GetMapping("/{id}")
  public ResponseEntity<MessageResponseDTO> getMessageById(@PathVariable Long id) {
    MessageResponseDTO message = messageService.findById(id);
    return ResponseEntity.ok(message);
  }

  @PostMapping
  public ResponseEntity<MessageResponseDTO> createMessage(@Valid @RequestBody MessageRequestDTO messageRequestDTO) {
    MessageResponseDTO message = messageService.save(messageRequestDTO);
    return ResponseEntity.status(HttpStatus.CREATED).body(message);
  }

  @PutMapping("/{id}")
  public ResponseEntity<MessageResponseDTO> updateMessage(@PathVariable Long id, @Valid @RequestBody MessageRequestDTO messageRequestDTO) {
    MessageResponseDTO message = messageService.update(id, messageRequestDTO);
    return ResponseEntity.ok(message);
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteMessage(@PathVariable Long id) {
    messageService.deleteById(id);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/couples")
  public ResponseEntity<List<MessageResponseDTO>> getMessagesByCoupleId(
    @AuthenticationPrincipal User currentUser
  ) {
    List<MessageResponseDTO> messages = messageService.findByUser(currentUser);
    return ResponseEntity.ok(messages);
  }
}
