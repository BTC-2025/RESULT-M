package com.resulthub.api.csv.service;

import com.resulthub.api.csv.dto.UploadResponse;
import com.resulthub.api.csv.entity.ImportJob;
import com.resulthub.api.csv.entity.UploadedFile;
import com.resulthub.api.csv.enums.ImportStatus;
import com.resulthub.api.csv.repository.ImportJobRepository;
import com.resulthub.api.csv.repository.UploadedFileRepository;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetRecord;
import com.resulthub.api.dataset.entity.DatasetSchema;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.dataset.repository.DatasetSchemaRepository;
import com.resulthub.api.dataset.service.SchemaValidationService;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CsvImportService {

    private final DatasetRepository datasetRepository;
    private final WorkspaceMemberRepository memberRepository;
    private final DatasetSchemaRepository schemaRepository;
    private final DatasetRecordRepository recordRepository;
    private final ImportJobRepository importJobRepository;
    private final UploadedFileRepository fileRepository;
    private final SchemaValidationService validationService;

    @Transactional
    public UploadResponse uploadCsv(UUID datasetId, MultipartFile file, User user) {
        Dataset dataset = datasetRepository.findByIdAndNotDeleted(datasetId)
                .orElseThrow(() -> new RuntimeException("Dataset not found"));

        validateEditorAccess(dataset.getWorkspace().getId(), user.getId());

        if (file.isEmpty() || !file.getOriginalFilename().endsWith(".csv")) {
            throw new RuntimeException("Invalid file format. Only CSV is supported.");
        }

        try {
            // Simulated file save to local storage
            Path tempFile = Files.createTempFile("resulthub_csv_", ".csv");
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

            log.info("AUDIT: CSV_UPLOAD_STARTED - Job {} queued for Dataset {} by User {}", importJob.getId(), datasetId, user.getId());
            
            // In a real system, we would publish an event here.
            // For now, we will execute it synchronously/asynchronously.
            processCsvImport(importJob.getId(), tempFile);

            return UploadResponse.builder()
                    .importJobId(importJob.getId())
                    .filename(file.getOriginalFilename())
                    .message("Upload successful. Import job queued.")
                    .build();

        } catch (Exception e) {
            log.error("Failed to upload CSV", e);
            throw new RuntimeException("Upload failed: " + e.getMessage());
        }
    }

    @Async
    @Transactional
    public void processCsvImport(UUID jobId, Path filePath) {
        ImportJob job = importJobRepository.findById(jobId).orElseThrow();
        job.setStatus(ImportStatus.PROCESSING);
        job.setStartedAt(LocalDateTime.now());
        importJobRepository.save(job);

        DatasetSchema schema = schemaRepository.findByDatasetId(job.getDataset().getId()).orElse(null);
        
        int total = 0;
        int successful = 0;
        int failed = 0;
        
        List<DatasetRecord> batch = new ArrayList<>();
        int BATCH_SIZE = 1000;

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(Files.newInputStream(filePath), StandardCharsets.UTF_8));
             CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT.withFirstRecordAsHeader().withIgnoreHeaderCase().withTrim())) {

            for (CSVRecord csvRecord : csvParser) {
                total++;
                try {
                    Map<String, Object> rowData = new HashMap<>();
                    csvRecord.toMap().forEach(rowData::put); // All strings initially from CSV
                    
                    // Note: A true production engine would parse numeric strings to actual Numbers based on the JSON schema here.
                    // For brevity, we pass the raw map to validation.
                    
                    if (schema != null && schema.getIsRequired()) {
                        validationService.validateDataAgainstSchema(rowData, schema.getSchemaDefinition());
                    }

                    DatasetRecord record = DatasetRecord.builder()
                            .dataset(job.getDataset())
                            .recordKey(UUID.randomUUID().toString()) // Can be derived from a specific column if configured
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
                    log.error("Row {} failed validation: {}", total, rowEx.getMessage());
                    // Real implementation would stream this to an error CSV file
                }
            }

            if (!batch.isEmpty()) {
                recordRepository.saveAll(batch);
                successful += batch.size();
            }

            job.setStatus(failed > 0 ? (successful == 0 ? ImportStatus.FAILED : ImportStatus.COMPLETED) : ImportStatus.COMPLETED);
            
            log.info("AUDIT: CSV_UPLOAD_COMPLETED - Job {} completed. Imported: {}, Failed: {}", jobId, successful, failed);

        } catch (Exception e) {
            job.setStatus(ImportStatus.FAILED);
            job.setErrorFilePath("Critical error: " + e.getMessage());
            log.error("AUDIT: CSV_UPLOAD_FAILED - Job {} failed.", jobId, e);
        } finally {
            job.setTotalRows(total);
            job.setSuccessfulRows(successful);
            job.setFailedRows(failed);
            job.setCompletedAt(LocalDateTime.now());
            importJobRepository.save(job);
        }
    }

    private void validateEditorAccess(UUID workspaceId, UUID userId) {
        WorkspaceMember member = memberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                .orElseThrow(() -> new RuntimeException("Access denied. Must be a member of the workspace."));
        if (member.getRole() == WorkspaceRole.VIEWER) {
            throw new RuntimeException("Access denied. VIEWER cannot upload CSV data.");
        }
    }
}
