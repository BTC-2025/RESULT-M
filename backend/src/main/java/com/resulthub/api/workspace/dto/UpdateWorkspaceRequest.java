package com.resulthub.api.workspace.dto;

import com.resulthub.api.workspace.enums.VisibilityMode;
import lombok.Data;

@Data
public class UpdateWorkspaceRequest {
    private String name;
    private String description;
    private VisibilityMode visibility;
    private String accessCode;
}
