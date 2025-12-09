package com.ourstory.our_story_back.dto.request;

import com.ourstory.our_story_back.enums.MessageType;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageRequestDTO {
  @NotNull(message = "Couple ID is required")
  private Long coupleId;

  @NotNull(message = "Sender ID is required")
  private Long senderId;

  @NotBlank(message = "Content is required")
  private String content;

  private MessageType msgType;
}
