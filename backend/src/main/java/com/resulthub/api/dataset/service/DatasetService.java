package com.resulthub.api.dataset.service;

import com.resulthub.api.dataset.dto.DatasetRequest;
import com.resulthub.api.dataset.dto.DatasetResponse;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.enums.DatasetStatus;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DatasetService {

    private final DatasetRepository datasetRepository;
    private final WorkspaceRepository workspaceRepository;
    private final WorkspaceMemberRepository memberRepository;

    @Transactional
    public DatasetResponse createDataset(UUID workspaceId, DatasetRequest request, User user) {
        Workspace workspace = workspaceRepository.findByIdAndNotDeleted(workspaceId)
                .orElseThrow(() -> new RuntimeException("Workspace not found"));

        validateEditorAccess(workspaceId, user.getId());

        Dataset dataset = Dataset.builder()
                .workspace(workspace)
                .name(request.getName())
                .slug(request.getSlug())
                .description(request.getDescription())
                .domainType(request.getDomainType())
                .status(DatasetStatus.DRAFT)
                .createdBy(user)
                .build();

        dataset = datasetRepository.save(dataset);
        log.info("AUDIT: DATASET_CREATED - Dataset {} created by User {}", dataset.getId(), user.getId());
        return mapToResponse(dataset);
    }

    public Page<DatasetResponse> getDatasetsByWorkspace(UUID workspaceId, Pageable pageable) {
        // Assume workspace visibility check is done at the controller layer or a facade
        return datasetRepository.findByWorkspaceIdAndNotDeleted(workspaceId, pageable)
                .map(this::mapToResponse);
    }

    public DatasetResponse getDataset(UUID id) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));
        return mapToResponse(dataset);
    }

    @Transactional
    public DatasetResponse updateDataset(UUID id, DatasetRequest request, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));

        validateEditorAccess(dataset.getWorkspace().getId(), user.getId());

        dataset.setName(request.getName());
        dataset.setDescription(request.getDescription());
        dataset.setDomainType(request.getDomainType());
        // Do not update slug directly in standard update
        dataset.setVersion(dataset.getVersion() + 1);

        dataset = datasetRepository.save(dataset);
        log.info("AUDIT: DATASET_UPDATED - Dataset {} updated by User {}", dataset.getId(), user.getId());
        return mapToResponse(dataset);
    }

    @Transactional
    public void publishDataset(UUID id, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));
        validateEditorAccess(dataset.getWorkspace().getId(), user.getId());
        
        dataset.setStatus(DatasetStatus.PUBLISHED);
        datasetRepository.save(dataset);
        log.info("AUDIT: DATASET_PUBLISHED - Dataset {} published by User {}", dataset.getId(), user.getId());
    }

    @Transactional
    public void archiveDataset(UUID id, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));
        validateEditorAccess(dataset.getWorkspace().getId(), user.getId());
        
        dataset.setStatus(DatasetStatus.ARCHIVED);
        datasetRepository.save(dataset);
        log.info("AUDIT: DATASET_ARCHIVED - Dataset {} archived by User {}", dataset.getId(), user.getId());
    }

    @Transactional
    public void deleteDataset(UUID id, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(id)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));
        validateEditorAccess(dataset.getWorkspace().getId(), user.getId());
        
        dataset.setDeletedAt(LocalDateTime.now());
        datasetRepository.save(dataset);
        log.info("AUDIT: DATASET_DELETED - Dataset {} soft-deleted by User {}", dataset.getId(), user.getId());
    }

    private void validateEditorAccess(UUID workspaceId, UUID userId) {
        WorkspaceMember member = memberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                .orElseThrow(() -> new RuntimeException("Access denied. Must be a member of the workspace."));
        
        if (member.getRole() == WorkspaceRole.VIEWER) {
            throw new RuntimeException("Access denied. VIEWER cannot modify datasets.");
        }
    }

    private DatasetResponse mapToResponse(Dataset dataset) {
        return DatasetResponse.builder()
                .id(dataset.getId())
                .workspaceId(dataset.getWorkspace().getId())
                .name(dataset.getName())
                .slug(dataset.getSlug())
                .description(dataset.getDescription())
                .domainType(dataset.getDomainType())
                .status(dataset.getStatus())
                .version(dataset.getVersion())
                .createdById(dataset.getCreatedBy() != null ? dataset.getCreatedBy().getId() : null)
                .createdAt(dataset.getCreatedAt())
                .updatedAt(dataset.getUpdatedAt())
                .build();
    }
}
