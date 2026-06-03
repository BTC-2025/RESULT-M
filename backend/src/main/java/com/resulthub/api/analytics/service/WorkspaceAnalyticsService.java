package com.resulthub.api.analytics.service;

import com.resulthub.api.analytics.dto.ChartDataPoint;
import com.resulthub.api.analytics.dto.GlobalAnalyticsResponse;
import com.resulthub.api.analytics.dto.WorkspaceAnalyticsResponse;
import com.resulthub.api.analytics.repository.AnalyticsEventRepository;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkspaceAnalyticsService {

    private final AnalyticsEventRepository analyticsRepository;
    private final WorkspaceRepository workspaceRepository;
    private final DatasetRepository datasetRepository;
    private final DatasetRecordRepository recordRepository;
    private final WorkspaceMemberRepository memberRepository;

    public WorkspaceAnalyticsResponse getWorkspaceAnalytics(UUID workspaceId, UUID userId) {
        // Enforce RBAC
        WorkspaceMember member = memberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                .orElseThrow(() -> new RuntimeException("Access denied."));

        if (member.getRole() != WorkspaceRole.OWNER && member.getRole() != WorkspaceRole.ADMIN) {
            throw new RuntimeException("Access denied. Only OWNER or ADMIN can view analytics.");
        }

        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);

        List<ChartDataPoint> dailyViews = analyticsRepository.getDailyViewsByWorkspaceId(workspaceId, thirtyDaysAgo)
                .stream()
                .map(row -> new ChartDataPoint((String) row[0], ((Number) row[1]).longValue()))
                .collect(Collectors.toList());

        return WorkspaceAnalyticsResponse.builder()
                .workspaceId(workspaceId)
                .totalViews(analyticsRepository.countViewsByWorkspaceId(workspaceId))
                .uniqueVisitors(analyticsRepository.countUniqueVisitorsByWorkspaceId(workspaceId))
                .searchCount(analyticsRepository.countSearchesByWorkspaceId(workspaceId))
                .datasetsCount((long) datasetRepository.findByWorkspaceIdAndNotDeleted(workspaceId, org.springframework.data.domain.Pageable.unpaged()).getContent().size())
                .recordsCount(0L) // Typically requires a complex SUM query or materialized view in a real environment
                .dailyViews(dailyViews)
                .build();
    }

    public GlobalAnalyticsResponse getGlobalAnalytics(UUID userId) {
        // Real implementation would check if User is System Admin via UserRole enum
        
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        
        List<ChartDataPoint> dailyViews = analyticsRepository.getGlobalDailyViews(thirtyDaysAgo)
                .stream()
                .map(row -> new ChartDataPoint((String) row[0], ((Number) row[1]).longValue()))
                .collect(Collectors.toList());

        return GlobalAnalyticsResponse.builder()
                .totalWorkspaces(workspaceRepository.count())
                .totalDatasets(datasetRepository.count())
                .totalRecords(recordRepository.count())
                .totalViews(analyticsRepository.countGlobalViews())
                .totalSearches(analyticsRepository.countGlobalSearches())
                .totalUploads(analyticsRepository.countGlobalUploads())
                .dailyViews(dailyViews)
                .build();
    }
}
