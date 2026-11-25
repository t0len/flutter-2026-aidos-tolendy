import 'package:prac13/core/api/api_exception.dart';
import 'package:prac13/features/users/user.dart';
import 'package:prac13/features/users/user_repository.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  static const _users = <User>[
    User(
      id: 1,
      name: 'Leanne Graham',
      username: 'Bret',
      email: 'Sincere@april.biz',
      phone: '1-770-736-8031 x56442',
      website: 'hildegard.org',
      address: Address(
        street: 'Kulas Light',
        suite: 'Apt. 556',
        city: 'Gwenborough',
        zipcode: '92998-3874',
        geo: Geo(lat: -37.3159, lng: 81.1496),
      ),
      company: (
        name: 'Romaguera-Crona',
        catchPhrase: 'Multi-layered client-server neural-net',
      ),
    ),
    User(
      id: 2,
      name: 'Ervin Howell',
      username: 'Antonette',
      email: 'Shanna@melissa.tv',
      phone: '010-692-6593 x09125',
      website: 'anastasia.net',
      address: Address(
        street: 'Victor Plains',
        suite: 'Suite 879',
        city: 'Wisokyburgh',
        zipcode: '90566-7771',
        geo: Geo(lat: -43.9509, lng: -34.4618),
      ),
      company: (
        name: 'Deckow-Crist',
        catchPhrase: 'Proactive didactic contingency',
      ),
    ),
  ];

  Future<void> _wait() => Future<void>.delayed(delay);

  @override
  Future<UsersResult> getAll() async {
    await _wait();
    if (fail) throw const NoConnectionException();
    return const UsersResult(items: _users, fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _wait();
    if (fail) throw const NoConnectionException();
    for (final user in _users) {
      if (user.id == id) return user;
    }
    throw const NotFoundException();
  }

  @override
  Future<User> create(User draft) async {
    await _wait();
    if (fail) throw const NoConnectionException();
    return draft;
  }
}
