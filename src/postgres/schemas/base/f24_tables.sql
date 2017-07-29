CREATE TABLE events (
       id               INTEGER PRIMARY KEY,
       match_id         INTEGER REFERENCES matches(id),
       team_id          INTEGER REFERENCES teams(id),
       player_id        INTEGER REFERENCES players(id),
       event_id         INTEGER,
       type_id          INTEGER,
       period_id        INTEGER,
       min              INTEGER,
       sec              INTEGER,
       outcome          BOOLEAN,
       keypass          BOOLEAN,
       assist           BOOLEAN,
       x                FLOAT,
       y                FLOAT,
       timestamp        TIMESTAMP,
       last_modified    TIMESTAMP,
       version          BIGINT
);

CREATE TABLE qualifiers (
       id               SERIAL PRIMARY KEY,
       event_id         INTEGER REFERENCES events(id),
       qualifier_id     INTEGER,
       value            TEXT
);
