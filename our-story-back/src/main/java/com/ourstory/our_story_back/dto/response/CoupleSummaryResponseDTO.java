package com.ourstory.our_story_back.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CoupleSummaryResponseDTO {
  private Long id;
  private String coupleName;
  private String coupleImage;
  private Integer daysTogether;
}
