import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prac11/features/users/user.dart';

void main() {
  test('user 1 survives fromJson and round-trips', () {
    final json = jsonDecode(_user1) as Map<String, dynamic>;
    final user = User.fromJson(json);

    expect(user.id, 1);
    expect(user.name, 'Leanne Graham');
    expect(user.website, 'hildegard.org');
    expect(user.address.geo.lat, double.parse('-37.3159'));
    expect(user.address.geo.lng, double.parse('81.1496'));
    expect(user.company.name, 'Romaguera-Crona');
    expect(user.company.catchPhrase, 'Multi-layered client-server neural-net');
    expect(user.phoneDigits, '1770736803156442');
    expect(user.toString(), 'User(1, Leanne Graham)');
    expect((user.toJson()['address'] as Map)['geo']['lat'], isA<String>());

    final again = User.fromJson(
      jsonDecode(jsonEncode(user.toJson())) as Map<String, dynamic>,
    );
    expect(again, user);
    expect(again.name, user.name);
    expect(again.address.city, user.address.city);
    expect(again.address.geo.lng, user.address.geo.lng);
    expect(again.company.catchPhrase, user.company.catchPhrase);
  });

  test('website is the only optional field', () {
    final json = jsonDecode(_user1) as Map<String, dynamic>;
    json['website'] = null;
    expect(User.fromJson(json).website, isNull);

    json.remove('website');
    final user = User.fromJson(json);
    expect(user.website, isNull);
    expect(User.fromJson(user.toJson()).website, isNull);
  });

  test('a string id or a numeric lat fails at the cast', () {
    final stringId = jsonDecode(_user1) as Map<String, dynamic>;
    stringId['id'] = '1';
    expect(() => User.fromJson(stringId), throwsA(isA<TypeError>()));

    final numericLat = jsonDecode(_user1) as Map<String, dynamic>;
    final address = numericLat['address'] as Map<String, dynamic>;
    final geo = address['geo'] as Map<String, dynamic>;
    geo['lat'] = -37.3159;
    expect(() => User.fromJson(numericLat), throwsA(isA<TypeError>()));
  });
}

const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';
