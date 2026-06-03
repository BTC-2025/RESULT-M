package com.resulthub.api.dataset.service;

import com.resulthub.api.dataset.dto.RecordRequest;
import com.resulthub.api.dataset.dto.RecordResponse;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetRecord;
import com.resulthub.api.dataset.entity.DatasetSchema;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.dataset.repository.DatasetSchemaRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DatasetRecordService {

    private final DatasetRecordRepository recordRepository;
    private final DatasetRepository datasetRepository;
    private final DatasetSchemaRepository schemaRepository;
    private final WorkspaceMemberRepository memberRepository;
    private final SchemaValidationService validationService;
    private final com.resulthub.api.security.WorkspaceTokenService workspaceTokenService;

    @Transactional
    public RecordResponse createRecord(UUID datasetId, RecordRequest request, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(datasetId)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));

        validateEditorAccess(dataset.getWorkspace().getId(), user.getId());

        Optional<DatasetSchema> schemaOpt = schemaRepository.findByDatasetId(datasetId);
        if (schemaOpt.isPresent() && schemaOpt.get().getIsRequired()) {
            validationService.validateDataAgainstSchema(request.getData(), schemaOpt.get().getSchemaDefinition());
        }

        DatasetRecord record = DatasetRecord.builder()
                .dataset(dataset)
                .recordKey(request.getRecordKey())
                .recordTitle(request.getRecordTitle())
                .tags(request.getTags())
                .data(request.getData())
                .build();

        record = recordRepository.save(record);
        log.info("AUDIT: RECORD_CREATED - Record {} created in Dataset {} by User {}", record.getId(), datasetId, user.getId());
        return mapToResponse(record);
    }

    public Page<RecordResponse> getRecords(UUID datasetId, Pageable pageable) {
        // Validation for workspace visibility should ideally happen upstream or via a facade,
        // assuming viewer has access for now based on controller checks.
        return recordRepository.findByDatasetIdAndNotDeleted(datasetId, pageable)
                .map(this::mapToResponse);
    }

    public RecordResponse getRecord(UUID recordId) {
        DatasetRecord record = recordRepository.findByIdAndNotDeleted(recordId)
                .orElseThrow(() -> new RuntimeException("Record not found"));
        return mapToResponse(record);
    }

    @Transactional
    public RecordResponse updateRecord(UUID recordId, RecordRequest request, User user) {
        DatasetRecord record = recordRepository.findByIdAndNotDeleted(recordId)
                .orElseThrow(() -> new RuntimeException("Record not found"));

        if (request.getVersion() != null && !request.getVersion().equals(record.getVersion())) {
            throw new org.springframework.orm.ObjectOptimisticLockingFailureException(DatasetRecord.class, record.getId());
        }

        validateEditorAccess(record.getDataset().getWorkspace().getId(), user.getId());

        Optional<DatasetSchema> schemaOpt = schemaRepository.findByDatasetId(record.getDataset().getId());
        if (schemaOpt.isPresent() && schemaOpt.get().getIsRequired()) {
            validationService.validateDataAgainstSchema(request.getData(), schemaOpt.get().getSchemaDefinition());
        }

        record.setRecordKey(request.getRecordKey());
        record.setRecordTitle(request.getRecordTitle());
        record.setTags(request.getTags());
        
        if (request.getData() != null) {
            java.util.Map<String, Object> existingData = record.getData();
            if (existingData == null) {
                existingData = new java.util.HashMap<>();
            } else {
                existingData = new java.util.HashMap<>(existingData);
            }
            existingData.putAll(request.getData());
            record.setData(existingData);
        }

        record = recordRepository.save(record);
        log.info("AUDIT: RECORD_UPDATED - Record {} updated by User {}", record.getId(), user.getId());
        return mapToResponse(record);
    }

    @Transactional
    public void deleteRecord(UUID recordId, User user) {
        DatasetRecord record = recordRepository.findByIdAndNotDeleted(recordId)
                .orElseThrow(() -> new RuntimeException("Record not found"));

        validateEditorAccess(record.getDataset().getWorkspace().getId(), user.getId());

        record.setDeletedAt(LocalDateTime.now());
        recordRepository.save(record);
        log.info("AUDIT: RECORD_DELETED - Record {} soft-deleted by User {}", record.getId(), user.getId());
    }

    private void validateEditorAccess(UUID workspaceId, UUID userId) {
        WorkspaceMember member = memberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                .orElseThrow(() -> new RuntimeException("Access denied. Must be a member of the workspace."));

        if (member.getRole() == WorkspaceRole.VIEWER) {
            throw new RuntimeException("Access denied. VIEWER cannot modify records.");
        }
    }

    public RecordResponse lookupRecord(UUID datasetId, String rollNumber, String dateOfBirth, String authHeader) {
        if ((rollNumber == null || rollNumber.trim().isEmpty()) && (dateOfBirth == null || dateOfBirth.trim().isEmpty())) {
            throw new IllegalArgumentException("Must provide either rollNumber or dateOfBirth");
        }

        Dataset dataset = datasetRepository.findByIdAndNotDeleted(datasetId)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));

        if (dataset.getWorkspace().getVisibility() == com.resulthub.api.workspace.enums.VisibilityMode.PRIVATE) {
            throw new RuntimeException("Access denied. Private workspace results cannot be looked up publicly.");
        }

        if (dataset.getWorkspace().getVisibility() == com.resulthub.api.workspace.enums.VisibilityMode.PASSWORD_PROTECTED) {
            if (authHeader == null || !authHeader.startsWith("Workspace ")) {
                throw new RuntimeException("Access denied. Missing workspace token.");
            }
            String token = authHeader.substring(10);
            if (!workspaceTokenService.isTokenValid(token)) {
                throw new RuntimeException("Access denied. Invalid workspace token.");
            }
            String tokenWorkspaceId = workspaceTokenService.extractWorkspaceId(token);
            if (!tokenWorkspaceId.equals(dataset.getWorkspace().getId().toString())) {
                throw new RuntimeException("Access denied. Token does not match dataset's workspace.");
            }
        }

        DatasetRecord record = recordRepository.lookupRecord(datasetId, rollNumber, dateOfBirth)
                .orElseThrow(() -> new RuntimeException("No result found for the provided details"));

        return mapToResponse(record);
    }

    private RecordResponse mapToResponse(DatasetRecord record) {
        return RecordResponse.builder()
                .id(record.getId())
                .datasetId(record.getDataset().getId())
                .recordKey(record.getRecordKey())
                .recordTitle(record.getRecordTitle())
                .tags(record.getTags())
                .data(record.getData())
                .version(record.getVersion())
                .createdAt(record.getCreatedAt())
                .updatedAt(record.getUpdatedAt())
                .build();
    }
}
