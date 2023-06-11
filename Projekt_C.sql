--Imię i nazwisko: MARCIN MUSIAŁ, OSKAR OKRUCIŃSKI
--Temat bazy danych: SERWIS (TEMAT NR 5)

--1a) Tworzymy 3 widoki
CREATE VIEW ilosc_napraw_klienta
AS
SELECT k.id_klient, k.imie, k.nazwisko, COUNT(s.id_klient) AS "ilosc_napraw"
FROM klient k LEFT JOIN sprzet s ON k.id_klient=s.id_klient
GROUP BY k.id_klient, k.imie, k.nazwisko;

CREATE VIEW ilosc_napraw_pracownika
AS
SELECT p.id_pracownicy, p.imie, p.nazwisko, COUNT(p.id_pracownicy) AS "ilosc_napraw"
FROM pracownicy p LEFT JOIN pracownicy_naprawy n ON p.id_pracownicy=n.id_pracownicy
GROUP BY p.id_pracownicy, p.imie, p.nazwisko;

CREATE VIEW pracownicy_kilentow as
select k.imie, k.nazwisko, p.imie as "imie pracownika", p.nazwisko as "nazwisko pracownika" from klient k 
join sprzet s on k.id_klient = s.id_klient
join naprawa n on s.id_naprawa = n.id_naprawa
join pracownicy_naprawy pn on n.id_naprawa = pn.id_naprawa
join pracownicy p on pn.id_pracownicy = p.id_pracownicy

--1b) Sprawdzenie, że widoki działają
SELECT * FROM ilosc_napraw_klienta
SELECT * FROM ilosc_napraw_pracownika
SELECT * FROM pracownicy_kilentow

--2a) Tworzymy funkcję 1
CREATE OR REPLACE FUNCTION srednia_cena_naprawy()
RETURNS NUMERIC AS $$
DECLARE
    srednia_cena NUMERIC;
BEGIN
    SELECT AVG(cena) INTO srednia_cena FROM naprawa;
    RETURN srednia_cena;
END;
$$ LANGUAGE plpgsql;

--2b) Sprawdzenie, że funkcja 1 działa
SELECT srednia_cena_naprawy();

--3a) Tworzymy funkcję 2
CREATE OR REPLACE FUNCTION liczba_czesci_dostawcy(id_dostawcy INT)
RETURNS INT AS $$
DECLARE
    liczba_czesci INT;
BEGIN
    SELECT SUM(ilosc) INTO liczba_czesci FROM potrzebne_czesci WHERE id_dostawca = id_dostawcy;
    RETURN liczba_czesci;
END;
$$ LANGUAGE plpgsql;

--3b) Sprawdzenie, że funkcja 2 działa
SELECT liczba_czesci_dostawcy(2);

--4a) Tworzymy procedurę 1

--4b) Sprawdzenie, że procedura 1 działa

--5a) Tworzymy procedurę 2

--5b) Sprawdzenie, że procedura 2 działa

--6a) Tworzymy wyzwalacz 1
create function najnizsza_krajowa()
return trigger as $$
begin 
 if NEW.pensja < 1800 then 
  update stanowisko set pensja=1800 where pensja=new.pensja;
 end IF;
 return new;
end;
$$ LANGUAGE 'plpqsql';

--6b) Sprawdzenie, że wyzwalacz 1 działa
update stanowisko 
set pesja = 1500 
where nazwa = sprzedawca

select pesja,nazwa from stanowisko where nazwa = sprzedawca
--7a) Tworzymy wyzwalacz 2

--7b) Sprawdzenie, że wyzwalacz 2 działa

--8a) Tworzymy wyzwalacz 3

--8b) Sprawdzenie, że wyzwalacz 3 działa

--9a) Tworzymy wyzwalacz 4

--9b) Sprawdzenie, że wyzwalacz 4 działa

--10a) Tworzymy 2 kursory

--10b) Sprawdzenie, że kursory działają
