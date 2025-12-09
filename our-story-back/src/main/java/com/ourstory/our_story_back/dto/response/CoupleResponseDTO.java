package com.ourstory.our_story_back.dto.response;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.ourstory.our_story_back.enums.CoupleStatus;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CoupleResponseDTO {
  private Long id;
  private UserResponseDTO user1;
  private UserResponseDTO user2;
  private String coupleName;
  private LocalDate relationshipStart;
  private CoupleStatus status;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;
}
