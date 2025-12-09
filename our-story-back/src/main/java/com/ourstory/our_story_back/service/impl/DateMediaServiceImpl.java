package com.ourstory.our_story_back.service.impl;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.ourstory.our_story_back.dto.request.DateMediaRequestDTO;
import com.ourstory.our_story_back.dto.response.DateMediaResponseDTO;
import com.ourstory.our_story_back.entity.DateMedia;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.mapper.DateMediaMapper;
import com.ourstory.our_story_back.repository.DateMediaRepository;
import com.ourstory.our_story_back.service.DateMediaService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DateMediaServiceImpl implements DateMediaService {
  private final DateMediaRepository dateMediaRepository;
  private final DateMediaMapper dateMediaMapper;

  @Override
  public List<DateMediaResponseDTO> findAll() {
    return dateMediaRepository.findAll().stream()
      .map(dateMediaMapper::toResponseDTO)
      .collect(Collectors.toList());
  }

  @Override
  public DateMediaResponseDTO findById(Long id) {
    DateMedia dateMedia = dateMediaRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("DateMedia not found with id: " + id));
    return dateMediaMapper.toResponseDTO(dateMedia);
  }

  @Override
  public List<DateMediaResponseDTO> findByDateId(Long dateId) {
    return dateMediaRepository.findByDateIdOrderByOrderIndexAsc(dateId).stream()
      .map(dateMediaMapper::toResponseDTO)
      .collect(Collectors.toList());
  }

  @Override
  public DateMediaResponseDTO save(DateMediaRequestDTO dateMediaRequestDTO) {
    DateMedia dateMedia = dateMediaMapper.toEntity(dateMediaRequestDTO);
    DateMedia savedDateMedia = dateMediaRepository.save(dateMedia);
    return dateMediaMapper.toResponseDTO(savedDateMedia);
  }

  @Override
  public DateMediaResponseDTO update(Long id, DateMediaRequestDTO dateMediaRequestDTO) {
    DateMedia existingDateMedia = dateMediaRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("DateMedia not found with id: " + id));
    dateMediaMapper.updateEntityFromDTO(existingDateMedia, dateMediaRequestDTO);
    DateMedia updatedDateMedia = dateMediaRepository.save(existingDateMedia);
    return dateMediaMapper.toResponseDTO(updatedDateMedia);
  }

  @Override
  public void deleteById(Long id) {
    dateMediaRepository.deleteById(id);
  }
}

