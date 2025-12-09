package com.ourstory.our_story_back.dto.response;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponseDTO {
  private Long id;
  private String username;
  private String firstName;
  private String lastName;
  private String avatarUrl;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;
}
