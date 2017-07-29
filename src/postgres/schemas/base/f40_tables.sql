CREATE TABLE teams (
       id                   INTEGER PRIMARY KEY,
       name                 TEXT NOT NULL,
       short_club_name      TEXT,
       official_club_name   TEXT,
       founded              INTEGER,
       city                 TEXT,
       country              TEXT,
       region               TEXT
);

CREATE TABLE players (
       id                   INTEGER PRIMARY KEY,
       name                 TEXT NOT NULL,
       first_name           TEXT,
       middle_name          TEXT,
       last_name            TEXT,
       known_name           TEXT,
       birth_place          TEXT,
       birth_date           DATE,
       deceased             TEXT,
       weight               INTEGER,
       height               INTEGER,
       preferred_foot       TEXT,
       country              TEXT,
       first_nationality    TEXT
);

CREATE TABLE competitions (
       id                   INTEGER PRIMARY KEY,
       name                 TEXT NOT NULL,
       symid                TEXT,
       code                 TEXT NOT NULL
);

CREATE TABLE seasons (
       id                   INTEGER PRIMARY KEY,
       name                 TEXT NOT NULL
);

CREATE TABLE squad_entries (
       id                   SERIAL PRIMARY KEY,
       player_id            INTEGER REFERENCES players(id),
       team_id              INTEGER REFERENCES teams(id),
       season_id            INTEGER REFERENCES seasons(id),
       competition_id       INTEGER REFERENCES competitions(id),
       position             TEXT,
       real_position        TEXT,
       real_position_side   TEXT,
       new_team             TEXT,
       join_date            DATE,
       leave_date           DATE,
       jersey_num           INTEGER
);
