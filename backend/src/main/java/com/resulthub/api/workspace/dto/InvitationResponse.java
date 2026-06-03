package com.resulthub.api.workspace.dto;

import com.resulthub.api.workspace.enums.WorkspaceRole;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class InvitationResponse {
    private UUID id;
    private String email;
    private WorkspaceRole role;
    private String token;
    private LocalDateTime expiresAt;
    private String status;
}
