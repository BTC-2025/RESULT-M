package com.resulthub.api.dataset.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class RecordRequest {
    private String recordKey;
    private String recordTitle;
    private List<String> tags;

    @NotNull(message = "Data payload is required")
    private Map<String, Object> data;

    private Long version;
}
