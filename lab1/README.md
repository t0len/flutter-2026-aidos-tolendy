# Exchange

Language exchange meetups. A meetup has a start time, a language, and a seat limit. You join with the name saved on the profile tab. The list and the profile stay in memory.

## Screenshots

![Phone, light theme](screenshots/phone-light.png)

![Phone, dark theme](screenshots/phone-dark.png)

![Tablet grid](screenshots/tablet-grid.png)

## Decisions

The meetup list and the profile live in the shell's state, and the three tabs only receive them as arguments plus callbacks. The detail is another route on the same navigator, so it cannot call setState on the shell; the callbacks in its route arguments are how a join, an edit, or a delete gets back into that list. The form does not change the list itself: it pops the meetup it built, and the caller writes it into state only when the result is non-null and the widget is still mounted, so backing out leaves the list alone. The grid breakpoint is a LayoutBuilder on the list's own width, at 600 px, with as many columns as keep each cell at or under 360 px, because a MediaQuery would measure the screen rather than the space the list actually has. PopScope compares the controllers, the clock, and the switches with the meetup the form was opened with, and it asks before leaving only when those differ; Save pops the result directly. ThemeMode is state on MyApp, above MaterialApp, and the profile tab receives it through the shell as a value and a callback, the same way the tabs receive the list. With week 9's tools I would move this list and the profile out of the shell into something that survives a restart, so the routes would stop carrying a callback for every change.
