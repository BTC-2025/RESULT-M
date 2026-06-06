package com.resulthub.api.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class VoteBoxTokenService {

    @Value("${jwt.votebox.secret:defaultvoteboxsecretkeythatisverylongandsecureenoughforhs256algorithm}")
    private String secretKey;

    @Value("${jwt.votebox.expiration:86400000}")
    private long jwtExpiration;

    public String extractVoteBoxId(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public String extractTokenType(String token) {
        return extractClaim(token, claims -> claims.get("tokenType", String.class));
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public String generateToken(String voteBoxId) {
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("tokenType", "VOTE_BOX_ACCESS");

        return Jwts
                .builder()
                .setClaims(extraClaims)
                .setSubject(voteBoxId)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean isTokenValid(String token) {
        try {
            return !isTokenExpired(token) && "VOTE_BOX_ACCESS".equals(extractTokenType(token));
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    private Claims extractAllClaims(String token) {
        return Jwts
                .parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Key getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        // Fallback for non-base64 test keys
        if (keyBytes.length < 32) {
            return Keys.hmacShaKeyFor(secretKey.getBytes());
        }
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
