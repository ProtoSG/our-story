package com.ourstory.our_story_back.dto.request;

import com.ourstory.our_story_back.enums.MediaType;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DateMediaRequestDTO {
  @NotNull(message = "Date ID is required")
  private Long dateId;

  @NotNull(message = "Media type is required")
  private MediaType mediaType;

  @NotNull(message = "Media URL is required")
  private String mediaUrl;

  private String thumbnailUrl;
  
  @NotNull(message = "File name is required")
  private String fileName;
  
  private Long fileSize;
  
  private Integer orderIndex;

  @NotNull(message = "Uploaded by user ID is required")
  private Long uploadedBy;
}

