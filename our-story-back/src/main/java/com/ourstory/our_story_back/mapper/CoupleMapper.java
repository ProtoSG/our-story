package com.ourstory.our_story_back.mapper;

import org.springframework.stereotype.Component;

import com.ourstory.our_story_back.dto.request.CoupleRequestDTO;
import com.ourstory.our_story_back.dto.response.CoupleResponseDTO;
import com.ourstory.our_story_back.dto.response.CoupleSummaryResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CoupleMapper {
  private final UserRepository userRepository;
  private final UserMapper userMapper;

  public Couple toEntity(CoupleRequestDTO dto) {
    User user1 = userRepository.findById(dto.getUser1Id())
      .orElseThrow(() -> new RuntimeException("User1 not found with id: " + dto.getUser1Id()));
    User user2 = userRepository.findById(dto.getUser2Id())
      .orElseThrow(() -> new RuntimeException("User2 not found with id: " + dto.getUser2Id()));

    return Couple.builder()
      .user1(user1)
      .user2(user2)
      .coupleName(dto.getCoupleName())
      .relationshipStart(dto.getRelationshipStart())
      .status(dto.getStatus())
      .build();
  }

  public CoupleResponseDTO toResponseDTO(Couple entity) {
    return CoupleResponseDTO.builder()
      .id(entity.getId())
      .user1(userMapper.toResponseDTO(entity.getUser1()))
      .user2(userMapper.toResponseDTO(entity.getUser2()))
      .coupleName(entity.getCoupleName())
      .relationshipStart(entity.getRelationshipStart())
      .status(entity.getStatus())
      .createdAt(entity.getCreatedAt())
      .updatedAt(entity.getUpdatedAt())
      .build();
  }

  public void updateEntityFromDTO(Couple entity, CoupleRequestDTO dto) {
    User user1 = userRepository.findById(dto.getUser1Id())
      .orElseThrow(() -> new RuntimeException("User1 not found with id: " + dto.getUser1Id()));
    User user2 = userRepository.findById(dto.getUser2Id())
      .orElseThrow(() -> new RuntimeException("User2 not found with id: " + dto.getUser2Id()));

    entity.setUser1(user1);
    entity.setUser2(user2);
    entity.setCoupleName(dto.getCoupleName());
    entity.setRelationshipStart(dto.getRelationshipStart());
    entity.setStatus(dto.getStatus());
  }

  public CoupleSummaryResponseDTO toSummaryDTO(Couple entity) {
    return CoupleSummaryResponseDTO.builder()
      .id(entity.getId())
      .coupleName(entity.getCoupleName())
      .coupleImage(entity.getCoupleImage())
      .build();
  }
}
