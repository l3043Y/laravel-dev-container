<?php

namespace App\Http\Controllers\Api\V1;


use App\Http\Controllers\Controller;
use app\Http\Requests\SayHelloRequest;
use App\Services\HelloWorldService;
use l3043y\Common\Data\ApiResponse;

class HelloWorldController extends Controller
{
    protected HelloWorldService $helloWorldService;
    public function __construct(HelloWorldService $helloWorldService)
    {
        $this->helloWorldService = $helloWorldService;
    }

    public function helloWorld() #: ApiResponse
    {
        try{
            $data = $this->helloWorldService->helloWorld();
            return ApiResponse::create([
                'code' => 200,
                'data' => $data
            ]);
        }catch (\Throwable $e){
            return ApiResponse::getDebug($e);
        }
    }

    public function sayHello(SayHelloRequest $request): ApiResponse
    {
        $data = $this->helloWorldService->sayHello($request->getName());
        return ApiResponse::create([
            'code' => 200,
            'data' => $data
        ]);
    }

}
