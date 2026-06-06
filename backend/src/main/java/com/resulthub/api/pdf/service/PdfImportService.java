package com.resulthub.api.pdf.service;

import com.resulthub.api.csv.dto.ImportJobResponse;
import com.resulthub.api.csv.dto.UploadResponse;
import com.resulthub.api.csv.entity.ImportJob;
import com.resulthub.api.csv.entity.UploadedFile;
import com.resulthub.api.csv.enums.ImportStatus;
import com.resulthub.api.csv.repository.ImportJobRepository;
import com.resulthub.api.csv.repository.UploadedFileRepository;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetRecord;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class PdfImportService {

    private final DatasetRepository datasetRepository;
    private final WorkspaceMemberRepository memberRepository;
    private final DatasetRecordRepository recordRepository;
    private final ImportJobRepository importJobRepository;
    private final UploadedFileRepository fileRepository;

    @Transactional
    public UploadResponse uploadPdf(UUID datasetId, MultipartFile file, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(datasetId)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));

        validateEditorAccess(dataset.getWorkspace().getId(), user.getId());

        try {
            Path tempFile = Files.createTempFile("resulthub_pdf_", ".pdf");
            file.transferTo(tempFile.toFile());

            UploadedFile uploadedFile = UploadedFile.builder()
                    .workspace(dataset.getWorkspace())
                    .dataset(dataset)
                    .originalFilename(file.getOriginalFilename())
                    .storedFilename(tempFile.getFileName().toString())
                    .filePath(tempFile.toString())
                    .mimeType(file.getContentType())
                    .fileSize(file.getSize())
                    .uploadedBy(user)
                    .build();
            fileRepository.save(uploadedFile);

            ImportJob importJob = ImportJob.builder()
                    .dataset(dataset)
                    .uploadedBy(user)
                    .filename(file.getOriginalFilename())
                    .status(ImportStatus.PENDING)
                    .build();
            importJob = importJobRepository.save(importJob);

            log.info("AUDIT: PDF_UPLOAD_STARTED - Job {} queued for Dataset {} by User {}", importJob.getId(), datasetId, user.getId());
            
            processPdfImport(importJob.getId(), tempFile);

            return UploadResponse.builder()
                    .importJobId(importJob.getId())
                    .filename(file.getOriginalFilename())
                    .message("PDF upload successful. Parsing job queued.")
                    .build();

        } catch (Exception e) {
            log.error("Failed to upload PDF", e);
            throw new RuntimeException("Upload failed: " + e.getMessage());
        }
    }

    @Async
    @Transactional
    public void processPdfImport(UUID jobId, Path filePath) {
        ImportJob job = importJobRepository.findById(jobId).orElseThrow();
        job.setStatus(ImportStatus.PROCESSING);
        job.setStartedAt(LocalDateTime.now());
        importJobRepository.save(job);

        int total = 0;
        int successful = 0;
        int failed = 0;
        
        List<DatasetRecord> batch = new ArrayList<>();
        int BATCH_SIZE = 1000;

        try (PDDocument document = Loader.loadPDF(filePath.toFile())) {
            PDFTextStripper pdfStripper = new PDFTextStripper();
            pdfStripper.setSortByPosition(true); // Attempt to sort texts by coordinates
            String text = pdfStripper.getText(document);

            String[] lines = text.split("\\r?\\n");
            
            // Strategy 1: Table Detection via heuristics
            // Look for a line that looks like a header (multiple words separated by wide spaces)
            boolean isTableStructure = false;
            String[] headers = null;
            
            for (int i = 0; i < Math.min(lines.length, 20); i++) {
                String line = lines[i].trim();
                if (line.contains("  ") || line.contains("\\t") || line.contains("|")) {
                    headers = line.split("\\s{2,}|\\t|\\|"); // Split by multiple spaces, tab, or pipe
                    if (headers.length > 2) { // At least 3 columns
                        isTableStructure = true;
                        break;
                    }
                }
            }

            for (String line : lines) {
                line = line.trim();
                if (line.isEmpty()) continue;
                total++;

                try {
                    Map<String, Object> rowData = new HashMap<>();
                    
                    if (isTableStructure && headers != null) {
                        String[] columns = line.split("\\s{2,}|\\t|\\|");
                        for (int i = 0; i < Math.min(headers.length, columns.length); i++) {
                            rowData.put(headers[i].trim(), columns[i].trim());
                        }
                    } else {
                        // Strategy 2: Fallback to whole line
                        rowData.put("line", line);
                    }

                    DatasetRecord record = DatasetRecord.builder()
                            .dataset(job.getDataset())
                            .recordKey(UUID.randomUUID().toString())
                            .data(rowData)
                            .build();

                    batch.add(record);

                    if (batch.size() >= BATCH_SIZE) {
                        recordRepository.saveAll(batch);
                        successful += batch.size();
                        batch.clear();
                    }
                } catch (Exception rowEx) {
                    failed++;
                    log.error("PDF Row {} failed validation: {}", total, rowEx.getMessage());
                }
            }

            if (!batch.isEmpty()) {
                recordRepository.saveAll(batch);
                successful += batch.size();
            }

            job.setStatus(failed > 0 ? (successful == 0 ? ImportStatus.FAILED : ImportStatus.COMPLETED) : ImportStatus.COMPLETED);
            log.info("AUDIT: PDF_UPLOAD_COMPLETED - Job {} completed. Imported: {}, Failed: {}", jobId, successful, failed);

        } catch (Exception e) {
            job.setStatus(ImportStatus.FAILED);
            job.setErrorFilePath("Critical error parsing PDF: " + e.getMessage());
            log.error("AUDIT: PDF_UPLOAD_FAILED - Job {} failed.", jobId, e);
        } finally {
            job.setTotalRows(total);
            job.setSuccessfulRows(successful);
            job.setFailedRows(failed);
            job.setCompletedAt(LocalDateTime.now());
            importJobRepository.save(job);
        }
    }

    public ImportJobResponse getJobStatus(UUID jobId, User user) {
        ImportJob job = importJobRepository.findById(jobId).orElseThrow(() -> new RuntimeException("Job not found"));
        // Basic security check: user must be member of workspace
        validateEditorAccess(job.getDataset().getWorkspace().getId(), user.getId());

        return ImportJobResponse.builder()
                .id(job.getId())
                .datasetId(job.getDataset().getId())
                .filename(job.getFilename())
                .status(job.getStatus())
                .totalRows(job.getTotalRows())
                .successfulRows(job.getSuccessfulRows())
                .failedRows(job.getFailedRows())
                .errorFilePath(job.getErrorFilePath())
                .startedAt(job.getStartedAt())
                .completedAt(job.getCompletedAt())
                .createdAt(job.getCreatedAt())
                .build();
    }

    private void validateEditorAccess(UUID workspaceId, UUID userId) {
        WorkspaceMember member = memberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                .orElseThrow(() -> new RuntimeException("Access denied. Must be a member of the workspace."));
        if (member.getRole() == WorkspaceRole.VIEWER) {
            throw new RuntimeException("Access denied. VIEWER cannot upload PDF data.");
        }
    }
}
