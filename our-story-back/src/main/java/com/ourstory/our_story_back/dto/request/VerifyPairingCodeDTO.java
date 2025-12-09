package com.ourstory.our_story_back.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerifyPairingCodeDTO {
  
  @NotBlank(message = "El código de verificación es requerido")
  @Size(min = 6, max = 6, message = "El código debe tener 6 caracteres")
  private String verificationCode;
}
