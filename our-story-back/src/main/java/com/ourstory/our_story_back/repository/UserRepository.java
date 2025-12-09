package com.ourstory.our_story_back.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ourstory.our_story_back.entity.User;

public interface UserRepository extends JpaRepository<User, Long> {
  Optional<User> findByUsername(String username);
  Boolean existsByUsername(String username);
}
