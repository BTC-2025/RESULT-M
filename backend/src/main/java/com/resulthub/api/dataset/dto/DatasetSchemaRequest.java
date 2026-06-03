package com.resulthub.api.dataset.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.Map;

@Data
public class DatasetSchemaRequest {
    @NotBlank(message = "Schema name is required")
    private String schemaName;

    @NotNull(message = "Schema definition is required")
    private Map<String, Object> schemaDefinition;

    private Boolean isRequired = true;
}
