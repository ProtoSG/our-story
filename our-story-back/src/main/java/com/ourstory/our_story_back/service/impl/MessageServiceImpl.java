package com.ourstory.our_story_back.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.ourstory.our_story_back.dto.request.MessageRequestDTO;
import com.ourstory.our_story_back.dto.response.MessageResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.Message;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.mapper.MessageMapper;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.MessageRepository;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.MessageService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements MessageService {
  private final MessageRepository messageRepository;
  private final MessageMapper messageMapper;
  private final UserRepository userRepository;
  private final CoupleRepository coupleRepository;

  @Override
  public List<MessageResponseDTO> findAll() {
    return messageRepository.findAll().stream()
      .map(messageMapper::toResponseDTO)
      .collect(Collectors.toList());
  }

  @Override
  public MessageResponseDTO findById(Long id) {
    Message message = messageRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Message not found with id: " + id));
    return messageMapper.toResponseDTO(message);
  }

  @Override
  public MessageResponseDTO save(MessageRequestDTO messageRequestDTO) {
    Message message = messageMapper.toEntity(messageRequestDTO);
    Message savedMessage = messageRepository.save(message);
    return messageMapper.toResponseDTO(savedMessage);
  }

  @Override
  public MessageResponseDTO update(Long id, MessageRequestDTO messageRequestDTO) {
    Message existingMessage = messageRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Message not found with id: " + id));
    messageMapper.updateEntityFromDTO(existingMessage, messageRequestDTO);
    Message updatedMessage = messageRepository.save(existingMessage);
    return messageMapper.toResponseDTO(updatedMessage);
  }

  @Override
  public void deleteById(Long id) {
    messageRepository.deleteById(id);
  }

  @Override
  public MessageResponseDTO markAsRead(Long messageId) {
    Message message = messageRepository.findById(messageId)
      .orElseThrow(() -> new ResourceNotFoundException("Message not found"));

    message.setReadAt(LocalDateTime.now());
    Message updated = messageRepository.save(message);

    return messageMapper.toResponseDTO(updated);
  }

  @Override
  public List<MessageResponseDTO> findByUser(User currentUser) {
    User user = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    // Si el usuario no tiene pareja, retornar lista vacía
    Couple couple = coupleRepository.findByUserId(user.getId())
      .orElse(null);
    
    if (couple == null) {
      return List.of();
    }

    return messageRepository.findByCoupleIdOrderByCreatedAtAsc(couple.getId())
      .stream()
      .map(messageMapper::toResponseDTO)
      .toList();
  }
}
