-- TODO

CREATE OR REPLACE FUNCTION counter_attacks()
    RETURNS SETOF eventq AS $$
DECLARE 
  pertinent boolean := false;
  event RECORD;
BEGIN
FOR event IN SELECT * FROM eventq LOOP
    IF NOT pertinent AND event.type_id = 1
                     AND event.qualifier_id = 6 THEN
        pertinent := true;
    ELSIF pertinent AND event.type_id = 12
                    AND event.outcome
                    AND event.qualifier_id = 15 THEN
        pertinent := false;
        RETURN NEXT event;
    ELSIF pertinent AND event.type_id != 44 THEN
        pertinent := false;
    END IF;
END LOOP;
END
$$ LANGUAGE plpgsql;

SELECT count(*) FROM corners_headed_clear();
