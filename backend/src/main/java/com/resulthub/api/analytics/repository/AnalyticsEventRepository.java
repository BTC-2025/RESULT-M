package com.resulthub.api.analytics.repository;

import com.resulthub.api.analytics.entity.AnalyticsEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface AnalyticsEventRepository extends JpaRepository<AnalyticsEvent, UUID> {

    @Query("SELECT COUNT(e) FROM AnalyticsEvent e WHERE e.workspaceId = :workspaceId AND e.eventType IN ('WORKSPACE_VIEW', 'DATASET_VIEW', 'RECORD_VIEW')")
    Long countViewsByWorkspaceId(@Param("workspaceId") UUID workspaceId);

    @Query("SELECT COUNT(DISTINCT e.anonymousSessionId) FROM AnalyticsEvent e WHERE e.workspaceId = :workspaceId")
    Long countUniqueVisitorsByWorkspaceId(@Param("workspaceId") UUID workspaceId);

    @Query("SELECT COUNT(e) FROM AnalyticsEvent e WHERE e.workspaceId = :workspaceId AND e.eventType = 'SEARCH'")
    Long countSearchesByWorkspaceId(@Param("workspaceId") UUID workspaceId);

    // Native query for grouping by day efficiently
    @Query(value = """
        SELECT to_char(created_at, 'YYYY-MM-DD') as date, count(*) as count 
        FROM analytics_events 
        WHERE workspace_id = :workspaceId 
          AND event_type IN ('WORKSPACE_VIEW', 'DATASET_VIEW', 'RECORD_VIEW')
          AND created_at >= :since 
        GROUP BY date 
        ORDER BY date ASC
    """, nativeQuery = true)
    List<Object[]> getDailyViewsByWorkspaceId(@Param("workspaceId") UUID workspaceId, @Param("since") LocalDateTime since);

    @Query("SELECT COUNT(e) FROM AnalyticsEvent e WHERE e.eventType IN ('WORKSPACE_VIEW', 'DATASET_VIEW', 'RECORD_VIEW')")
    Long countGlobalViews();

    @Query("SELECT COUNT(e) FROM AnalyticsEvent e WHERE e.eventType = 'SEARCH'")
    Long countGlobalSearches();

    @Query("SELECT COUNT(e) FROM AnalyticsEvent e WHERE e.eventType = 'CSV_UPLOAD'")
    Long countGlobalUploads();

    @Query(value = """
        SELECT to_char(created_at, 'YYYY-MM-DD') as date, count(*) as count 
        FROM analytics_events 
        WHERE event_type IN ('WORKSPACE_VIEW', 'DATASET_VIEW', 'RECORD_VIEW')
          AND created_at >= :since 
        GROUP BY date 
        ORDER BY date ASC
    """, nativeQuery = true)
    List<Object[]> getGlobalDailyViews(@Param("since") LocalDateTime since);
}
