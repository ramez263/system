<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Billing\BillingManager;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class GooglePlayWebhookController extends Controller
{
    protected BillingManager $billingManager;

    public function __construct(BillingManager $billingManager)
    {
        $this->billingManager = $billingManager;
    }

    /**
     * Handles Google Play Real-Time Developer Notifications (Pub/Sub push).
     */
    public function handle(Request $request): JsonResponse
    {
        $data = [];

        // 1. Check if Google Cloud Pub/Sub enveloped payload
        if ($request->has('message.data')) {
            $decoded = base64_decode($request->input('message.data'));
            $data = json_decode($decoded, true) ?? [];
        } else {
            $data = $request->all();
        }

        Log::info('Google Play RTDN webhook received', ['payload' => $data]);

        $subNotification = $data['subscriptionNotification'] ?? $data;
        $notificationType = $subNotification['notificationType'] ?? null;
        $purchaseToken = $subNotification['purchaseToken'] ?? null;
        $subscriptionId = $subNotification['subscriptionId'] ?? '';

        if ($notificationType === null || !$purchaseToken) {
            return response()->json([
                'status' => 'ignored',
                'message' => 'Missing notificationType or purchaseToken in payload.',
            ], 200); // 200 OK so Pub/Sub does not endlessly retry invalid payload
        }

        $result = $this->billingManager->handleGooglePlayNotification(
            (int) $notificationType,
            (string) $purchaseToken,
            (string) $subscriptionId
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Notification processed successfully.',
            'data' => $result,
        ], 200);
    }
}
