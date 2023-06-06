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
