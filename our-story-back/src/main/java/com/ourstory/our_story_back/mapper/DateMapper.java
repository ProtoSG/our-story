package com.ourstory.our_story_back.mapper;

import org.springframework.stereotype.Component;

import com.ourstory.our_story_back.dto.request.DateRequestDTO;
import com.ourstory.our_story_back.dto.response.DateResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.Date;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DateMapper {
  private final CoupleRepository coupleRepository;
  private final UserRepository userRepository;
  private final UserMapper userMapper;

  public Date toEntity(DateRequestDTO dto) {
    return Date.builder()
      .title(dto.getTitle())
      .description(dto.getDescription())
      .location(dto.getLocation())
      .date(dto.getDate())
      .dateImage(dto.getDateImage())
      .rating(dto.getRating())
      .category(dto.getCategory())
      .build();
  }

  public DateResponseDTO toResponseDTO(Date entity) {
    return DateResponseDTO.builder()
      .id(entity.getId())
      .coupleId(entity.getCouple().getId())
      .createdBy(userMapper.toResponseDTO(entity.getCreatedBy()))
      .title(entity.getTitle())
      .description(entity.getDescription())
      .location(entity.getLocation())
      .date(entity.getDate())
      .dateImage(entity.getDateImage())
      .rating(entity.getRating())
      .category(entity.getCategory())
      .createdAt(entity.getCreatedAt())
      .updatedAt(entity.getUpdatedAt())
      .build();
  }

  public void updateEntityFromDTO(Date entity, DateRequestDTO dto) {
    entity.setTitle(dto.getTitle());
    entity.setDescription(dto.getDescription());
    entity.setLocation(dto.getLocation());
    entity.setDate(dto.getDate());
    entity.setDateImage(dto.getDateImage());
    entity.setRating(dto.getRating());
    entity.setCategory(dto.getCategory());
  }
}
