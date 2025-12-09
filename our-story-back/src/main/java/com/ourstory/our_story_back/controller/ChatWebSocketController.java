package com.ourstory.our_story_back.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.ourstory.our_story_back.dto.request.MessageRequestDTO;
import com.ourstory.our_story_back.dto.request.TypingNotificationDTO;
import com.ourstory.our_story_back.dto.response.MessageResponseDTO;
import com.ourstory.our_story_back.service.MessageService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ChatWebSocketController {
    
    private final MessageService messageService;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Receive messages from client and broadcast to all couple users
     * Client sends to: /app/chat.sendMessage
     * Server sends to: /topic/couple/{coupleId}
     */
    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@Payload MessageRequestDTO messageRequest) {
        log.info("Received message: {} from sender: {}", 
                 messageRequest.getContent(), messageRequest.getSenderId());
        
        try {
            // Save message to database
            MessageResponseDTO savedMessage = messageService.save(messageRequest);
            
            // Send to all subscribers of the couple
            messagingTemplate.convertAndSend(
                "/topic/couple/" + savedMessage.getCoupleId(), 
                savedMessage
            );
            
            log.info("Message sent to topic /topic/couple/{}", savedMessage.getCoupleId());
        } catch (Exception e) {
            log.error("Error sending message: ", e);
        }
    }

    /**
     * Mark a message as read
     * Client sends to: /app/chat.markAsRead
     */
    @MessageMapping("/chat.markAsRead")
    public void markAsRead(@Payload Long messageId) {
        log.info("Marking message {} as read", messageId);
        
        try {
            MessageResponseDTO updatedMessage = messageService.markAsRead(messageId);
            
            // Notify the other user
            messagingTemplate.convertAndSend(
                "/topic/couple/" + updatedMessage.getCoupleId() + "/read", 
                updatedMessage
            );
        } catch (Exception e) {
            log.error("Error marking message as read: ", e);
        }
    }

    /**
     * Notify when a user is typing
     * Client sends to: /app/chat.typing
     */
    @MessageMapping("/chat.typing")
    public void userTyping(@Payload TypingNotificationDTO notification) {
        log.info("User {} is typing in couple {}", 
                 notification.getUserId(), notification.getCoupleId());
        
        // Send typing notification to the other user
        messagingTemplate.convertAndSend(
            "/topic/couple/" + notification.getCoupleId() + "/typing", 
            notification
        );
    }
}
