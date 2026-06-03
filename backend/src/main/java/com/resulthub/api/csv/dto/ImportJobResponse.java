package com.resulthub.api.csv.dto;

import com.resulthub.api.csv.enums.ImportStatus;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class ImportJobResponse {
    private UUID id;
    private UUID datasetId;
    private String filename;
    private ImportStatus status;
    private Integer totalRows;
    private Integer successfulRows;
    private Integer failedRows;
    private String errorFilePath;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
}
