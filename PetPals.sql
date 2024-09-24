--Create and Use the Database
if not exists (select * from sys.databases where name = 'petpals')
begin
create database PetPals
end

use PetPals

--drop existing tables to prevent conflicts
if object_id('pets','u') is not null drop table pets
if object_id('shelters','u') is not null drop table shelters
if object_id('donations','u') is not null drop table donations
if object_id('adoptionevents','u') is not null drop table adoptionevents
if object_id('participants','u') is not null drop table participants
--create shelters table
create table shelters(
shelterid int primary key,
name nvarchar(100) not null,
location nvarchar(100) not null
)
--create pets table
create table pets(
petid int primary key,
name nvarchar(50) not null,
age int not null,
breed nvarchar(50) not null,
type nvarchar(50) not null,
availableforadoption bit not null,
shelterid int,
foreign key(shelterid) references shelters(shelterid)
)
--create donations table
create table donations(
donationid int primary key,
donorname nvarchar(100) not null,
donationtype nvarchar(50) not null,
donationamount decimal(10,2),
donationitem nvarchar(100),
donationdate datetime not null,
shelterid int,
foreign key(shelterid) references shelters(shelterid)
)
--create adoptionevents table
create table adoptionevents(
eventid int primary key,
eventname nvarchar(100) not null,
eventdate datetime not null,
location nvarchar(100) not null
)
--create participants table
create table participants(
participantid int primary key,
participantname nvarchar(100) not null,
participanttype nvarchar(50) not null,
eventid int,
foreign key(eventid) references adoptionevents(eventid)
)
--insert sample data into shelters
insert into shelters(shelterid,name,location)
values(1,'happy shelter','chennai'),
(2,'stray shelter','bombay'),
(3,'Delhi shelter','delhi')
--insert sample data into pets
insert into pets(petid,name,age,breed,type,availableforadoption,shelterid)
values(1,'rocky',3,'labrador','dog',1,1),
(2,'molly',2,'stray','cat',0,2),
(3,'bruno',5,'german shepherd','dog',1,1)
--insert sample data into donations
insert into donations(donationid,donorname,donationtype,donationamount,donationitem,donationdate,shelterid)
values(1,'mukesh','cash',150,null,'2024-09-20 10:30:00',1),
(2,'mohan','item',null,'dog food','2024-09-21 12:00:00',2),
(3,'manan','cash',200,null,'2024-09-22 09:00:00',1)
--insert sample data into adoptionevents
insert into adoptionevents(eventid,eventname,eventdate,location)
values(1,'adopt a pet','2024-09-25 10:00:00','chennai'),
(2,'pet fest','2024-10-01 09:00:00','bombay'),
(3,'cat fest','2024-11-15 11:00:00','delhi')
--insert sample data into participants
insert into participants(participantid,participantname,participanttype,eventid)
values(1,'happy shelter','shelter',1),
(2,'rohan','adopter',1),
(3,'stray shelter','shelter',2)
--task 5: query to retrieve list of available pets
select name,age,breed,type
from pets
where availableforadoption=1
--task 6: query to retrieve participants for a specific adoption event
declare @eventid int=1;
select p.participantname,p.participanttype
from participants p
join adoptionevents ae on p.eventid=ae.eventid
where p.eventid=@eventid;

--task 7:Stored procedure question:TO BE SKIPPED

--task 8: query to calculate total donation amount by shelter
select s.name as sheltername,sum(d.donationamount) as totaldonationamount
from donations d
right join shelters s on d.shelterid=s.shelterid
group by s.name

--task 9: query to retrieve pets without an owner
select name,age,breed,type
from pets
where availableforadoption=1

--task 10: query to retrieve total donation amount by month and year

select 
format(donationdate, 'MMMM yyyy') as monthyear, 
isnull(sum(donationamount), 0) as totaldonationamount
from 
donations
group by 
format(donationdate, 'MMMM yyyy')
order by 
min(donationdate)


--task 11: retrieve distinct breeds of pets in specific age range
select distinct breed
from pets
where (age between 1 and 3) or age>5
--task 12: retrieve list of pets and their shelters available for adoption
select p.name as petname,s.name as sheltername
from pets p
join shelters s on p.shelterid=s.shelterid
where p.availableforadoption=1
--task 13: total number of participants in events organized by shelters in specific city
declare @city nvarchar(100)='chennai'
select count(p.participantid) as totalparticipants
from participants p
join adoptionevents ae on p.eventid=ae.eventid
join shelters s on ae.location=s.location
where s.location=@city
--task 14: retrieve unique breeds for pets aged between 1 and 5 years
select distinct breed
from pets
where age between 1 and 5
--task 15: retrieve pets that have not been adopted
select name,age,breed,type
from pets
where availableforadoption=1
--task 16: retrieve names of adopted pets and their adopters
select 
pt.participantname as adoptername,
p.name as petname
from 
participants pt
join 
pets p on pt.participantid = p.petid  
where 
pt.participanttype = 'adopter'



--task 17: list of all shelters and count of pets available for adoption
select s.name as sheltername,count(p.petid) as availablepetscount
from shelters s
left join pets p on s.shelterid=p.shelterid
where p.availableforadoption=1
group by s.name
--task 18: find pairs of pets from same shelter with same breed
insert into pets(petid,name,age,breed,type,availableforadoption,shelterid)
values(4,'paty',4,'german shepherd','dog',1,1)
select 
p1.name as pet1, 
p2.name as pet2, 
p1.breed, 
p1.shelterid
from pets p1
inner join pets p2 
on p1.shelterid = p2.shelterid 
and p1.breed = p2.breed 
and p1.petid < p2.petid


--task 19: list all possible combinations of shelters and adoption events
select s.name as sheltername,ae.eventname
from shelters s
cross join adoptionevents ae
--task 20: shelter with highest number of adopted pets

select top 1 s.name as sheltername, count(p.petid) as totalpets
from shelters s
left join pets p on s.shelterid = p.shelterid
group by s.name
order by count(p.petid) desc

