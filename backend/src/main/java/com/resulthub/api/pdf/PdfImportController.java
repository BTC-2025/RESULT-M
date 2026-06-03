package com.resulthub.api.pdf;

import com.resulthub.api.csv.dto.ImportJobResponse;
import com.resulthub.api.csv.dto.UploadResponse;
import com.resulthub.api.pdf.service.PdfImportService;
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
public class PdfImportController {

    private final PdfImportService pdfImportService;

    @PostMapping("/pdf/import")
    public ResponseEntity<UploadResponse> uploadPdf(
            @RequestParam UUID datasetId,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal User user
    ) {
        if (file.isEmpty() || !file.getOriginalFilename().toLowerCase().endsWith(".pdf")) {
            return ResponseEntity.badRequest().body(UploadResponse.builder()
                    .message("Invalid file format. Only PDF is supported.")
                    .build());
        }
        
        // 20MB limit (checked by Spring config mostly, but we can do a hard check here too)
        if (file.getSize() > 20 * 1024 * 1024) {
            return ResponseEntity.status(413).body(UploadResponse.builder()
                    .message("Payload Too Large. Max size is 20MB.")
                    .build());
        }

        return ResponseEntity.ok(pdfImportService.uploadPdf(datasetId, file, user));
    }

    @GetMapping("/pdf/import/{jobId}")
    public ResponseEntity<ImportJobResponse> getJobStatus(
            @PathVariable UUID jobId,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(pdfImportService.getJobStatus(jobId, user));
    }
}
