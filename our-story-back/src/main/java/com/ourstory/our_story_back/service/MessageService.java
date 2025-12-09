package com.ourstory.our_story_back.service;

import java.util.List;

import com.ourstory.our_story_back.dto.request.MessageRequestDTO;
import com.ourstory.our_story_back.dto.response.MessageResponseDTO;
import com.ourstory.our_story_back.entity.User;

public interface MessageService {
  List<MessageResponseDTO> findAll();
  MessageResponseDTO findById(Long id);
  MessageResponseDTO save(MessageRequestDTO messageRequestDTO);
  MessageResponseDTO update(Long id, MessageRequestDTO messageRequestDTO);
  void deleteById(Long id);


  MessageResponseDTO markAsRead(Long messageId);
  List<MessageResponseDTO> findByUser(User currentUser);
}
