package com.ourstory.our_story_back.service;

import com.ourstory.our_story_back.dto.request.AuthRequestDTO;
import com.ourstory.our_story_back.dto.request.UserRequestDTO;
import com.ourstory.our_story_back.dto.response.AuthResponseDTO;

public interface AuthService {
  AuthResponseDTO login(AuthRequestDTO authRequestDTO);
  AuthResponseDTO register(UserRequestDTO userRequestDTO);
  AuthResponseDTO refreshToken(final String refreshToken);
}
