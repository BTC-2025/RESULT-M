package com.resulthub.api.dataset.service;

import com.resulthub.api.dataset.dto.DatasetSchemaRequest;
import com.resulthub.api.dataset.dto.DatasetSchemaResponse;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetSchema;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.dataset.repository.DatasetSchemaRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DatasetSchemaService {

    private final DatasetSchemaRepository schemaRepository;
    private final DatasetRepository datasetRepository;
    private final WorkspaceMemberRepository memberRepository;

    @Transactional
    public DatasetSchemaResponse createOrUpdateSchema(UUID datasetId, DatasetSchemaRequest request, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(datasetId)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));

        WorkspaceMember member = memberRepository.findByWorkspaceIdAndUserId(dataset.getWorkspace().getId(), user.getId())
                .orElseThrow(() -> new RuntimeException("Access denied. Must be a member of the workspace."));

        if (member.getRole() != WorkspaceRole.OWNER && member.getRole() != WorkspaceRole.ADMIN) {
            throw new RuntimeException("Access denied. Only ADMIN or OWNER can modify schemas.");
        }

        DatasetSchema schema = schemaRepository.findByDatasetId(datasetId)
                .orElse(DatasetSchema.builder().dataset(dataset).build());

        schema.setSchemaName(request.getSchemaName());
        schema.setSchemaDefinition(request.getSchemaDefinition());
        schema.setIsRequired(request.getIsRequired());

        schema = schemaRepository.save(schema);
        log.info("AUDIT: SCHEMA_UPDATED - Schema for Dataset {} updated by User {}", datasetId, user.getId());

        return DatasetSchemaResponse.builder()
                .id(schema.getId())
                .datasetId(schema.getDataset().getId())
                .schemaName(schema.getSchemaName())
                .schemaDefinition(schema.getSchemaDefinition())
                .isRequired(schema.getIsRequired())
                .createdAt(schema.getCreatedAt())
                .build();
    }
    
    public DatasetSchemaResponse getSchema(UUID datasetId) {
        DatasetSchema schema = schemaRepository.findByDatasetId(datasetId)
                .orElseThrow(() -> new RuntimeException("Schema not found for dataset"));
        return DatasetSchemaResponse.builder()
                .id(schema.getId())
                .datasetId(schema.getDataset().getId())
                .schemaName(schema.getSchemaName())
                .schemaDefinition(schema.getSchemaDefinition())
                .isRequired(schema.getIsRequired())
                .createdAt(schema.getCreatedAt())
                .build();
    }
}
