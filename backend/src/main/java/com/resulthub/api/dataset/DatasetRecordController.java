package com.resulthub.api.dataset;

import com.resulthub.api.dataset.dto.RecordRequest;
import com.resulthub.api.dataset.dto.RecordResponse;
import com.resulthub.api.dataset.service.DatasetRecordService;
import com.resulthub.api.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class DatasetRecordController {

    private final DatasetRecordService recordService;

    @PostMapping("/datasets/{datasetId}/records")
    public ResponseEntity<RecordResponse> createRecord(
            @PathVariable UUID datasetId,
            @Valid @RequestBody RecordRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(recordService.createRecord(datasetId, request, user));
    }

    @GetMapping("/datasets/{datasetId}/records")
    public ResponseEntity<Page<RecordResponse>> getRecords(
            @PathVariable UUID datasetId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @AuthenticationPrincipal User user,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        return ResponseEntity.ok(recordService.getRecords(datasetId, PageRequest.of(page, size), user, authHeader));
    }

    @GetMapping("/datasets/{datasetId}/records/stream")
    public SseEmitter streamRecords(
            @PathVariable UUID datasetId,
            @AuthenticationPrincipal User user,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        return recordService.streamRecords(datasetId, user, authHeader);
    }

    @GetMapping("/records/{recordId}")
    public ResponseEntity<RecordResponse> getRecord(
            @PathVariable UUID recordId,
            @AuthenticationPrincipal User user,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        return ResponseEntity.ok(recordService.getRecord(recordId, user, authHeader));
    }

    @PutMapping("/records/{recordId}")
    public ResponseEntity<RecordResponse> updateRecord(
            @PathVariable UUID recordId,
            @Valid @RequestBody RecordRequest request,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(recordService.updateRecord(recordId, request, user));
    }

    @DeleteMapping("/records/{recordId}")
    public ResponseEntity<Void> deleteRecord(
            @PathVariable UUID recordId,
            @AuthenticationPrincipal User user
    ) {
        recordService.deleteRecord(recordId, user);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/datasets/{datasetId}/records/lookup")
    public ResponseEntity<RecordResponse> lookupRecord(
            @PathVariable UUID datasetId,
            @RequestParam(required = false) String rollNumber,
            @RequestParam(required = false) String dateOfBirth,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        return ResponseEntity.ok(recordService.lookupRecord(datasetId, rollNumber, dateOfBirth, authHeader));
    }
}
