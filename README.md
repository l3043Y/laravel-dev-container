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
