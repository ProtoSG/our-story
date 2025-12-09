package com.ourstory.our_story_back.service.impl;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.ourstory.our_story_back.dto.request.UserRequestDTO;
import com.ourstory.our_story_back.dto.response.UserResponseDTO;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.mapper.UserMapper;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.UserService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
  private final UserRepository userRepository;
  private final UserMapper userMapper;

  @Override
  public List<UserResponseDTO> findAll() {
    return userRepository.findAll().stream()
      .map(userMapper::toResponseDTO)
      .collect(Collectors.toList());
  }

  @Override
  public UserResponseDTO findById(Long id) {
    User user = userRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    return userMapper.toResponseDTO(user);
  }

  @Override
  public UserResponseDTO findByUsername(String username) {
    User user = userRepository.findByUsername(username)
      .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));
    return userMapper.toResponseDTO(user);
  }

  @Override
  public UserResponseDTO save(UserRequestDTO userRequestDTO) {
    User user = userMapper.toEntity(userRequestDTO);
    User savedUser = userRepository.save(user);
    return userMapper.toResponseDTO(savedUser);
  }

  @Override
  public UserResponseDTO update(Long id, UserRequestDTO userRequestDTO) {
    User existingUser = userRepository.findById(id)
      .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    userMapper.updateEntityFromDTO(existingUser, userRequestDTO);
    User updatedUser = userRepository.save(existingUser);
    return userMapper.toResponseDTO(updatedUser);
  }

  @Override
  public void deleteById(Long id) {
    userRepository.deleteById(id);
  }
}
