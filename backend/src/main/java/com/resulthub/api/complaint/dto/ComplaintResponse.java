package com.resulthub.api.complaint.dto;

import com.resulthub.api.complaint.entity.Complaint;
import com.resulthub.api.complaint.entity.ComplaintVote;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record ComplaintResponse(
        UUID id,
        UUID creatorId,
        String category,
        String title,
        String description,
        String[] mediaUrls,
        BigDecimal latitude,
        BigDecimal longitude,
        String locationName,
        Complaint.ComplaintStatus status,
        Boolean isAnonymous,
        Integer flagCount,
        Integer upvotes,
        Integer downvotes,
        Integer netScore,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        ComplaintVote.VoteType hasUserVoted,
        int commentCount
) {
}
