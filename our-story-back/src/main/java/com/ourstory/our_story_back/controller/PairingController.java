package com.ourstory.our_story_back.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ourstory.our_story_back.dto.request.SendPairingRequestDTO;
import com.ourstory.our_story_back.dto.request.VerifyPairingCodeDTO;
import com.ourstory.our_story_back.dto.response.CoupleResponseDTO;
import com.ourstory.our_story_back.dto.response.PairingResponseDTO;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.PairingService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/pairing")
@RequiredArgsConstructor
public class PairingController {

  private final PairingService pairingService;
  private final UserRepository userRepository;

  @PostMapping("/send")
  public ResponseEntity<PairingResponseDTO> sendPairingRequest(
    @Valid @RequestBody SendPairingRequestDTO request,
    @AuthenticationPrincipal User currentUser
  ) {
    // Long currentUserId = getCurrentUserId();
    PairingResponseDTO response = pairingService.sendPairingRequest(currentUser, request);
    return ResponseEntity.status(HttpStatus.CREATED).body(response);
  }

  @PostMapping("/verify")
  public ResponseEntity<CoupleResponseDTO> verifyPairingCode(
      @Valid @RequestBody VerifyPairingCodeDTO request,
      @AuthenticationPrincipal User currentUser
  ) {
    CoupleResponseDTO response = pairingService.verifyPairingCode(currentUser, request);
    return ResponseEntity.ok(response);
  }

  @GetMapping("/my-request")
  public ResponseEntity<PairingResponseDTO> getMyActiveRequest() {
    Long currentUserId = getCurrentUserId();
    PairingResponseDTO response = pairingService.getMyActiveRequest(currentUserId);
    return ResponseEntity.ok(response);
  }

  @DeleteMapping("/my-request")
  public ResponseEntity<Void> cancelMyRequest() {
    Long currentUserId = getCurrentUserId();
    pairingService.cancelMyRequest(currentUserId);
    return ResponseEntity.noContent().build();
  }

  private Long getCurrentUserId() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    String username = authentication.getName();
    User user = userRepository.findByUsername(username)
      .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    return user.getId();
  }
}
