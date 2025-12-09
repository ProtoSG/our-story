package com.ourstory.our_story_back.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ourstory.our_story_back.entity.Message;

public interface MessageRepository extends JpaRepository<Message, Long> {
  List<Message> findByCoupleIdOrderByCreatedAtAsc(Long coupleId);
}
