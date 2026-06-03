package com.resulthub.api.analytics.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Builder
public class WorkspaceAnalyticsResponse {
    private UUID workspaceId;
    private Long totalViews;
    private Long uniqueVisitors;
    private Long datasetsCount;
    private Long recordsCount;
    private Long searchCount;
    
    private List<ChartDataPoint> dailyViews;
}
