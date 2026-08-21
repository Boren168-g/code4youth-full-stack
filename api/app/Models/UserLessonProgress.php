<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserLessonProgress extends Model
{
    protected $table = 'user_lesson_progress';

    protected $fillable = [
        'user_id',
        'lesson_id',
        'last_step_index',
        'completed_at'
    ];

    protected $casts = [
        'completed_at' => 'datetime'
    ];
}
