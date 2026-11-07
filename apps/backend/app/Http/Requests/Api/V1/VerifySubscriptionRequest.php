<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class VerifySubscriptionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'plan_id' => ['required_without:plan_slug', 'nullable', 'exists:plans,id'],
            'plan_slug' => ['required_without:plan_id', 'nullable', 'exists:plans,slug'],
            'purchase_token' => ['required', 'string'],
            'order_id' => ['nullable', 'string', 'max:100'],
            'store' => ['nullable', 'string', 'in:google_play,promo,trial,sandbox,manual'],
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Subscription verification request is invalid.',
            'data' => null,
            'errors' => $validator->errors(),
            'meta' => [
                'timestamp' => now()->toIso8601String(),
                'error_code' => 'ERR_VALIDATION_FAILED',
            ],
        ], 422));
    }
}
