package com.resulthub.api.auth.repository;

import com.resulthub.api.auth.model.PasswordResetToken;
import com.resulthub.api.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {
    Optional<PasswordResetToken> findByUserAndOtpAndUsedFalse(User user, String otp);
}
