package com.ourstory.our_story_back.dto.response;

import java.time.LocalDateTime;

import com.ourstory.our_story_back.enums.PairingStatus;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PairingResponseDTO {
  private Long id;
  private String senderUsername;
  private String recipientUsername;
  private String verificationCode;
  private PairingStatus status;
  private Integer attempts;
  private LocalDateTime expiresAt;
  private LocalDateTime createdAt;
}
