--1********************************************************************************
SELECT
 	CASE WHEN e.roles = 4 THEN e.fio_empl END AS "ФИО риелтора",
	COALESCE(ag_rent_count.count, 0) AS "Число договоров аренды", --1
	COALESCE(ag_rent_sum.sum_ag, 0) AS "Сумма договоров аренды", --1
	COALESCE(doc_buy_count.count, 0) AS "Число договоров продажи", --2
	COALESCE(doc_buy_sum.sum_buy, 0) AS "Сумма договоров продажи", --2
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
SELECT 
  r.room_reg AS "Регион",
  r.type_room AS "Тип жилья",
  r.adress AS "Адрес",
  CONCAT(' Регион: ', r.room_reg, ' Площадь: ', r.room_sq, ' Этаж: ', r.flor) AS "Другие данные жилья",
  da.date_ag AS "Дата выставления на продажу",
  CASE WHEN db.id_buy IS NOT NULL THEN 'Да' ELSE 'Нет' END AS "Продан или нет",
  (da.sum_ag / r.room_sq) AS "Цена за метр",
  r.room_sq AS "Площадь",
  da.sum_ag AS "Общая цена",
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM room r2 
      JOIN doc_ag da2 ON r2.room_id = da2.flat_ag
      WHERE r2.room_reg = r.room_reg AND da2.sum_ag / r2.room_sq < da.sum_ag / r.room_sq
    ) THEN 'Да'
    ELSE 'Нет'
  END AS "Более дорогое жилье в регионе"
FROM 
  room r
   RIGHT JOIN doc_ag da ON r.room_id = da.flat_ag
   LEFT JOIN doc_buy db ON da.id_ag = db.agency_buy
ORDER BY da.sum_ag / r.room_sq;
	
--3********************************************************************************
SELECT
    CONCAT('Адрес: ', r.adress, ', Площадь: ', r.room_sq)
	AS "Описание жилья",
    CONCAT(e.fio_empl, ' (', e.passport_empl, ')') AS "Участник договора",
	(SELECT date_rent FROM doc_rent dr WHERE d.rent_prev = dr.id_rent  
	 ORDER BY date_rent DESC LIMIT 1) AS "Дата начала первого договора",
    COUNT(*) + 1 AS "Число договоров",
    MAX(d.date_rent) AS "Дата начала последнего",
    MAX(d.date_rent + d.time_rent) AS "Дата окончания последнего",
    CASE
        WHEN CURRENT_DATE > MAX(d.date_rent + d.time_rent) THEN 'Нет'
        ELSE 'Да'
    END AS "Есть ли актуальный договор",
    SUM(d.cost_rent) + (SELECT cost_rent FROM doc_rent dr WHERE d.rent_prev = dr.id_rent  
	 ORDER BY date_rent DESC LIMIT 1 )	AS "Общая сумма всех договоров",
    (SUM(d.cost_rent) + (SELECT cost_rent FROM doc_rent dr WHERE d.rent_prev = dr.id_rent  
	 ORDER BY date_rent DESC LIMIT 1 )) / (COUNT(*) + 1) AS "Средняя цена за месяц по договорам",
    (SELECT cost_rent FROM doc_rent WHERE flat_id = r.room_id 
	 ORDER BY date_rent DESC LIMIT 1) AS "Цена за месяц у последнего договора",
    (SUM(b.sum_bill) + ((SELECT SUM(sum_bill) FROM bill b2 WHERE d.rent_prev = b2.doc_rent)))
	AS "Общая сумма выплат риелтору в качестве вознаграждений"
FROM
    room r
    JOIN doc_rent d ON r.room_id = d.flat_id
    JOIN doc_ag da ON d.agency_rent = da.id_ag
	LEFT JOIN bill b ON b.doc_rent = d.id_rent
    JOIN employee e ON d.rieltor_rent = e.passport_empl
WHERE
    d.rent_prev IS NOT NULL
GROUP BY
    r.room_id, e.passport_empl, d.rent_prev
HAVING
    COUNT(*) > 3;*/

--4********************************************************************************
SELECT
    e.fio_empl AS name_employee,
--ЯНВАРЬ
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 01 THEN 1 END), 0) AS count_rent1,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 01 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent1,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 01 THEN 1 END), 0) AS count_buy1,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 01 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy1,
--ФЕВРАЛЬ	
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 02 THEN 1 END), 0) AS count_rent2,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 02 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent2,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 02 THEN 1 END), 0) AS count_buy2,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 02 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy2,
--МАРТ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 03 THEN 1 END), 0) AS count_rent3,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 03 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent3,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 03 THEN 1 END), 0) AS count_buy3,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 03 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy3,
--АПРЕЛЬ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 04 THEN 1 END), 0) AS count_rent4,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 04 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent4,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 04 THEN 1 END), 0) AS count_buy4,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 04 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy4,
--МАЙ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 05 THEN 1 END), 0) AS count_rent5,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 05 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent5,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 05 THEN 1 END), 0) AS count_buy5,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 05 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy5,
--ИЮНЬ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 06 THEN 1 END), 0) AS count_rent6,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 06 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent6,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 06 THEN 1 END), 0) AS count_buy6,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 06 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy6,
--ИЮЛЬ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 07 THEN 1 END), 0) AS count_rent7,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 07 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent7,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 07 THEN 1 END), 0) AS count_buy7,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 07 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy7,
--АВГУСТ
COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 08 THEN 1 END), 0) AS count_rent8,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 08 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent8,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 08 THEN 1 END), 0) AS count_buy8,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 08 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy8,
--СЕНТЯБРЬ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 09 THEN 1 END), 0) AS count_rent9,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 09 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent9,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 09 THEN 1 END), 0) AS count_buy9,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 09 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy9,
--ОКТЯБРЬ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 10 THEN 1 END), 0) AS count_rent10,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 10 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent10,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 10 THEN 1 END), 0) AS count_buy10,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 10 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy10,
--НОЯБРЬ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 11 THEN 1 END), 0) AS count_rent11,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 11 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent11,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 11 THEN 1 END), 0) AS count_buy11,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 11 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy11,
--ДЕКАБРЬ
	COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_rent.date_rent) = 12 THEN 1 END), 0) AS count_rent12,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 12 AND bill.doc_rent IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_rent12,
    COALESCE(COUNT(DISTINCT CASE WHEN EXTRACT(MONTH FROM doc_buy.date_buy) = 12 THEN 1 END), 0) AS count_buy12,
    COALESCE(SUM(DISTINCT CASE WHEN EXTRACT(MONTH FROM bill.data_bill) = 12 AND bill.doc_buy IS NOT NULL 
				 AND e.passport_empl = bill.recipient THEN bill.sum_bill END), 0) AS sum_buy12

FROM employee e
	LEFT JOIN doc_rent ON e.passport_empl = doc_rent.rieltor_rent AND EXTRACT(YEAR FROM doc_rent.date_rent) = 2022
	LEFT JOIN doc_buy ON e.passport_empl = doc_buy.rieltor_buy AND EXTRACT(YEAR FROM doc_buy.date_buy) = 2022
	LEFT JOIN bill ON e.passport_empl = bill.recipient AND bill.type_bill = 0 
		AND EXTRACT(YEAR FROM bill.data_bill) = 2022
WHERE 
	e.roles = 4
GROUP BY
	e.fio_empl
ORDER BY
	e.fio_empl;

--5********************************************************************************
WITH RECURSIVE region_hierarchy AS (
	SELECT id_reg, script, parrent_reg, name_reg, id_reg AS top_parent_reg
	FROM region
	WHERE parrent_reg IS NULL
	UNION ALL
	SELECT r.id_reg, r.script, r.parrent_reg, r.name_reg, rh.top_parent_reg
	FROM region r
	JOIN region_hierarchy rh ON r.parrent_reg = rh.id_reg
	)

	SELECT r.name_reg AS "Название региона",
	r.script AS "Описание",
	r.parrent_reg AS "Родительский регион",
	rh.top_parent_reg AS "Самый верхний родительский регион"
	FROM region r
	LEFT JOIN region_hierarchy rh ON r.id_reg = rh.id_reg;
