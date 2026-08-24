# How to Activate Admin Mode

To use the Admin Dashboard in the Code4Youth app, you must first create an admin record in the database.

### 1. Identify your Firebase UID
1. Open the Code4Youth app on your phone.
2. Go to **Profile** > **Settings**.
3. Tap on **"Backend Status"** or **"Sync to Firebase"**.
4. In your Render logs, look for a line like: `User Sync: ID 5, Firebase UID: USCVxHlYS...`
5. Copy that long ID.

### 2. Create the Admin record
Run this SQL command in phpMyAdmin (inside `defaultdb`):

```sql
INSERT INTO `admins` (`name`, `email`, `password`, `role`, `is_active`, `created_at`, `updated_at`) 
VALUES (
    'Your Name', 
    'your-email@example.com', 
    'NOT_USED_FOR_FIREBASE', 
    'super', 
    1, 
    NOW(), 
    NOW()
);
```

### 3. Link your User to the Admin
Find the ID of the admin you just created and the ID of your user. Update the `users` table to mark that user as an admin.

```sql
-- Replace '1' with your user ID and 'super' with the role
UPDATE `users` SET `status` = 'admin' WHERE `id` = 1;
```

### 4. Admin Display
Once your user status is set to `admin`, the app will automatically show the **Admin Dashboard** at the top of your Profile screen.
