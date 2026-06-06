package com.resulthub.api.complaint.service;

import com.resulthub.api.complaint.dto.CastVoteRequest;
import com.resulthub.api.complaint.dto.ComplaintCommentResponse;
import com.resulthub.api.complaint.dto.ComplaintResponse;
import com.resulthub.api.complaint.dto.CreateComplaintRequest;
import com.resulthub.api.complaint.entity.Complaint;
import com.resulthub.api.complaint.entity.ComplaintComment;
import com.resulthub.api.complaint.entity.ComplaintVote;
import com.resulthub.api.complaint.repository.ComplaintCommentRepository;
import com.resulthub.api.complaint.repository.ComplaintRepository;
import com.resulthub.api.complaint.repository.ComplaintVoteRepository;
import com.resulthub.api.outbox.service.WriteOutboxPublisher;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final ComplaintVoteRepository voteRepository;
    private final ComplaintCommentRepository commentRepository;
    private final ComplaintMediaService mediaService;
    private final UserRepository userRepository;
    private final WriteOutboxPublisher outboxPublisher;

    @Transactional
    public ComplaintResponse createComplaint(CreateComplaintRequest request, MultipartFile[] files, UUID creatorId) {
        User creator = creatorId != null
                ? userRepository.findById(creatorId)
                        .orElseThrow(() -> new EntityNotFoundException("User not found"))
                : null;

        Complaint complaint = Complaint.builder()
                .creator(creator)
                .title(request.title())
                .description(request.description())
                .category(request.category())
                .latitude(request.latitude())
                .longitude(request.longitude())
                .locationName(request.locationName())
                .isAnonymous(creator == null || (request.isAnonymous() != null ? request.isAnonymous() : false))
                .build();

        complaint = complaintRepository.save(complaint);

        String[] mediaUrls = mediaService.saveMediaFiles(complaint.getId(), files);
        if (mediaUrls.length > 0) {
            complaint.setMediaUrls(mediaUrls);
            complaint = complaintRepository.save(complaint);
        }

        return mapToResponse(complaint, creatorId);
    }

    public Page<ComplaintResponse> getTrendingComplaints(Pageable pageable, UUID currentUserId) {
        return complaintRepository.findTrending(pageable)
                .map(c -> mapToResponse(c, currentUserId));
    }

    public Page<ComplaintResponse> getTopComplaints(Pageable pageable, UUID currentUserId) {
        return complaintRepository.findAllByOrderByNetScoreDesc(pageable)
                .map(c -> mapToResponse(c, currentUserId));
    }

    public Page<ComplaintResponse> getNewComplaints(Pageable pageable, UUID currentUserId) {
        return complaintRepository.findAllByOrderByCreatedAtDesc(pageable)
                .map(c -> mapToResponse(c, currentUserId));
    }

    public Page<ComplaintResponse> getComplaintsByCategory(String category, Pageable pageable, UUID currentUserId) {
        return complaintRepository.findByCategory(category, pageable)
                .map(c -> mapToResponse(c, currentUserId));
    }

    public Page<ComplaintResponse> getComplaintsByStatus(Complaint.ComplaintStatus status, Pageable pageable, UUID currentUserId) {
        return complaintRepository.findByStatus(status, pageable)
                .map(c -> mapToResponse(c, currentUserId));
    }

    public Page<ComplaintResponse> getComplaintsByCategoryAndStatus(
            String category,
            Complaint.ComplaintStatus status,
            Pageable pageable,
            UUID currentUserId
    ) {
        return complaintRepository.findByCategoryAndStatus(category, status, pageable)
                .map(c -> mapToResponse(c, currentUserId));
    }

    public ComplaintResponse getComplaintById(UUID id, UUID currentUserId) {
        Complaint complaint = complaintRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Complaint not found"));
        return mapToResponse(complaint, currentUserId);
    }

    @Transactional
    public void castVote(UUID complaintId, CastVoteRequest request, UUID userId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new EntityNotFoundException("Complaint not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        Optional<ComplaintVote> existingVoteOpt = voteRepository.findByComplaintIdAndUserId(complaintId, userId);

        if (existingVoteOpt.isPresent()) {
            ComplaintVote existingVote = existingVoteOpt.get();
            if (existingVote.getVoteType() == request.voteType()) {
                // Toggle off
                voteRepository.delete(existingVote);
                if (request.voteType() == ComplaintVote.VoteType.UP) {
                    complaintRepository.incrementUpvotes(complaintId, -1);
                    outboxPublisher.publishComplaintCounterEvent(complaintId, userId, "COMPLAINT_VOTE_TOGGLED_OFF", -1, 0, 0);
                } else {
                    complaintRepository.incrementDownvotes(complaintId, -1);
                    outboxPublisher.publishComplaintCounterEvent(complaintId, userId, "COMPLAINT_VOTE_TOGGLED_OFF", 0, -1, 0);
                }
            } else {
                // Change vote
                if (existingVote.getVoteType() == ComplaintVote.VoteType.UP) {
                    complaintRepository.incrementUpvotes(complaintId, -1);
                    complaintRepository.incrementDownvotes(complaintId, 1);
                    outboxPublisher.publishComplaintCounterEvent(complaintId, userId, "COMPLAINT_VOTE_CHANGED", -1, 1, 0);
                } else {
                    complaintRepository.incrementDownvotes(complaintId, -1);
                    complaintRepository.incrementUpvotes(complaintId, 1);
                    outboxPublisher.publishComplaintCounterEvent(complaintId, userId, "COMPLAINT_VOTE_CHANGED", 1, -1, 0);
                }
                existingVote.setVoteType(request.voteType());
                voteRepository.save(existingVote);
            }
        } else {
            // New vote
            ComplaintVote newVote = ComplaintVote.builder()
                    .complaint(complaint)
                    .user(user)
                    .voteType(request.voteType())
                    .build();
            voteRepository.save(newVote);
            
            if (request.voteType() == ComplaintVote.VoteType.UP) {
                complaintRepository.incrementUpvotes(complaintId, 1);
                outboxPublisher.publishComplaintCounterEvent(complaintId, userId, "COMPLAINT_VOTE_CAST", 1, 0, 0);
            } else {
                complaintRepository.incrementDownvotes(complaintId, 1);
                outboxPublisher.publishComplaintCounterEvent(complaintId, userId, "COMPLAINT_VOTE_CAST", 0, 1, 0);
            }
        }
    }

    @Transactional
    public void updateStatus(UUID id, Complaint.ComplaintStatus status) {
        Complaint complaint = complaintRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Complaint not found"));
        complaint.setStatus(status);
        complaintRepository.save(complaint);
    }

    @Transactional
    public void flagComplaint(UUID id) {
        Complaint complaint = complaintRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Complaint not found"));
        
        complaintRepository.incrementFlagCount(id);
        outboxPublisher.publishComplaintCounterEvent(id, null, "COMPLAINT_FLAGGED", 0, 0, 1);
        complaintRepository.moveToReviewWhenFlagThresholdReached(
                id,
                Complaint.ComplaintStatus.OPEN,
                Complaint.ComplaintStatus.UNDER_REVIEW,
                10
        );
    }

    @Transactional
    public ComplaintCommentResponse addComment(UUID complaintId, String content, Boolean isAnonymous, UUID creatorId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new EntityNotFoundException("Complaint not found"));
        User creator = userRepository.findById(creatorId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        ComplaintComment comment = ComplaintComment.builder()
                .complaint(complaint)
                .creator(creator)
                .content(content)
                .isAnonymous(isAnonymous != null ? isAnonymous : false)
                .build();

        comment = commentRepository.save(comment);
        return mapToCommentResponse(comment);
    }

    public List<ComplaintCommentResponse> getComments(UUID complaintId) {
        return commentRepository.findByComplaintId(complaintId).stream()
                .map(this::mapToCommentResponse)
                .collect(Collectors.toList());
    }

    private ComplaintResponse mapToResponse(Complaint complaint, UUID currentUserId) {
        ComplaintVote.VoteType hasVoted = null;
        if (currentUserId != null) {
            Optional<ComplaintVote> voteOpt = voteRepository.findByComplaintIdAndUserId(complaint.getId(), currentUserId);
            if (voteOpt.isPresent()) {
                hasVoted = voteOpt.get().getVoteType();
            }
        }

        int commentCount = commentRepository.findByComplaintId(complaint.getId()).size();
        
        // Ensure netScore is always calculated in the response even if not fetched from DB generated column yet
        int netScore = (complaint.getUpvotes() != null ? complaint.getUpvotes() : 0) - 
                       (complaint.getDownvotes() != null ? complaint.getDownvotes() : 0);

        return new ComplaintResponse(
                complaint.getId(),
                complaint.getIsAnonymous() ? null : (complaint.getCreator() != null ? complaint.getCreator().getId() : null),
                complaint.getCategory(),
                complaint.getTitle(),
                complaint.getDescription(),
                complaint.getMediaUrls(),
                complaint.getLatitude(),
                complaint.getLongitude(),
                complaint.getLocationName(),
                complaint.getStatus(),
                complaint.getIsAnonymous(),
                complaint.getFlagCount(),
                complaint.getUpvotes(),
                complaint.getDownvotes(),
                netScore,
                complaint.getCreatedAt(),
                complaint.getUpdatedAt(),
                hasVoted,
                commentCount
        );
    }

    private ComplaintCommentResponse mapToCommentResponse(ComplaintComment comment) {
        String creatorName = comment.getIsAnonymous() ? "Anonymous" : 
                             (comment.getCreator() != null ? comment.getCreator().getName() : "Unknown");
        return new ComplaintCommentResponse(
                comment.getId(),
                comment.getContent(),
                creatorName,
                comment.getCreatedAt()
        );
    }
}
