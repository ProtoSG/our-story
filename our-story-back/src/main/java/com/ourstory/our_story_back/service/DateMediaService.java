package com.ourstory.our_story_back.service;

import java.util.List;

import com.ourstory.our_story_back.dto.request.DateMediaRequestDTO;
import com.ourstory.our_story_back.dto.response.DateMediaResponseDTO;

public interface DateMediaService {
  List<DateMediaResponseDTO> findAll();
  DateMediaResponseDTO findById(Long id);
  List<DateMediaResponseDTO> findByDateId(Long dateId);
  DateMediaResponseDTO save(DateMediaRequestDTO dateMediaRequestDTO);
  DateMediaResponseDTO update(Long id, DateMediaRequestDTO dateMediaRequestDTO);
  void deleteById(Long id);
}

