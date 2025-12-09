package com.ourstory.our_story_back.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ourstory.our_story_back.entity.DateMedia;

public interface DateMediaRepository extends JpaRepository<DateMedia, Long> {
    List<DateMedia> findByDateIdOrderByOrderIndexAsc(Long dateId);
}

