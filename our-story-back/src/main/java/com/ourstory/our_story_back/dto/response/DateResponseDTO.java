package com.ourstory.our_story_back.dto.response;

import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DateResponseDTO {
  private Long id;
  private Long coupleId;
  private UserResponseDTO createdBy;
  private String title;
  private String description;
  private String location;
  private LocalDate date;
  private String dateImage;
  private Integer rating;
  private String category;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;
}
