package com.resulthub.api.analytics;

import com.resulthub.api.analytics.dto.GlobalAnalyticsResponse;
import com.resulthub.api.analytics.dto.WorkspaceAnalyticsResponse;
import com.resulthub.api.analytics.service.WorkspaceAnalyticsService;
import com.resulthub.api.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final WorkspaceAnalyticsService analyticsService;

    @GetMapping("/workspace/{workspaceId}")
    public ResponseEntity<WorkspaceAnalyticsResponse> getWorkspaceAnalytics(
            @PathVariable UUID workspaceId,
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(analyticsService.getWorkspaceAnalytics(workspaceId, user.getId()));
    }

    @GetMapping("/global")
    public ResponseEntity<GlobalAnalyticsResponse> getGlobalAnalytics(
            @AuthenticationPrincipal User user
    ) {
        return ResponseEntity.ok(analyticsService.getGlobalAnalytics(user.getId()));
    }
}
