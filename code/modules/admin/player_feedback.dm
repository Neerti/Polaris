// This provides a basic implementation of a feedback system in-game.
// The advantage of having it in-game is that the feedback received is most likely to be from
// a player whom is active and cares about the server, as opposed to someone who hasn't played in
// two years and might actually be banned.

// This file is for the 'front-end' code, IE what players and staff will see.
// The actual data is stored in a local SQLite database. The code to handle that
// is inside code/modules/sqlite/feedback.dm .
