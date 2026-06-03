package com.resulthub.api.dataset.dto;

import com.resulthub.api.dataset.enums.DomainType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DatasetRequest {
    @NotBlank(message = "Dataset name is required")
    private String name;

    @NotBlank(message = "Slug is required")
    private String slug;

    private String description;

    @NotNull(message = "Domain type is required")
    private DomainType domainType;
}
