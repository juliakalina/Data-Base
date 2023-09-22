--DROP PROCEDURE continue_doc_rent(rent_id INT);

CREATE OR REPLACE PROCEDURE continue_doc_rent(contr_id INT) 
LANGUAGE plpgsql
AS $$
DECLARE
  end_date DATE;
  duration INT;
  id_proc INT;
  prev INT;
BEGIN
  SELECT date_rent + time_rent*INTERVAL '1 DAY' - INTERVAL '1 DAY'
  INTO end_date
  FROM doc_rent
  WHERE id_rent = contr_id OR rent_prev = contr_id OR rent_prev = (SELECT rent_prev 
																   FROM doc_rent WHERE id_rent = contr_id)
  ORDER BY date_rent DESC
  LIMIT 1;
  
  SELECT time_rent
  INTO duration
  FROM doc_rent
  WHERE id_rent = contr_id;
  
  SELECT rent_prev INTO STRICT prev from doc_rent WHERE id_rent = contr_id;
  
  IF prev IS NULL THEN prev = contr_id;
  END IF;
  
  IF end_date <= CURRENT_DATE + INTERVAL '5 DAY' THEN
    INSERT INTO doc_rent (id_rent, date_rent, cost_rent, time_rent, bank_rent, 
						  rieltor_rent, rent_prev, buy_person, agency_rent, flat_id)
    VALUES ((SELECT MAX(id_rent)+1 FROM doc_rent), CURRENT_DATE, (SELECT cost_rent FROM doc_rent 
			WHERE id_rent = contr_id), 180, (SELECT bank_rent FROM doc_rent 
			WHERE id_rent = contr_id), (SELECT rieltor_rent FROM doc_rent 
			WHERE id_rent = contr_id), prev, 
			(SELECT buy_person FROM doc_rent 
			WHERE id_rent = contr_id), (SELECT agency_rent FROM doc_rent 
			WHERE id_rent = contr_id), (SELECT flat_id FROM doc_rent 
			WHERE id_rent = contr_id));
    RAISE NOTICE 'Договор аренды продлен на пол года';
  ELSE
    RAISE NOTICE 'Невозможно продлить договор: до конца более 5 дней';
  END IF;
END;
$$;
