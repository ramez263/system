<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class ServerQueryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'country' => ['nullable', 'string', 'size:2'],
            'protocol' => ['nullable', 'string', 'max:20'],
            'is_premium' => ['nullable', 'boolean'],
            'search' => ['nullable', 'string', 'max:50'],
        ];
    }
}
