package com.resulthub.api.csv.dto;

import com.resulthub.api.csv.enums.ImportStatus;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ImportSummary {
    private String datasetName;
    private String filename;
    private ImportStatus status;
    private int totalRows;
    private int successfulRows;
    private int failedRows;
    private String downloadErrorUrl;
}
