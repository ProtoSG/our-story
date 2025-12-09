package com.ourstory.our_story_back.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TypingNotificationDTO {
    private Long userId;
    private Long coupleId;
    private boolean isTyping;
}
