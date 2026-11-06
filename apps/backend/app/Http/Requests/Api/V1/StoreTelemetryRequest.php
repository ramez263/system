<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class StoreTelemetryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'session_uuid' => ['required', 'string', 'max:64'],
            'server_id' => ['nullable', 'exists:servers,id'],
            'configuration_id' => ['nullable', 'exists:configurations,id'],
            'protocol' => ['nullable', 'string', 'max:30'],
            'bytes_in' => ['required', 'integer', 'min:0'],
            'bytes_out' => ['required', 'integer', 'min:0'],
            'duration_seconds' => ['required', 'integer', 'min:0'],
            'disconnect_reason' => ['nullable', 'string', 'max:100'],
            'connected_at' => ['nullable', 'date'],
            'disconnected_at' => ['nullable', 'date'],
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Telemetry payload validation failed.',
            'data' => null,
            'errors' => $validator->errors(),
            'meta' => [
                'timestamp' => now()->toIso8601String(),
                'error_code' => 'ERR_VALIDATION_FAILED',
            ],
        ], 422));
    }
}
