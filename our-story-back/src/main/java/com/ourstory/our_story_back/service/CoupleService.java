package com.ourstory.our_story_back.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.ourstory.our_story_back.dto.request.CoupleRequestDTO;
import com.ourstory.our_story_back.dto.response.CoupleResponseDTO;
import com.ourstory.our_story_back.dto.response.CoupleSummaryResponseDTO;
import com.ourstory.our_story_back.entity.User;

public interface CoupleService {
  List<CoupleResponseDTO> findAll();
  CoupleResponseDTO findById(Long id);
  CoupleResponseDTO save(CoupleRequestDTO coupleRequestDTO);
  CoupleResponseDTO update(Long id, CoupleRequestDTO coupleRequestDTO);
  void deleteById(Long id);

  CoupleSummaryResponseDTO findCoupleSummary(User user);
  void updateCoupleImage(User currentUser, MultipartFile file);
}
