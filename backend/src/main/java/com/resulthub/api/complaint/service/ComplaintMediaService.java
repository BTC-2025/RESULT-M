package com.resulthub.api.complaint.service;

import com.resulthub.api.common.exception.PayloadTooLargeException;
import com.resulthub.api.common.exception.UnsupportedMediaTypeException;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class ComplaintMediaService {

    @Value("${app.upload.dir:uploads/complaints}")
    private String uploadDir;

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final int MAX_FILES = 5;
    private static final Set<String> ALLOWED_MIME_TYPES = Set.of(
            "image/jpeg",
            "image/png",
            "image/webp",
            "video/mp4"
    );

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(Paths.get(uploadDir));
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directory", e);
        }
    }

    public String[] saveMediaFiles(UUID complaintId, MultipartFile[] files) {
        if (files == null || files.length == 0) {
            return new String[0];
        }

        if (files.length > MAX_FILES) {
            throw new PayloadTooLargeException("Maximum " + MAX_FILES + " files allowed");
        }

        List<String> savedPaths = new ArrayList<>();
        Path complaintDir = Paths.get(uploadDir, complaintId.toString());

        try {
            Files.createDirectories(complaintDir);

            for (MultipartFile file : files) {
                if (file.isEmpty()) continue;

                if (file.getSize() > MAX_FILE_SIZE) {
                    throw new PayloadTooLargeException("File " + file.getOriginalFilename() + " exceeds 10MB limit");
                }

                String contentType = file.getContentType();
                if (contentType == null || !ALLOWED_MIME_TYPES.contains(contentType)) {
                    throw new UnsupportedMediaTypeException("File type " + contentType + " is not allowed. Allowed types: JPEG, PNG, WEBP, MP4");
                }

                String originalFilename = file.getOriginalFilename();
                if (originalFilename == null) {
                    originalFilename = UUID.randomUUID().toString();
                }

                Path destinationFile = complaintDir.resolve(originalFilename).normalize().toAbsolutePath();

                if (!destinationFile.getParent().equals(complaintDir.toAbsolutePath())) {
                    throw new SecurityException("Cannot store file outside current directory");
                }

                file.transferTo(destinationFile);
                
                // Store relative path
                savedPaths.add(complaintId.toString() + "/" + originalFilename);
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to store media files", e);
        }

        return savedPaths.toArray(new String[0]);
    }

    public Resource loadMediaAsResource(String complaintId, String filename) {
        try {
            Path filePath = Paths.get(uploadDir, complaintId, filename).normalize();
            Resource resource = new FileSystemResource(filePath);
            
            if (resource.exists() || resource.isReadable()) {
                return resource;
            } else {
                throw new RuntimeException("Could not read file: " + filename);
            }
        } catch (Exception e) {
            throw new RuntimeException("Could not read file: " + filename, e);
        }
    }
}
