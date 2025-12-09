package com.ourstory.our_story_back.dto.response;

import java.time.LocalDateTime;

import com.ourstory.our_story_back.enums.MediaType;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DateMediaResponseDTO {
  private Long id;
  private Long dateId;
  private MediaType mediaType;
  private String mediaUrl;
  private String thumbnailUrl;
  private String fileName;
  private Long fileSize;
  private Integer orderIndex;
  private Long uploadedBy;
  private LocalDateTime uploadedAt;
}

