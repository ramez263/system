<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class StoreConfigurationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:500'],
            'protocol' => ['required', 'string', 'in:ovpn,vless,vmess,trojan,ssh,rtp'],
            'config_data' => ['required', 'string'],
            'server_id' => ['nullable', 'exists:servers,id'],
            'is_public' => ['nullable', 'boolean'],
            'export_locked' => ['nullable', 'boolean'],
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Configuration validation failed.',
            'data' => null,
            'errors' => $validator->errors(),
            'meta' => [
                'timestamp' => now()->toIso8601String(),
                'error_code' => 'ERR_VALIDATION_FAILED',
            ],
        ], 422));
    }
}
