package com.resulthub.api.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@EnableCaching
public class CacheConfig implements WebMvcConfigurer {

    @Value("${resulthub.cache.public-max-age:60}")
    private int publicMaxAge;

    @Value("${resulthub.cache.public-stale-while-revalidate:300}")
    private int publicStaleWhileRevalidate;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new PublicReadCacheHeaderInterceptor(publicMaxAge, publicStaleWhileRevalidate))
                .addPathPatterns("/api/v1/workspaces/public");
    }

    private static class PublicReadCacheHeaderInterceptor implements HandlerInterceptor {
        private final int publicMaxAge;
        private final int publicStaleWhileRevalidate;

        private PublicReadCacheHeaderInterceptor(int publicMaxAge, int publicStaleWhileRevalidate) {
            this.publicMaxAge = publicMaxAge;
            this.publicStaleWhileRevalidate = publicStaleWhileRevalidate;
        }

        @Override
        public boolean preHandle(
                HttpServletRequest request,
                HttpServletResponse response,
                Object handler
        ) {
            if ("GET".equalsIgnoreCase(request.getMethod())) {
                response.setHeader(
                        "Cache-Control",
                        "public, max-age=" + publicMaxAge + ", stale-while-revalidate=" + publicStaleWhileRevalidate
                );
                response.setHeader("Vary", "Authorization");
            }
            return true;
        }
    }
}
