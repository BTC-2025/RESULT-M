package com.resulthub.api.workspace.service;

import com.resulthub.api.dataset.enums.DatasetStatus;
import com.resulthub.api.dataset.enums.DomainType;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.dto.CreateWorkspaceRequest;
import com.resulthub.api.workspace.dto.UpdateWorkspaceRequest;
import com.resulthub.api.workspace.dto.WorkspaceResponse;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.VisibilityMode;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class WorkspaceService {

    private final WorkspaceRepository workspaceRepository;
    private final WorkspaceMemberRepository memberRepository;
    private final com.resulthub.api.security.WorkspaceTokenService workspaceTokenService;

    @Transactional
    @CacheEvict(value = "publicWorkspaces", allEntries = true)
    public WorkspaceResponse createWorkspace(CreateWorkspaceRequest request, User user) {
        Workspace workspace = Workspace.builder()
                .name(request.getName())
                .slug(request.getSlug())
                .description(request.getDescription())
                .visibility(request.getVisibility())
                .accessCode(request.getAccessCode())
                .owner(user)
                .build();
        workspace = workspaceRepository.save(workspace);

        WorkspaceMember ownerMember = WorkspaceMember.builder()
                .workspace(workspace)
                .user(user)
                .role(WorkspaceRole.OWNER)
                .build();
        memberRepository.save(ownerMember);

        log.info("AUDIT: WORKSPACE_CREATED - Workspace {} created by User {}", workspace.getId(), user.getId());
        return mapToResponse(workspace);
    }

    public WorkspaceResponse getWorkspace(UUID id, User user, String providedAccessCode) {
        Workspace workspace = workspaceRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Workspace not found"));

        if (workspace.getVisibility() == VisibilityMode.PUBLIC) {
            return mapToResponse(workspace);
        }

        if (workspace.getVisibility() == VisibilityMode.PASSWORD_PROTECTED) {
            if (workspace.getAccessCode().equals(providedAccessCode)) {
                return mapToResponse(workspace);
            }
            if (user != null && memberRepository.existsByWorkspaceIdAndUserId(id, user.getId())) {
                return mapToResponse(workspace);
            }
            throw new RuntimeException("Invalid access code or not a member");
        }

        if (workspace.getVisibility() == VisibilityMode.PRIVATE) {
            if (user == null || !memberRepository.existsByWorkspaceIdAndUserId(id, user.getId())) {
                throw new RuntimeException("Access denied. Must be an invited member.");
            }
            return mapToResponse(workspace);
        }

        throw new RuntimeException("Unknown visibility mode");
    }

    public WorkspaceResponse getWorkspaceBySlug(String slug) {
        Workspace workspace = workspaceRepository.findBySlugAndNotDeleted(slug)
                .orElseThrow(() -> new RuntimeException("Workspace not found"));
                
        // Only return basic details so resolver knows where to route
        return mapToResponse(workspace);
    }

    public String unlockWorkspace(UUID id, String accessCode) {
        Workspace workspace = workspaceRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Workspace not found"));

        if (workspace.getVisibility() != VisibilityMode.PASSWORD_PROTECTED) {
            throw new RuntimeException("Workspace is not password protected");
        }

        if (!workspace.getAccessCode().equals(accessCode)) {
            throw new RuntimeException("Invalid access code");
        }

        return workspaceTokenService.generateToken(workspace.getId().toString());
    }

    @Cacheable(
            value = "publicWorkspaces",
            key = "(#domainType == null ? 'ALL' : #domainType.name()) + ':' + #pageable.pageNumber + ':' + #pageable.pageSize",
            sync = true
    )
    public Page<WorkspaceResponse> getPublicWorkspaces(DomainType domainType, Pageable pageable) {
        Page<Workspace> workspaces = domainType == null
                ? workspaceRepository.findByVisibilityAndNotDeleted(VisibilityMode.PUBLIC, pageable)
                : workspaceRepository.findByVisibilityAndPublishedDomainAndNotDeleted(
                        VisibilityMode.PUBLIC,
                        DatasetStatus.PUBLISHED,
                        domainType,
                        pageable
                );

        return workspaces
                .map(this::mapToResponse);
    }

    public Page<WorkspaceResponse> getMyWorkspaces(User user, Pageable pageable) {
        return workspaceRepository.findByOwnerIdAndNotDeleted(user.getId(), pageable)
                .map(this::mapToResponse);
    }

    @Transactional
    @CacheEvict(value = "publicWorkspaces", allEntries = true)
    public WorkspaceResponse updateWorkspace(UUID id, UpdateWorkspaceRequest request, User user) {
        Workspace workspace = validateOwner(id, user);

        if (request.getName() != null) workspace.setName(request.getName());
        if (request.getDescription() != null) workspace.setDescription(request.getDescription());
        if (request.getVisibility() != null) workspace.setVisibility(request.getVisibility());
        if (request.getAccessCode() != null) workspace.setAccessCode(request.getAccessCode());

        workspace = workspaceRepository.save(workspace);
        log.info("AUDIT: WORKSPACE_UPDATED - Workspace {} updated by User {}", workspace.getId(), user.getId());
        return mapToResponse(workspace);
    }

    @Transactional
    @CacheEvict(value = "publicWorkspaces", allEntries = true)
    public void deleteWorkspace(UUID id, User user) {
        Workspace workspace = validateOwner(id, user);
        workspace.setDeletedAt(LocalDateTime.now());
        workspace.setDeletedBy(user.getId());
        workspaceRepository.save(workspace);
        log.info("AUDIT: WORKSPACE_DELETED - Workspace {} deleted by User {}", workspace.getId(), user.getId());
    }

    private Workspace validateOwner(UUID id, User user) {
        Workspace workspace = workspaceRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Workspace not found"));
        if (!workspace.getOwner().getId().equals(user.getId())) {
            throw new RuntimeException("Access denied. Must be the workspace owner.");
        }
        return workspace;
    }

    private Workspace validateOwnerOrAdmin(UUID id, User user) {
        Workspace workspace = workspaceRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Workspace not found"));
        
        WorkspaceMember member = memberRepository.findByWorkspaceIdAndUserId(id, user.getId())
                .orElseThrow(() -> new RuntimeException("Access denied. Not a member of the workspace."));
                
        if (member.getRole() != WorkspaceRole.OWNER && member.getRole() != WorkspaceRole.ADMIN) {
            throw new RuntimeException("Access denied. Must be OWNER or ADMIN.");
        }
        return workspace;
    }

    public String generateShareLink(UUID workspaceId, User user) {
        Workspace workspace = validateOwnerOrAdmin(workspaceId, user);

        if (workspace.getVisibility() == VisibilityMode.PRIVATE) {
            throw new IllegalArgumentException("Private workspaces cannot be shared via link");
        }

        String baseUrl = "https://resulthub.app/w/" + workspace.getSlug();

        if (workspace.getVisibility() == VisibilityMode.PUBLIC) {
            return baseUrl;
        }

        // PASSWORD_PROTECTED
        return baseUrl + "?code=" + workspace.getAccessCode();
    }

    @Transactional
    public String regenerateAccessCode(UUID workspaceId, User user) {
        Workspace workspace = validateOwnerOrAdmin(workspaceId, user);
        
        if (workspace.getVisibility() == VisibilityMode.PRIVATE) {
            throw new IllegalArgumentException("Private workspaces do not use access codes");
        }

        String newCode = generateRandomAccessCode();
        workspace.setAccessCode(newCode);
        workspaceRepository.save(workspace);
        
        log.info("AUDIT: WORKSPACE_CODE_REGENERATED - Workspace {} code regenerated by User {}", workspace.getId(), user.getId());
        return generateShareLink(workspaceId, user);
    }

    private String generateRandomAccessCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder sb = new StringBuilder(6);
        java.util.Random rnd = new java.util.Random();
        for (int i = 0; i < 6; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }

    private WorkspaceResponse mapToResponse(Workspace workspace) {
        return WorkspaceResponse.builder()
                .id(workspace.getId())
                .name(workspace.getName())
                .slug(workspace.getSlug())
                .description(workspace.getDescription())
                .visibility(workspace.getVisibility())
                .ownerId(workspace.getOwner() != null ? workspace.getOwner().getId() : null)
                .createdAt(workspace.getCreatedAt())
                .build();
    }
}
