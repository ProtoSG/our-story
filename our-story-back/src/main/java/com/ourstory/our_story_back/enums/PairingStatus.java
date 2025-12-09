package com.ourstory.our_story_back.enums;

public enum PairingStatus {
  PENDING,    // Código generado, esperando verificación
  USED,       // Código usado exitosamente
  EXPIRED,    // Código expirado (24 horas)
  CANCELLED   // Solicitud cancelada por el usuario
}
