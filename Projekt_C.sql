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
CREATE FUNCTION wypisz_opinie(p_ocena INT)
RETURNS SETOF opinie_o_naprawie AS
$$
BEGIN
    RETURN QUERY
    SELECT * FROM opinie_o_naprawie WHERE ocena_gwiazdki = p_ocena;
END;
$$ LANGUAGE plpgsql;

--4b) Sprawdzenie, że procedura 1 działa
SELECT * FROM wypisz_opinie(5);

--5a) Tworzymy procedurę 2
CREATE OR REPLACE FUNCTION wypisz_stalych_klientow()
RETURNS SETOF klient AS
$$
BEGIN
    RETURN QUERY
    SELECT * FROM klient WHERE staly_klient = TRUE;
END;
$$ LANGUAGE 'plpgsql';

--5b) Sprawdzenie, że procedura 2 działa
SELECT * FROM wypisz_stalych_klientow();

--6a) Tworzymy wyzwalacz 1
create function najnizsza_krajowa()
returns trigger as $$
begin 
 if NEW.pensja < 1600 then 
  update stanowisko set pensja=1600 where pensja=new.pensja;
 end IF;
 return new;
end;
$$ LANGUAGE 'plpgsql';

create trigger najnizsza_krajowa
after update on stanowisko
for each row execute procedure najnizsza_krajowa()

--6b) Sprawdzenie, że wyzwalacz 1 działa
update stanowisko 
set pensja = 1500 
where nazwa = 'Sprzedawca'

select pensja, nazwa from stanowisko where nazwa = 'Sprzedawca'

--7a) Tworzymy wyzwalacz 2

create function premia()
returns trigger as $$
begin 
 if new.awans = TRUE THEN
  update pracownik set podwyzka=true,awans=true where id_pracownicy=new.id_pracownicy;
 end IF;
 return new;
end;
$$ LANGUAGE 'plpgsql';

create trigger premia
after update on pracownicy
for each row execute procedure premia()

--7b) Sprawdzenie, że wyzwalacz 2 działa

update pracownicy 
set podwyzka = TRUE
where id_pracownicy = 3

select id_pracownicy,awans,podwyzka from pracownicy where id_pracownicy = 3

--8a) Tworzymy wyzwalacz 3

create function premiazawyksztalcenie()
returns trigger as $$
begin 
 if old.wyksztalcenie<>new.wyksztalcenie THEN
  update pracownik set podwyzka=true id_pracownicy=new.id_pracownicy;
 end IF;
 return new;
end;
$$ LANGUAGE 'plpgsql';

create trigger premiazawyksztalcenie
after update on pracownicy
for each row execute procedure premiazawyksztalcenie()

--8b) Sprawdzenie, że wyzwalacz 3 działa

update pracownicy 
set wyksztalcenie = srednie
where id_pracownicy = 2

select id_pracownicy,wyksztalcenie,podwyzka from pracownicy
where id_pracownicy = 2


--9a) Tworzymy wyzwalacz 4
CREATE OR REPLACE FUNCTION aktualizuj_przewidywane_zakonczenie()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.zakonczono = TRUE THEN
        NEW.przewidywane_zakonczenie := CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER aktualizuj_przewidywane_zakonczenie
BEFORE INSERT OR UPDATE ON naprawa
FOR EACH ROW EXECUTE PROCEDURE aktualizuj_przewidywane_zakonczenie();

--9b) Sprawdzenie, że wyzwalacz 4 działa
UPDATE naprawa
SET zakonczono = TRUE
WHERE id_naprawa IN (1, 2, 3, 4, 5);

SELECT * FROM naprawa

--10a) Tworzymy 2 kursory
begin TRANSACTION;
DECLARE kur CURSOR for 
select k.imie, k.nazwisko, p.imie as "imie pracownika", p.nazwisko as "nazwisko pracownika" from klient k 
join sprzet s on k.id_klient = s.id_klient
join naprawa n on s.id_naprawa = n.id_naprawa
join pracownicy_naprawy pn on n.id_naprawa = pn.id_naprawa
join pracownicy p on pn.id_pracownicy = p.id_pracownicy
ORDER BY k.nazwisko, k.imie, p.id_pracownicy, p.nazwisko, p.imie, s.id_naprawa;

fetch 3 from kur;

close kur;
COMMIT TRANSACTION;

---------------------------------------------

begin TRANSACTION;
DECLARE gwi CURSOR for 

select o.ilosc_gwiazdek,p.imie,p.nazwisko,s.nazwa from opinia_o_pracowniku o 
join pracownicy p on o.id_pracownicy = p.id_pracownicy 
join stanowisko s on s.id_stanowisko =p.id_stanowisko
order by o.ilosc_gwiazdek,p.imie,p.nazwisko,s.nazwa;

fetch all from gwi;

close gwi;
COMMIT TRANSACTION;
--10b) Sprawdzenie, że kursory działają
