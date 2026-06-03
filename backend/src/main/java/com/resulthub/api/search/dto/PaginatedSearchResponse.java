package com.resulthub.api.search.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class PaginatedSearchResponse {
    private List<SearchResult> results;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
}
