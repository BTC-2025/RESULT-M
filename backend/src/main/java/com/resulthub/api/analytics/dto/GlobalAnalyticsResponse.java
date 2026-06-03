package com.resulthub.api.analytics.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GlobalAnalyticsResponse {
    private Long totalWorkspaces;
    private Long totalDatasets;
    private Long totalRecords;
    private Long totalViews;
    private Long totalSearches;
    private Long totalUploads;

    private List<ChartDataPoint> dailyViews;
}
