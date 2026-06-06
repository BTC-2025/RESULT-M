package com.resulthub.api.complaint.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record ComplaintCommentResponse(
        UUID id,
        String content,
        String creatorName,
        LocalDateTime createdAt
) {
}
