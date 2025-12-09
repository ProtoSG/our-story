package com.ourstory.our_story_back.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.ourstory.our_story_back.dto.request.DateRequestDTO;
import com.ourstory.our_story_back.dto.response.DateResponseDTO;
import com.ourstory.our_story_back.entity.User;

public interface DateService {
  List<DateResponseDTO> findAll();
  DateResponseDTO findById(Long id);
  DateResponseDTO save(User currentUser, DateRequestDTO dateRequestDTO);
  DateResponseDTO update(Long id, DateRequestDTO dateRequestDTO);
  void deleteById(Long id);

  List<DateResponseDTO> findAllByCouple(User currentUser);
  DateResponseDTO findLatestUnranked(User currentUser);
  List<DateResponseDTO> findRecentRated(User currentUser);
  
  void updateDateImage(Long id, User currentUser, MultipartFile file);
}
