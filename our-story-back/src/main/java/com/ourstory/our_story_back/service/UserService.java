package com.ourstory.our_story_back.service;

import java.util.List;

import com.ourstory.our_story_back.dto.request.UserRequestDTO;
import com.ourstory.our_story_back.dto.response.UserResponseDTO;

public interface UserService {
  List<UserResponseDTO> findAll();
  UserResponseDTO findById(Long id);
  UserResponseDTO findByUsername(String username);
  UserResponseDTO save(UserRequestDTO userRequestDTO);
  UserResponseDTO update(Long id, UserRequestDTO userRequestDTO);
  void deleteById(Long id);
}
