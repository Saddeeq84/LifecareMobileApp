// lib/config/environment.dart

enum AppEnvironment { dev, prod }

class AppConfig {
  static const AppEnvironment current = AppEnvironment.dev;

  static String get apiKey => current == AppEnvironment.prod
      ? 'PROD_API_KEY'
      : 'AIzaSyAAJqnlBCZJUQ6bGdfbiuVJHVflW4SuHhg'; // ✅ Replace with real DEV API key

  static String get appId => current == AppEnvironment.prod
      ? 'PROD_APP_ID'
      : '1:815876091951:android:4e64b28fad26e9ef1616da'; // ✅ Real DEV App ID

  static String get messagingSenderId => current == AppEnvironment.prod
      ? 'PROD_MSG_ID'
      : '815876091951'; // ✅ Real DEV messaging sender ID

  static String get projectId => current == AppEnvironment.prod
      ? 'PROD_PROJECT_ID'
      : 'lifecare-connect';

  static String get storageBucket => current == AppEnvironment.prod
      ? 'PROD_BUCKET'
      : 'lifecare-connect.appspot.com';
}
// lib/main.dart