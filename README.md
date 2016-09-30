# Stopwatch.app

Recreation of the iPhone Stopwatch app in Swift 3. This started out as 
a school project and grew into sort of a feature-complete clone of the iOS Stopwatch.

The app was built using Swift 3 in XCode 8.0, and I haven't tested it in any other point releases.

The UI is a little different, but has the same basic elements as the standard app: 2 buttons, a tableview of lap times, and a giant, ticking clock.

## Internals

The app uses MVC to structure code paths, and delegation to communicate. 

The `Stopwatch` class contains all the business logic for the actual timer. It keeps time by taking deltas of start/stop/current time using `Date` (formally `NSDate`). This is the only way I have found to keep *real time*. Using internal counters for `milliseconds`, `seconds`, and `minutes` proved futile, as the `Timer` doesn't appear to fire at *exactly* the intervals you give it. Sometimes it fires, sometimes it doesn't.