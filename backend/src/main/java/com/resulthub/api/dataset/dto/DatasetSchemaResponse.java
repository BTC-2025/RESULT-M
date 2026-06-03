package com.resulthub.api.dataset.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
public class DatasetSchemaResponse {
    private UUID id;
    private UUID datasetId;
    private String schemaName;
    private Map<String, Object> schemaDefinition;
    private Boolean isRequired;
    private LocalDateTime createdAt;
}
