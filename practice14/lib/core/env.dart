abstract final class Env {
  static const host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'jsonplaceholder.typicode.com',
  );
  static const useFakes = bool.fromEnvironment('USE_FAKES');
  static const name = String.fromEnvironment('ENV', defaultValue: 'local');
}
