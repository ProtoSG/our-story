package com.ourstory.our_story_back.service.impl;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.ourstory.our_story_back.dto.request.DateRequestDTO;
import com.ourstory.our_story_back.dto.response.DateResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.Date;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.mapper.DateMapper;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.DateRepository;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.DateService;
import com.ourstory.our_story_back.service.FirebaseStorageService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DateServiceImpl implements DateService {
  private final DateRepository dateRepository;
  private final DateMapper dateMapper;
  private final UserRepository userRepository;
  private final CoupleRepository coupleRepository;
  private final FirebaseStorageService firebaseStorageService;

  @Override
  public List<DateResponseDTO> findAll() {
    return dateRepository.findAll().stream()
      .map(dateMapper::toResponseDTO)
      .collect(Collectors.toList());
  }

  @Override
  public DateResponseDTO findById(Long id) {
    Date date = dateRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Date not found with id: " + id));
    return dateMapper.toResponseDTO(date);
  }

  @Override
  public DateResponseDTO save(User currentUser, DateRequestDTO dateRequestDTO) {
    User user = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    Couple couple = coupleRepository.findByUserId(user.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Couple not found"));

    Date date = dateMapper.toEntity(dateRequestDTO);
    date.setCouple(couple);
    date.setCreatedBy(user);

    Date savedDate = dateRepository.save(date);
    return dateMapper.toResponseDTO(savedDate);
  }

  @Override
  public DateResponseDTO update(Long id, DateRequestDTO dateRequestDTO) {
    Date existingDate = dateRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Date not found with id: " + id));
    dateMapper.updateEntityFromDTO(existingDate, dateRequestDTO);
    Date updatedDate = dateRepository.save(existingDate);
    return dateMapper.toResponseDTO(updatedDate);
  }

  @Override
  public void deleteById(Long id) {
    dateRepository.deleteById(id);
  }

  @Override
  public List<DateResponseDTO> findAllByCouple(User currentUser) {
    Couple couple = getCouple(currentUser);

    List<Date> dates = dateRepository.findByCoupleId(couple.getId());
    return dates.stream()
      .map(dateMapper::toResponseDTO)
      .toList();
  }

  @Override
  public DateResponseDTO findLatestUnranked(User currentUser) {
    Couple couple = getCouple(currentUser);

    Date date = dateRepository.findFirstByCoupleIdAndRatingIsNullOrderByDateDesc(couple.getId())
      .orElse(null);

    if (date == null) {
      return null;
    }

    return dateMapper.toResponseDTO(date);
  }

  @Override
  public List<DateResponseDTO> findRecentRated(User currentUser) {
    Couple couple = getCouple(currentUser);

    List<Date> dates = dateRepository
      .findTop3ByCoupleIdAndRatingIsNotNullOrderByCreatedAtDesc(couple.getId());

    return dates.stream()
      .map(dateMapper::toResponseDTO)
      .toList();
  }

  private Couple getCouple(User currentUser) {
    User user = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    Couple couple = coupleRepository.findByUserId(user.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Couple not found"));

    return couple;
  }

  @Override
  public void updateDateImage(Long id, User currentUser, MultipartFile file) {
    Date date = dateRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("Date not found with id: " + id));

    Couple couple = getCouple(currentUser);

    if (!date.getCouple().getId().equals(couple.getId())) {
      throw new ResourceNotFoundException("Date does not belong to this couple");
    }

    if (file.isEmpty()) {
      throw new IllegalArgumentException("File is empty");
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
      if (date.getDateImage() != null) {
        firebaseStorageService.deleteFile(date.getDateImage());
      }

      String folder = "dates/" + date.getId();
      String imageUrl = firebaseStorageService.uploadFile(file, folder);

      date.setDateImage(imageUrl);
      dateRepository.save(date);
    } catch (IOException e) {
      throw new RuntimeException("Error uploading date image", e);
    }
  }
}
