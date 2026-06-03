package com.resulthub.api.dataset.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
public class RecordResponse {
    private UUID id;
    private UUID datasetId;
    private String recordKey;
    private String recordTitle;
    private List<String> tags;
    private Map<String, Object> data;
    private Long version;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
