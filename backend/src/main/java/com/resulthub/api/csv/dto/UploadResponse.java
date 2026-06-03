package com.resulthub.api.csv.dto;

import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class UploadResponse {
    private UUID importJobId;
    private String filename;
    private String message;
}
