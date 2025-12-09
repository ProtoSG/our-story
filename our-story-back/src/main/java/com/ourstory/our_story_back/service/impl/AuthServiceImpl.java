package com.ourstory.our_story_back.service.impl;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.ourstory.our_story_back.dto.request.AuthRequestDTO;
import com.ourstory.our_story_back.dto.request.UserRequestDTO;
import com.ourstory.our_story_back.dto.response.AuthResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.exceptions.ResourceConflictException;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.exceptions.UnauthorizedException;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.AuthService;
import com.ourstory.our_story_back.service.JwtService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

  private final UserRepository userRepository;
  private final CoupleRepository coupleRepository;
  private final PasswordEncoder passwordEncoder;
  private final JwtService jwtService;
  private final AuthenticationManager authenticationManager;

  @Override
  public AuthResponseDTO login(AuthRequestDTO authRequestDTO) {
    authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(
          authRequestDTO.getUsername(), 
          authRequestDTO.getPassword()
        )
      );

    User user = userRepository.findByUsername(authRequestDTO.getUsername())
      .orElseThrow();

    String jwtToken = jwtService.generateToken(user);
    String refreshToken = jwtService.generateRefreshToken(user);

    // Find couple for this user
    Long coupleId = coupleRepository.findByUserId(user.getId())
      .map(Couple::getId)
      .orElse(null);

    return AuthResponseDTO.builder()
      .userId(user.getId())
      .username(user.getUsername())
      .firstName(user.getFirstName())
      .lastName(user.getLastName())
      .coupleId(coupleId)
      .hasActiveCouple(coupleId != null)
      .token(jwtToken)
      .refreshToken(refreshToken)
      .build();
  }

  @Override
  public AuthResponseDTO register(UserRequestDTO userRequestDTO) {
    if (userRepository.existsByUsername(userRequestDTO.getUsername())) {
      throw new ResourceConflictException("Usuario con username: '" + userRequestDTO.getUsername() + "' ya existe");
    }

    User user = User.builder()
      .firstName(userRequestDTO.getFirstName())
      .lastName(userRequestDTO.getLastName())
      .username(userRequestDTO.getUsername())
      .passwordHash(passwordEncoder.encode(userRequestDTO.getPasswordHash()))
      .avatarUrl(userRequestDTO.getAvatarUrl())
      .build();

    User savedUser = userRepository.save(user);

    String jwtToken = jwtService.generateToken(savedUser);
    String refreshToken = jwtService.generateRefreshToken(savedUser);

    // Find couple for this user (will be null for new users)
    Long coupleId = coupleRepository.findByUserId(savedUser.getId())
      .map(Couple::getId)
      .orElse(null);

    AuthResponseDTO responseDTO = AuthResponseDTO.builder()
      .userId(savedUser.getId())
      .username(userRequestDTO.getUsername())
      .firstName(savedUser.getFirstName())
      .lastName(savedUser.getLastName())
      .coupleId(coupleId)
      .hasActiveCouple(coupleId != null)
      .token(jwtToken)
      .refreshToken(refreshToken)
      .build();

    return responseDTO;
  }

  @Override
  public AuthResponseDTO refreshToken(String refreshToken) {
    if (refreshToken == null || refreshToken.isBlank()) {
      throw new UnauthorizedException("Invalid cookie token");
    }

    final String username = jwtService.extractUsername(refreshToken);

    if(username == null) {
      throw new UnauthorizedException("Invalid refresh token");
    }

    final User user = userRepository.findByUsername(username)
      .orElseThrow(() -> new ResourceNotFoundException("Usuario con username: '" + username + "' no existe"));

    if (!jwtService.isTokenValid(refreshToken, user)) {
      throw new UnauthorizedException("Invalid refresh token");
    }

    final String accessToken = jwtService.generateToken(user);
    final String newRefreshToken = jwtService.generateRefreshToken(user);

    // Find couple for this user
    Long coupleId = coupleRepository.findByUserId(user.getId())
      .map(Couple::getId)
      .orElse(null);

    return AuthResponseDTO.builder()
      .userId(user.getId())
      .username(user.getUsername())
      .firstName(user.getFirstName())
      .lastName(user.getLastName())
      .coupleId(coupleId)
      .hasActiveCouple(coupleId != null)
      .token(accessToken)
      .refreshToken(newRefreshToken)
      .build();
  }
}
