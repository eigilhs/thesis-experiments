import os
import sys
from base_schema import BaseGraph as Graph
from xml.etree import ElementTree as et
import glob

def stringfromelem(e):
    return et.tostring(e, method='text', encoding='utf-8').strip().decode()

graph = Graph() # 'http://neo4j:1234@localhost:7474/db/data/')

football = graph.create_node('Sport', name='Football', id='football')
competitions = set()
players = set()
datadir = sys.argv[1]

for fname in glob.glob(os.path.join(datadir, 'srml-*-squads.xml')):
    print('Reading', fname, '...', end='', flush=True, file=sys.stderr)
    root = et.parse(fname).getroot()
    soccer_document = root.find('SoccerDocument')
    soccer_document.attrib['season_id'] += soccer_document.attrib['competition_id'] 
    season = graph.create_node('Season', **soccer_document.attrib)

    if soccer_document.attrib['competition_id'] not in competitions:
        league = graph.create_node('Competition', competition_name=soccer_document.attrib['competition_name'],
                    competition_code=soccer_document.attrib['competition_code'],
                        competition_id=soccer_document.attrib['competition_id'])
        competitions.add(soccer_document.attrib['competition_id'])
    
    for team in soccer_document.findall('Team'):
        name = stringfromelem(team.find('Name'))
        t = graph.create_node('Team', name=name, **team.attrib)
    
        for player in team.findall('Player'):
            for stat in player.findall('Stat'):
                player.attrib[stat.get('Type')] = stringfromelem(stat)
            p = graph.create_node(
                'Player',
                name=stringfromelem(player.find('Name')),
                position=stringfromelem(player.find('Position')),
                **player.attrib
            )
            players.add(p)
            graph.create_rel(p, 'PLAYS FOR', t)
    
        graph.create_rel(t, 'PLAYS IN', season)

    player_changes = soccer_document.find('PlayerChanges')
    if player_changes:
        for team in player_changes.findall('Team'):
            for player in team.findall('Player'):
                for stat in player.findall('Stat'):
                    player.attrib[stat.get('Type')] = stringfromelem(stat)
                p = graph.create_node(
                    'Player',
                    name=stringfromelem(player.find('Name')),
                    position=stringfromelem(player.find('Position')),
                    **player.attrib
                )
                graph.create_rel(p, 'PLAYS FOR', team.attrib['uID'])
        

    graph.create_rel(season, 'IS A SEASON OF', league)
    graph.create_rel(league, 'IS A LEAGUE IN', football)
    print(' done.', file=sys.stderr)

for fname in glob.glob(os.path.join(datadir, 'f24*eventdetails.xml')):
    if int(fname.split('-')[2]) < 2015:
        continue
    print('Reading', fname, '...', end='', file=sys.stderr, flush=True)
    games = et.parse(fname).getroot()

    game = games.find('Game')
    s = game.attrib['season_id'] + game.attrib['competition_id']
    g = graph.create_node('Game', **game.attrib)

    period, previous = 1, None
    for event in game:
        # Ignore deleted events
        if event.attrib['type_id'] == 43:
            continue
        e = graph.create_node('Event', **event.attrib)
        for qualifier in event:
            qualifier.attrib['id'] += event.attrib['id']
            q = graph.create_node('Qualifier', **qualifier.attrib)
            graph.create_rel(q, 'IS PART OF', e)
        pid = event.get('player_id')
        if pid and ('p'+pid) in players:
            graph.create_rel('p'+pid, 'WAS INVOLVED IN', e)
        if previous and event.attrib['period_id'] == period:
            graph.create_rel(previous, 'PRECEDED', e)
        graph.create_rel(e, 'HAPPENED IN', g)
        period, previous = event.attrib['period_id'], e
    
    graph.create_rel('t'+game.attrib['home_team_id'], 'PLAYED IN', g)
    graph.create_rel('t'+game.attrib['away_team_id'], 'PLAYED IN', g)
    graph.create_rel(g, 'IS A GAME IN', s)
    print(' done.', file=sys.stderr)
