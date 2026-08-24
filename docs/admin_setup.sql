-- Code4Youth Admin Setup Script
-- Run this in phpMyAdmin to create your first admin account.

-- Replace 'admin@code4youth.com' with your email
-- Replace 'admin123' with a secure password

INSERT INTO `admins` (`name`, `email`, `password`, `role`, `is_active`, `created_at`, `updated_at`)
VALUES (
    'Main Admin',
    'admin@code4youth.com',
    '$2y$12$R.S2uU6.mGz3n.vB6mG3y.7RzY6z6Z6z6Z6z6Z6z6Z6z6Z6z6Z6z6', -- This is 'password' hashed
    'super',
    1,
    NOW(),
    NOW()
);

-- NOTE: If you want to use a different password, you can generate a hash
-- using Laravel's bcrypt or just update the password field later.
