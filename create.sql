CREATE TABLE region (
	id_reg INT NOT NULL PRIMARY KEY,
	script VARCHAR(500) NOT NULL,
	parrent_reg INT,
	name_reg VARCHAR(100) NOT NULL,
	per_sell INT NOT NULL,
	per_rent INT NOT NULL
); 

CREATE TABLE room (
	room_id INT NOT NULL,
	room_sq INT NOT NULL,
	num_room INT NOT NULL,
	type_room INT NOT NULL,
	manager_room BIGINT NOT NULL,
	room_reg INT NOT NULL,
	flor INT NOT NULL,
	adress VARCHAR(500) NOT NULL,
	PRIMARY KEY(room_id),
	CONSTRAINT fk_room_reg FOREIGN KEY (room_reg) REFERENCES region (id_reg)
);

CREATE TABLE empl_role (
	id_role INT NOT NULL PRIMARY KEY,
	name_role VARCHAR(20) NOT NULL
); 

CREATE TABLE employee (
	passport_empl BIGINT NOT NULL PRIMARY KEY,
	phone BIGINT NOT NULL,
	birth DATE NOT NULL,
	inn BIGINT NOT NULL,
	roles INT NOT NULL,
	fio_empl VARCHAR(100) NOT NULL,
	date_accept DATE NOT NULL,
	date_del DATE,
	CONSTRAINT fk_roles FOREIGN KEY (roles) REFERENCES empl_role (id_role)
); 

CREATE TABLE seller (
	passport_sel BIGINT NOT NULL PRIMARY KEY,
	fio_sel VARCHAR(100) NOT NULL,
	adress_sel VARCHAR(500) NOT NULL
); 

CREATE TABLE buyer (
	passport_buy BIGINT NOT NULL PRIMARY KEY,
	fio_buy VARCHAR(100) NOT NULL,
	adress_buy VARCHAR(500) NOT NULL
); 

CREATE TABLE bank (
	bik BIGINT NOT NULL PRIMARY KEY,
	num_lic BIGINT NOT NULL,
	name_bank VARCHAR(100) NOT NULL,
	r_s BIGINT NOT NULL,
	k_s BIGINT NOT NULL
); 

ALTER TABLE doc_ag ADD COLUMN flat_ag  INT CHECK (flat_ag > 0),
ADD CONSTRAINT fk_flat_ag FOREIGN KEY (flat_ag) REFERENCES room (room_id);
ALTER TABLE doc_ag DROP COLUMN sum_ad INT;
CREATE TABLE doc_ag (
	id_ag INT NOT NULL PRIMARY KEY,
	worker BIGINT NOT NULL, --риелтор
	sum_priz INT NOT NULL,
	doc_previous INT,
	flat_ag INT, -- >0
	type_ag INT NOT NULL, -- 1-аренда, 2-продажа
	sum_ag NUMERIC NOT NULL, -- стоимость аренды в мес или стоимость продажи
	manager_ag BIGINT NOT NULL,
	date_ag DATE NOT NULL,
	sel_ag BIGINT,
	buy_ag BIGINT, 
	CONSTRAINT fk_worker FOREIGN KEY (worker) REFERENCES employee (passport_empl),
	CONSTRAINT fk_seller FOREIGN KEY (sel_ag) REFERENCES seller (passport_sel),
	CONSTRAINT fk_manager_ag FOREIGN KEY (manager_ag) REFERENCES employee (passport_empl),
	CONSTRAINT fk_buyer FOREIGN KEY (buy_ag) REFERENCES buyer (passport_buy)
);

ALTER TABLE doc_rent ADD COLUMN flat_id INT, ADD CHECK (flat_id <> NULL), 
ADD CONSTRAINT fk_flat_id FOREIGN KEY (flat_id) REFERENCES room (room_id);
CREATE TABLE doc_rent (
	id_rent INT NOT NULL PRIMARY KEY,
	date_rent DATE NOT NULL,
	cost_rent INT NOT NULL,
	time_rent INT NOT NULL,
	bank_rent BIGINT,
	flat_id INT NOT NULL,
	rieltor_rent BIGINT NOT NULL,
	rent_prev INT,
	buy_person BIGINT NOT NULL,
	agency_rent BIGINT NOT NULL,  --договор агенства для аренды
	CONSTRAINT fk_buy_person FOREIGN KEY (buy_person) REFERENCES buyer (passport_buy),
	CONSTRAINT fk_rieltor FOREIGN KEY (rieltor_rent) REFERENCES employee (passport_empl),
	CONSTRAINT fk_doc_prev FOREIGN KEY (rent_prev) REFERENCES doc_rent (id_rent),
	CONSTRAINT fk_agency FOREIGN KEY (agency_rent) REFERENCES doc_ag (id_ag),
	CONSTRAINT fk_flat FOREIGN KEY (flat_id) REFERENCES room (room_id),
	CONSTRAINT fk_bank_rent FOREIGN KEY (bank_rent) REFERENCES bank (bik)
);

CREATE TABLE doc_buy (
	id_buy INT NOT NULL PRIMARY KEY,
	date_buy DATE NOT NULL,
	ipoteka_dur INT,
	sum_buy INT NOT NULL,
	percent_buy INT NOT NULL,
	flat INT NOT NULL,
	bank_buy BIGINT,
	rieltor_buy BIGINT NOT NULL,
	particip BIGINT NOT NULL, --покупатель
	agency_buy BIGINT NOT NULL, --договор агенства для покупки
	CONSTRAINT fk_flat FOREIGN KEY (flat) REFERENCES room (room_id),
	CONSTRAINT fk_bank_buy FOREIGN KEY (bank_buy) REFERENCES bank (bik),
	CONSTRAINT fk_rieltor FOREIGN KEY (rieltor_buy) REFERENCES employee (passport_empl),
	CONSTRAINT fk_agency FOREIGN KEY (agency_buy) REFERENCES doc_ag (id_ag)
);


ALTER TABLE bill ADD CHECK ((doc_rent <> NULL AND doc_buy = NULL) OR (doc_rent = NULL AND doc_buy <> NULL));
ALTER TABLE bill ADD CONSTRAINT chk_recip_send CHECK ((type_bill = 1 AND sender <> NULL AND recipient = NULL) OR 
							(type_bill = 0 AND sender = NULL AND recipient <> NULL));
CREATE TABLE bill ( 
	idd_bill INT NOT NULL PRIMARY KEY,
	doc_rent INT,
	doc_buy INT,
	CHECK ((doc_rent <> NULL AND doc_buy = NULL) OR (doc_rent = NULL AND doc_buy <> NULL)),
	data_bill DATE NOT NULL,
	sum_bill NUMERIC NOT NULL,
	type_bill INT NOT NULL, --type1/0 - входящий/исходящий платеж
	sender BIGINT,
	bank_buy INT,
	recipient BIGINT NOT NULL,
	booker BIGINT NOT NULL,
	CONSTRAINT fk_doc_rent FOREIGN KEY (doc_rent) REFERENCES doc_rent (id_rent),
	CONSTRAINT fk_doc_buy FOREIGN KEY (doc_buy) REFERENCES doc_buy (id_buy),
	CONSTRAINT fk_recipient FOREIGN KEY (recipient) REFERENCES employee (passport_empl),
	CONSTRAINT chk_recip_send CHECK ((type_bill = 1 AND sender <> NULL AND recipient = NULL) OR 
							(type_bill = 0 AND sender = NULL AND recipient <> NULL)),
	CONSTRAINT fk_sender FOREIGN KEY (sender) REFERENCES buyer (passport_buy)
); 

ALTER TABLE bill ADD COLUMN booker BIGINT, ADD CHECK (booker != NULL), 
ADD CONSTRAINT fk_booker FOREIGN KEY (booker) REFERENCES employee (passport_empl);*/
--если входящий, то или документ аренды, или документ продажи указывается, 
--отправитель - клиент
--получатель - null

--если исходящий, то также указывается документ аренды или продажи, по которому выплачиваем вознагрждение
--отправитель - Null
--получатель - сотрудник
