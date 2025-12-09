package com.ourstory.our_story_back.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NoteUpdateRequestDTO {
  private String title;
  private String content;
  private String color;
  private Boolean isPinned;
  private String sticker;
}
