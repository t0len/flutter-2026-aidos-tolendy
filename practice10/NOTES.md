# NOTES

## Level 1 — predicted vs actual print order

Predicted, reading the lines as if each call waited:

```
A
B
C
6 students
```

Actual, from `main` before `runApp`:

```
A
C
fetchStudents #1
<first frame of the app>
B
6 students
```

`main` ran to the end. The first frame was drawn, and only about two seconds later `B` and `6 students` arrived.

Three `fetchStudents()` calls in a row on a fresh `FakeApi`. The third one:

```
Unhandled Exception: Instance of 'NoConnectionException'
```

The app kept running.

Replacing `await Future.delayed` with `sleep` held the first frame off screen for two seconds. The loop was blocked, not waiting. `await` is restored, and the `main` experiments are removed.

## Level 2 — setState() called after dispose()

With both `if (!mounted) return;` lines removed, Back during the two-second load printed:

```
setState() called after dispose(): _StudentsScreenState#a5f85(lifecycle state: defunct, not mounted)
```

The guards are back in `_load`.

## Level 4 — countdown, with and without cancel()

Version B, `_sub.cancel()` in `dispose`, Back at 7:

```
tick 10
tick 9
tick 8
tick 7
```

The console stopped at tick 7. The subscription was cancelled, the generator stopped at its next await, and nothing ticked for a dead screen.

Version B, `_sub.cancel()` removed, Back at 7:

```
setState() called after dispose(): _ListenCountdownState#bcce0(lifecycle state: defunct, not mounted)
```

The console kept printing:

```
tick 6
tick 5
tick 4
tick 3
tick 2
tick 1
tick 0
```

Version A, StreamBuilder, no `cancel()` in that code, Back at 7: the console stopped. StreamBuilder cancelled the subscription.

## Level 5 — unawaited save

The line that did not await `save` and then popped:

The second tap popped the screen as if it had worked, and the console printed:

```
Unhandled Exception: Bad state: server rejected 6
```

The user saw a success.

`flutter analyze` flagged that line with `unawaited_futures`. Save is now awaited, the route pops only on success, and a `StateError` is shown in a snackbar.
