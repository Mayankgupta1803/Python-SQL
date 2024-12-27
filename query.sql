use bank_loan_db;

show tables;

select * from financial_loan;
select * from bank_loan_data;

drop table bank_loan_data;
drop table financial_loan;

create table financial_data(
	id int(20),
    address_state varchar(10),
    application_type varchar(15),
    emp_length varchar(10),
    emp_title varchar(150),
	grade varchar(2),
	home_ownership varchar(20),
	issue_date date,
	last_credit_pull_date date,
	last_payment_date date,
	loan_status varchar(15),
	next_payment_date date,
	member_id int,
	purpose varchar(50),
	sub_grade varchar(5),
	term varchar(15),
	verification_status varchar(15),
	annual_income decimal(10,2),
	dti decimal,
	installment decimal,
	int_rate decimal,
	loan_amount decimal(10,2),
	total_acc int,
	total_payment decimal(10,2)
);


select * from financial_data;

select count(id) from financial_data;

alter table financial_data
add constraint pk_financial_data primary key (id);


select * from information_schema.check_constraints;
select * from information_schema.key_column_usage where table_schema = 'bank_loan_db' 
														and table_name = 'financial_data';
select * from information_schema.statistics;
	
--- Total Loan Application
select count(id) as Total_loan_application from financial_data;

--- MTD Total Loan Application
select * from financial_data;

select * from financial_data
where month(issue_date) = 10;             # not working

-- ------------------------- Modifying Date Columns -------------------- -- 
describe financial_data;

UPDATE financial_data
SET issue_date = STR_TO_DATE(issue_date, '%d-%m-%Y');

alter table financial_data modify issue_date date;

UPDATE financial_data
SET last_credit_pull_date = STR_TO_DATE(last_credit_pull_date, '%d-%m-%Y');
UPDATE financial_data
SET last_payment_date = STR_TO_DATE(last_payment_date, '%d-%m-%Y');
UPDATE financial_data
SET next_payment_date = STR_TO_DATE(next_payment_date, '%d-%m-%Y');

alter table financial_data modify last_credit_pull_date date;
alter table financial_data modify last_payment_date date;
alter table financial_data modify next_payment_date date;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 								Key DATE functions in MySql						   --
-- ----------------------------------------------------------------------------------

select curdate();

-- Return last day of the date
select last_day('2024-12-15');

-- Date_SUB(date, INTERVAL n Unit)  = subtract specific interval from the date
select date_sub('2024-12-15', interval 1 MONTH);

SELECT DAY(curdate());

-- + INTERVAL n UNIT
SELECT '2024-12-27' + interval 1 month;
select curdate() + interval 5 day;

-- ----------------------------------------------
-- ----------------------------------------------

---- PMTD total applications

select count(*) as PMTD from financial_data
where 
	issue_date >= Last_day(curdate() - interval 2 month) + Interval 1 month
    and issue_date <= last_day(curdate() - interval 1 month);
    
select max(issue_date) from financial_data;

set @max_date = (select max(issue_date) from financial_data);
select count(*) as PMTD from financial_data
where 
	issue_date >= Last_day(@max_date - interval 2 month) + Interval 1 day
    and issue_date <= last_day(@max_date - interval 1 month);
    
    
-- ----------------------------------------------------------------------------

---- total funded amount
---- total mtd funded amount
---- total pmtd funded amount

select sum(loan_amount) from financial_data;

set @max = (select max(issue_date) from financial_data);
select sum(loan_amount) MTD from financial_data
where 
	issue_date >= Last_day(@max - interval 1 month) + interval 1 day
    and issue_date <= Last_day(@max);

set @max = (select max(issue_date) from financial_data);
select sum(loan_amount) PMTD from financial_data
where 
	issue_date >= last_day(@max - interval 2 month) + interval 1 day
    and 
    issue_date <= last_day(@max - interval 1 month);
	
-- -----------------------------------------------------------------
-- -----------------------------------------------------------------

---- Good Loan Application

select * from financial_data;
select distinct(loan_status) from financial_data;

select count(case when loan_status = 'Fully Paid' or loan_status ='Current' then id End) Total_Good_Application
from financial_data;


---- Bad Loan Application

select count(case when loan_status = 'Charged Off' then id end)
from financial_data;


---- Good Loan Application Amount
select sum(case when loan_status = 'Fully Paid' or loan_status ='Current' then id End) Good_Amount,
		round(sum(case when loan_status = 'Fully Paid' or loan_status ='Current' then id End)/1000000,4) Good_Amount_in_Million
from financial_data;