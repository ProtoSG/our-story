package com.ourstory.our_story_back.dto.request;

import java.time.LocalDate;

import com.ourstory.our_story_back.enums.CoupleStatus;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CoupleRequestDTO {
  @NotNull(message = "User1 ID is required")
  private Long user1Id;

  @NotNull(message = "User2 ID is required")
  private Long user2Id;

  private String coupleName;
  private LocalDate relationshipStart;
  private CoupleStatus status;
}
