<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Module extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'slug',
        'title',
        'title_km',
        'description',
        'icon_key',
        'sort_order',
        'created_by_admin_id',
        'published_at'
    ];
}
