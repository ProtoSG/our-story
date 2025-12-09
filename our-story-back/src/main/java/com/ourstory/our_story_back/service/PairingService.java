package com.ourstory.our_story_back.service;

import com.ourstory.our_story_back.dto.request.SendPairingRequestDTO;
import com.ourstory.our_story_back.dto.request.VerifyPairingCodeDTO;
import com.ourstory.our_story_back.dto.response.CoupleResponseDTO;
import com.ourstory.our_story_back.dto.response.PairingResponseDTO;
import com.ourstory.our_story_back.entity.User;

public interface PairingService {
  PairingResponseDTO sendPairingRequest(User currentUser, SendPairingRequestDTO request);
  CoupleResponseDTO verifyPairingCode(User currentUser, VerifyPairingCodeDTO request);
  PairingResponseDTO getMyActiveRequest(Long userId);
  void cancelMyRequest(Long userId);
}
