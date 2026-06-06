package com.resulthub.api.complaint.dto;

import java.math.BigDecimal;

public record CreateComplaintRequest(
        String title,
        String description,
        String category,
        BigDecimal latitude,
        BigDecimal longitude,
        String locationName,
        Boolean isAnonymous
) {
}
