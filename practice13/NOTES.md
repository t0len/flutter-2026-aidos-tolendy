# NOTES

The first line you cannot write is the arrange step. The old `UsersModel` built its own repository, so `UsersModel(FakeUserRepository(fail: true))` has nowhere to pass the fake.

A widget can be const, has its own rebuild scope, shows up in DevTools, and can be pumped in a test. A method cannot.

## Numeric lat

`lat` on user 1 was the number `-37.3159`. `Geo.fromJson` casts it with `as String`.

```
type 'double' is not a subtype of type 'String' in type cast
    message: double is not a String

#0      new Geo.fromJson (package:prac13/features/users/user.dart:9:37)
    first frame: the cast, line 9 column 37
#1      new Address.fromJson (package:prac13/features/users/user.dart:40:16)
#2      new User.fromJson (package:prac13/features/users/user.dart:87:24)
#3      HttpUserRepository._one (package:prac13/features/users/user_repository.dart:77:19)
#4      HttpUserRepository._users (package:prac13/features/users/user_repository.dart:66:40)
#5      HttpUserRepository._fetch (package:prac13/features/users/user_repository.dart:60:12)
<asynchronous suspension>
#6      HttpUserRepository.getAll (package:prac13/features/users/user_repository.dart:30:21)
<asynchronous suspension>
#7      UsersModel.load (package:prac13/features/users/users_model.dart:22:22)
    path into load, after asynchronous suspension
<asynchronous suspension>
```

#0 is the right place to throw: the cast in `Geo.fromJson` is the contract that `lat` is a String. It is the wrong place to fix: the server broke that contract, so `HttpUserRepository` maps the `TypeError` to `BadResponseException('users: lat is not a String')` and the screen shows the error.
