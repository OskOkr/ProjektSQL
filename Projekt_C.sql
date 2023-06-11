--WIDOKI
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


create function najnizsza_krajowa()
return trigger sa $$
begin 
 if NEW.pensja < 1600 then 
  update stanowisko set pensja=1600 where pensja=new.pensja;
 end IF;
 return new;
end;
$$ LANGUAGE 'plpqsql';
