import os
import sys
# from py2neo import Graph, Node, Relationship
from csvgraph import Graph
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
    
        for official in team.findall('TeamOfficial'):
            for info in official.find('PersonName'):
                official.attrib[info.tag] = stringfromelem(info)
            o = graph.create_node('TeamOfficial', **official.attrib)
            graph.create_rel(o, 'MANAGES', t)
    
        for stadium in team.findall('Stadium'):
            for info in stadium:
                stadium.attrib[info.tag] = stringfromelem(info)
            s = graph.create_node('Stadium', **stadium.attrib)
            graph.create_rel(s, 'IS THE STADIUM OF', t)
    
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
    print('Reading', fname, '...', end='', file=sys.stderr, flush=True)
    games = et.parse(fname).getroot()

    game = games.find('Game')
    s = game.attrib['season_id'] + game.attrib['competition_id']
    g = graph.create_node('Game', **game.attrib)
    # s = graph.run('MATCH (s:Season { season_id: "%s" })'
    #               '--(l:Competition { competition_id: "%s" })'
    #               ' RETURN s' % (game.attrib['season_id'],
    #                              game.attrib['competition_id'])).evaluate()
    # if not s:
    #     continue
    # home = graph.run('MATCH (t:Team { uID: "t%s" }) RETURN t'
    #                  % game.attrib['home_team_id']).evaluate()
    # away = graph.run('MATCH (t:Team { uID: "t%s" }) RETURN t'
    #                  % game.attrib['away_team_id']).evaluate()

    for event in game:
        e = graph.create_node('Event', **event.attrib)
        for qualifier in event:
            qualifier.attrib['id'] += event.attrib['id']
            q = graph.create_node('Qualifier', **qualifier.attrib)
            graph.create_rel(q, 'IS PART OF', e)
        pid = event.get('player_id')
        if pid and ('p'+pid) in players:
            graph.create_rel('p'+pid, 'WAS INVOLVED IN', e)
        graph.create_rel(e, 'HAPPENED IN', g)
    
    graph.create_rel('t'+game.attrib['home_team_id'], 'PLAYED IN', g)
    graph.create_rel('t'+game.attrib['away_team_id'], 'PLAYED IN', g)
    graph.create_rel(g, 'IS A GAME IN', s)
    print(' done.', file=sys.stderr)
