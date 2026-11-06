<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Root endpoint redirects to Admin dashboard.
     */
    public function test_root_redirects_to_admin_dashboard(): void
    {
        $response = $this->get('/');

        $response->assertRedirect('/admin');
    }
}
