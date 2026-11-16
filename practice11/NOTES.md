# NOTES

Wire: `https://jsonplaceholder.typicode.com`. Checked with GET and POST before writing `fromJson`.

## GET /users and GET /users/1

| | |
| --- | --- |
| Status | 200 |
| Content-Type | application/json; charset=utf-8 |
| Body | a JSON array of users. GET `/users/1` is one object, not an array |

10 users. Every object has the same keys. Nothing in the ten responses is missing or `null`.

Top-level keys: `id`, `name`, `username`, `email`, `address`, `phone`, `website`, `company`.

Nested twice: `address` and `company`. `address.geo` is one level deeper (`lat`, `lng`).

### User

| field | JSON type | Dart type | nullable? |
| --- | --- | --- | --- |
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | no in all 10 responses; the model still reads it with `as String?`, the only optional field |
| company | object | `({String name, String catchPhrase})` | no |

### Address

| field | JSON type | Dart type | nullable? |
| --- | --- | --- | --- |
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object | Geo | no |

### Geo

`lat` and `lng` are strings on the wire (`"-37.3159"`, `"81.1496"`), not numbers. The model stores `double` via `double.parse`.

| field | JSON type | Dart type | nullable? |
| --- | --- | --- | --- |
| lat | string | double | no |
| lng | string | double | no |

### Company

| field | JSON type | Dart type | nullable? |
| --- | --- | --- | --- |
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | not stored | no |

`company` in the model is the record `({String name, String catchPhrase})`. `bs` is on the wire and is not part of the record.

## GET /users/999

| | |
| --- | --- |
| Status | 404 |
| Content-Type | application/json; charset=utf-8 |
| Body | `{}` |

Level 3 maps this to `NotFoundException`. The status has to be checked before `fromJson`: the body is valid JSON, and the cast on `id` would otherwise throw `BadResponseException` for the wrong reason.

## POST /users

Request: `Content-Type: application/json`, body `{"name":"Ada Lovelace","username":"ada","email":"ada@example.com"}`.

| | |
| --- | --- |
| Status | 201 |
| Content-Type | application/json; charset=utf-8 |
| Body | the same object, plus `id` |

The server adds `id`. For this request the id was `11`. Level 3 expects 201. `401` → `UnauthorizedException`, `>= 500` → `ServerException`.

## GET /users?id=3

| | |
| --- | --- |
| Status | 200 |
| Content-Type | application/json; charset=utf-8 |
| Body | a list of one user, not an object |

This is the shape `Uri.https` produces when query parameters are passed: a filter, still a list.

## No network

Same Offline screen either way (`NoConnectionException`).

| Test | Time |
| --- | --- |
| Airplane mode. No route, `SocketException` | under 1 s |
| Wi-Fi that leads nowhere. Packets never return, `TimeoutException` | 10 s |

`screenshot_timeout.png` — DevTools → Network, `/users`, no status, about 10 s.

`screenshot_200.png` — the same request with the network back, status 200, response body open.
