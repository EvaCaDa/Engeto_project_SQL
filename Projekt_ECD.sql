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
-- kdyz je NULL u industry_branch_code, tak je to prumer pro vsechny branche? Neni, proste nevim, co je to za cislo.


SELECT *
FROM czechia_payroll cp
WHERE
	value_type_code = 5958 -- prumerna hruba mzda zamestnance
	AND calculation_code = 100
	AND payroll_year = 2000
	AND payroll_quarter = 1; -- fyzicky plat (kod 200 je prepocteny na plne uvazky) - lepe bude ilustrovat realnou dostupnost potravin, o kterou nam jde
-- kdyz je NULL u industry_branch_code, tak je to prumer pro vsechny branche? Neni. WTF? podle toho ciselniku z csu a dokumentace tam uplne chybi dve kategorie (t a u), fakt nevim, co to je za cislo	
	
SELECT
	*
FROM czechia_payroll cp
WHERE
	calculation_code = 100
	AND payroll_year = 2000
	AND payroll_quarter = 1
	AND industry_branch_code IS NOT NULL; -- 11593


SELECT 1720/20

SELECT avg(value)
FROM czechia_payroll cp
WHERE
	value_type_code = 5958
	AND calculation_code = 100;

SELECT avg(value)
FROM czechia_payroll cp
WHERE
	value_type_code = 5958
	AND calculation_code = 200;

SELECT
	min(payroll_year), -- 2000
	max(payroll_year) -- 2021
FROM czechia_payroll cp
WHERE
	value_type_code = 5958
	AND calculation_code = 100; 

-- Priprava primarni tabulky - ceny

SELECT *
FROM czechia_price cp;
-- limitace, pro ceny to mam rozbite na kraje, ale pro mzdy ne --- mam se zamerit jen na cr, nebo resit i kraje, kdyz pro to nemuzu udelat totez ve mzdach?

SELECT
	min(YEAR(date_from)), -- 2006
	max(YEAR(date_from))-- 2018
FROM czechia_price cp;

-- Zacneme omezenim na roky.

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
	quarter(date_from) != quarter(date_to) -- ok, mam problem, co s tim
ORDER BY quarter(date_to);

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
	quarter(date_from),
	min(dayofmonth(date_to)),
	max(dayofmonth(date_to))
FROM czechia_price cp
WHERE
	quarter(date_from) != quarter(date_to)
GROUP BY quarter(date_from);

SELECT
	*,
	dayofmonth(date_from),
	dayofmonth(date_to),
	quarter(date_from),
	quarter(date_to),
	dayname(date_from)
FROM czechia_price cp
WHERE
	quarter(date_from) = 1 
	AND quarter(date_to) = 2
	AND (year(date_from) BETWEEN 2006 AND 2018);
-- tyden ma sedm dni, pokud bude dayofmonth(date_to) 4 a vice, tak to prsknu do vetsiho quarteru

SELECT
	*,
	year(date_from) AS price_year,
	CASE
		WHEN quarter(date_from) = quarter(date_to) THEN quarter(date_from)
		WHEN quarter(date_from) != quarter(date_to) AND dayofmonth(date_to) < 4 THEN quarter(date_from)
		ELSE quarter(date_to) 
	END AS price_quarter
FROM czechia_price cp;

SELECT
	*,
	year(date_from) AS price_year,
	CASE
		WHEN quarter(date_from) = quarter(date_to) THEN quarter(date_from)
		WHEN quarter(date_from) != quarter(date_to) AND dayofmonth(date_to) < 4 THEN quarter(date_from)
		ELSE quarter(date_to) 
	END AS price_quarter
FROM czechia_price cp
WHERE 
	quarter(date_from) != quarter(date_to)
GROUP BY
	price_year,
	price_quarter;

-- t_{jmeno}_{prijmeni}_project_SQL_primary_final

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

SELECT
	*
FROM t_eva_cajzlova_czechia_price_year_quarter cpyq
WHERE
	category_code IS NULL;

SELECT
	cpyq.id,
	cpyq.value,
	cpyq.category_code,
	cpc.name,
	concat(cpc.price_value, ' ', cpc.price_unit) AS price_value_unit,
	cpyq.region_code,
	cpyq.price_year,
	cpyq.price_quarter
FROM t_eva_cajzlova_czechia_price_year_quarter cpyq
JOIN czechia_price_category cpc
	ON cpyq.category_code = cpc.code;


