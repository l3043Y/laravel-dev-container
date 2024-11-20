<?php

namespace App\Services;

class HelloWorldService
{
    public function __construct()
    {

    }

    public function helloWorld(): string
    {
        throw new \Exception('Hello World');
        return 'Hello World';
    }

    public function sayHello(string $name): string
    {
        return "Hello $name!";
    }
}
