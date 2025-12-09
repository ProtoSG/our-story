package com.ourstory.our_story_back.dto.response;

import java.time.LocalDateTime;

import com.ourstory.our_story_back.enums.MessageType;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageResponseDTO {
  private Long id;
  private Long coupleId;
  private UserResponseDTO sender;
  private String content;
  private MessageType msgType;
  private LocalDateTime readAT;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;
}
