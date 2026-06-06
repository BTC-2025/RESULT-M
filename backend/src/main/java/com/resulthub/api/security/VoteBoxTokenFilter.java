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
public class VoteBoxTokenFilter extends OncePerRequestFilter {

    private final VoteBoxTokenService voteBoxTokenService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        final String authHeader = request.getHeader("Authorization");
        final String token;
        final String voteBoxId;

        // Skip if there's no Authorization header or if it's not a Workspace token format
        if (authHeader == null || !authHeader.startsWith("Workspace ")) {
            filterChain.doFilter(request, response);
            return;
        }

        token = authHeader.substring(10);
        
        try {
            if (voteBoxTokenService.isTokenValid(token)) {
                voteBoxId = voteBoxTokenService.extractVoteBoxId(token);
                
                if (voteBoxId != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    VoteBoxAuthToken authToken = new VoteBoxAuthToken(voteBoxId);
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        } catch (Exception e) {
            // Token parsing failed (might be a valid Workspace token instead, which WorkspaceTokenFilter will handle)
        }
        
        filterChain.doFilter(request, response);
    }
}
