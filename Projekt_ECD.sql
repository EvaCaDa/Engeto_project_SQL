-- PROJEKT

/*Zadání projektu
Úvod do projektu

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, 
že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. 
Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. 
Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
Datové sady, které je možné použít pro získání vhodného datového podkladu

Primární tabulky:

    czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
    czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
    czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
    czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
    czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
    czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
    czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.

Číselníky sdílených informací o ČR:

    czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
    czechia_district – Číselník okresů České republiky dle normy LAU.

Dodatečné tabulky:

    countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
    economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Výzkumné otázky

    Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
    Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
    Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
    Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
    Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
    projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Výstup projektu

Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. 
Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) 
a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

Dále připravte sadu SQL, které z vámi připravených tabulek získají datový podklad k odpovězení na vytyčené výzkumné otázky. 
Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data.

Na svém GitHub účtu vytvořte repozitář (může být soukromý), kam uložíte všechny informace k projektu – 
hlavně SQL skript generující výslednou tabulku, popis mezivýsledků (průvodní listinu) a informace o výstupních datech (například kde chybí hodnoty apod.).

Neupravujte data v primárních tabulkách! Pokud bude potřeba transformovat hodnoty, dělejte tak až v tabulkách nebo pohledech, které si nově vytváříte.

Otazky:
Takze potrebujeme:
	sql skripty pro generaci dvou tabulek
	sql skripty pro ziskani odpovedi
	pruvodni listina/
	popis mezivysledku --- to znamena popis odpovedi na vyzkumne otazky
	informace o vystupnich datech --- to jako o me tabulce, nebo o tech konkretnich pro zodpovezeni konkretnich otazek???

Je lepsi pouzivat data prepoctena na plny uvazek, nebo pro jednotlivy realny uvazky?
Ja bych pouzila realny, protoze to bude lip ilustrovat realnou dostupnost potravin pro lidi myslim.

*/

-- Priprava primarni tabulky - payroll

SELECT *
FROM czechia_payroll cp
WHERE
	value_type_code = 5958 -- prumerna hruba mzda zamestnance
	AND calculation_code = 100; -- fyzicky plat (kod 200 je prepocteny na plne uvazky) - lepe bude ilustrovat realnou dostupnost potravin, o kterou nam jde

CREATE OR REPLACE VIEW v_eva_cajzlova_payroll_ibch_null AS
	SELECT *
	FROM czechia_payroll cp
	WHERE
		value_type_code = 5958
		AND calculation_code = 100
		AND industry_branch_code IS NULL;
-- NULL u industry branch code - jedna hodnota ke kazdemu ctvrtleti kazdeho roku, je to prumer?

CREATE OR REPLACE VIEW v_eva_cajzlova_payroll_ibch_not_null_avg AS		
	SELECT
		payroll_year,
		payroll_quarter,
		avg(value) AS average_value_ibch_not_null
	FROM czechia_payroll cp
	WHERE
		value_type_code = 5958 -- prumerna hruba mzda zamestnance
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
FROM v_eva_cajzlova_payroll_ibch_not_null_avg pinna
JOIN v_eva_cajzlova_payroll_ibch_null pin
	ON pinna.payroll_year = pin.payroll_year
	AND pinna.payroll_quarter = pin.payroll_quarter;
-- NULL ibc neni prumer, nevim, co by to mohlo byt, odignoruju to v analyze

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
		cp.value_type_code = 5958 -- prumerna hruba mzda zamestnance
		AND cp.calculation_code = 100  -- fyzicky plat
		AND industry_branch_code IS NOT NULL -- ignoruji ty prazdne hodnoty, nevim, co je TO za cislo, tak co bych s tim delala?
	ORDER BY
		cp.industry_branch_code,
		cp.payroll_year,
		cp.payroll_quarter;


-- Priprava primarni tabulky - ceny

SELECT *
FROM czechia_price cp;
-- limitace, pro ceny to mam rozbite na kraje, ale pro mzdy ne --- mam se zamerit jen na cr, nebo resit i kraje, kdyz pro to nemuzu udelat totez ve mzdach?
-- NULL u kraje znamena, ze jsou to data jen pro celou CR, staci mi jenom ta?
-- zkusim resit jen pro celou cr, kdyz nemam protipol u mezd, tak by to stejne bylo divne; MOZNA PRIDAT?

SELECT
	*,
	year(date_from),
	year(date_to)
FROM czechia_price cp
WHERE
	year(date_from) != year(date_to); -- good, vsude sedi rok, cajk

SELECT
	*,
	quarter(date_from),
	quarter(date_to)
FROM czechia_price cp
WHERE
	quarter(date_from) != quarter(date_to); -- ok, mam problem, co s tim

SELECT
	*,
	dayofmonth(date_from),
	dayofmonth(date_to),
	quarter(date_from),
	quarter(date_to)
FROM czechia_price cp
WHERE
	quarter(date_from) != quarter(date_to);

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
	*,
	year(date_from) AS price_year,
	CASE
		WHEN quarter(date_from) = quarter(date_to) THEN quarter(date_from)
		WHEN quarter(date_from) != quarter(date_to) AND dayofmonth(date_to) < 4 THEN quarter(date_from) -- tyden ma sedm dni, pokud bude dayofmonth(date_to) 4 a vice, tak to prsknu do vetsiho quarteru
		ELSE quarter(date_to) 
	END AS price_quarter
FROM czechia_price cp;

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

CREATE OR REPLACE TABLE t_eva_cajzlova_czechia_price_year_quarter AS
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
FROM t_eva_cajzlova_czechia_price_year_quarter teccpyq
WHERE
	region_code IS NULL
ORDER BY
	category_code,
	price_year,
	price_quarter;

CREATE OR REPLACE TABLE t_eva_cajzlova_czechia_price_year_quarter_avg AS
	SELECT
		id,
		round(avg(value), 2) AS avg_price_value_quarter,
		category_code,
		price_year,
		price_quarter
	FROM t_eva_cajzlova_czechia_price_year_quarter teccpyq
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
	FROM t_eva_cajzlova_czechia_price_year_quarter_avg pyqa
	JOIN czechia_price_category cpc
		ON pyqa.category_code = cpc.code
	ORDER BY
		pyqa.category_code,
		pyqa.price_year,
		pyqa.price_quarter;

-- Spojeni predpripravenych payroll a price tabulek
SELECT
	min(payroll_year), -- 2000
	max(payroll_year) -- 2021
FROM t_eva_cajzlova_czechia_payroll_final teccpf;

SELECT
	min(price_year), -- 2006
	max(price_year)-- 2018
FROM t_eva_cajzlova_czechia_price_final teccpf;

-- 2006 - 2018
-- t_{jmeno}_{prijmeni}_project_SQL_primary_final

CREATE OR REPLACE TABLE t_eva_cajzlova_project_SQL_primary_final
	SELECT *
	FROM t_eva_cajzlova_czechia_payroll_final payf
	JOIN t_eva_cajzlova_czechia_price_final prif
		ON payf.payroll_year = prif.price_year
		AND payf.payroll_quarter = prif.price_quarter
	WHERE
		prif.price_year BETWEEN 2006 AND 2018;
-- pozor na kapra (meri se jednou v roce na Vanoce), a vino (meri se od roku 2015)

-- uhladit kod (udelat si view, ne tabulky nekde?)
-- zkontrolovat jeste jednou logiku
-- sepseat popis dat do readme, proc  jsem vybrala co jsem vybrala, pak vyhodit vetsinu poznamek z kodu



-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE VIEW v_eva_cajzlova_question1_avg_payroll_year AS
	SELECT
		industry_branch_code,
		branch_code_name,
		payroll_year,
		round(avg(payroll_value), 2) AS average_payroll
	FROM t_eva_cajzlova_project_SQL_primary_final
	GROUP BY
		industry_branch_code,
		payroll_year
	ORDER BY
		industry_branch_code,
		payroll_year;

-- napojit tento prikaz na sebe, polozit vedle sebe ty payrolly z predchozich let, udelat rozdil?
-- nejvic by se mi libil nejaky case, kde 1 bude znamenat pokles, 0 narust treba

CREATE TABLE t_eva_cajzlova_project_sql_question1_final AS
	SELECT
		tab1.*,
		tab2.average_payroll AS last_year_average_payroll,
		tab1.average_payroll - tab2.average_payroll AS interannual_difference,
		CASE
			WHEN tab1.average_payroll > tab2.average_payroll THEN 1
			ELSE 0
		END AS average_payroll_growth
	FROM v_eva_cajzlova_question1_avg_payroll_year tab1
	JOIN v_eva_cajzlova_question1_avg_payroll_year tab2
		ON tab1.payroll_year = tab2.payroll_year + 1
		AND tab1.industry_branch_code = tab2.industry_branch_code;

CREATE TABLE t_eva_cajzlova_project_sql_question1_payroll_decrease AS
	SELECT *
	FROM t_eva_cajzlova_project_sql_question1_final
	WHERE average_payroll_growth = 0;


-- Otazka 3.
-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT *
FROM t_eva_cajzlova_project_sql_primary_final tecpspf;

CREATE VIEW v_eva_cajzlova_question3_avg_price_year AS
	SELECT
		category_code,
		category_name,
		price_value_unit,
		price_year,
		round(avg(price_avg_value), 2) AS average_price
	FROM t_eva_cajzlova_project_sql_primary_final
	GROUP BY
		category_code,
		price_year
	ORDER BY
		category_code,
		price_year;

CREATE VIEW v_eva_cajzlova_question3_interannual_difference_percent AS
	SELECT
		tab1.*,
		tab2.average_price AS last_year_average_price,
		round(((tab1.average_price / tab2.average_price * 100) - 100), 2) AS interannual_difference_percent
	FROM v_eva_cajzlova_question3_avg_price_year tab1
	JOIN v_eva_cajzlova_question3_avg_price_year tab2
		ON tab1.price_year = tab2.price_year + 1
		AND tab1.category_code = tab2.category_code;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question3_final
	SELECT
		category_code,
		category_name,
		price_value_unit,
		sum(interannual_difference_percent) AS total_price_growth_percent
	FROM v_eva_cajzlova_question3_interannual_difference_percent
	GROUP BY
		category_code
	ORDER BY
		total_price_growth_percent ASC;

SELECT
	category_code,
	category_name,
	price_value_unit,
	round(avg(interannual_difference_percent), 2) AS price_growth_percent_avg
FROM v_eva_cajzlova_question3_interannual_difference_percent
GROUP BY
	category_code
ORDER BY
	price_growth_percent_avg ASC;

-- pro orientacni zjisteni, jak casto vlastne cena merenych potravin klesala a jak casto rostla
CREATE VIEW v_eva_cajzlova_question3_growth AS
	SELECT
		*,
		CASE
			WHEN interannual_difference_percent >= 0 THEN 1
			ELSE 0
		END AS growth
	FROM v_eva_cajzlova_question3_interannual_difference_percent;

SELECT
	count(average_price),
	sum(growth)
FROM v_eva_cajzlova_question3_growth;

-- Tady si hraju, ale asi to necham byt, je to v kontextu tech procent docela divny.
SELECT
	category_code,
	category_name,
	price_value_unit,
	min(average_price),
	max(average_price),
	sum(interannual_difference_percent) AS total_price_growth_percent
FROM v_eva_cajzlova_question3_interannual_difference_percent
GROUP BY
	category_code
ORDER BY
	total_price_growth_percent ASC;


-- Otazka 2
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
-- mleko: 114201; chleba: 111301
-- prvni: 2006, posledni: 2018

CREATE OR REPLACE VIEW v_eva_cajzlova_question2_quarters AS
	SELECT
		industry_branch_code,
		branch_code_name,
		payroll_year,
		payroll_quarter,
		payroll_value,
		category_code,
		category_name,
		price_value_unit,
		price_avg_value
	FROM t_eva_cajzlova_project_sql_primary_final
	WHERE
		(category_code = 114201 AND price_year = 2006 AND price_quarter = 1)
		OR (category_code = 111301 AND price_year = 2006 AND price_quarter = 1)
		OR (category_code = 114201 AND price_year = 2018 AND price_quarter = 4)
		OR (category_code = 111301 AND price_year = 2018 AND price_quarter = 4)
	ORDER BY
		industry_branch_code ASC,
		category_code ASC,
		payroll_year ASC,
		payroll_quarter ASC;

CREATE OR REPLACE VIEW v_eva_cajzlova_question2_quarters_all_branches AS 
	SELECT
		payroll_year,
		payroll_quarter,
		industry_branch_code,
		branch_code_name,
		category_code,
		category_name,
		round((payroll_value/price_avg_value), 2) AS affordable_amount
	FROM v_eva_cajzlova_question2_quarters
	ORDER BY
		category_code ASC,
		payroll_year ASC,
		payroll_quarter ASC,
		industry_branch_code ASC;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question2_quarters_total AS 
	SELECT
		payroll_year,
		payroll_quarter,
		category_code,
		category_name,
		round(avg(affordable_amount), 2) AS average_affordable_amount
	FROM v_eva_cajzlova_question2_quarters_all_branches
	GROUP BY
		payroll_year,
		payroll_quarter,
		category_code
	ORDER BY
		payroll_year ASC;

-- Musim dodelat, ale klidne bych udelala jedno srovnani za prvni ctvrtleti 2006 a posledni ctvrtleti 2018 (viz vyse), pak durhy teda za roky, o to se snazim tady ted.

CREATE OR REPLACE VIEW v_eva_cajzlova_question2_years AS
	SELECT
		industry_branch_code,
		branch_code_name,
		payroll_year,
		round(avg(payroll_value), 2) AS average_payroll,
		category_code,
		category_name,
		price_value_unit,
		round(avg(price_avg_value), 2) AS average_price
	FROM t_eva_cajzlova_project_sql_primary_final
	WHERE
		(category_code = 114201 AND price_year = 2006)
		OR (category_code = 111301 AND price_year = 2006)
		OR (category_code = 114201 AND price_year = 2018)
		OR (category_code = 111301 AND price_year = 2018)
	GROUP BY
		category_code,
		industry_branch_code,
		payroll_year;

CREATE OR REPLACE VIEW v_eva_cajzlova_question2_years_all_branches AS 
	SELECT
		payroll_year,
		industry_branch_code,
		branch_code_name,
		category_code,
		category_name,
		round((average_payroll/average_price), 2) AS affordable_amount
	FROM v_eva_cajzlova_question2_years
	ORDER BY
		category_code ASC,
		payroll_year ASC,
		industry_branch_code ASC;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question2_years_total AS 
	SELECT
		payroll_year,
		category_code,
		category_name,
		round(avg(affordable_amount), 2) AS average_affordable_amount
	FROM v_eva_cajzlova_question2_years_all_branches
	GROUP BY
		payroll_year,
		category_code
	ORDER BY
		payroll_year ASC;

-- Otazka 4
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- propojit postup otazek 1 a 3, pripravit si data pro mzdy a potraviny zvlast, pak je spojit, asi az na roce
-- zjednodusit odpovedi na otazky, pisu jakejsi roman tam

-- zdrojova data
-- v_eva_cajzlova_question3_interannual_difference_percent
-- v_eva_cajzlova_question1_payroll_year_avg

-- potravin

SELECT *
FROM v_eva_cajzlova_question3_interannual_difference_percent;

CREATE OR REPLACE VIEW v_eva_cajzlova_question4_price_dif_percent_avg AS
	SELECT
		price_year,
		round(avg(interannual_difference_percent), 2) AS price_ia_diff_percent_avg_all
	FROM v_eva_cajzlova_question3_interannual_difference_percent
	GROUP BY
		price_year;

-- mzdy
CREATE OR REPLACE VIEW v_eva_cajzlova_question4_payroll_difference_percent AS 
	SELECT
		tab1.*,
		tab2.average_payroll AS last_year_average_payroll,
		round(((tab1.average_payroll / tab2.average_payroll * 100) - 100), 2) AS interannual_difference_percent
	FROM v_eva_cajzlova_question1_payroll_year_avg tab1
	JOIN v_eva_cajzlova_question1_payroll_year_avg tab2
		ON tab1.payroll_year = tab2.payroll_year + 1
		AND tab1.industry_branch_code = tab2.industry_branch_code;

CREATE OR REPLACE VIEW v_eva_cajzlova_question4_payroll_dif_percent_avg AS
	SELECT
		payroll_year,
		round(avg(interannual_difference_percent), 2) AS payroll_ia_diff_percent_avg_all
	FROM v_eva_cajzlova_question4_payroll_difference_percent
	GROUP BY
		payroll_year;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question4_final AS 
	SELECT
		pay.payroll_year AS `year`,
		pay.payroll_ia_diff_percent_avg,
		pri.price_ia_diff_percent_avg,
		(pri.price_ia_diff_percent_avg - pay.payroll_ia_diff_percent_avg) AS growth_difference
	FROM v_eva_cajzlova_question4_payroll_dif_percent_avg pay
	JOIN v_eva_cajzlova_question4_price_dif_percent_avg pri
		ON pay.payroll_year = pri.price_year
	ORDER BY
		growth_difference;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_sql_question4_all_branches_categories AS 
	SELECT
		pay.payroll_year AS `year`,
		pay.industry_branch_code,
		pay.branch_code_name,
		pay.interannual_difference_percent AS payroll_ia_diff_percent,
		pri.category_code,
		pri.category_name,
		pri.price_value_unit,
		pri.interannual_difference_percent AS rice_ia_diff_percent,
		(pri.interannual_difference_percent - pay.interannual_difference_percent) AS growth_difference
	FROM v_eva_cajzlova_question4_payroll_difference_percent pay
	JOIN v_eva_cajzlova_question3_interannual_difference_percent pri
		ON pay.payroll_year = pri.price_year;

SELECT *
FROM t_eva_cajzlova_project_sql_question4_all_branches_categories
WHERE
	growth_difference > 10
ORDER BY
	`year`;

SELECT
	DISTINCT(`year`)
FROM t_eva_cajzlova_project_sql_question4_all_branches_categories
WHERE
	growth_difference > 10
ORDER BY
	`year`;

-- jeste to omezit jen na roky? uvidime, co bude dobre

-- musim to cele nutne projit od zacatku (az dokoncim 4), mam desnej bordel v pojmenovavani veci, je to neprehledny, tady se to hodne ukazuje - jak views, tak promennych
-- mrknout se jeste na with, jestli by me to nezbavilo nejakych views, mam jich tam vazne hodne


-- Otazka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

-- plus t_{jmeno}_{prijmeni}_project_SQL_secondary_final
-- dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR -- 2006-2018
-- countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
-- economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.


CREATE OR REPLACE VIEW v_eva_cajzlova_countries_states AS 
	SELECT
		country
	FROM countries c
	WHERE
		continent = 'Europe';

CREATE OR REPLACE VIEW v_eva_cajzlova_economies_states AS
	SELECT
		DISTINCT(country)
	FROM economies e
	WHERE
		country IN (
			SELECT
				country
			FROM countries c
			WHERE
				continent = 'Europe'
	);

SELECT
	cs.country AS list_countries,
	es.country AS list_economies
FROM v_eva_cajzlova_countries_states cs
LEFT JOIN v_eva_cajzlova_economies_states es
	ON cs.country = es.country;

CREATE OR REPLACE TABLE t_eva_cajzlova_project_SQL_secondary_final
	SELECT
		country,
		`year`,
		GDP,
		population,
		gini
	FROM economies e
	WHERE
		(`year` BETWEEN 2006 AND 2018)
		 AND country IN (
			SELECT
				country
			FROM countries c
			WHERE
				continent = 'Europe'
		)
	ORDER BY
		country,
		`year`;