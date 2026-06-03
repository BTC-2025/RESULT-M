package com.resulthub.api.workspace.dto;

import com.resulthub.api.workspace.enums.VisibilityMode;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class WorkspaceResponse {
    private UUID id;
    private String name;
    private String slug;
    private String description;
    private VisibilityMode visibility;
    private UUID ownerId;
    private LocalDateTime createdAt;
}
