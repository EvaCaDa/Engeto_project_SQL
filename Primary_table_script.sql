/* 
 * DATA PRO MZDY - PŘÍPRAVA
 * 
 * Zdrojová data:
 * czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
 * czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
 * czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
 * czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
 * czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
 */

SELECT *
FROM czechia_payroll cp
WHERE
	value_type_code = 5958 -- průměrná hrubá mzda zaměstnance
	AND calculation_code = 100; -- fyzický plat

CREATE OR REPLACE VIEW v_eva_cajzlova_czechia_payroll_ibch_null AS
	SELECT *
	FROM czechia_payroll cp
	WHERE
		value_type_code = 5958
		AND calculation_code = 100
		AND industry_branch_code IS NULL;

CREATE OR REPLACE VIEW v_eva_cajzlova_czechia_payroll_ibch_not_null_avg AS		
	SELECT
		payroll_year,
		payroll_quarter,
		avg(value) AS average_value_ibch_not_null
	FROM czechia_payroll cp
	WHERE
		value_type_code = 5958
		AND calculation_code = 100
		AND industry_branch_code IS NOT NULL
	GROUP BY
		payroll_year,
		payroll_quarter
	ORDER BY
		payroll_year,
		payroll_quarter;

SELECT
	pinna.*,
	pin.value AS value_ibch_null
FROM v_eva_cajzlova_czechia_payroll_ibch_not_null_avg pinna
JOIN v_eva_cajzlova_czechia_payroll_ibch_null pin
	ON pinna.payroll_year = pin.payroll_year
	AND pinna.payroll_quarter = pin.payroll_quarter;
-- NULL hodnoty v industry_branch_code nejsou průměrem pro všechna odvětví, nedokážu zjistit, co dané řádky reprezentují za data, do primární zdrojové tabulky nepůjdou

CREATE OR REPLACE TABLE t_eva_cajzlova_czechia_payroll_final AS 
	SELECT
		cp.id AS payroll_id,
		cp.value AS payroll_value,
		cpu.name AS payroll_value_name,
		cp.industry_branch_code,
		cpib.name AS branch_code_name,
		cp.payroll_year,
		cp.payroll_quarter
	FROM czechia_payroll cp
	LEFT JOIN czechia_payroll_industry_branch cpib
		ON cp.industry_branch_code = cpib.code
	JOIN czechia_payroll_unit cpu
		ON cp.unit_code = cpu.code
	WHERE
		cp.value_type_code = 5958
		AND cp.calculation_code = 100
		AND industry_branch_code IS NOT NULL
	ORDER BY
		cp.industry_branch_code,
		cp.payroll_year,
		cp.payroll_quarter;


/* 
 * DATA PRO CENY - PŘÍPRAVA
 * 
 * Zdrojová data:
 * czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
 * czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
 */

SELECT *
FROM czechia_price cp;

SELECT
	*,
	year(date_from),
	year(date_to)
FROM czechia_price cp
WHERE
	year(date_from) != year(date_to);

SELECT
	*,
	quarter(date_from),
	quarter(date_to)
FROM czechia_price cp
WHERE
	quarter(date_from) != quarter(date_to);
-- problém přechodných týdnů mezi čtvrtletími

SELECT
	year(date_from),
	quarter(date_from),
	min(dayofmonth(date_to)),
	max(dayofmonth(date_to))
FROM czechia_price cp
WHERE
	quarter(date_from) != quarter(date_to)
GROUP BY
	year(date_from),
	quarter(date_from);

SELECT
	year(date_from) AS price_year,
	CASE
		WHEN quarter(date_from) = quarter(date_to) THEN quarter(date_from)
		WHEN quarter(date_from) != quarter(date_to) AND dayofmonth(date_to) < 4 THEN quarter(date_from)
		ELSE quarter(date_to) 
	END AS price_quarter,
	quarter(date_from),
	dayofmonth(date_to)
FROM czechia_price cp
WHERE 
	quarter(date_from) != quarter(date_to)
GROUP BY
	price_year,
	price_quarter;

CREATE OR REPLACE VIEW v_eva_cajzlova_czechia_price_year_quarter AS
	SELECT
		id,
		value,
		category_code,
		region_code,
		year(date_from) AS price_year,
		CASE
			WHEN quarter(date_from) = quarter(date_to) THEN quarter(date_from)
			WHEN quarter(date_from) != quarter(date_to) AND dayofmonth(date_to) < 4 THEN quarter(date_from)
			ELSE quarter(date_to) 
		END AS price_quarter
	FROM czechia_price cp;

SELECT *
FROM v_eva_cajzlova_czechia_price_year_quarter pyq
WHERE
	region_code IS NULL -- data pro celou ČR
ORDER BY
	category_code,
	price_year,
	price_quarter;

CREATE OR REPLACE VIEW v_eva_cajzlova_czechia_price_year_quarter_avg AS
	SELECT
		id,
		round(avg(value), 2) AS avg_price_value_quarter,
		category_code,
		price_year,
		price_quarter
	FROM v_eva_cajzlova_czechia_price_year_quarter pyq
	WHERE
		region_code IS NULL
	GROUP BY
		category_code,
		price_year,
		price_quarter
	ORDER BY
		category_code,
		price_year,
		price_quarter;
	
CREATE OR REPLACE TABLE t_eva_cajzlova_czechia_price_final AS
	SELECT
		pyqa.id AS price_id,
		pyqa.avg_price_value_quarter AS price_avg_value,
		pyqa.category_code,
		cpc.name AS category_name,
		concat(cpc.price_value, ' ', cpc.price_unit) AS price_value_unit,
		pyqa.price_year,
		pyqa.price_quarter
	FROM v_eva_cajzlova_czechia_price_year_quarter_avg pyqa
	JOIN czechia_price_category cpc
		ON pyqa.category_code = cpc.code
	ORDER BY
		pyqa.category_code,
		pyqa.price_year,
		pyqa.price_quarter;


/* 
 * VYTVOŘENÍ PRIMÁRNÍ TABULKY - SPOJENÍ DAT CEN A MEZD
 */

SELECT
	min(payroll_year), -- 2000
	max(payroll_year) -- 2021
FROM t_eva_cajzlova_czechia_payroll_final payf;

SELECT
	min(price_year), -- 2006
	max(price_year)-- 2018
FROM t_eva_cajzlova_czechia_price_final prif;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_SQL_primary_final
	SELECT *
	FROM t_eva_cajzlova_czechia_payroll_final payf
	JOIN t_eva_cajzlova_czechia_price_final prif
		ON payf.payroll_year = prif.price_year
		AND payf.payroll_quarter = prif.price_quarter
	WHERE
		prif.price_year BETWEEN 2006 AND 2018;