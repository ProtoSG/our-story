package com.ourstory.our_story_back.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter @Setter
public class AuthRequestDTO {

  @NotNull(message = "El username es obligatorio")
  private String username;

  @NotNull(message = "La contraseña es obligatoria")
  private String password;

}
