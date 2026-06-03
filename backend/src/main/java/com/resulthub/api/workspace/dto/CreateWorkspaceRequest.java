package com.resulthub.api.workspace.dto;

import com.resulthub.api.workspace.enums.VisibilityMode;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateWorkspaceRequest {
    @NotBlank(message = "Workspace name is required")
    private String name;

    @NotBlank(message = "Slug is required")
    private String slug;

    private String description;

    @NotNull(message = "Visibility mode is required")
    private VisibilityMode visibility;

    private String accessCode; // Required if visibility is PASSWORD_PROTECTED
}
