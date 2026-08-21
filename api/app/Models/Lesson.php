<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Lesson extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'slug',
        'module_id',
        'title',
        'title_km',
        'summary',
        'minutes',
        'xp',
        'sort_order',
        'is_project',
        'created_by_admin_id',
        'published_at'
    ];
}
