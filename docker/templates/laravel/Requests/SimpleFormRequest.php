<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use ReflectionClass;
use Spatie\LaravelData\Contracts\BaseData;
use Spatie\LaravelData\Contracts\ValidateableData;

class SimpleFormRequest extends FormRequest
{
    public function getData(string $className = BaseData::class): ValidateableData
    {
        $class = new ReflectionClass($className);
        if (!class_exists($className) || !$class?->implementsInterface(ValidateableData::class)) {
            throw new \InvalidArgumentException("The provided class name must be a valid subclass of " . ValidateableData::class);
        }
        return $className::validateAndCreate($this->input());
    }

    public function getQuery(string $className = BaseData::class)
    {
        return $className::validateAndCreate($this->query());
    }
}
