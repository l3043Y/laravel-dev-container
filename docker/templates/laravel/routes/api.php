<?php

use Illuminate\Support\Facades\Route;
use l3043y\Common\Data\ApiResponse;

Route::prefix('v1.0')->group(base_path('routes/tnps/v1.0.php'));
Route::get('up', function(){
    return ApiResponse::create([
        'code' => 200,
        'message' => 'Service is up and running'
    ]);
})->name('service-check');
