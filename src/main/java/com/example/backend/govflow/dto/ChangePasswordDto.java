package com.example.backend.govflow.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ChangePasswordDto {
    @NotEmpty(message = "Current password is required.")
    private String currentPassword;

    @NotEmpty(message = "New password is required.")
    @Size(min = 8, message = "New password must be at least 8 characters long.")
    private String newPassword;
}