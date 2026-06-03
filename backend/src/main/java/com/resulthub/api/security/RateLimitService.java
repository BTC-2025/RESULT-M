package com.resulthub.api.security;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Rate Limit Service.
 * REDIS-READY ARCHITECTURE:
 * Currently uses an in-memory ConcurrentHashMap to avoid deploying Redis as per core restrictions.
 * To migrate to Redis for multi-node deployments, replace the ConcurrentHashMap with a ProxyManager
 * (e.g., LettuceBasedProxyManager or RedissonBasedProxyManager from bucket4j-redis) and inject it here.
 */
@Service
public class RateLimitService {

    private final Map<String, Bucket> cache = new ConcurrentHashMap<>();

    public Bucket resolveBucket(String key, String requestPath, boolean isAdmin) {
        if (isAdmin) {
            // Unlimited bandwidth for ADMIN role
            return Bucket.builder()
                    .addLimit(Bandwidth.builder().capacity(Integer.MAX_VALUE).refillGreedy(Integer.MAX_VALUE, Duration.ofSeconds(1)).build())
                    .build();
        }
        
        String planType = resolvePlanType(requestPath);
        String bucketId = key + "-" + planType;
        
        return cache.computeIfAbsent(bucketId, k -> newBucket(planType));
    }

    private String resolvePlanType(String requestPath) {
        if (requestPath.startsWith("/api/v1/auth")) {
            return "AUTH";
        } else if (requestPath.startsWith("/api/v1/search")) {
            return "SEARCH";
        } else {
            return "PUBLIC";
        }
    }

    private Bucket newBucket(String planType) {
        Bandwidth limit;
        if ("AUTH".equals(planType)) {
            // 20 requests/minute
            limit = Bandwidth.builder().capacity(20).refillGreedy(20, Duration.ofMinutes(1)).build();
        } else if ("SEARCH".equals(planType)) {
            // 50 requests/minute
            limit = Bandwidth.builder().capacity(50).refillGreedy(50, Duration.ofMinutes(1)).build();
        } else {
            // 100 requests/minute
            limit = Bandwidth.builder().capacity(100).refillGreedy(100, Duration.ofMinutes(1)).build();
        }

        return Bucket.builder()
                .addLimit(limit)
                .build();
    }
}
