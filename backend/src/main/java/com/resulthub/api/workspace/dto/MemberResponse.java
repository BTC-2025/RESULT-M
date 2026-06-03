package com.resulthub.api.workspace.dto;

import com.resulthub.api.workspace.enums.WorkspaceRole;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class MemberResponse {
    private UUID id;
    private UUID userId;
    private String name;
    private String email;
    private WorkspaceRole role;
    private LocalDateTime joinedAt;
}
