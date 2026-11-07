<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Plan;
use App\Models\PromoCode;
use App\Models\Subscription;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\View\View;

class AdminPlanController extends Controller
{
    /**
     * Plans and promo codes manager.
     */
    public function index(): View
    {
        $plans = Plan::withCount(['subscriptions', 'promoCodes'])->get();
        $promoCodes = PromoCode::with(['plan'])->withCount('redeemedDevices')->latest()->paginate(15);

        $stats = [
            'total_plans' => Plan::count(),
            'active_plans' => Plan::where('is_active', true)->count(),
            'total_promos' => PromoCode::count(),
            'active_promos' => PromoCode::where('is_active', true)->count(),
            'total_redemptions' => PromoCode::sum('uses_count'),
            'active_subscribers' => Subscription::whereIn('status', ['active', 'in_grace_period'])->count(),
        ];

        return view('admin.plans.index', compact('plans', 'promoCodes', 'stats'));
    }

    /**
     * Store a new subscription plan.
     */
    public function storePlan(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'slug' => ['required', 'string', 'max:100', 'unique:plans,slug'],
            'google_play_product_id' => ['required', 'string', 'max:100', 'unique:plans,google_play_product_id'],
            'description' => ['nullable', 'string', 'max:255'],
            'price_cents' => ['required', 'integer', 'min:0'],
            'currency' => ['required', 'string', 'size:3'],
            'duration_days' => ['required', 'integer', 'min:1'],
            'features' => ['nullable', 'string'], // comma separated
            'is_featured' => ['boolean'],
            'is_active' => ['boolean'],
        ]);

        $featuresList = !empty($validated['features'])
            ? array_map('trim', explode(',', $validated['features']))
            : ['High Speed', 'Unlimited Bandwidth', 'All Server Locations'];

        $plan = Plan::create([
            'name' => $validated['name'],
            'slug' => Str::slug($validated['slug']),
            'google_play_product_id' => $validated['google_play_product_id'],
            'description' => $validated['description'],
            'price_cents' => (int) $validated['price_cents'],
            'currency' => strtoupper($validated['currency']),
            'duration_days' => (int) $validated['duration_days'],
            'features' => $featuresList,
            'is_featured' => $request->boolean('is_featured'),
            'is_active' => $request->has('is_active') ? $request->boolean('is_active') : true,
        ]);

        AuditLog::record(
            action: 'plan.created',
            resourceType: 'Plan',
            resourceId: $plan->id,
            details: ['name' => $plan->name, 'price' => $plan->price_cents, 'slug' => $plan->slug]
        );

        return redirect()->route('admin.plans.index')->with('success', "Plan '{$plan->name}' created successfully.");
    }

    /**
     * Update an existing plan.
     */
    public function updatePlan(Request $request, int $id): RedirectResponse
    {
        $plan = Plan::findOrFail($id);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'google_play_product_id' => ['required', 'string', 'max:100', 'unique:plans,google_play_product_id,' . $plan->id],
            'description' => ['nullable', 'string', 'max:255'],
            'price_cents' => ['required', 'integer', 'min:0'],
            'duration_days' => ['required', 'integer', 'min:1'],
            'is_featured' => ['boolean'],
            'is_active' => ['boolean'],
        ]);

        $validated['is_featured'] = $request->boolean('is_featured');
        $validated['is_active'] = $request->boolean('is_active');

        $plan->update($validated);

        AuditLog::record(
            action: 'plan.updated',
            resourceType: 'Plan',
            resourceId: $plan->id,
            details: ['name' => $plan->name, 'price' => $plan->price_cents]
        );

        return redirect()->route('admin.plans.index')->with('success', "Plan '{$plan->name}' updated.");
    }

    /**
     * Toggle plan active state.
     */
    public function togglePlan(int $id): RedirectResponse
    {
        $plan = Plan::findOrFail($id);
        $plan->is_active = !$plan->is_active;
        $plan->save();

        AuditLog::record(
            action: 'plan.toggled',
            resourceType: 'Plan',
            resourceId: $plan->id,
            details: ['name' => $plan->name, 'is_active' => $plan->is_active]
        );

        $status = $plan->is_active ? 'ENABLED' : 'DISABLED';
        return redirect()->back()->with('success', "Plan '{$plan->name}' is now {$status}.");
    }

    /**
     * Create promo code voucher.
     */
    public function storePromo(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'code' => ['required', 'string', 'max:50', 'unique:promo_codes,code'],
            'plan_id' => ['nullable', 'exists:plans,id'],
            'description' => ['nullable', 'string', 'max:255'],
            'duration_days' => ['required', 'integer', 'min:1'],
            'max_uses' => ['required', 'integer', 'min:0'], // 0 = unlimited
            'expires_at' => ['nullable', 'date'],
        ]);

        $promo = PromoCode::create([
            'code' => strtoupper(trim($validated['code'])),
            'plan_id' => $validated['plan_id'] ?? null,
            'description' => $validated['description'] ?? 'Promotional voucher',
            'duration_days' => (int) $validated['duration_days'],
            'max_uses' => (int) $validated['max_uses'],
            'uses_count' => 0,
            'is_active' => true,
            'expires_at' => $validated['expires_at'] ?? null,
        ]);

        AuditLog::record(
            action: 'promo_code.created',
            resourceType: 'PromoCode',
            resourceId: $promo->id,
            details: [
                'code' => $promo->code,
                'duration_days' => $promo->duration_days,
                'max_uses' => $promo->max_uses,
            ]
        );

        return redirect()->route('admin.plans.index')->with('success', "Promo code voucher '{$promo->code}' created successfully.");
    }

    /**
     * Toggle promo code active state.
     */
    public function togglePromo(int $id): RedirectResponse
    {
        $promo = PromoCode::findOrFail($id);
        $promo->is_active = !$promo->is_active;
        $promo->save();

        AuditLog::record(
            action: 'promo_code.toggled',
            resourceType: 'PromoCode',
            resourceId: $promo->id,
            details: ['code' => $promo->code, 'is_active' => $promo->is_active]
        );

        $status = $promo->is_active ? 'ENABLED' : 'DISABLED';
        return redirect()->back()->with('success', "Promo code '{$promo->code}' is now {$status}.");
    }

    /**
     * Delete promo code.
     */
    public function destroyPromo(int $id): RedirectResponse
    {
        $promo = PromoCode::findOrFail($id);
        $code = $promo->code;

        AuditLog::record(
            action: 'promo_code.deleted',
            resourceType: 'PromoCode',
            resourceId: $promo->id,
            details: ['code' => $code]
        );

        $promo->delete();

        return redirect()->route('admin.plans.index')->with('success', "Promo code '{$code}' deleted.");
    }
}
