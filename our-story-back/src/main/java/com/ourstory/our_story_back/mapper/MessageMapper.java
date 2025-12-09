package com.ourstory.our_story_back.mapper;

import org.springframework.stereotype.Component;

import com.ourstory.our_story_back.dto.request.MessageRequestDTO;
import com.ourstory.our_story_back.dto.response.MessageResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.Message;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class MessageMapper {
  private final CoupleRepository coupleRepository;
  private final UserRepository userRepository;
  private final UserMapper userMapper;

  public Message toEntity(MessageRequestDTO dto) {
    Couple couple = coupleRepository.findById(dto.getCoupleId())
      .orElseThrow(() -> new RuntimeException("Couple not found with id: " + dto.getCoupleId()));
    User sender = userRepository.findById(dto.getSenderId())
      .orElseThrow(() -> new RuntimeException("User not found with id: " + dto.getSenderId()));

    return Message.builder()
      .couple(couple)
      .sender(sender)
      .content(dto.getContent())
      .msgType(dto.getMsgType())
      .build();
  }

  public MessageResponseDTO toResponseDTO(Message entity) {
    return MessageResponseDTO.builder()
      .id(entity.getId())
      .coupleId(entity.getCouple().getId())
      .sender(userMapper.toResponseDTO(entity.getSender()))
      .content(entity.getContent())
      .msgType(entity.getMsgType())
      .readAT(entity.getReadAt())
      .createdAt(entity.getCreatedAt())
      .updatedAt(entity.getUpdatedAt())
      .build();
  }

  public void updateEntityFromDTO(Message entity, MessageRequestDTO dto) {
    Couple couple = coupleRepository.findById(dto.getCoupleId())
      .orElseThrow(() -> new RuntimeException("Couple not found with id: " + dto.getCoupleId()));
    User sender = userRepository.findById(dto.getSenderId())
      .orElseThrow(() -> new RuntimeException("User not found with id: " + dto.getSenderId()));

    entity.setCouple(couple);
    entity.setSender(sender);
    entity.setContent(dto.getContent());
    entity.setMsgType(dto.getMsgType());
  }
}
