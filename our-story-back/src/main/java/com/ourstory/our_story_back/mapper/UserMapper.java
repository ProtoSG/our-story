package com.ourstory.our_story_back.mapper;

import org.springframework.stereotype.Component;

import com.ourstory.our_story_back.dto.request.UserRequestDTO;
import com.ourstory.our_story_back.dto.response.UserResponseDTO;
import com.ourstory.our_story_back.entity.User;

@Component
public class UserMapper {

  public User toEntity(UserRequestDTO dto) {
    return User.builder()
      .username(dto.getUsername())
      .passwordHash(dto.getPasswordHash())
      .firstName(dto.getFirstName())
      .lastName(dto.getLastName())
      .avatarUrl(dto.getAvatarUrl())
      .build();
  }

  public UserResponseDTO toResponseDTO(User entity) {
    return UserResponseDTO.builder()
      .id(entity.getId())
      .username(entity.getUsername())
      .firstName(entity.getFirstName())
      .lastName(entity.getLastName())
      .avatarUrl(entity.getAvatarUrl())
      .createdAt(entity.getCreatedAt())
      .updatedAt(entity.getUpdatedAt())
      .build();
  }

  public void updateEntityFromDTO(User entity, UserRequestDTO dto) {
    entity.setUsername(dto.getUsername());
    entity.setPasswordHash(dto.getPasswordHash());
    entity.setFirstName(dto.getFirstName());
    entity.setLastName(dto.getLastName());
    entity.setAvatarUrl(dto.getAvatarUrl());
  }
}
