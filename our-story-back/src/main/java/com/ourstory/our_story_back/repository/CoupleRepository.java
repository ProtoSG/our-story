package com.ourstory.our_story_back.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.ourstory.our_story_back.entity.Couple;

public interface CoupleRepository extends JpaRepository<Couple, Long> {

  @Query("SELECT c FROM Couple c WHERE c.user1.id = :userId OR c.user2.id = :userId")
  Optional<Couple> findByUserId(@Param("userId") Long userId);

}
