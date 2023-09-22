DROP TRIGGER IF EXISTS payment_trigger ON bill;

CREATE OR REPLACE FUNCTION payment_trigger() RETURNS TRIGGER AS $$
DECLARE
    manager_reward NUMERIC;
    realtor_reward NUMERIC;
	percent_renta INT;
	percent_buy INT;
BEGIN
	IF (NEW.type_bill = 1) AND (NEW.doc_rent IS NOT NULL) THEN --аренда
		SELECT per_rent INTO STRICT percent_renta FROM region WHERE id_reg = (
			SELECT room_reg FROM room WHERE room_id = (
				SELECT flat_id FROM doc_rent WHERE id_rent = (
					SELECT doc_rent FROM bill WHERE idd_bill = NEW.idd_bill
				)
			)
		);
		SELECT NEW.sum_bill * 0.1 INTO manager_reward;
        SELECT NEW.sum_bill * 0.05 + (NEW.sum_bill * percent_renta / 100) INTO realtor_reward;
        INSERT INTO bill (idd_bill, data_bill, sum_bill, type_bill, sender, recipient, booker,
						 bank_buy, doc_buy, doc_rent)
        VALUES ((SELECT MAX(NEW.idd_bill)+1 FROM doc_rent), NEW.data_bill, manager_reward, 0, NULL, (
            SELECT passport_empl FROM employee WHERE passport_empl = (
                SELECT manager_ag FROM doc_ag WHERE id_ag = (
                    SELECT agency_rent FROM doc_rent WHERE id_rent = NEW.doc_rent
                )
            )
        ), NEW.booker, NEW.bank_buy, NEW.doc_buy, NEW.doc_rent), (NEW.idd_bill + 2, NEW.data_bill, 
																  realtor_reward, 0, NULL, (
            SELECT passport_empl FROM employee WHERE passport_empl = (
				SELECT rieltor_rent FROM doc_rent WHERE id_rent = NEW.doc_rent
            )
        ), NEW.booker, NEW.bank_buy, NEW.doc_buy, NEW.doc_rent);
		
		
		
		ELSEIF (NEW.type_bill = 1) AND (NEW.doc_buy IS NOT NULL) THEN --покупка
			SELECT per_sell INTO STRICT percent_buy FROM region WHERE id_reg = (
				SELECT room_reg FROM room WHERE room_id = (
					SELECT flat FROM doc_buy WHERE id_buy = (
						SELECT doc_buy FROM bill WHERE idd_bill = NEW.idd_bill
						)
					)
				);
        	SELECT NEW.sum_bill * 0.15 INTO manager_reward;
        	SELECT NEW.sum_bill * 0.05 + (NEW.sum_bill * percent_buy / 100) INTO realtor_reward;
        	INSERT INTO bill (idd_bill, data_bill, sum_bill, type_bill, sender, recipient, booker,
						 bank_buy, doc_buy, doc_rent)
        	VALUES ((SELECT MAX(NEW.idd_bill)+1 FROM doc_rent), NEW.data_bill, manager_reward, 0, NULL, (
            SELECT passport_empl FROM employee WHERE passport_empl = (
            	SELECT manager_ag FROM doc_ag WHERE id_ag = (
                	SELECT agency_buy FROM doc_buy WHERE id_buy = NEW.doc_buy
                )
            )
        	), NEW.booker, NEW.bank_buy, NEW.doc_buy, NEW.doc_rent), (NEW.idd_bill + 2, NEW.data_bill, 
																  realtor_reward, 0, NULL, (
            SELECT passport_empl FROM employee WHERE passport_empl = (
				SELECT rieltor_buy FROM doc_buy WHERE id_buy = NEW.doc_buy
            )
        ), NEW.booker, NEW.bank_buy, NEW.doc_buy, NEW.doc_rent);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER payment_trigger
AFTER INSERT ON bill
FOR EACH ROW
EXECUTE FUNCTION payment_trigger();
