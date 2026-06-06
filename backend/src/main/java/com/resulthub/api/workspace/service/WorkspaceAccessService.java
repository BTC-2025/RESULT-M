package com.resulthub.api.workspace.service;

import com.resulthub.api.security.WorkspaceTokenService;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.VisibilityMode;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class WorkspaceAccessService {

    private final WorkspaceMemberRepository memberRepository;
    private final WorkspaceTokenService workspaceTokenService;

    public void validateCanView(Workspace workspace, User user, String authHeader) {
        if (workspace.getVisibility() == VisibilityMode.PUBLIC) {
            return;
        }

        UUID workspaceId = workspace.getId();
        if (user != null && memberRepository.existsByWorkspaceIdAndUserId(workspaceId, user.getId())) {
            return;
        }

        if (workspace.getVisibility() == VisibilityMode.PASSWORD_PROTECTED
                && isValidWorkspaceToken(authHeader, workspaceId)) {
            return;
        }

        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied for workspace");
    }

    public void validateCanEdit(Workspace workspace, User user) {
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication required");
        }

        WorkspaceMember member = memberRepository
                .findByWorkspaceIdAndUserId(workspace.getId(), user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "Workspace membership required"));

        if (member.getRole() == WorkspaceRole.VIEWER) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Editor access required");
        }
    }

    public boolean isMember(UUID workspaceId, User user) {
        return user != null && memberRepository.existsByWorkspaceIdAndUserId(workspaceId, user.getId());
    }

    private boolean isValidWorkspaceToken(String authHeader, UUID workspaceId) {
        if (authHeader == null || !authHeader.startsWith("Workspace ")) {
            return false;
        }

        String token = authHeader.substring(10);
        if (!workspaceTokenService.isTokenValid(token)) {
            return false;
        }

        String tokenWorkspaceId = workspaceTokenService.extractWorkspaceId(token);
        return workspaceId.toString().equals(tokenWorkspaceId);
    }
}
