package com.ourstory.our_story_back.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AuthResponseDTO {

  private Long userId;
  private String username;
  private String firstName;
  private String lastName;
  private Long coupleId;
  private Boolean hasActiveCouple;
  private String token;

  @JsonIgnore
  private String refreshToken;

}
