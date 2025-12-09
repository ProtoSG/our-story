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

import com.ourstory.our_story_back.dto.request.CoupleRequestDTO;
import com.ourstory.our_story_back.dto.response.CoupleResponseDTO;
import com.ourstory.our_story_back.dto.response.CoupleSummaryResponseDTO;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.service.CoupleService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/couples")
@RequiredArgsConstructor
public class CoupleController {
  private final CoupleService coupleService;

  @GetMapping
  public ResponseEntity<List<CoupleResponseDTO>> getAllCouples() {
    return ResponseEntity.ok(coupleService.findAll());
  }

  @GetMapping("/{id}")
  public ResponseEntity<CoupleResponseDTO> getCoupleById(@PathVariable Long id) {
    CoupleResponseDTO couple = coupleService.findById(id);
    return ResponseEntity.ok(couple);
  }

  @PostMapping
  public ResponseEntity<CoupleResponseDTO> createCouple(@Valid @RequestBody CoupleRequestDTO coupleRequestDTO) {
    CoupleResponseDTO couple = coupleService.save(coupleRequestDTO);
    return ResponseEntity.status(HttpStatus.CREATED).body(couple);
  }

  @PutMapping("/{id}")
  public ResponseEntity<CoupleResponseDTO> updateCouple(@PathVariable Long id, @Valid @RequestBody CoupleRequestDTO coupleRequestDTO) {
    CoupleResponseDTO couple = coupleService.update(id, coupleRequestDTO);
    return ResponseEntity.ok(couple);
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteCouple(@PathVariable Long id) {
    coupleService.deleteById(id);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/summary")
  public ResponseEntity<CoupleSummaryResponseDTO> getCoupleSummary(
    @AuthenticationPrincipal User currentUser
  ) {
    CoupleSummaryResponseDTO couple = coupleService.findCoupleSummary(currentUser);
    return ResponseEntity.ok().body(couple);
  }

  @PutMapping("/image")
  public ResponseEntity<Void> updateCoupleImage(
    @AuthenticationPrincipal User currentUser,
    @RequestParam("file") MultipartFile file
  ) {
    coupleService.updateCoupleImage(currentUser, file);
    return ResponseEntity.noContent().build();
  }
}
