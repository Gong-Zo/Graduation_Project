# flutter_application_1

A new Flutter project.

## API keys

Pass API keys at build or run time instead of committing them to the repository:

```shell
flutter run --dart-define=GEMINI_API_KEY=your_gemini_key --dart-define=API_NINJAS_KEY=your_api_ninjas_key --dart-define=DATA_GO_KR_SERVICE_KEY=your_data_go_kr_key
```

These compile-time values are included in the client app; use a backend proxy for production secrets.
