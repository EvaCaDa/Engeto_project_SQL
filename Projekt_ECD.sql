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