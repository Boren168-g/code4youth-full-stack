-- Code4Youth Admin Promotion Script
-- 1. Change the email below to the user you want to make an Admin
SET @target_email = 'boren@gmail.com';

-- 2. Create the Admin record for the backend
INSERT INTO `admins` (`name`, `email`, `password`, `role`, `is_active`, `created_at`, `updated_at`)
SELECT `name`, `email`, 'NOT_USED_BY_FIREBASE', 'super', 1, NOW(), NOW()
FROM `users`
WHERE `email` = @target_email
ON DUPLICATE KEY UPDATE `role` = 'super';

-- 3. Set user status to 'admin' (This activates Admin Mode in the Flutter app)
UPDATE `users` SET `status` = 'admin' WHERE `email` = @target_email;

-- Result check
SELECT `id`, `name`, `email`, `status` FROM `users` WHERE `email` = @target_email;
