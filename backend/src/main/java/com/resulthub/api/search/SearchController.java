package com.resulthub.api.search;

import com.resulthub.api.search.dto.PaginatedSearchResponse;
import com.resulthub.api.search.service.SearchService;
import com.resulthub.api.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping
    public ResponseEntity<PaginatedSearchResponse> globalSearch(
            @RequestParam String q,
            @RequestParam(required = false) java.util.UUID workspaceId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(searchService.globalSearch(q, workspaceId, page, size, user, authHeader));
    }
}
