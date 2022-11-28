############################################################################################################################################################################
#TICKETS
############################################################################################################################################################################

drop procedure if exists fill_ticket_NewSession;
DeLIMITER //	
create procedure fill_ticket_NewSession(IN _filmID int, IN _idHall int, IN _price float, IN _idDay int, IN _idTime int )
language sql
deterministic
BEGIN
declare i int default 1;
declare j int default 1;
declare _rows int default 0 ;
declare _place int default 0 ;
SELECT rowsQuantity INTO _rows FROM hall WHERE idHall = _idHall;
SELECT place INTO _place FROM hall WHERE idHall = _idHall;

while i <= _rows do
while j<= _place do
insert into newticket ( idfilm, idHall, rownum, place, price,  idday, idtime ) values(  _filmID, _idHall, i, j, _price,  _idDay, _idTime );
if j between 3 and 8 then update newticket set status = 1 where place=j;
end if;
set j = j+1;
end while;

set j=1;
set i=i+1;
End while;
END //
DELIMITER ;
###################################################################################################################################################################################

use mydb;
drop trigger if exists INSERT_ticket_Session;

delimiter //
create trigger INSERT_ticket_Session before insert on newticket
for each row
begin 
if exists (select *
from newticket
where   idHall= new.idHall AND  idday= new.idday AND idtime= new.idtime AND rowNum= new.rowNum AND place= new.place AND Status=new.Status)
 then
 signal sqlstate '20000'
 set message_text = 'This this time already used',
 MYSQL_ERRNO = 202; 
 end if;
end//
DELIMITER ;
###################################################################################################################################################################################
use mydb;
drop trigger if exists UPDATE_ticket_Session;
delimiter //
create trigger UPDATE_ticket_Session before update on newticket
for each row
begin
if exists (select *
from newticket
where   price= new.price AND idHall= new.idHall AND  idday= new.idday AND idtime= new.idtime AND rowNum= new.rowNum AND place= new.place AND 'old.Status'='new.Status')
 then
 signal sqlstate '20000'
 set message_text = 'This this time already used',
 MYSQL_ERRNO = 202; 
 end if;
end//
DELIMITER ;
/**/###################################################################################################################################################################################
drop procedure if exists PR_update_Ticket;
delimiter //
CREATE PROCEDURE PR_update_Ticket(IN _filmID int, IN _idHall int, IN _price float, IN _idDay int, IN _idTime int )
language sql
deterministic
BEGIN
#update company  where name like _N;
if(_idHall != "0")then
update newticket set idhall=_idHall where idfilm=_filmID  ;
end if;
if(_price != "0")then
update newticket set price=_price where idfilm=_filmID  ;
end if;
if(_idDay != "0")then
update newticket set idday=_idDay where idfilm=_filmID  ;
end if;
if(_idTime != "0")then
update newticket set idtime=_idTime where idfilm=_filmID  ;
end if;
 
END//
DELIMITER ;
############################################################################################################################################################################
#STAFF 
##############################################################################################################################################################################
 /* */
use mydb;
drop trigger if exists DELETE_staff_Check;
delimiter //
create trigger DELETE_staff_Check before  delete on staff
for each row
begin
if not exists (select * from staff   where Surname like  _SN and name like _N and  Position_idPosition = _pos) 
then
 signal sqlstate '30000'
 set message_text = 'Incorrect name\surname\ idPosition!',
 MYSQL_ERRNO = 303; 
 end if;  
end//
DELIMITER ;
drop trigger if exists DELETE_staff_Check;

##############################################################################################################################################################################
 
drop procedure if exists PR_delete_Staff;
delimiter //
CREATE PROCEDURE PR_delete_Staff(IN _N varchar(20), IN _SN varchar(20),  IN _pos int )
language sql
deterministic
BEGIN
delete from staff   where Surname like  _SN and name like _N and  Position_idPosition = _pos ;
END//
DELIMITER ;
##############################################################################################################################################################################
 
drop procedure if exists PR_insert_Staff;
delimiter //
CREATE PROCEDURE PR_insert_Staff(IN _N varchar(20), IN _SN varchar(20), IN _PN varchar(20), IN _ph int, IN _pos int, IN d_c varchar(20), IN d_o varchar(20))
# IN _posN varchar(20)
language sql
deterministic
BEGIN
#update company  where name like _N;
#declare _pos int default 1;
#select idposition into _pos from position where name like _posN ;
insert into  staff (name,Surname, Patronymic, phone, Position_idPosition, DayCome, DayOut) values(_N , _SN, _PN, _ph, _pos, d_c, d_o);
END//
DELIMITER ;
 
##############################################################################################################################################################################

drop procedure if exists PR_update_Staff;
delimiter //
CREATE PROCEDURE PR_update_Staff(IN _N varchar(20), IN _SN varchar(20), IN _PN varchar(20), IN _ph int, IN _pos int, IN d_c varchar(20), IN d_o varchar(20))
language sql
deterministic
BEGIN 
if(_SN != "0")then
update staff set Surname=_SN where name like _N;
end if;
if(_PN != "0")then
update staff set Patronymic = _PN where name like _N;
end if;
if(_ph != 0)then
update staff set phone= _ph where name like _N;
end if;
if(_pos != 0)then
update staff set Position_idPosition = _pos where name like _N;
end if;
if(d_c != 0)then
update staff set DayCome = d_c where name like _N;
end if;
if(d_o != 0)then
update staff set DayOut = d_o where name like _N;
end if;
select * from staff;
END//
DELIMITER ;
##############################################################################################################################################################################

use mydb;
drop view if exists VIEW_Staff;
create view VIEW_Staff( idstaff, Name, Surname, Patronymic, Phone, idPosition, Position , Day_Come, Day_Out )
AS 
select staff.idstaff, staff.name, staff.surname, staff.patronymic, staff.phone, staff.Position_idPosition, position.Name, staff.daycome, staff.dayout
 from staff 
 join  position
 ON (position.idposition=staff.position_idposition ) ;
 #select * from VIEW_Staff ; 
 ############################################################################################################################################################################
 #FILM
 ############################################################################################################################################################################ 
 
 use mydb;
drop trigger if exists delete_cascade_from_FILM ;
delimiter //
create trigger delete_cascade_from_FILM before delete on film
for each row
begin
delete from newticket
where idFilm=old.idFilm AND status = 0;
end//
DELIMITER ;
##############################################################################################################################################################################

drop trigger if exists INSERT_FILM_Check;
delimiter //
create trigger INSERT_FILM_Check before insert on film
for each row
begin
if exists (select * from film where name= new.name and format= new.format) 
then
 signal sqlstate '30000'
 set message_text = 'This film already exists!',
 MYSQL_ERRNO = 303; 
 end if;  
end//
DELIMITER ;
 

use mydb;

 
##############################################################################################################################################################################

 drop procedure if exists PR_insert_Film;
delimiter //
CREATE PROCEDURE PR_insert_Film(IN _name varchar(20), IN _duration varchar(20), IN _genre varchar(20), IN _director varchar(20), IN _actors varchar(20),
 IN _format varchar(20), IN _country varchar(20), IN _cycle varchar(20), IN _Company_idCompany int)
 
language sql
deterministic
BEGIN

insert into  film ( name ,duration , genre, directed_by,actors ,format , country ,cycle , Company_idCompany ) 
 values( _name , _duration ,  _genre ,  _director ,  _actors ,  _format ,  _country,  _cycle ,  _Company_idCompany );
 
END//
DELIMITER ;
############################################################################################################################################################################
   drop procedure if exists PR_update_Film;
delimiter //
CREATE PROCEDURE PR_update_Film (IN _name varchar(20), IN _duration varchar(20), IN _genre varchar(20), IN _director varchar(20),  IN _actors varchar(20), 
IN _format varchar(20),IN _country varchar(20), IN _cycle varchar(20), IN _idcompany int)
language sql
deterministic
BEGIN
 if(_duration != 0)then
update film set duration=_duration where name = _name;
end if;
 if(_genre != 0)then
update film set genre=_genre where name = _name;
end if;
 if(_director != 0)then
update film set directed_by=_director where name = _name;
end if;
 if(_actors != 0)then
update film set  actors=_actors where name = _name;
end if;
 if(_format != 0)then
update film set   format=_format where name = _name;
end if;
 if(_country != 0)then
update film set    country=_country where name = _name;
end if;
 if(_cycle != 0)then
update film set    cycle=_cycle where name = _name;
end if;
 if(_idcompany != 0)then
update film set    company_idcompany=_idcompany where name = _name;
end if;
END//
DELIMITER ;
############################################################################################################################################################################
#COMPANY
############################################################################################################################################################################

drop procedure if exists PR_delete_Company;
delimiter //
CREATE PROCEDURE PR_delete_Company (IN _N varchar(20), IN _con int, IN _M varchar(20),IN _Ph int)
language sql
deterministic
BEGIN
delete from company where name like _N;
delete from company where idContract like _con;
delete from company where MailAddres like _M;
delete from company where phone like _Ph;
select * from company;
END//
DELIMITER ;
##############################################################################################################################################################################

drop procedure if exists PR_update_Company;
delimiter //
CREATE PROCEDURE PR_update_Company (IN _N varchar(20), IN _con int, IN _M varchar(20),IN _Ph int)
language sql
deterministic
BEGIN
#update company  where name like _N;
if(_con != 0)then
update company set idContract=_con where name like _N;
end if;
if(_M != "0")then
update company set mailaddres = _M where name like _N;
end if;
if(_ph != 0)then
update company set phone= _ph where name like _N;
end if;
select * from company;
END//
DELIMITER ;
############################################################################################################################################################################
drop procedure if exists PR_fill_Sum;
delimiter //
CREATE PROCEDURE PR_fill_Sum ()
language sql
deterministic
BEGIN

DECLARE i INT DEFAULT 1;
DECLARE j INT DEFAULT 1;
 select max(IdCompany) into j from company;
while i< j do
update company set sumcompany = 
(select sum(price) from newticket where idFilm=
(select idFilm from film where Company_idCompany=i) AND Status=1 )
where idcompany=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idDay) into j from tableday;
while i< j do
update tableday set sumday = 
(select sum(price) from newticket where idDay=i AND Status=1 )
where idDay=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idTime) into j from tabletime;
while i< j do
update tabletime set sumtime = 
(select sum(price) from newticket where idTime=i AND Status=1 )
where idTime=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idhall) into j from hall;
while i< j do
update hall set sumhall = 
(select sum(price) from newticket where idhall=i AND Status=1 )
where idhall=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idfilm) into j from film;
while i< j do
update film set sumfilm = 
(select sum(price) from newticket where idfilm=i AND Status=1 )
where idfilm=i; 
set i=i+1;
end while;

END//

DELIMITER ;
############################################################################################################################################################################
#POSITION
############################################################################################################################################################################

drop procedure if exists PR_update_Position;
delimiter //
CREATE PROCEDURE PR_update_Position(IN _N varchar(20), IN _S int, IN _H int, IN _d  varchar(20))
language sql
deterministic
BEGIN
#update company  where name like _N;
if(_S != "0")then
update position set salary=_S where name like _N;
end if;
if(_H != "0")then
update position set hoursworks = _H where name like _N;
end if;
if(_d != 0)then
update position set daysworks= _d where name like _N;
end if;
END//
DELIMITER ;
############################################################################################################################################################################
############################################################################################################################################################################
#HALL
############################################################################################################################################################################
 
use mydb;
drop trigger if exists delete_cascade_from_HALL ;
delimiter //
create trigger delete_cascade_from_HALL before delete on hall
for each row
begin
delete from newticket
where idHall=old.idHall AND status = 0;
end//
DELIMITER ;
############################################################################################################################################################################
drop procedure if exists PR_update_Hall;
delimiter //
CREATE PROCEDURE PR_update_Hall(IN _N varchar(20),IN _place int, IN _rows int  )
language sql
deterministic
BEGIN
 if(_place != 0)then
update hall set place=_place where name like _N;
end if;
if(_rows != 0)then
update hall set rowsQuantity = _rows where name like _N;
end if;
 END//
DELIMITER ;
############################################################################################################################################################################
#DAY
############################################################################################################################################################################
############################################################################################################################################################################
#TIME
############################################################################################################################################################################
############################################################################################################################################################################
#VIEWS
############################################################################################################################################################################use mydb;
drop view if exists Booked_Tickets;
create view Booked_Tickets(idFilm, Film, Format,  Duration , Ticket_Number, RowNum, Place, Price , Hall , Day_Week  , Time_ )
AS 
select film.idFilm, film.name, film.Format, film.Duration , newticket.idNewTicket, newticket.RowNum, newticket.place, newticket.Price , hall.Name,
concat( tableday.date, ' ' , tableday.Day_Week) , concat(tabletime.startsat, ' - ',tabletime.FinishAt)
  from film 
 join  newticket
 ON (newticket.idFilm=film.idFilm AND newticket.Status=1)
 join tableday
 ON (tableday.idDay IN (select idDay from newticket where idFilm=film.idFilm AND newticket.Status=1))
 join tabletime
 ON(tabletime.idTIME IN (select idTIME from newticket where idFilm=film.idFilm AND newticket.Status=1))
 join hall
 ON( hall.idHall IN
 (select idHall from newticket where idFilm=film.idFilm AND Status=1));
############################################################################################################################################################################
drop procedure if exists PR_fill_Sum;
delimiter //
CREATE PROCEDURE PR_fill_Sum ()
language sql
deterministic
BEGIN

DECLARE i INT DEFAULT 1;
DECLARE j INT DEFAULT 1;
 select max(IdCompany) into j from company;
while i< j do
update company set sumcompany = 
(select sum(price) from newticket where idFilm=
(select idFilm from film where Company_idCompany=i) AND Status=1 )
where idcompany=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idDay) into j from tableday;
while i< j do
update tableday set sumday = 
(select sum(price) from newticket where idDay=i AND Status=1 )
where idDay=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idTime) into j from tabletime;
while i< j do
update tabletime set sumtime = 
(select sum(price) from newticket where idTime=i AND Status=1 )
where idTime=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idhall) into j from hall;
while i< j do
update hall set sumhall = 
(select sum(price) from newticket where idhall=i AND Status=1 )
where idhall=i; 
set i=i+1;
end while;

set i=1;
set j=1;
select max(idfilm) into j from film;
while i< j do
update film set sumfilm = 
(select sum(price) from newticket where idfilm=i AND Status=1 )
where idfilm=i; 
set i=i+1;
end while;

END//
DELIMITER ;
############################################################################################################################################################################
use mydb;
drop view if exists _genreSum;
create view _genreSum(Genre, SumGenre ) 
AS 
select  'Боевик', sum(Price)  from newticket
where idFilm IN(select idfilm from film where genre like '%Боевик%') AND status = 1
union 
select  'Драма', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Драма%' ) AND status = 1
union 
select  'Семейный', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Семейный%' ) AND status = 1
union 
select  'Комедия', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Комедия%' ) AND status = 1
union
select  'Фэнтэзи', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Фэнтэзи%' ) AND status = 1
union 
select  'Фантастика', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Фантастика%' ) AND status = 1
union 
select  'Исторический', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Исторический%' ) AND status = 1
union 
select  'Биография', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Биография%' ) AND status = 1
union 
select  'Детектив', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Детектив%' ) AND status = 1
union 
select  'Ужасы', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Ужасы%' ) AND status = 1
union 
select  'Триллер', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Триллер%') AND status = 1
union 
select  'Спорт', sum(Price) from newticket
where idFilm IN (select idfilm from film where genre like '%Спорт%' ) AND status = 1
;
 ############################################################################################################################################################################
  use mydb;
drop view if exists _CompanySum;
create view _CompanySum(Company, SumCompany ) 
AS 
select Company.name, Company.sumcompany 
from company
order by company.sumcompany DESC
;
select * from _CompanySum;
############################################################################################################################################################################

use mydb;
drop view if exists _DaySum;
create view _DaySum(  Day_, SumDay ) 
AS 
select   tableday.Day_Week, tableday.Sumday 
from tableday
order by tableday.Sumday DESC;
select * from _DaySum;
############################################################################################################################################################################
use mydb;
drop view if exists _TimeSum;
create view _TimeSum(  Time, SumTime  ) 
AS 
select   tabletime.StartsAt, tabletime.SumTime 
from tabletime
order by tabletime.SumTime  DESC;
#select * from _TimeSum;
############################################################################################################################################################################

use mydb;
drop view if exists _HallSum;
create view _HallSum(  Hall, SumHall  ) 
AS 
select   hall.Name, hall.SumHall 
from Hall
order by hall.SumHall  DESC; 
############################################################################################################################################################################

use mydb;
drop view if exists _FilmSum;
create view _FilmSum(  Film, SumFilm ) 
AS 
select   film.name, film.Sumfilm
from film
order by film.Sumfilm  DESC;
 ############################################################################################################################################################################

use mydb;
drop view if exists Tickets;
create view Tickets(Ticket_Number, idFilm, Film, Format,  Duration /*,  */,Row_, Place, Price , Hall , Day_Week  , Time_ )
AS 
select newticket.idNewTicket, film.idFilm, film.name, film.Format, film.Duration /*, */ , newticket.RowNum, newticket.place, newticket.Price , hall.Name,
concat( tableday.date, ' ' , tableday.Day_Week) , concat(tabletime.startsat, ' - ',tabletime.FinishAt) 
 from film 
 join  newticket
 ON (newticket.idFilm=film.idFilm AND newticket.Status=0)
 join tableday
 ON (tableday.idDay IN (select idDay from newticket where idFilm=film.idFilm AND newticket.Status=0))
 join tabletime
 ON(tabletime.idTIME IN (select idTIME from newticket where idFilm=film.idFilm AND newticket.Status=0))
 join hall
 ON( hall.idHall IN
 (select idHall from newticket where idFilm=film.idFilm AND Status=0)) ;
############################################################################################################################################################################
#ADMINpass
############################################################################################################################################################################