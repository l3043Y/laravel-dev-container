<?php

use App\Http\Controllers\Api\V1\HelloWorldController;
use Illuminate\Support\Facades\Route;

Route::get('hello-world', [HelloWorldController::class, 'helloWorld']);
Route::post('hello-world', [HelloWorldController::class, 'sayHello']);



