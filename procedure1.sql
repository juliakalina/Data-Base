DROP PROCEDURE manager_reward(manager_id BIGINT);
CREATE PROCEDURE manager_reward(manager_id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
	rent_id INT;
	buy_id INT;
BEGIN
	CREATE TEMPORARY TABLE temp_rent AS
	SELECT *
	FROM doc_rent
	INNER JOIN doc_ag ON doc_rent.agency_rent = doc_ag.id_ag
	WHERE doc_ag.manager_ag = manager_id
		AND NOT EXISTS (
		SELECT 1
		FROM bill
 		WHERE bill.doc_rent = doc_rent.id_rent
    	);
		FOR rent_id IN (SELECT id_rent FROM temp_rent)
		LOOP
			INSERT INTO bill (idd_bill, data_bill, sum_bill, type_bill, sender, recipient, booker,
						 bank_buy, doc_buy, doc_rent)
			VALUES((SELECT MAX(idd_bill) + 1 FROM bill), CURRENT_DATE, 
			   ((SELECT cost_rent / 30 FROM temp_rent WHERE id_rent = rent_id) * (SELECT time_rent FROM temp_rent WHERE id_rent = rent_id)) * 0.10, 0, NULL, manager_id,
			    8720985712, (SELECT bank_rent FROM temp_rent WHERE id_rent = rent_id), NULL, rent_id);
		END LOOP;	
		
		CREATE TEMPORARY TABLE temp_buy AS
		SELECT *
		FROM doc_buy
		INNER JOIN doc_ag ON doc_buy.agency_buy = doc_ag.id_ag
		WHERE doc_ag.manager_ag = manager_id
			AND NOT EXISTS (
			SELECT 1
			FROM bill
 			WHERE bill.doc_buy = doc_buy.id_buy
    		);
			
		FOR buy_id IN (SELECT id_buy FROM temp_buy)
		LOOP
			INSERT INTO bill (idd_bill, data_bill, sum_bill, type_bill, sender, recipient, booker,
						 bank_buy, doc_buy, doc_rent)
			VALUES((SELECT MAX(idd_bill) + 1 FROM bill), CURRENT_DATE, 
			   (SELECT sum_buy FROM temp_buy WHERE id_buy = buy_id) * 0.15, 0, NULL, manager_id,
			    8720985712, (SELECT bank_buy FROM temp_buy WHERE id_buy = buy_id), buy_id, NULL);
		END LOOP;

	DROP TABLE temp_buy;
	DROP TABLE temp_rent;	
END;
$$;
