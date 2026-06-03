package com.resulthub.api.security;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.Collections;

public class WorkspaceAuthToken extends AbstractAuthenticationToken {

    private final String workspaceId;

    public WorkspaceAuthToken(String workspaceId) {
        super(Collections.singletonList(new SimpleGrantedAuthority("ROLE_WORKSPACE_GUEST")));
        this.workspaceId = workspaceId;
        setAuthenticated(true);
    }

    @Override
    public Object getCredentials() {
        return null;
    }

    @Override
    public Object getPrincipal() {
        return this.workspaceId;
    }
}
