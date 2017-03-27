import os
import re
import sys
from collections import defaultdict
from glob import glob

import psycopg2
from psycopg2.extensions import AsIs


class BaseSchema:

    __schema_name__ = "base"

    tabledir = os.path.dirname(os.path.realpath(__file__))
    f9_tables = os.path.join(tabledir, 'f9_tables.sql')
    f24_tables = os.path.join(tabledir, 'f24_tables.sql')
    f40_tables = os.path.join(tabledir, 'f40_tables.sql')

    def log(self, s, *args, **kwargs):
        return print('[%s] %s' % (self.__schema_name__, s), *args,
                     file=sys.stderr, **kwargs)

    def load(self):

        conn = psycopg2.connect(dbname='opta', host='/tmp/')
        cur = conn.cursor()

        cur.execute('CREATE SCHEMA IF NOT EXISTS ' + self.__schema_name__)
        cur.execute('SET search_path TO ' + self.__schema_name__)

        with open(self.f40_tables) as file:
            cur.execute(file.read())

        self.insert_f40(cur)

        with open(self.f9_tables) as file:
            cur.execute(file.read())

        self.insert_f9(cur)

        with open(self.f24_tables) as file:
            cur.execute(file.read())

        self.insert_f24(cur)

        self.create_indexes(cur)
        conn.commit()
        cur.close()
        conn.close()

    def insert_f40(self, cur):
        for fname in glob('optadata/srml-*-squads.xml'):
            if int(fname.split('-')[2]) < 2015:
                continue
            self.log('Reading', fname, flush=True)
            with open(fname) as file:
                competition, season, squad_entries, players, teams = self.process_f40(file)
            self.log('Inserting', fname, flush=True)
            cur.execute('INSERT INTO competitions (%s) VALUES %s ON CONFLICT DO NOTHING',
                        (AsIs(', '.join(competition.keys())), tuple(competition.values())))
            cur.execute('INSERT INTO seasons (%s) VALUES %s ON CONFLICT DO NOTHING',
                        (AsIs(', '.join(season.keys())), tuple(season.values())))
            for team in teams.values():
                cur.execute('INSERT INTO teams (%s) VALUES %s ON CONFLICT DO NOTHING', (AsIs(', '.join(team.keys())), tuple(team.values())))
            for player in players.values():
                cur.execute('INSERT INTO players (%s) VALUES %s ON CONFLICT DO NOTHING', (AsIs(', '.join(player.keys())), tuple(player.values())))
            for entry in squad_entries.values():
                cur.execute('INSERT INTO squad_entries (%s) VALUES %s', (AsIs(', '.join(entry.keys())), tuple(entry.values())))

    def insert_f9(self, cur):
        for fname in glob('optadata/srml-*-matchresults.xml'):
            if int(fname.split('-')[2]) < 2015:
                continue
            self.log('Reading', fname, flush=True)
            with open(fname) as file:
                m, p, t, mp = self.process_f9(file)
            self.log('Inserting', fname, flush=True)

            for plr in mp:
                cur.execute('INSERT INTO players (%s) VALUES %s ON CONFLICT DO NOTHING',
                            (AsIs(', '.join(plr.keys())), tuple(plr.values())))

            cur.execute('INSERT INTO matches (%s) VALUES %s',
                            (AsIs(', '.join(m.keys())), tuple(m.values())))
            for player_id, stats in p.items():
                cur.execute('INSERT INTO player_results (%s) VALUES %s',
                            (AsIs(', '.join(stats.keys())), tuple(stats.values())))
            for team in t:
                cur.execute('INSERT INTO team_results (%s) VALUES %s',
                            (AsIs(', '.join(team.keys())), tuple(team.values())))

    def insert_f24(self, cur):

        cur.execute('SELECT * FROM events LIMIT 0;')
        event_cols = [desc[0] for desc in cur.description]
        cur.execute('SELECT * FROM qualifiers LIMIT 0;')
        qual_cols = [desc[0] for desc in cur.description if desc[0] != 'id']

        from csv import DictWriter
        from tempfile import TemporaryFile

        event_file = TemporaryFile('w+')
        qualifier_file = TemporaryFile('w+')
        event_csv = DictWriter(event_file, event_cols, restval=r'\N',
                               extrasaction='ignore', dialect='excel-tab')
        qualifier_csv = DictWriter(qualifier_file, qual_cols, restval=r'\N',
                                   extrasaction='ignore', dialect='excel-tab')

        for fname in glob('optadata/f24-*.xml'):
            if int(fname.split('-')[2]) < 2015:
                continue
            self.log('Reading', fname, flush=True)
            with open(fname) as file:
                self.process_f24(file, event_csv, qualifier_csv)

        event_file.seek(0)
        qualifier_file.seek(0)
        self.log('Inserting events', flush=True)
        cur.copy_from(event_file, 'events', columns=event_cols)
        self.log('Inserting qualifiers', flush=True)
        cur.copy_from(qualifier_file, 'qualifiers', columns=qual_cols)

    def create_indexes(self, cur):
        cur.execute('CREATE INDEX ON qualifiers (event_id);')
        cur.execute('CREATE INDEX ON events (type_id);')
        cur.execute('CREATE INDEX ON events (match_id);')
        cur.execute('CREATE INDEX ON events (player_id);')

    def process_f24(self, file, event_file, qualifier_file):
        from xml.etree import ElementTree as et

        games = et.parse(file).getroot()
        game = games.find('Game')

        for event in game:
            if event.get('type_id') == '43': # Deleted event
                continue
            qj = {}

            event_file.writerow({'match_id': game.get('id'),
                                 **event.attrib})
            for qualifier in event:
                qualifier_file.writerow({'event_id': event.get('id'),
                                         **qualifier.attrib})

    def process_f9(self, file):
        shared_stats = {}
        match_stats, player_stats = {}, []
        _, competition_id, season_id, match_id, *_ = file.name.split('-')
        match_id = match_id[1:]
        ts = {'competition_id': competition_id, 'season_id': season_id,
              'match_id': match_id}
        match_stats = {'competition_id': competition_id, 'season_id': season_id,
              'id': match_id}
        team_stats = [ts.copy(), ts.copy()]
        shared_stats = ts.copy()
        for line in file:
            if line.startswith('<SoccerFeed'):
                break
        file.readline()             # <SoccerDocument ...
        file.readline()             # <Competition ...
        for line in file:
            if 'matchday' in line:
                match_stats['matchday'] = re.search(r'>(.+)<', line).group(1)
                break
            elif '</Competition' in line:
                break

        for line in file:
            if '<MatchInfo' in line:
                break
        m = dict(re.findall(r'([^ ]+)="([^"]+)"', line))
        match_stats['weather'] = m.get('Weather', None)
        match_stats['match_type'] = m['MatchType']
        s = ''
        for line in file:
            s += line
            if '/MatchInfo' in line:
                break
        m = re.search(r'Attendance>(.+)<', s)
        if m:
            match_stats['attendance'] = m.group(1)
        m = re.search(r'Date>(.+)<', s)
        if m:
            match_stats['kickoff'] = m.group(1)
        m = re.search(r'Result Type="([^"]+)"', s)
        if m:
            match_stats['result_type'] = m.group(1)
        m = re.search(r'Winner="([^"]+)"', s)
        if m:
            match_stats['winner'] = m.group(1)[1:]
        for line in file:
            if 'TeamData' in line:
                break

        # Team 1
        m = {'score': re.search(r'Score="([^"]+)"', line).group(1),
             'side': re.search(r'Side="([^"]+)"', line).group(1),
             'team_id': re.search(r'TeamRef="([^"]+)"', line).group(1)[1:]}
        for d in shared_stats, team_stats[0]:
            d.update(m)
        player_stats = defaultdict(shared_stats.copy)

        for line in file:
            if 'PlayerLineUp' in line:
                break

        # Scan player stats
        for line in file:
            m = dict(re.findall(r'([^ ]+)="([^"]+)"', line))
            if not m or 'MatchPlayer' not in line:
                break
            player_id = m['PlayerRef'][1:]
            player_stats[player_id]['player_id'] = player_id
            player_stats[player_id]['position'] = m['Position']
            player_stats[player_id]['shirt_number'] = m['ShirtNumber']
            player_stats[player_id]['status'] = m['Status']
            if 'SubPosition' in m:
                player_stats[player_id]['sub_position'] = m['SubPosition']
            for line in file:
                m = re.search(r'<Stat Type="(?P<type>[^"]+)">(?P<value>[^<]+)<', line)
                if not m:
                    break
                if m.group('value') != 'Unknown':
                    player_stats[player_id][m.group('type')] = m.group('value')
        file.readline()
        for line in file:
            m = re.search(r'<Stat FH="(?P<first>[^"]+)" SH="(?P<second>[^"]+)" Type="(?P<type>[^"]+)">(?P<value>[^<]+)<', line)
            if not m:
                break
            # TODO: Care about first and second half
            team_stats[0][m.group('type')] = m.group('value')

        for line in file:
            if '<TeamData' in line:
                break
        # Team 2
        m = {'score': re.search(r'Score="([^"]+)"', line).group(1),
             'side': re.search(r'Side="([^"]+)"', line).group(1),
             'team_id': re.search(r'TeamRef="([^"]+)"', line).group(1)[1:]}
        for d in shared_stats, team_stats[1]:
            d.update(m)

        for line in file:
            if 'PlayerLineUp' in line:
                break
        # Scan player stats
        for line in file:
            m = dict(re.findall(r'([^ ]+)="([^"]+)"', line))
            if not m or 'MatchPlayer' not in line:
                break
            player_id = m['PlayerRef'][1:]
            player_stats[player_id]['player_id'] = player_id
            player_stats[player_id]['position'] = m['Position']
            player_stats[player_id]['shirt_number'] = m['ShirtNumber']
            player_stats[player_id]['status'] = m['Status']
            if 'SubPosition' in m:
                player_stats[player_id]['sub_position'] = m['SubPosition']
        for line in file:
            m = re.search(r'<Stat Type="(?P<type>[^"]+)">(?P<value>[^<]+)<', line)
            if not m:
                break
            if m.group('value') != 'Unknown':
                player_stats[player_id][m.group('type')] = m.group('value')
        file.readline()
        for line in file:
            m = re.search(r'<Stat FH="(?P<first>[^"]+)" SH="(?P<second>[^"]+)" Type="(?P<type>[^"]+)">(?P<value>[^<]+)<', line)
            if not m:
                break
            # TODO: Care about first and second half
            team_stats[1][m.group('type')] = m.group('value')

        s = file.read()
        m = re.findall(r'<Player Position="([^"]+)" uID="([^"]+)">\s+<PersonName>'
                       r'\s+<First>([^<]+)</First>\s+<Last>([^<]+)</Last>', s)

        match_players = [{'id': p[1][1:], 'name': ' '.join(p[2:]),
                          'last_name': p[3], 'first_name': p[2]} for p in m]

        return match_stats, player_stats, team_stats, match_players

    def process_f40(self, file):
        _, comp, season, *_ = file.name.split('-')
        shared_stats = {'competition_id': comp, 'season_id': season}

        competition = {'id': comp}
        season = {'id': season}
        squad_entries = defaultdict(shared_stats.copy)
        players = defaultdict(dict)
        teams = defaultdict(dict)

        for line in file:
            if '<SoccerDocument' in line:
                break
        m = dict(re.findall(r'([^ ]+)="([^"]+)"', line))

        competition['name'] = m['competition_name']
        competition['code'] = m['competition_code']
        season['name'] = m['season_name']

        for line in file:
            if '<Team ' in line:
                m = dict(re.findall(r'([^ ]+)="([^"]+)"', line))
                team_id = m['uID'][1:]
                teams[team_id]['id'] = team_id
                for key in {'short_club_name', 'official_club_name', 'city', 'region', 'country'}:
                    if key in m:
                        teams[team_id][key] = m[key]
                line = file.readline()
                while '<Name>' not in line:
                    m = re.search(r'<(?P<key>[^>]+)>(?P<value>[^<]+)<', line)
                    teams[team_id][m.group('key').lower()] = m.group('value')
                    line = file.readline()
                teams[team_id]['name'] = re.search(r'<Name>([^<]+)<', line).group(1)

                for line in file:
                    if '<Player ' in line:
                        player_id = re.search(r'uID="p([^"]+)"', line).group(1)
                        players[player_id]['id'] = player_id
                        squad_entries[player_id]['team_id'] = team_id
                        squad_entries[player_id]['player_id'] = player_id
                        players[player_id]['name'] = re.search(r'>([^<]+)<', file.readline()).group(1)
                        squad_entries[player_id]['position'] = re.search(r'>([^<]+)<', file.readline()).group(1)
                        for line in file:
                            m = re.search(r'<Stat Type="(?P<type>[^"]+)">(?P<val>[^>]+)<', line)
                            if m and m.group('val') != 'Unknown' and not '-00' in m.group('val'):
                                if m.group('type') in {'join_date', 'leave_date',
                                                 'new_team', 'real_position',
                                                 'real_position_side', 'jersey_num'}:
                                    squad_entries[player_id][m.group('type')] = m.group('val')
                                else:
                                    players[player_id][m.group('type')] = m.group('val')
                            elif not m:
                                break
                    elif '</Team>' in line:
                        break
            elif '</SoccerDocument' in line:
                break

        return competition, season, squad_entries, players, teams
