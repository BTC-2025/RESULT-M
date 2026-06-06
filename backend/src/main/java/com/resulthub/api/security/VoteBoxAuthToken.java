package com.resulthub.api.security;

import org.springframework.security.authentication.AbstractAuthenticationToken;

import java.util.Collections;

public class VoteBoxAuthToken extends AbstractAuthenticationToken {

    private final String voteBoxId;

    public VoteBoxAuthToken(String voteBoxId) {
        super(Collections.emptyList());
        this.voteBoxId = voteBoxId;
        setAuthenticated(true);
    }

    @Override
    public Object getCredentials() {
        return null;
    }

    @Override
    public Object getPrincipal() {
        return voteBoxId;
    }
}
