package com.ourstory.our_story_back.mapper;

import org.springframework.stereotype.Component;

import com.ourstory.our_story_back.dto.request.DateMediaRequestDTO;
import com.ourstory.our_story_back.dto.response.DateMediaResponseDTO;
import com.ourstory.our_story_back.entity.Date;
import com.ourstory.our_story_back.entity.DateMedia;
import com.ourstory.our_story_back.repository.DateRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DateMediaMapper {
  private final DateRepository dateRepository;

  public DateMedia toEntity(DateMediaRequestDTO dto) {
    Date date = dateRepository.findById(dto.getDateId())
      .orElseThrow(() -> new RuntimeException("Date not found with id: " + dto.getDateId()));

    return DateMedia.builder()
      .date(date)
      .mediaType(dto.getMediaType())
      .mediaUrl(dto.getMediaUrl())
      .thumbnailUrl(dto.getThumbnailUrl())
      .fileName(dto.getFileName())
      .fileSize(dto.getFileSize())
      .orderIndex(dto.getOrderIndex())
      .uploadedBy(dto.getUploadedBy())
      .build();
  }

  public DateMediaResponseDTO toResponseDTO(DateMedia entity) {
    return DateMediaResponseDTO.builder()
      .id(entity.getId())
      .dateId(entity.getDate().getId())
      .mediaType(entity.getMediaType())
      .mediaUrl(entity.getMediaUrl())
      .thumbnailUrl(entity.getThumbnailUrl())
      .fileName(entity.getFileName())
      .fileSize(entity.getFileSize())
      .orderIndex(entity.getOrderIndex())
      .uploadedBy(entity.getUploadedBy())
      .uploadedAt(entity.getUploadedAt())
      .build();
  }

  public void updateEntityFromDTO(DateMedia entity, DateMediaRequestDTO dto) {
    Date date = dateRepository.findById(dto.getDateId())
      .orElseThrow(() -> new RuntimeException("Date not found with id: " + dto.getDateId()));

    entity.setDate(date);
    entity.setMediaType(dto.getMediaType());
    entity.setMediaUrl(dto.getMediaUrl());
    entity.setThumbnailUrl(dto.getThumbnailUrl());
    entity.setFileName(dto.getFileName());
    entity.setFileSize(dto.getFileSize());
    entity.setOrderIndex(dto.getOrderIndex());
    entity.setUploadedBy(dto.getUploadedBy());
  }
}

