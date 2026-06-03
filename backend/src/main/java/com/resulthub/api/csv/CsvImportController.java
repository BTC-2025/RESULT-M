package com.resulthub.api.csv;

import com.resulthub.api.csv.dto.UploadResponse;
import com.resulthub.api.csv.service.CsvImportService;
import com.resulthub.api.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class CsvImportController {

    private final CsvImportService csvImportService;

    @PostMapping("/datasets/{datasetId}/upload-csv")
    public ResponseEntity<UploadResponse> uploadCsv(
            @PathVariable UUID datasetId,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(csvImportService.uploadCsv(datasetId, file, user));
    }
}
