import csv


headers = {'Player': ('uID:ID(Player),name:string,loan:int,position:string,'
                      'birth_date:string,birth_place:string,'
                      'first_nationality:string,preferred_foot:string,'
                      'weight:int,height:int,jersey_num:int,'
                      'real_position:string,real_position_side:string,'
                      'join_date:string,leave_date:string,country:string,'
                      'new_team:string'),
           'Event': ('id:ID(Event),event_id:int,type_id:int,period_id:int,'
                     'min:int,sec:int,player_id:int,team_id:int,'
                     'outcome:int,x:float,y:float,timestamp:string,'
                     'last_modified:string,version:string,keypass:int,'
                     'assist:int'),
           'Sport': 'id:ID(Sport),name:string',
           'Game': ('id:ID(Game),away_team_id:int,away_team_name:string,'
                    'home_team_id:int,home_team_name:string,'
                    'competition_id:int,competition_name:string,'
                    'game_date:string,matchday:int,period_1_start:string,'
                    'period_2_start:string,period_3_start:string,'
                    'period_4_start:string,period_5_start:string,'
                    'season_id:int,season_name:string'),
           'Qualifier': 'id:ID(Qualifier),qualifier_id:int,value:string',
           'Season': 'season_id:ID(Season),season_name:string',
           'Competition': ('competition_id:ID(Competition),competition_code:string,'
                      'competition_name:string'),
           'Team': ('uID:ID(Team),name:string,city:string,country:string,country_id:int,'
                    'region_id:int,region_name:string,short_club_name:string,'
                    'street:string,web_address:string'),
           'PLAYS FOR': ':START_ID(Player),:END_ID(Team)',
           'PLAYS IN': ':START_ID(Team),:END_ID(Season)',
           'IS A SEASON OF': ':START_ID(Season),:END_ID(Competition)',
           'IS A LEAGUE IN': ':START_ID(Competition),:END_ID(Sport)',
           'WAS INVOLVED IN': ':START_ID(Player),:END_ID(Event)',
           'IS PART OF': ':START_ID(Qualifier),:END_ID(Event)',
           'HAPPENED IN': ':START_ID(Event),:END_ID(Game)',
           'PRECEDED': ':START_ID(Event),:END_ID(Event)',
           'PLAYED IN': ':START_ID(Team),:END_ID(Game)',
           'IS A GAME IN': ':START_ID(Game),:END_ID(Season)',
}


class BaseGraph:

    def __init__(self):
        import os
        if not os.path.exists('/tmp/csvgraph'):
            os.mkdir('/tmp/csvgraph')
        self.files = {}

    def create_rel(self, a, kind, b):
        if kind not in self.files:
            self.files[kind] = csv.writer(open('/tmp/csvgraph/%s.csv' % kind.replace(' ', '_'), 'w'))
            self.files[kind].writerow(headers[kind].split(','))
        self.files[kind].writerow([a, b])

    def create_node(self, kind, **kwargs):
        if kind not in self.files:
            self.files[kind] = csv.writer(open('/tmp/csvgraph/%s.csv' % kind.replace(' ', '_'), 'w'))
            self.files[kind].writerow(headers[kind].split(','))
        if 'id' not in kwargs:
            for k in kwargs:
                if (kind.lower() + '_id') == k or k == 'uID':
                    kwargs['id'] = kwargs[k]
                    break
        h = map(lambda s: kwargs.get(s.split(':')[0], ''), headers[kind].split(','))
        self.files[kind].writerow([(k if k != 'Unknown' else '') for k in h])
        return kwargs['id']

    def close(self):
        for k in self.files:
            self.files[k].close()
