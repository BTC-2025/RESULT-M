package com.resulthub.api.search.dto;

import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class SearchResult {
    private UUID id;
    private String type; // WORKSPACE, DATASET, RECORD
    private String title;
    private String description;
    private Double relevanceScore;
    
    // Context fields (nullable depending on type)
    private UUID workspaceId;
    private UUID datasetId;
    private String domainType;
}
