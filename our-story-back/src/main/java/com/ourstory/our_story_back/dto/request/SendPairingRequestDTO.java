package com.ourstory.our_story_back.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendPairingRequestDTO {

  @NotBlank(message = "El username del destinatario es requerido")
  private String recipientUsername;
}
