package com.resulthub.api.search.entity;

import com.resulthub.api.user.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "search_analytics")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SearchAnalytics {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String searchQuery;

    private Integer resultCount;

    private String anonymousSessionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (resultCount == null) resultCount = 0;
    }
}
