<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('smartnas/subscriber/v1.0')->group(base_path('routes/subscriber/v1.0.php'));
Route::get('smartnas/subscriber/up', function(){
    return ApiResponse::create([
        'code' => 200,
        'message' => 'service is up'
    ]);
})->name('service-check');