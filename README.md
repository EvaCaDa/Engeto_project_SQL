# Engeto projekt: SQL


## Základní informace o projektu

Projekt zodpovídá pět předem definovaných otázek týkajících se dostupnosti základních potravin české veřejnosti.

Datové podklady sloužící jako základ pro zodpovězení těchto otázek vycházejí především z tabulek czechia_payroll a czechia_price (primární tabulka) a countries a economies (sekundární tabulka). Tabulky byly poskytnuté v rámci kurzu od společnosti Engeto; data v tabulkách czechia_payroll a czechia_price pocházejí z Portálu otevřených dat ČR, u dat tabulek countries a economies neznám jejich původní zdroj. 


## Datové podklady

### Primární tabulka

Primární tabulka obsahuje data průměrných hrubých mezd a průměrných cen potravin v České republice za období 2006-2018.
Vzhledem k tomu, že hlavním cílem výzkumu je analýza dostupnosti základních potravin široké veřejnosti, průměrné hrubé mzdy odpovídají fyzickému platu zaměstnanců (nejsou přepočítány na plné úvazky). Je tak lépe vidět, co si lidé skutečně mohli dovolit v daných letech koupit.

### Sekundární tabulka

Sekundární tabulka obsahuje informace o HDP, populaci a GINI koeficientu České republiky a dalších 44 evropských zemí, teritorií a území. Tyto informace se týkají stejných let jako primární tabulka.
Data bohužel nejsou kompletní. Pro některé státy, teritoria či území nejsou dostupné všechny informace o HDP (Faerské ostrovy, Gibraltar, Lichtnštejnsko). Rovněž GINI koeficient je pro některé státy v některých letech neznámý.
Data pro Českou republiku za dané období jsou však kompletní.


## Výzkumné otázky

### Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

V letech 2006-2018 každoročně rostly mzdy pouze v pěti sledovaných odvětvích: Zpracovatelský průmysl, Doprava a skladování, Administrativní a podpůrné činnosti, Zdravotní a sociální péče, Ostatní činnosti.
Všechna ostatní sledovaná odvětví jinak zaznamenala alespoň jeden meziroční pokles. Nejčastěji klesaly průměrné mzdy v oblasti Těžba a dobývání, a to v letech 2009, 2013, 2014 a 2016.

### Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

V roce 2006 bylo možné si za průměrnou mzdu v rámci všech odvětví koupit 1408 l mléka nebo 1258 kg chleba. O dvanáct let později bylo možné za průměrnou mzdu získat 1613 l mléka nebo 1319 kg chleba.

### Otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Mezi lety 2006-2018 (pro kategorii Jakostní víno bílé jsou dostupná data pro rozmezí let 2015-2018) nejpomaleji zdražoval Cukr krystalový - 1 kg tohoto zboží každoročně v průměru zlevnil o 1,92 %. Stejně tak ve sledovaném období zlevňovala Rajská jablka červená kulatá (každoročně průměrně o 0,72 %). Ostatní měřené kategorie v průměru naopak zdražovaly, nejvíce pak Papriky.

### Otázka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Pokud se podíváme na průměrnou hodnotu růstu cen všech měřených kategorií potravin a srovnáme ji s průměrnou hodnotou růstu mezd ve všech měřených odvětvích, tak takový rok neexistuje. Nejblíže k němu měl rok 2013, ve kterém ceny potravin rostly o 6,81 % více než mzdy.

Je však možné se na data podívat do většího detailu. Při srovnání růstu cen jednotlivých kategorií s průměrnou hodnotou mezd ve všech měřených odvětvích pouze v letech 2009 a 2014 meziročně nezdražila ani jediná kategorie potravin ve srovnání s průměrným růstem mezd. Ve všech ostatních srovnatelných letech cena alespoň jedné kategorie potravin vzrostla výrazně více než mzdy.
Lze také srovnat růst cen všech měřených kategorií potravin se mzdami jednotlivých měřených odvětví. Při tomto pohledu pak rostly ceny všech potravin výrazně více než mzdy pouze v roce 2013, a to pro dvě měřená odvětví: Výroba a rozvod elektřiny, plynu, tepla a klimatizovaného vzduchu (10,4 %) a Peněžnictví a pojišťovnictví (15,11 %).

### Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Medián růstu HDP je v rámci let 2006-2018 2,49 %. Tato hodnota byla stanovena jako hranice pro výraznější růst HDP, cen potravin i mezd pro zodpovězení páté otázky.
Při pohledu na data lze vysledovat, že pokud vzroste v jednom roce HDP o více než 2,49 %, mzdy v tomtéž či následujícím roce také vzrostou o více než 2,49 %. (Z dostupných dat však nelze s jistotou vyčíst, že právě růst HDP způsobil růst mezd.)
Totéž nelze říci o růstu cen potravin. V roce 2015 vzrostlo oproti předchozímu roku HDP o 5,39 %, ceny potravin však v letech 2015 i 2016 meziročně klesaly. (Stejně tak v roce 2018 HDP meziročně vzrostlo o 3,2 %, naopak ceny potravin šly dolů. Nejsou ale dostupná data pro rok 2019.)

