package com.resulthub.api.dataset;

import com.resulthub.api.dataset.dto.DatasetRequest;
import com.resulthub.api.dataset.dto.DatasetResponse;
import com.resulthub.api.dataset.dto.DatasetSchemaRequest;
import com.resulthub.api.dataset.dto.DatasetSchemaResponse;
import com.resulthub.api.dataset.service.DatasetSchemaService;
import com.resulthub.api.dataset.service.DatasetService;
import com.resulthub.api.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class DatasetController {

    private final DatasetService datasetService;
    private final DatasetSchemaService schemaService;

    @PostMapping("/workspaces/{workspaceId}/datasets")
    public ResponseEntity<DatasetResponse> createDataset(
            @PathVariable UUID workspaceId,
            @Valid @RequestBody DatasetRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(datasetService.createDataset(workspaceId, request, user));
    }

    @GetMapping("/workspaces/{workspaceId}/datasets")
    public ResponseEntity<Page<DatasetResponse>> getDatasetsByWorkspace(
            @PathVariable UUID workspaceId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        return ResponseEntity.ok(datasetService.getDatasetsByWorkspace(workspaceId, PageRequest.of(page, size)));
    }

    @GetMapping("/datasets/{id}")
    public ResponseEntity<DatasetResponse> getDataset(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(datasetService.getDataset(id));
    }

    @PutMapping("/datasets/{id}")
    public ResponseEntity<DatasetResponse> updateDataset(
            @PathVariable UUID id,
            @Valid @RequestBody DatasetRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(datasetService.updateDataset(id, request, user));
    }

    @PostMapping("/datasets/{id}/publish")
    public ResponseEntity<Void> publishDataset(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        datasetService.publishDataset(id, user);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/datasets/{id}/archive")
    public ResponseEntity<Void> archiveDataset(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        datasetService.archiveDataset(id, user);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/datasets/{id}")
    public ResponseEntity<Void> deleteDataset(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user
    ) {
        datasetService.deleteDataset(id, user);
        return ResponseEntity.noContent().build();
    }

    // Schema Management Endpoints
    @PutMapping("/datasets/{id}/schema")
    public ResponseEntity<DatasetSchemaResponse> createOrUpdateSchema(
            @PathVariable UUID id,
            @Valid @RequestBody DatasetSchemaRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(schemaService.createOrUpdateSchema(id, request, user));
    }

    @GetMapping("/datasets/{id}/schema")
    public ResponseEntity<DatasetSchemaResponse> getSchema(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(schemaService.getSchema(id));
    }
}
