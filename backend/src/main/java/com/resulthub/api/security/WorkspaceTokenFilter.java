package com.resulthub.api.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class WorkspaceTokenFilter extends OncePerRequestFilter {

    private final WorkspaceTokenService workspaceTokenService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        final String authHeader = request.getHeader("Authorization");
        final String token;
        final String workspaceId;

        // Skip if there's no Authorization header or if it's not a Workspace token
        if (authHeader == null || !authHeader.startsWith("Workspace ")) {
            filterChain.doFilter(request, response);
            return;
        }

        token = authHeader.substring(10);
        
        try {
            if (workspaceTokenService.isTokenValid(token)) {
                workspaceId = workspaceTokenService.extractWorkspaceId(token);
                
                if (workspaceId != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    WorkspaceAuthToken authToken = new WorkspaceAuthToken(workspaceId);
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        } catch (Exception e) {
            // Token parsing failed
        }
        
        filterChain.doFilter(request, response);
    }
}
