<?php

namespace App\Http\Middlewares;

use Closure;
use Illuminate\Http\Request;

class ForceJsonResponse
{

    public function handle(Request $request, Closure $next)
    {
        $request->headers->set('Accept', 'application/json');
        return $next($request);
    }
}
