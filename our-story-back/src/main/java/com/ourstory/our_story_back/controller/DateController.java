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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.ourstory.our_story_back.dto.request.DateRequestDTO;
import com.ourstory.our_story_back.dto.response.DateResponseDTO;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.service.DateService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/dates")
@RequiredArgsConstructor
public class DateController {
  private final DateService dateService;

  @GetMapping
  public ResponseEntity<List<DateResponseDTO>> getAllDates() {
    return ResponseEntity.ok(dateService.findAll());
  }

  @GetMapping("/{id}")
  public ResponseEntity<DateResponseDTO> getDateById(@PathVariable Long id) {
    DateResponseDTO date = dateService.findById(id);
    return ResponseEntity.ok(date);
  }

  @PostMapping
  public ResponseEntity<DateResponseDTO> createDate(
    @AuthenticationPrincipal User currentUser,
    @Valid @RequestBody DateRequestDTO dateRequestDTO
  ) {
    DateResponseDTO date = dateService.save(currentUser, dateRequestDTO);
    return ResponseEntity.status(HttpStatus.CREATED).body(date);
  }

  @PutMapping("/{id}")
  public ResponseEntity<DateResponseDTO> updateDate(@PathVariable Long id, @Valid @RequestBody DateRequestDTO dateRequestDTO) {
    DateResponseDTO date = dateService.update(id, dateRequestDTO);
    return ResponseEntity.ok(date);
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteDate(@PathVariable Long id) {
    dateService.deleteById(id);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/couples")
  public ResponseEntity<List<DateResponseDTO>> getAllByCouple(
    @AuthenticationPrincipal User currentUser
  ) {
    List<DateResponseDTO> dates = dateService.findAllByCouple(currentUser);
    return ResponseEntity.ok(dates);
  }

  @GetMapping("/unranked")
  public ResponseEntity<DateResponseDTO> getLatestUnranked(
    @AuthenticationPrincipal User currentUser
  ) {
    DateResponseDTO date = dateService.findLatestUnranked(currentUser);

    if (date == null) {
      return ResponseEntity.noContent().build();
    }
    return ResponseEntity.ok(date);
  }

  @GetMapping("/recent")
  public ResponseEntity<List<DateResponseDTO>> getRecentRated(
    @AuthenticationPrincipal User currentUser
  ) {
    List<DateResponseDTO> dates = dateService.findRecentRated(currentUser);
    return ResponseEntity.ok(dates);
  }

  @PutMapping("/{id}/image")
  public ResponseEntity<Void> updateDateImage(
    @PathVariable Long id,
    @AuthenticationPrincipal User currentUser,
    @RequestParam("file") MultipartFile file
  ) {
    dateService.updateDateImage(id, currentUser, file);
    return ResponseEntity.noContent().build();
  }
}
