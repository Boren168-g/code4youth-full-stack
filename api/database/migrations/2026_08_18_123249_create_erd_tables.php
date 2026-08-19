<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Grades
        Schema::create('grades', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique();
            $table->string('label', 50);
            $table->boolean('is_minor');
            $table->smallInteger('sort_order');
        });

        // 2. Admins
        Schema::create('admins', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('password');
            $table->string('role', 20);
            $table->boolean('is_active');
            $table->timestamps();
        });

        // 3. Update Users (modifying the existing users table created by Laravel)
        Schema::table('users', function (Blueprint $table) {
            $table->string('firebase_uid', 128)->unique()->after('id')->nullable();
            $table->string('avatar', 16)->nullable();
            $table->foreignId('grade_id')->nullable()->constrained('grades')->onDelete('restrict');
            $table->string('status', 20)->default('active');
            $table->string('consent_status', 20)->nullable();
            $table->timestamp('last_active_at')->nullable();
            $table->timestamp('onboarded_at')->nullable();
            $table->integer('xp')->default(0);
            $table->smallInteger('lessons_completed')->default(0);
            $table->smallInteger('streak_days')->default(0);
            $table->softDeletes();
        });

        // 4. Audit Logs
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->string('actor_type', 20);
            $table->bigInteger('actor_id');
            $table->string('actor_name');
            $table->string('action', 40);
            $table->string('target_type', 20)->nullable();
            $table->bigInteger('target_id')->nullable();
            $table->string('target_name')->nullable();
            $table->string('previous_value')->nullable();
            $table->string('new_value')->nullable();
            $table->string('note')->nullable();
            $table->timestamp('created_at')->useCurrent();
        });

        // 5. App Settings
        Schema::create('app_settings', function (Blueprint $table) {
            $table->string('key', 64)->primary();
            $table->text('value');
            $table->timestamps();
        });

        // 6. Cohorts
        Schema::create('cohorts', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique();
            $table->string('name');
            $table->string('school_name')->nullable();
            $table->foreignId('admin_id')->constrained('admins')->onDelete('restrict');
            $table->timestamps();
            $table->softDeletes();
        });

        // 7. Cohort User
        Schema::create('cohort_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cohort_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->timestamp('joined_at')->useCurrent();
            $table->timestamp('left_at')->nullable();
        });

        // 8. User Stats
        Schema::create('user_stats', function (Blueprint $table) {
            $table->foreignId('user_id')->primary()->constrained()->onDelete('cascade');
            $table->integer('xp')->default(0);
            $table->smallInteger('streak_days')->default(0);
            $table->smallInteger('first_try_correct')->default(0);
            $table->date('last_activity_date')->nullable();
            $table->timestamps();
        });

        // 9. User Preferences
        Schema::create('user_preferences', function (Blueprint $table) {
            $table->foreignId('user_id')->primary()->constrained()->onDelete('cascade');
            $table->string('theme_mode', 10)->default('system');
            $table->char('locale', 2)->default('en');
            $table->boolean('reduce_motion')->default(false);
            $table->boolean('daily_reminder')->default(true);
            $table->timestamps();
        });

        // 10. Guardian Consents
        Schema::create('guardian_consents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('guardian_email');
            $table->string('status', 20);
            $table->string('token', 64)->unique();
            $table->boolean('is_current');
            $table->timestamp('requested_at');
            $table->timestamp('responded_at')->nullable();
        });

        // 11. Modules
        Schema::create('modules', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 20)->unique();
            $table->string('title');
            $table->string('title_km');
            $table->text('description');
            $table->string('icon_key', 64);
            $table->smallInteger('sort_order')->unique();
            $table->foreignId('created_by_admin_id')->constrained('admins')->onDelete('restrict');
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        // 12. Module Prerequisites
        Schema::create('module_prerequisites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('module_id')->constrained()->onDelete('cascade');
            $table->foreignId('prerequisite_module_id')->constrained('modules')->onDelete('cascade');
            $table->timestamp('created_at')->useCurrent();
        });

        // 13. Lessons
        Schema::create('lessons', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 20)->unique();
            $table->foreignId('module_id')->constrained()->onDelete('restrict');
            $table->string('title');
            $table->string('title_km');
            $table->text('summary');
            $table->smallInteger('minutes');
            $table->smallInteger('xp')->default(30);
            $table->smallInteger('sort_order');
            $table->boolean('is_project')->default(false);
            $table->foreignId('created_by_admin_id')->constrained('admins')->onDelete('restrict');
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        // 14. Lesson Steps
        Schema::create('lesson_steps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lesson_id')->constrained()->onDelete('cascade');
            $table->smallInteger('step_index');
            $table->string('kind', 20);
            $table->string('title');
            $table->text('body');
            $table->text('body_km')->nullable();
            $table->string('language', 20)->default('python');
            $table->timestamps();
        });

        // 15. Lesson Step Items
        Schema::create('lesson_step_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lesson_step_id')->constrained()->onDelete('cascade');
            $table->smallInteger('position');
            $table->string('label');
        });

        // 16. Challenges
        Schema::create('challenges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lesson_id')->unique()->constrained()->onDelete('cascade');
            $table->string('kind', 20);
            $table->text('prompt');
            $table->string('answer')->nullable();
            $table->text('hint');
            $table->text('code')->nullable();
            $table->smallInteger('xp')->default(20);
            $table->timestamps();
        });

        // 17. Challenge Options
        Schema::create('challenge_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('challenge_id')->constrained()->onDelete('cascade');
            $table->smallInteger('position');
            $table->string('label');
            $table->boolean('is_correct');
        });

        // 18. Badges
        Schema::create('badges', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 40)->unique();
            $table->string('name');
            $table->text('description');
            $table->string('icon_key', 64);
            $table->string('requirement_text');
            $table->string('criteria_type', 40);
            $table->json('criteria_params');
            $table->smallInteger('sort_order');
        });

        // 19. Interests
        Schema::create('interests', function (Blueprint $table) {
            $table->id();
            $table->string('name', 50)->unique();
            $table->string('icon_key', 64);
            $table->smallInteger('sort_order');
        });

        // 20. Levels
        Schema::create('levels', function (Blueprint $table) {
            $table->id();
            $table->smallInteger('level_no')->unique();
            $table->integer('min_xp')->unique();
            $table->string('title', 50);
        });

        // 21. Interest User
        Schema::create('interest_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('interest_id')->constrained()->onDelete('restrict');
        });

        // 22. User Lesson Progress
        Schema::create('user_lesson_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('lesson_id')->constrained()->onDelete('restrict');
            $table->smallInteger('last_step_index');
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'lesson_id']);
        });

        // 23. Badge User
        Schema::create('badge_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('badge_id')->constrained()->onDelete('restrict');
            $table->timestamp('earned_at');
            $table->unique(['user_id', 'badge_id']);
        });

        // 24. Lesson Attempts
        Schema::create('lesson_attempts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('lesson_id')->constrained()->onDelete('restrict');
            $table->foreignId('module_id')->constrained()->onDelete('restrict');
            $table->string('lesson_title_snapshot');
            $table->string('module_title_snapshot');
            $table->smallInteger('xp_earned');
            $table->smallInteger('attempts');
            $table->boolean('passed');
            $table->timestamp('completed_at');
            $table->timestamp('created_at')->useCurrent();
        });

        // 25. Sync Queue Events
        Schema::create('sync_queue_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->char('client_event_uuid', 36)->unique();
            $table->string('event_type', 40);
            $table->json('payload');
            $table->timestamp('occurred_at');
            $table->timestamp('synced_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_queue_events');
        Schema::dropIfExists('lesson_attempts');
        Schema::dropIfExists('badge_user');
        Schema::dropIfExists('user_lesson_progress');
        Schema::dropIfExists('interest_user');
        Schema::dropIfExists('levels');
        Schema::dropIfExists('interests');
        Schema::dropIfExists('badges');
        Schema::dropIfExists('challenge_options');
        Schema::dropIfExists('challenges');
        Schema::dropIfExists('lesson_step_items');
        Schema::dropIfExists('lesson_steps');
        Schema::dropIfExists('lessons');
        Schema::dropIfExists('module_prerequisites');
        Schema::dropIfExists('modules');
        Schema::dropIfExists('guardian_consents');
        Schema::dropIfExists('user_preferences');
        Schema::dropIfExists('user_stats');
        Schema::dropIfExists('cohort_user');
        Schema::dropIfExists('cohorts');
        Schema::dropIfExists('app_settings');
        Schema::dropIfExists('audit_logs');

        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['grade_id']);
            $table->dropColumn([
                'firebase_uid', 'avatar', 'grade_id', 'status',
                'consent_status', 'last_active_at', 'onboarded_at',
                'xp', 'lessons_completed', 'streak_days'
            ]);
        });

        Schema::dropIfExists('admins');
        Schema::dropIfExists('grades');
    }
};
