package com.ourstory.our_story_back.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.ourstory.our_story_back.entity.Date;

public interface DateRepository extends JpaRepository<Date, Long> {
  // Order by date DESC with NULLS LAST, so dates without a date go to the end
  @Query("SELECT d FROM Date d WHERE d.couple.id = :coupleId ORDER BY " +
         "CASE WHEN d.date IS NULL THEN 1 ELSE 0 END, " +
         "d.date DESC NULLS LAST, " +
         "d.createdAt DESC")
  List<Date> findByCoupleId(@Param("coupleId") Long id);

  Optional<Date> findFirstByCoupleIdAndRatingIsNullOrderByDateDesc(Long coupleId);

  List<Date> findTop3ByCoupleIdAndRatingIsNotNullOrderByCreatedAtDesc(Long coupleId);
}
