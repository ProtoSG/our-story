package com.ourstory.our_story_back.mapper;

import org.springframework.stereotype.Component;

import com.ourstory.our_story_back.dto.request.NoteRequestDTO;
import com.ourstory.our_story_back.dto.response.NoteResponseDTO;
import com.ourstory.our_story_back.entity.Note;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class NoteMapper {
  private final UserMapper userMapper;

  public Note toEntity(NoteRequestDTO dto) {
    return Note.builder()
      .title(dto.getTitle())
      .content(dto.getContent())
      .color(dto.getColor())
      .isPinned(dto.getIsPinned())
      .sticker(dto.getSticker())
      .build();
  }

  public NoteResponseDTO toResponseDTO(Note entity) {
    return NoteResponseDTO.builder()
      .id(entity.getId())
      .coupleId(entity.getCouple().getId())
      .createdBy(userMapper.toResponseDTO(entity.getCreatedBy()))
      .title(entity.getTitle())
      .content(entity.getContent())
      .color(entity.getColor())
      .isPinned(entity.getIsPinned())
      .sticker(entity.getSticker())
      .createdAt(entity.getCreatedAt())
      .updatedAt(entity.getUpdatedAt())
      .build();
  }

  public void updateEntityFromDTO(Note entity, NoteRequestDTO dto) {
    entity.setTitle(dto.getTitle());
    entity.setContent(dto.getContent());
    entity.setColor(dto.getColor());
    entity.setIsPinned(dto.getIsPinned());
    entity.setSticker(dto.getSticker());
  }
}
