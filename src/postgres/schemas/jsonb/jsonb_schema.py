import json
import os

from glob import glob

from .. import BaseSchema


class JSONBSchema(BaseSchema):

    __schema_name__ = "jsonb"

    tabledir = os.path.dirname(os.path.realpath(__file__))
    f24_tables = os.path.join(tabledir, 'f24_tables.sql')

    def process_f24(self, file, event_file):
        from xml.etree import ElementTree as et

        games = et.parse(file).getroot()
        game = games.find('Game')

        for event in game:
            if event.get('type_id') == '43': # Deleted event
                continue
            qj = {}
            for qualifier in event:
                qj[qualifier.get('qualifier_id')] = self._parse_stuff(
                    qualifier.get('value', True))
        
            event_file.writerow({'match_id': game.get('id'),
                                 'qualifiers': json.dumps(qj),
                                 **event.attrib})

    def insert_f24(self, cur):

        cur.execute('SELECT * FROM events LIMIT 0;')
        event_cols = [desc[0] for desc in cur.description]

        from csv import DictWriter
        from tempfile import TemporaryFile

        event_file = TemporaryFile('w+')
        event_csv = DictWriter(event_file, event_cols, restval=r'\N',
                               extrasaction='ignore', dialect='excel-tab',
                               quotechar="'")

        for fname in glob('optadata/f24-*.xml'):
            if int(fname.split('-')[2]) < 2015:
                continue
            self.log('Reading', fname, flush=True)
            with open(fname) as file:
                self.process_f24(file, event_csv)

        event_file.seek(0)
        self.log('Inserting events', flush=True)
        cur.copy_from(event_file, 'events', columns=event_cols)

    def create_indexes(self, cur):
        cur.execute('CREATE INDEX ON events (type_id);')
        cur.execute('CREATE INDEX ON events (match_id);')
        cur.execute('CREATE INDEX ON events (player_id);')

    def _parse_stuff(self, thing):
        if thing is True:
            return True
        try:
            return int(thing)
        except ValueError:
            try:
                return float(thing)
            except ValueError:
                return thing
