/* 
 * VYTVOŘENÍ SEKUNDÁRNÍ TABULKY
 * 
 * Zdrojová data:
 * countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
 * economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.
 */

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