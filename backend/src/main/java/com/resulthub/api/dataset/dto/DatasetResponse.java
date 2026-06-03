package com.resulthub.api.dataset.dto;

import com.resulthub.api.dataset.enums.DatasetStatus;
import com.resulthub.api.dataset.enums.DomainType;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class DatasetResponse {
    private UUID id;
    private UUID workspaceId;
    private String name;
    private String slug;
    private String description;
    private DomainType domainType;
    private DatasetStatus status;
    private Integer version;
    private UUID createdById;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
