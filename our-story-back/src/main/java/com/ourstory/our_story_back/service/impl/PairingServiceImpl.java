package com.ourstory.our_story_back.service.impl;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ourstory.our_story_back.dto.request.SendPairingRequestDTO;
import com.ourstory.our_story_back.dto.request.VerifyPairingCodeDTO;
import com.ourstory.our_story_back.dto.response.CoupleResponseDTO;
import com.ourstory.our_story_back.dto.response.PairingResponseDTO;
import com.ourstory.our_story_back.entity.Couple;
import com.ourstory.our_story_back.entity.PairingRequest;
import com.ourstory.our_story_back.entity.User;
import com.ourstory.our_story_back.enums.CoupleStatus;
import com.ourstory.our_story_back.enums.PairingStatus;
import com.ourstory.our_story_back.exceptions.ResourceConflictException;
import com.ourstory.our_story_back.exceptions.ResourceNotFoundException;
import com.ourstory.our_story_back.exceptions.UnauthorizedException;
import com.ourstory.our_story_back.mapper.CoupleMapper;
import com.ourstory.our_story_back.repository.CoupleRepository;
import com.ourstory.our_story_back.repository.PairingRepository;
import com.ourstory.our_story_back.repository.UserRepository;
import com.ourstory.our_story_back.service.PairingService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PairingServiceImpl implements PairingService {

  private final PairingRepository pairingRepository;
  private final UserRepository userRepository;
  private final CoupleRepository coupleRepository;
  private final CoupleMapper coupleMapper;

  private static final String CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  private static final int CODE_LENGTH = 6;
  private static final int MAX_ATTEMPTS = 3;
  private static final long EXPIRATION_HOURS = 24;
  private static final SecureRandom random = new SecureRandom();

  @Override
  @Transactional
  public PairingResponseDTO sendPairingRequest(User currentUser, SendPairingRequestDTO request) {
    // Verificar que el sender existe
    User senderUser = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Usuario emisor no encontrado"));

    // Verificar que el recipient existe
    User recipientUser = userRepository.findByUsername(request.getRecipientUsername())
      .orElseThrow(() -> new ResourceNotFoundException("Usuario destinatario '" + request.getRecipientUsername() + "' no encontrado"));

    // No puede enviarse a sí mismo
    if (senderUser.getId().equals(recipientUser.getId())) {
      throw new ResourceConflictException("No puedes emparejarte contigo mismo");
    }

    // Verificar que el sender no esté ya emparejado
    Optional<Couple> senderCouple = coupleRepository.findByUserId(currentUser.getId());
    if (senderCouple.isPresent() && senderCouple.get().getStatus() == CoupleStatus.ACTIVE) {
      throw new ResourceConflictException("Ya estás emparejado con alguien");
    }

    // Verificar que el recipient no esté ya emparejado
    Optional<Couple> recipientCouple = coupleRepository.findByUserId(recipientUser.getId());
    if (recipientCouple.isPresent() && recipientCouple.get().getStatus() == CoupleStatus.ACTIVE) {
      throw new ResourceConflictException("El usuario '" + request.getRecipientUsername() + "' ya está emparejado");
    }

    // Generar código único
    String verificationCode = generateUniqueCode();

    // Crear solicitud
    PairingRequest pairingRequest = PairingRequest.builder()
      .senderUser(senderUser)
      .recipientUsername(recipientUser.getUsername())
      .verificationCode(verificationCode)
      .status(PairingStatus.PENDING)
      .attempts(0)
      .expiresAt(LocalDateTime.now().plusHours(EXPIRATION_HOURS))
      .build();

    pairingRequest = pairingRepository.save(pairingRequest);

    return mapToDTO(pairingRequest);
  }

  @Override
  @Transactional
  public CoupleResponseDTO verifyPairingCode(User currentUser, VerifyPairingCodeDTO request) {
    // Buscar el usuario verificador
    User verifierUser = userRepository.findById(currentUser.getId())
      .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

    // Buscar la solicitud por código
    PairingRequest pairingRequest = pairingRepository.findByVerificationCode(request.getVerificationCode().toUpperCase())
      .orElseThrow(() -> new ResourceNotFoundException("Código de verificación inválido"));

    // Verificar que el código no haya expirado
    if (LocalDateTime.now().isAfter(pairingRequest.getExpiresAt())) {
      pairingRequest.setStatus(PairingStatus.EXPIRED);
      pairingRepository.save(pairingRequest);
      throw new UnauthorizedException("El código ha expirado");
    }

    // Verificar que el código esté pendiente
    if (pairingRequest.getStatus() != PairingStatus.PENDING) {
      throw new UnauthorizedException("El código ya fue usado o cancelado");
    }

    // Verificar que el verificador sea el destinatario
    if (!pairingRequest.getRecipientUsername().equals(verifierUser.getUsername())) {
      // Incrementar intentos
      pairingRequest.setAttempts(pairingRequest.getAttempts() + 1);
      pairingRepository.save(pairingRequest);

      if (pairingRequest.getAttempts() >= MAX_ATTEMPTS) {
        pairingRequest.setStatus(PairingStatus.EXPIRED);
        pairingRepository.save(pairingRequest);
        throw new UnauthorizedException("Este código no es para ti. Demasiados intentos fallidos");
      }

      throw new UnauthorizedException("Este código no es para ti. Intentos restantes: " + (MAX_ATTEMPTS - pairingRequest.getAttempts()));
    }

    // Verificar que ninguno esté ya emparejado
    Optional<Couple> senderCouple = coupleRepository.findByUserId(pairingRequest.getSenderUser().getId());
    if (senderCouple.isPresent() && senderCouple.get().getStatus() == CoupleStatus.ACTIVE) {
      throw new ResourceConflictException("El usuario emisor ya está emparejado");
    }

    Optional<Couple> verifierCouple = coupleRepository.findByUserId(currentUser.getId());
    if (verifierCouple.isPresent() && verifierCouple.get().getStatus() == CoupleStatus.ACTIVE) {
      throw new ResourceConflictException("Ya estás emparejado con alguien");
    }

    // Crear la pareja
    Couple couple = Couple.builder()
      .user1(pairingRequest.getSenderUser())
      .user2(verifierUser)
      .coupleName(pairingRequest.getSenderUser().getFirstName() + " & " + verifierUser.getFirstName())
      .relationshipStart(LocalDateTime.now().toLocalDate())
      .status(CoupleStatus.ACTIVE)
      .build();

    couple = coupleRepository.save(couple);

    // Marcar la solicitud como usada
    pairingRequest.setStatus(PairingStatus.USED);
    pairingRepository.save(pairingRequest);

    return coupleMapper.toResponseDTO(couple);
  }

  @Override
  public PairingResponseDTO getMyActiveRequest(Long userId) {
    PairingRequest pairingRequest = pairingRepository.findActiveBySenderUserId(userId, LocalDateTime.now())
      .orElseThrow(() -> new ResourceNotFoundException("No tienes una solicitud activa"));

    return mapToDTO(pairingRequest);
  }

  @Override
  @Transactional
  public void cancelMyRequest(Long userId) {
    PairingRequest pairingRequest = pairingRepository.findActiveBySenderUserId(userId, LocalDateTime.now())
      .orElseThrow(() -> new ResourceNotFoundException("No tienes una solicitud activa"));

    pairingRequest.setStatus(PairingStatus.CANCELLED);
    pairingRepository.save(pairingRequest);
  }

  private String generateUniqueCode() {
    String code;
    do {
      code = generateRandomCode();
    } while (pairingRepository.existsByVerificationCodeAndStatus(code, PairingStatus.PENDING));
    return code;
  }

  private String generateRandomCode() {
    StringBuilder code = new StringBuilder(CODE_LENGTH);
    for (int i = 0; i < CODE_LENGTH; i++) {
      code.append(CHARACTERS.charAt(random.nextInt(CHARACTERS.length())));
    }
    return code.toString();
  }

  private PairingResponseDTO mapToDTO(PairingRequest pairingRequest) {
    return PairingResponseDTO.builder()
      .id(pairingRequest.getId())
      .senderUsername(pairingRequest.getSenderUser().getUsername())
      .recipientUsername(pairingRequest.getRecipientUsername())
      .verificationCode(pairingRequest.getVerificationCode())
      .status(pairingRequest.getStatus())
      .attempts(pairingRequest.getAttempts())
      .expiresAt(pairingRequest.getExpiresAt())
      .createdAt(pairingRequest.getCreatedAt())
      .build();
  }
}
