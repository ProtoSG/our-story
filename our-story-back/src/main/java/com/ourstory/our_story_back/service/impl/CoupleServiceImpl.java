package com.ourstory.our_story_back.service.impl;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.ourstory.our_story_back.dto.request.CoupleRequestDTO;
import com.ourstory.our_story_back.dto.response.CoupleResponseDTO;
import com.ourstory.our_story_back.dto.response.CoupleSummaryResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.mapper.CoupleMapper;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.CoupleService;
import com.ourstory.our_story_back.service.FirebaseStorageService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CoupleServiceImpl implements CoupleService {
  private final CoupleRepository coupleRepository;
  private final CoupleMapper coupleMapper;
  private final UserRepository userRepository;
  private final FirebaseStorageService firebaseStorageService;

  @Override
  public List<CoupleResponseDTO> findAll() {
    return coupleRepository.findAll().stream()
      .map(coupleMapper::toResponseDTO)
      .collect(Collectors.toList());
  }

  @Override
  public CoupleResponseDTO findById(Long id) {
    Couple couple = coupleRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Couple not found with id: " + id));
    return coupleMapper.toResponseDTO(couple);
  }

  @Override
  public CoupleResponseDTO save(CoupleRequestDTO coupleRequestDTO) {
    Couple couple = coupleMapper.toEntity(coupleRequestDTO);
    Couple savedCouple = coupleRepository.save(couple);
    return coupleMapper.toResponseDTO(savedCouple);
  }

  @Override
  public CoupleResponseDTO update(Long id, CoupleRequestDTO coupleRequestDTO) {
    Couple existingCouple = coupleRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Couple not found with id: " + id));
    coupleMapper.updateEntityFromDTO(existingCouple, coupleRequestDTO);
    Couple updatedCouple = coupleRepository.save(existingCouple);
    return coupleMapper.toResponseDTO(updatedCouple);
  }

  @Override
  public void deleteById(Long id) {
    coupleRepository.deleteById(id);
  }

  @Override
  public CoupleSummaryResponseDTO findCoupleSummary(User currentUser) {
    User user = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    Couple couple = coupleRepository.findByUserId(user.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Couple not found"));

    Integer daysTogether = null;

    if (couple.getRelationshipStart() != null) {
      daysTogether = (int) ChronoUnit.DAYS.between(
          couple.getRelationshipStart(), 
          LocalDate.now()
      );
    }

    CoupleSummaryResponseDTO coupleSDto = coupleMapper.toSummaryDTO(couple);
    coupleSDto.setDaysTogether(daysTogether);

    return coupleSDto;
  }

  @Override
  public void updateCoupleImage(User currentUser, MultipartFile file) {
    Couple couple = coupleRepository.findByUserId(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Couple not found"));

    if (file.isEmpty()) {
      throw new ResourceNotFoundException("File is empty");
    }

    String contentType = file.getContentType();

    System.out.println("🔍 DEBUG - File info:");
    System.out.println("   - Filename: " + file.getOriginalFilename());
    System.out.println("   - ContentType: " + contentType);
    System.out.println("   - Size: " + file.getSize());

    if (contentType == null || !contentType.startsWith("image/")) {
      throw new IllegalArgumentException("Only images are allowed");
    }

    try {
      if (couple.getCoupleImage() != null) {
        firebaseStorageService.deleteFile(couple.getCoupleImage());
      }

      String folder = "couples/" + couple.getId();
      String imageUrl = firebaseStorageService.uploadFile(file, folder);

      couple.setCoupleImage(imageUrl);
      coupleRepository.save(couple);
    } catch (IOException e) {
        throw new RuntimeException("Error uploading couple image", e);
    }
  }
}
