.PHONY: help test lint format mobile-test backend-test

help:
	@echo "Ramez Tunnel Plus Monorepo Commands:"
	@echo "  make lint         - Run linters on mobile and backend"
	@echo "  make test         - Run test suites on mobile and backend"
	@echo "  make format       - Format Dart and PHP code"
	@echo "  make mobile-run   - Launch mobile app in dev flavor"

lint:
	cd apps/mobile && flutter analyze
	cd apps/backend && composer phpstan

test: mobile-test backend-test

mobile-test:
	cd apps/mobile && flutter test

backend-test:
	cd apps/backend && php artisan test

format:
	cd apps/mobile && dart format .
	cd apps/backend && composer pint
