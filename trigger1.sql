CREATE OR REPLACE FUNCTION prev_agree() RETURNS TRIGGER AS $$
DECLARE
    prev_client BIGINT;
BEGIN
    IF NEW.rent_prev IS NOT NULL THEN
        SELECT buy_person INTO STRICT prev_client
        FROM doc_rent
        WHERE id_rent = NEW.rent_prev;
        IF prev_client <> NEW.buy_person THEN
            RAISE EXCEPTION 'ERROR: the previous agreement was for another client';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prev_agree_trigger
BEFORE INSERT ON doc_rent
FOR EACH ROW
EXECUTE FUNCTION prev_agree();
