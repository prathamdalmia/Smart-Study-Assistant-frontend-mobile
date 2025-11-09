# Fix Build Issues

If you're experiencing Kotlin compilation errors with incremental cache issues, follow these steps:

## Step 1: Clean Flutter Build
```bash
cd Frontend-Mobile
flutter clean
```

## Step 2: Clean Gradle Build Cache
```bash
cd android
./gradlew clean
cd ..
```

## Step 3: Delete Build Directory (if issues persist)
On Windows:
```bash
rmdir /s /q build
```

On Linux/Mac:
```bash
rm -rf build
```

## Step 4: Get Dependencies Again
```bash
flutter pub get
```

## Step 5: Rebuild
```bash
flutter run
```

## Alternative: If issues persist

If you still get Kotlin cache errors, try:

1. **Stop Gradle daemon:**
```bash
cd android
./gradlew --stop
cd ..
```

2. **Delete .gradle cache:**
```bash
cd android
rmdir /s /q .gradle
cd ..
```

3. **Delete Flutter build cache:**
```bash
flutter clean
rmdir /s /q build
```

4. **Rebuild from scratch:**
```bash
flutter pub get
flutter run
```

## Note
The Kotlin incremental compilation cache can get corrupted when:
- Files are moved between different drives (C: vs D:)
- Build is interrupted
- Gradle daemon crashes

The solution is always to clean the build cache and rebuild.

