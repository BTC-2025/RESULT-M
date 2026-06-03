package com.resulthub.api.search.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SearchSuggestion {
    private String title;
    private String type;
    private String id;
}
