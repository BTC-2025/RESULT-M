package com.resulthub.api.workspace;

import com.resulthub.api.dataset.enums.DomainType;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.dto.CreateWorkspaceRequest;
import com.resulthub.api.workspace.dto.UpdateWorkspaceRequest;
import com.resulthub.api.workspace.dto.WorkspaceResponse;
import com.resulthub.api.workspace.service.WorkspaceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/workspaces")
@RequiredArgsConstructor
public class WorkspaceController {

    private final WorkspaceService workspaceService;

    @PostMapping
    public ResponseEntity<WorkspaceResponse> createWorkspace(
            @Valid @RequestBody CreateWorkspaceRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(workspaceService.createWorkspace(request, user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<WorkspaceResponse> getWorkspace(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String accessCode
    ) {
        return ResponseEntity.ok(workspaceService.getWorkspace(id, user, accessCode));
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<WorkspaceResponse> getWorkspaceBySlug(
            @PathVariable String slug
    ) {
        return ResponseEntity.ok(workspaceService.getWorkspaceBySlug(slug));
    }

    @PostMapping("/{id}/unlock")
    public ResponseEntity<com.resulthub.api.workspace.dto.UnlockWorkspaceResponse> unlockWorkspace(
            @PathVariable UUID id,
            @Valid @RequestBody com.resulthub.api.workspace.dto.UnlockWorkspaceRequest request
    ) {
        String token = workspaceService.unlockWorkspace(id, request.getAccessCode());
        return ResponseEntity.ok(new com.resulthub.api.workspace.dto.UnlockWorkspaceResponse(token));
    }

    @GetMapping("/my")
    public ResponseEntity<Page<WorkspaceResponse>> getMyWorkspaces(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        return ResponseEntity.ok(workspaceService.getMyWorkspaces(user, PageRequest.of(page, size)));
    }

    @GetMapping("/public")
    public ResponseEntity<Page<WorkspaceResponse>> getPublicWorkspaces(
            @RequestParam(required = false) DomainType domainType,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        return ResponseEntity.ok(workspaceService.getPublicWorkspaces(domainType, PageRequest.of(page, size)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<WorkspaceResponse> updateWorkspace(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateWorkspaceRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(workspaceService.updateWorkspace(id, request, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWorkspace(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        workspaceService.deleteWorkspace(id, user);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/share-link")
    public ResponseEntity<com.resulthub.api.workspace.dto.ShareLinkResponse> getShareLink(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        String link = workspaceService.generateShareLink(id, user);
        return ResponseEntity.ok(new com.resulthub.api.workspace.dto.ShareLinkResponse(link));
    }

    @PostMapping("/{id}/regenerate-code")
    public ResponseEntity<com.resulthub.api.workspace.dto.ShareLinkResponse> regenerateCode(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        String link = workspaceService.regenerateAccessCode(id, user);
        return ResponseEntity.ok(new com.resulthub.api.workspace.dto.ShareLinkResponse(link));
    }
}
