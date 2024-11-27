## Larvel Latest Template

### Initialize Laravel Project
This will create a new project latest Laravel project natively via serversideup docker image
```bash
./init.sh --fresh-start
```
### Register Api Routes
```php
// bootstrap/app.php
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->api(append: [ForceJsonResponse::class]);
    });
```

```angular2html
php artisan vendor:publish --tag=log-viewer-assets
php artisan telescope:install
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
```
```angular2html
log viewer: https://st-k8s-ingress.smart.com.kh/log-viewer
health: https://st-k8s-ingress.smart.com.kh/up
pulse: https://st-k8s-ingress.smart.com.kh/pulse
telescope: https://st-k8s-ingress.smart.com.kh/telescope
api-doc: https://st-k8s-ingress.smart.com.kh/docs/api
```
