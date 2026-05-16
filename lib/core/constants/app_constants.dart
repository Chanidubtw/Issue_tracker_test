class AppConstants {
  static const String appName = 'Issue Tracker';
  static const String hiveIssueBox = 'issues_box';
  static const String hiveSettingsBox = 'settings_box';
  static const String prefThemeKey = 'is_dark_mode';
  static const String prefAuthTokenKey = 'auth_token';
  static const String prefUserEmailKey = 'user_email';
  static const String mockBaseUrl = 'https://mock.issuetracker.local';
  static const int mockNetworkDelay = 800;
}

class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String issueList = '/issues';
  static const String issueDetail = '/issues/:id';
  static const String issueCreate = '/issues/create';
  static const String issueEdit = '/issues/:id/edit';
}
