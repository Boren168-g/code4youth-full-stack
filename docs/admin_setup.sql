-- Code4Youth Admin Promotion Script
-- Email: yayueol@gmail.com
-- Password: admin

SET @target_email = 'yayueol@gmail.com';

-- 1. Create the Admin record for the backend
INSERT INTO `admins` (`name`, `email`, `password`, `role`, `is_active`, `created_at`, `updated_at`)
VALUES ('Admin', @target_email, 'admin', 'super', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = 'Admin', `role` = 'super';

-- 2. Set user status to 'admin' and name to 'Admin'
UPDATE `users` SET `name` = 'Admin', `status` = 'admin' WHERE `email` = @target_email;

-- Result check
SELECT `id`, `name`, `email`, `status` FROM `users` WHERE `email` = @target_email;
