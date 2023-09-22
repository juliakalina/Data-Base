--1********************************************************************************
EXPLAIN ANALYZE
SELECT
 	CASE WHEN e.roles = 4 THEN e.fio_empl END AS "ФИО риелтора",
	COALESCE(ag_rent_count.count, 0) AS "Число договоров аренды", 
	COALESCE(ag_rent_sum.sum_ag, 0) AS "Сумма договоров аренды", 
	COALESCE(doc_buy_count.count, 0) AS "Число договоров продажи", 
	COALESCE(doc_buy_sum.sum_buy, 0) AS "Сумма договоров продажи",
	COALESCE(last_ag.date_ag, '0001-01-01') AS "Дата последнего договора",
	COALESCE(last_ag_type.type_ag, 0) AS "Тип последнего договора",
	COALESCE(payments_sum.sum_payments, 0) AS "Сумма выплат риелтору"
	
	FROM employee AS e LEFT JOIN (
	SELECT rieltor_rent, COUNT(*) AS count
	FROM doc_rent
	GROUP BY rieltor_rent
	) AS ag_rent_count ON e.passport_empl = ag_rent_count.rieltor_rent
	
	LEFT JOIN (
	SELECT rieltor_rent, SUM(cost_rent) AS sum_ag
  	FROM doc_rent
  	GROUP BY rieltor_rent
	) AS ag_rent_sum ON e.passport_empl = ag_rent_sum.rieltor_rent
	
	LEFT JOIN (
  	SELECT rieltor_buy, COUNT(*) AS count
  	FROM doc_buy
  	GROUP BY rieltor_buy
	) AS doc_buy_count ON e.passport_empl = doc_buy_count.rieltor_buy
	
	LEFT JOIN (
  	SELECT rieltor_buy, SUM(sum_buy) AS sum_buy
  	FROM doc_buy
  	GROUP BY rieltor_buy
	) AS doc_buy_sum ON e.passport_empl = doc_buy_sum.rieltor_buy
	
	LEFT JOIN (
  	SELECT worker, MAX(date_ag) AS date_ag
  	FROM doc_ag
  	GROUP BY worker
	) AS last_ag ON e.passport_empl = last_ag.worker
	
	LEFT JOIN doc_ag AS last_ag_type ON last_ag.date_ag = last_ag_type.date_ag AND 
	e.passport_empl = last_ag_type.worker
	
	LEFT JOIN (
  	SELECT recipient, type_bill, SUM(sum_bill) AS sum_payments
  	FROM bill
  	GROUP BY recipient, type_bill
	) AS payments_sum ON e.passport_empl = payments_sum.recipient AND payments_sum.type_bill = 0;
	
--2********************************************************************************
EXPLAIN ANALYZE
WITH 
	rent AS (
  		SELECT rieltor_rent, 
    	COUNT(*) AS count_rent, 
    	SUM(cost_rent) AS sum_rent 
  		FROM doc_rent 
  		GROUP BY rieltor_rent),
	buy AS (
  		SELECT rieltor_buy, 
    	COUNT(*) AS count_buy, 
    	SUM(sum_buy) AS sum_buy 
  		FROM doc_buy 
		GROUP BY rieltor_buy),
	last_date AS (
  		SELECT worker, 
    	MAX(date_ag) AS date_ag 
  		FROM doc_ag 
  		GROUP BY worker),
	last_type AS (
  		SELECT d.worker, d.date_ag, d.type_ag 
  		FROM doc_ag d 
		JOIN last_date l ON d.worker = l.worker AND d.date_ag = l.date_ag),
	pay AS (
  		SELECT recipient, type_bill, 
		SUM(sum_bill) AS sum_pay
  		FROM bill 
 		GROUP BY recipient, type_bill)
SELECT 
  CASE WHEN e.roles = 4 THEN e.fio_empl END AS "ФИО риелтора", 
  COALESCE(rent.count_rent, 0) AS "Число договоров аренды", 
  COALESCE(rent.sum_rent, 0) AS "Сумма договоров аренды", 
  COALESCE(buy.count_buy, 0) AS "Число договоров продажи", 
  COALESCE(buy.sum_buy, 0) AS "Сумма договоров продажи", 
  COALESCE(last_date.date_ag, '0001-01-01') AS "Дата последнего договора", 
  COALESCE(last_type.type_ag, 0) AS "Тип последнего договора",
  COALESCE(pay.sum_pay, 0) AS "Сумма выплат риелтору" 
  
FROM 
  employee AS e 
  LEFT JOIN rent ON e.passport_empl = rent.rieltor_rent 
  LEFT JOIN buy ON e.passport_empl = buy.rieltor_buy 
  LEFT JOIN last_date ON e.passport_empl = last_date.worker 
  LEFT JOIN last_type ON last_date.date_ag = last_type.date_ag AND e.passport_empl = last_type.worker 
  LEFT JOIN pay ON e.passport_empl = pay.recipient AND pay.type_bill = 0;
	
