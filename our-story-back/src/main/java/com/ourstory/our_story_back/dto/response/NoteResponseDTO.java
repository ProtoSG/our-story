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
public class NoteResponseDTO {
  private Long id;
  private Long coupleId;
  private UserResponseDTO createdBy;
  private String title;
  private String content;
  private String color;
  private Boolean isPinned;
  private String sticker;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;
}
