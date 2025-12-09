package com.ourstory.our_story_back.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.ourstory.our_story_back.entity.PairingRequest;
import com.ourstory.our_story_back.enums.PairingStatus;

public interface PairingRepository extends JpaRepository<PairingRequest, Long> {
  
  // Buscar por código de verificación
  Optional<PairingRequest> findByVerificationCode(String verificationCode);
  
  // Buscar solicitud pendiente del usuario
  @Query("SELECT pr FROM PairingRequest pr WHERE pr.senderUser.id = :userId AND pr.status = 'PENDING' AND pr.expiresAt > :now")
  Optional<PairingRequest> findActiveBySenderUserId(@Param("userId") Long userId, @Param("now") LocalDateTime now);
  
  // Verificar si existe código activo
  boolean existsByVerificationCodeAndStatus(String verificationCode, PairingStatus status);
  
  // Cancelar solicitudes antiguas del usuario
  @Query("UPDATE PairingRequest pr SET pr.status = 'CANCELLED' WHERE pr.senderUser.id = :userId AND pr.status = 'PENDING'")
  void cancelPreviousRequestsByUserId(@Param("userId") Long userId);
}
