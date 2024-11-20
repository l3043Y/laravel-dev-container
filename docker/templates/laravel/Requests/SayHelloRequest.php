<?php

namespace app\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SayHelloRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => 'required'
        ];
    }

    public function getName(): string
    {
        return $this->input('name');
    }
}
