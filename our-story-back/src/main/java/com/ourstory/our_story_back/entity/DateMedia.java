package com.ourstory.our_story_back.entity;

import java.time.LocalDateTime;

import com.ourstory.our_story_back.enums.MediaType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "date_medias")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class DateMedia {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "date_id", referencedColumnName = "id", nullable = false)
  private Date date;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private MediaType mediaType;

  @Column(nullable = false, length = 1000)
  private String mediaUrl;

  @Column(length = 1000)
  private String thumbnailUrl;

  @Column(nullable = false)
  private String fileName;

  private Long fileSize;

  private Integer orderIndex;

  @Column(nullable = false)
  private Long uploadedBy;
  
  private LocalDateTime uploadedAt;

  @PrePersist
  protected void onCreate() {
    this.uploadedAt = LocalDateTime.now();
  }
}

