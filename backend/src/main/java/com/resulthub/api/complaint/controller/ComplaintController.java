package com.resulthub.api.complaint.controller;

import com.resulthub.api.complaint.dto.CastVoteRequest;
import com.resulthub.api.complaint.dto.ComplaintCommentResponse;
import com.resulthub.api.complaint.dto.ComplaintResponse;
import com.resulthub.api.complaint.dto.CreateComplaintRequest;
import com.resulthub.api.complaint.entity.Complaint;
import com.resulthub.api.complaint.service.ComplaintMediaService;
import com.resulthub.api.complaint.service.ComplaintService;
import com.resulthub.api.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/complaints")
@RequiredArgsConstructor
public class ComplaintController {

    private final ComplaintService complaintService;
    private final ComplaintMediaService mediaService;

    @GetMapping
    public ResponseEntity<Page<ComplaintResponse>> getComplaints(
            @RequestParam(defaultValue = "trending") String sort,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Complaint.ComplaintStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {

        Pageable pageable = PageRequest.of(page, size);
        UUID currentUserId = user != null ? user.getId() : null;

        if (status != null && category != null) {
            return ResponseEntity.ok(complaintService.getComplaintsByCategoryAndStatus(category, status, pageable, currentUserId));
        }

        if (status != null) {
            return ResponseEntity.ok(complaintService.getComplaintsByStatus(status, pageable, currentUserId));
        }

        if (category != null) {
            return ResponseEntity.ok(complaintService.getComplaintsByCategory(category, pageable, currentUserId));
        }

        return switch (sort.toLowerCase()) {
            case "top" -> ResponseEntity.ok(complaintService.getTopComplaints(pageable, currentUserId));
            case "new" -> ResponseEntity.ok(complaintService.getNewComplaints(pageable, currentUserId));
            default -> ResponseEntity.ok(complaintService.getTrendingComplaints(pageable, currentUserId)); // trending
        };
    }

    @GetMapping("/{id}")
    public ResponseEntity<ComplaintResponse> getComplaintById(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        UUID currentUserId = user != null ? user.getId() : null;
        return ResponseEntity.ok(complaintService.getComplaintById(id, currentUserId));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ComplaintResponse> createComplaint(
            @RequestPart("data") @Valid CreateComplaintRequest request,
            @RequestPart(value = "files", required = false) MultipartFile[] files,
            @AuthenticationPrincipal User user) {
        
        UUID creatorId = user != null ? user.getId() : null;
        ComplaintResponse response = complaintService.createComplaint(request, files, creatorId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> updateStatus(
            @PathVariable UUID id,
            @RequestParam Complaint.ComplaintStatus status) {
        complaintService.updateStatus(id, status);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/vote")
    public ResponseEntity<Void> castVote(
            @PathVariable UUID id,
            @RequestBody @Valid CastVoteRequest request,
            @AuthenticationPrincipal User user) {
        complaintService.castVote(id, request, user.getId());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/flag")
    public ResponseEntity<Void> flagComplaint(@PathVariable UUID id, @AuthenticationPrincipal User user) {
        // user authentication ensures only logged-in users can flag
        complaintService.flagComplaint(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/comments")
    public ResponseEntity<List<ComplaintCommentResponse>> getComments(@PathVariable UUID id) {
        return ResponseEntity.ok(complaintService.getComments(id));
    }

    @PostMapping("/{id}/comments")
    public ResponseEntity<ComplaintCommentResponse> addComment(
            @PathVariable UUID id,
            @RequestParam String content,
            @RequestParam(defaultValue = "false") Boolean isAnonymous,
            @AuthenticationPrincipal User user) {
        ComplaintCommentResponse response = complaintService.addComment(id, content, isAnonymous, user.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/media/{complaintId}/{filename:.+}")
    public ResponseEntity<Resource> serveMediaFile(
            @PathVariable String complaintId,
            @PathVariable String filename) {
        
        Resource file = mediaService.loadMediaAsResource(complaintId, filename);
        
        String mimeType = "application/octet-stream";
        try {
            mimeType = Files.probeContentType(file.getFile().toPath());
        } catch (IOException ignored) {
        }
        
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, mimeType)
                .body(file);
    }
}
