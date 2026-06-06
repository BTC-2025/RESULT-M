package com.resulthub.api.search.service;

import com.resulthub.api.search.dto.PaginatedSearchResponse;
import com.resulthub.api.search.dto.SearchResult;
import com.resulthub.api.search.entity.SearchAnalytics;
import com.resulthub.api.search.repository.SearchAnalyticsRepository;
import com.resulthub.api.search.repository.SearchRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import com.resulthub.api.workspace.service.WorkspaceAccessService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class SearchService {

    private final SearchRepository searchRepository;
    private final SearchAnalyticsRepository analyticsRepository;
    private final WorkspaceRepository workspaceRepository;
    private final WorkspaceAccessService workspaceAccessService;

    public PaginatedSearchResponse globalSearch(
            String query,
            UUID targetWorkspaceId,
            int page,
            int size,
            User user,
            String authHeader
    ) {
        if (query == null || query.trim().isEmpty()) {
            return PaginatedSearchResponse.builder()
                    .results(List.of())
                    .page(page)
                    .size(size)
                    .totalElements(0)
                    .totalPages(0)
                    .build();
        }

        UUID userId = user != null ? user.getId() : null;
        int offset = page * size;
        boolean canViewTargetWorkspace = false;

        if (targetWorkspaceId != null) {
            Workspace workspace = workspaceRepository.findByIdAndNotDeleted(targetWorkspaceId)
                    .orElseThrow(() -> new RuntimeException("Workspace not found"));
            workspaceAccessService.validateCanView(workspace, user, authHeader);
            canViewTargetWorkspace = true;
        }
        
        List<SearchResult> results = searchRepository.globalSearch(
                query,
                targetWorkspaceId,
                canViewTargetWorkspace,
                offset,
                size
        );

        // Track analytics asynchronously
        trackSearchAsync(query, results.size(), userId, null);

        // Note: totalElements and totalPages would typically require a secondary COUNT(*) query in Postgres 
        // for accurate pagination, but for FTS, counting millions of rows can be slow. 
        // We will approximate or omit it for now, returning size based logic.
        boolean hasNext = results.size() == size;

        return PaginatedSearchResponse.builder()
                .results(results)
                .page(page)
                .size(size)
                .totalElements(hasNext ? (offset + size + 1) : (offset + results.size()))
                .totalPages(hasNext ? page + 2 : page + 1)
                .build();
    }

    @Async
    protected void trackSearchAsync(String query, int resultCount, UUID userId, String sessionId) {
        try {
            SearchAnalytics analytics = SearchAnalytics.builder()
                    .searchQuery(query)
                    .resultCount(resultCount)
                    .user(userId != null ? User.builder().id(userId).build() : null)
                    .anonymousSessionId(sessionId)
                    .build();
            analyticsRepository.save(analytics);
        } catch (Exception e) {
            log.error("Failed to track search analytics", e);
        }
    }
}
