package com.ourstory.our_story_back.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.ourstory.our_story_back.dto.request.DateMediaRequestDTO;
import com.ourstory.our_story_back.dto.response.DateMediaResponseDTO;
import com.ourstory.our_story_back.enums.MediaType;
import com.ourstory.our_story_back.service.DateMediaService;
import com.ourstory.our_story_back.service.FirebaseStorageService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/date-medias")
@RequiredArgsConstructor
public class DateMediaController {
  private final DateMediaService dateMediaService;
  private final FirebaseStorageService firebaseStorageService;

  @GetMapping
  public ResponseEntity<List<DateMediaResponseDTO>> getAllDateMedias() {
    return ResponseEntity.ok(dateMediaService.findAll());
  }

  @GetMapping("/{id}")
  public ResponseEntity<DateMediaResponseDTO> getDateMediaById(@PathVariable Long id) {
    DateMediaResponseDTO dateMedia = dateMediaService.findById(id);
    return ResponseEntity.ok(dateMedia);
  }

  @GetMapping("/dates/{dateId}")
  public ResponseEntity<List<DateMediaResponseDTO>> getMediasByDateId(@PathVariable Long dateId) {
    List<DateMediaResponseDTO> medias = dateMediaService.findByDateId(dateId);
    return ResponseEntity.ok(medias);
  }

  @PostMapping
  public ResponseEntity<DateMediaResponseDTO> createDateMedia(@Valid @RequestBody DateMediaRequestDTO dateMediaRequestDTO) {
    DateMediaResponseDTO dateMedia = dateMediaService.save(dateMediaRequestDTO);
    return ResponseEntity.status(HttpStatus.CREATED).body(dateMedia);
  }

  @PostMapping("/upload")
  public ResponseEntity<DateMediaResponseDTO> uploadMedia(
      @RequestParam("file") MultipartFile file,
      @RequestParam("dateId") Long dateId,
      @RequestParam("mediaType") MediaType mediaType,
      @RequestParam("uploadedBy") Long uploadedBy,
      @RequestParam(value = "orderIndex", required = false) Integer orderIndex) {
    
    try {
      // Validate file
      if (file.isEmpty()) {
        return ResponseEntity.badRequest().build();
      }

      // Validate media type based on file content type
      String contentType = file.getContentType();
      if (contentType == null) {
        return ResponseEntity.badRequest().build();
      }

      if (mediaType == MediaType.IMAGE && !contentType.startsWith("image/")) {
        return ResponseEntity.badRequest().build();
      }

      if (mediaType == MediaType.VIDEO && !contentType.startsWith("video/")) {
        return ResponseEntity.badRequest().build();
      }

      // Upload file to Firebase Storage
      String folder = "dates/" + dateId;
      String mediaUrl = firebaseStorageService.uploadFile(file, folder);

      // Create DateMedia record
      DateMediaRequestDTO requestDTO = DateMediaRequestDTO.builder()
          .dateId(dateId)
          .mediaType(mediaType)
          .mediaUrl(mediaUrl)
          .fileName(file.getOriginalFilename())
          .fileSize(file.getSize())
          .orderIndex(orderIndex)
          .uploadedBy(uploadedBy)
          .build();

      DateMediaResponseDTO response = dateMediaService.save(requestDTO);
      return ResponseEntity.status(HttpStatus.CREATED).body(response);

    } catch (IOException e) {
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  @PutMapping("/{id}")
  public ResponseEntity<DateMediaResponseDTO> updateDateMedia(@PathVariable Long id, @Valid @RequestBody DateMediaRequestDTO dateMediaRequestDTO) {
    DateMediaResponseDTO dateMedia = dateMediaService.update(id, dateMediaRequestDTO);
    return ResponseEntity.ok(dateMedia);
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteDateMedia(@PathVariable Long id) {
    // Get the media to delete from Firebase
    DateMediaResponseDTO media = dateMediaService.findById(id);
    
    // Delete from Firebase Storage
    if (media.getMediaUrl() != null) {
      firebaseStorageService.deleteFile(media.getMediaUrl());
    }
    
    // Delete from database
    dateMediaService.deleteById(id);
    return ResponseEntity.noContent().build();
  }
}

