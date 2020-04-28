

use chi 

--select top 2 * from chi.dbo.intkey
--select top 2 * from chi.dbo.sourcecode

----------------------------------------------------
------ Get SourceCode Data from 2015-to-date -------
----------------------------------------------------


if object_id('Users.dbo.Keyword_SourceCodeData') is not null drop table Users.dbo.Keyword_SourceCodeData
       select distinct p2.person_id, p2.email,s3.sourcecode, s3.modified
	   into		Users.dbo.Keyword_SourceCodeData
	   from		chi.dbo.person p2 
					inner join chi.dbo.sourcecode s3 
						on p2.person_id = s3.person_id 
       where 
	   --/*
	   (s3.sourcecode like 'CHI-%-ATT-%'
	   or s3.sourcecode like 'CHI-%-INQ-%'
       or s3.sourcecode like 'CHI_-%-AT_-%'
       or s3.sourcecode like 'CHI_-%-OR_-%'
       or s3.sourcecode like 'CHI_-%-RP_-%'
       or s3.sourcecode like 'BBK_-%-AT_-%'
       or s3.sourcecode like 'BLS-%-AT_-%'
       or s3.sourcecode like 'BWS-%-AT_-%'
       or s3.sourcecode like 'BLS-%-OR_-%'
       or s3.sourcecode like 'BWS-%-OR_-%'
       or s3.sourcecode like 'BBK-%-OR_-%'
       or s3.sourcecode like 'BWS-%-RP_-%'
       or s3.sourcecode like 'BLS-%-RP_-%'
       or s3.sourcecode like 'BBK-%-RP_-%'
       )
       and 
	   --*/
	   s3.modified >= datepart(yy,'2015')

--drop table Users.dbo.Keyword_SourceCodeData


-----------------------------------------------------------------------
--------- Add First Hyphen '-' Position to Identify Category ----------
-----------------------------------------------------------------------

alter table Users.dbo.Keyword_SourceCodeData 
add Position1 varchar(50)
go
update Users.dbo.Keyword_SourceCodeData 
set Position1 = charindex('-', sourcecode, 1)

-----------------------------------------------------------------------
------ Add Second Hyphen '-' Position to Identify Product Brand -------
-----------------------------------------------------------------------

alter table Users.dbo.Keyword_SourceCodeData
add Position2 varchar(10)
go
update Users.dbo.Keyword_SourceCodeData
set Position2 = charindex('-', sourcecode, (charindex('-', sourcecode, 1))+2)

--select top 2* from Users.dbo.Keyword_SourceCodeData


--select distinct Position1 from Users.dbo.Keyword_SourceCodeData
--select * from Users.dbo.Keyword_SourceCodeData where position = '7' 

----------------------------------------------
------ CleanUp CII/CHI Email Addresses -------
----------------------------------------------

delete from Users.dbo.Keyword_SourceCodeData where position = '7' 
delete from Users.dbo.Keyword_SourceCodeData where email = ''
delete from Users.dbo.Keyword_SourceCodeData where email like '%healthtech.com'
delete from Users.dbo.Keyword_SourceCodeData where email like '%cambridgeinnovationinstitute.com'


/*TESTING
select distinct email, count(distinct sourcecode) as DistinctSourceCodes
from			Users.dbo.Keyword_SourceCodeData
group by		email
order by		DistinctSourceCodes desc

feirongjust@qq.com                                                              
mas@sc.itc.keio.ac.jp                                                           
leahbarton@surewest.net                                                                                                                        
zhangzhihua@big.ac.cn             

select * from Users.dbo.Keyword_SourceCodeData where email = 'feirongjust@qq.com' order by modified desc--sourcecode, modified
select * from Users.dbo.Keyword_SourceCodeData where email = 'kai_wucherpfennig@dfci.harvard.edu' order by modified desc

*/


------------------------------------------------------------
------ Extract Product_Acronym from SourceCode Table -------
------------------------------------------------------------


alter table Users.dbo.Keyword_SourceCodeData 
add		Product_Acronym_String varchar(50)
go
update	Users.dbo.Keyword_SourceCodeData
set		Product_Acronym_String = case	when Position1 = '4' and Position2 = '8' then left (sourcecode,7)
										when Position1 = '4' and Position2 = '9' then left (sourcecode,8)
										when Position1 = '4' and Position2 = '10' then left (sourcecode,9)
										when Position1 = '4' and Position2 = '11' then left (sourcecode,10)
										when Position1 = '4' and Position2 = '12' then left (sourcecode,11)
										when Position1 = '5' and Position2 = '8' then left (sourcecode,7)
										when Position1 = '5' and Position2 = '9' then left (sourcecode,8)
										when Position1 = '5' and Position2 = '10' then left (sourcecode,9)
										end 


alter table Users.dbo.Keyword_SourceCodeData 
add		Product_Acronym varchar(50)
go 
update	Users.dbo.Keyword_SourceCodeData
set		Product_Acronym = case			when Position1 = '4' and Position2 = '8' then right (Product_Acronym_String,3)
										when Position1 = '4' and Position2 = '9' then right (Product_Acronym_String,4)
										when Position1 = '4' and Position2 = '10' then right (Product_Acronym_String,5)
										when Position1 = '4' and Position2 = '11' then right (Product_Acronym_String,6)
										when Position1 = '4' and Position2 = '12' then right (Product_Acronym_String,7)
										when Position1 = '5' and Position2 = '8' then right (Product_Acronym_String,2)
										when Position1 = '5' and Position2 = '9' then right (Product_Acronym_String,3)
										when Position1 = '5' and Position2 = '10' then right (Product_Acronym_String,4)
										end 

delete from Users.dbo.Keyword_SourceCodeData where Product_Acronym = '-RPT'

--select top 10 * from Users.dbo.Keyword_SourceCodeData	where position = '9'	
--select distinct Position2 from Users.dbo.Keyword_SourceCodeData where Position1 = '4'
--select top 100* from Users.dbo.Keyword_SourceCodeData where Position1 = '5' and Position2 = '10'
--select * from Users.dbo.Keyword_SourceCodeData where Product_Acronym like '%-%'


--select distinct Product_Acronym from Users.dbo.Keyword_SourceCodeData 


------------------------------------------------------
------ Get Registration Data from 2015-to-date -------
------------------------------------------------------

--select top 2 * from CHI.dbo.DS_Sales_Data

if object_id('Users.dbo.Keyword_RegistrationData') is not null drop table Users.dbo.Keyword_RegistrationData
       select distinct a.prospect_id, a.prospect_email, a.prospect_company,a.prospect_country, a.product_acronym
						,a.registration_category, a.registration_subcategory, a.registration_financial_coding, sum(registration_total_charges) as Revenue
	   into			Users.dbo.Keyword_RegistrationData
	   from			CHI.dbo.DS_Sales_Data a
	   where		registration_date >= datepart(yy,'2015')
	   group by		a.prospect_id, a.prospect_email, a.prospect_company,a.prospect_country, a.product_acronym
						,a.registration_category, a.registration_subcategory, a.registration_financial_coding

delete from		Users.dbo.Keyword_RegistrationData where prospect_email like '%healthtech.com'
delete from		Users.dbo.Keyword_RegistrationData where prospect_email like '%cambridgeinnovationinstitute.com'

if object_id('Users.dbo.Keyword_UnusedData') is not null drop table Users.dbo.Keyword_UnusedData
select distinct a.*
into			Users.dbo.Keyword_UnusedData
from			chi.dbo.intkey a
					left outer join Users.dbo.Keyword_RegistrationData r
						on a.keyword = r.product_acronym
					left outer join Users.dbo.Keyword_SourceCodeData s
						on a.keyword = s.product_acronym
where			r.product_acronym is null
and				s.product_acronym is null
order by		modified desc

--select * from Users.dbo.Keyword_UnusedData order by 
--select * from Users.dbo.Keyword_RegistrationData where product_acronym ='PEGV'
--select * from Users.dbo.Keyword_SourceCodeData where product_acronym ='AIGB'

--SELECT * from chi.dbo.intkey order by keyword, modified desc

if object_id('tempdb..#Reg') is not null drop table #Reg
select	distinct trim(prospect_email)+'-'+trim(product_acronym) as Email_Acronym
into	#Reg
from	Users.dbo.Keyword_RegistrationData
--select top 2 * from #Reg

if object_id('tempdb..#SourceCode') is not null drop table #SourceCode
select	distinct trim(email)+'-'+trim(product_acronym) as Email_Acronym
into	#SourceCode
from	Users.dbo.Keyword_SourceCodeData
--select top 2 * from #SourceCode

alter table Users.dbo.Keyword_RegistrationData
add			Email_Acronym varchar(250)
go
update		Users.dbo.Keyword_RegistrationData
set			Email_Acronym = trim(prospect_email)+'-'+trim(product_acronym)


alter table Users.dbo.Keyword_SourceCodeData
add			Email_Acronym varchar(250)
go
update		Users.dbo.Keyword_SourceCodeData
set			Email_Acronym = trim(email)+'-'+trim(product_acronym)


select	top 100 A.*
from	Users.dbo.Keyword_SourceCodeData A
			left outer join Users.dbo.Keyword_RegistrationData B
				on A.Email_Acronym = B.Email_Acronym
where	B.Email_Acronym is null
order by	A.modified desc

select count(distinct Email_Acronym) from Users.dbo.Keyword_SourceCodeData
--1,986,611
select count(distinct Email_Acronym) from Users.dbo.Keyword_RegistrationData
--359,135

select count(distinct Email) from Users.dbo.Keyword_SourceCodeData
--436,847
select count(distinct Prospect_Email) from Users.dbo.Keyword_RegistrationData
--226,097


--select * from Users.dbo.Keyword_RegistrationData where Prospect_email = 'pelin.durali@sanofi.com'
--select * from Users.dbo.Keyword_SourceCodeData where email = 'pelin.durali@sanofi.com' order by modified desc
--select * from chi.dbo.intkey where keyword = 'ams'
--select * from chi.dbo.intkey order by keyword 

select top 10 * from Users.dbo.Keyword_SourceCodeData
select top 10 * from Users.dbo.Keyword_RegistrationData

--delete from Users.dbo.Keyword_RegistrationData where prospect_email = ''
--delete from Users.dbo.Keyword_SourceCodeData where Email is null
--select * from Users.dbo.Keyword_RegistrationData where Email_Acronym = 'jhyoo@mhrnd.com-imx'

select * from Users.dbo.Keyword_RegistrationData where prospect_email = 'charles.ho@fda.hhs.gov'
select * from Users.dbo.Keyword_SourceCodeData where email = 'charles.ho@fda.hhs.gov' order by modified desc



--------------------------------------------------------------------------------------
----- Create Existing Keyword Interest Table for Registration & SourceCode Data ------
--------------------------------------------------------------------------------------
if object_id('Users.dbo.Keyword_ExistingInterests') is not null drop table Users.dbo.Keyword_ExistingInterests
select distinct Prospect_email as Email, Product_Acronym, Email_Acronym, Registration = cast (NULL as int), SourceCode = cast (NULL as int)
into			Users.dbo.Keyword_ExistingInterests
from			Users.dbo.Keyword_RegistrationData

insert into		Users.dbo.Keyword_ExistingInterests
select			distinct Email, A.Product_Acronym, A.Email_Acronym, Registration = cast (NULL as int), SourceCode = cast(NULL as int)
from			Users.dbo.Keyword_SourceCodeData A
					left outer join Users.dbo.Keyword_RegistrationData B
						on A.Email_Acronym = B.Email_Acronym
where			B.Email_Acronym is null

--select * from Users.dbo.Keyword_RegistrationData where Email_Acronym = 'sdevries@idtdna.com-MMTC'

update			A
set				Registration = 1
from			Users.dbo.Keyword_ExistingInterests A
					join Users.dbo.Keyword_RegistrationData B
						on A.Email_Acronym = B.Email_Acronym

update			Users.dbo.Keyword_ExistingInterests 
set				Registration = case when Registration is null then '0' else Registration end 


update			A
set				SourceCode = 1
from			Users.dbo.Keyword_ExistingInterests A
					join Users.dbo.Keyword_SourceCodeData B
						on A.Email_Acronym = B.Email_Acronym

update			Users.dbo.Keyword_ExistingInterests 
set				SourceCode = case when SourceCode is null then '0' else SourceCode end 

--select top 10 * from Users.dbo.Keyword_ExistingInterests

select distinct Registration from Users.dbo.Keyword_ExistingInterests
select top 2 * from Users.dbo.Keyword_SourceCodeData


select count(distinct Email) from Users.dbo.Keyword_ExistingInterests
--465,685
select count(distinct Email_Acronym) from Users.dbo.Keyword_ExistingInterests
--2,074,674


select count(distinct Email) from Users.dbo.Keyword_ExistingInterests 
where Registration = '1' and SourceCode = '0'
where SourceCode = '1' and Registration = '0'

select count(*) from Users.dbo.Keyword_ExistingInterests 


select distinct Email, Product_Acronym
from			Users.dbo.Keyword_ExistingInterests 
where			Registration = 0
and				SourceCode = 1
order by		Email, Product_Acronym 


------------------------------------------------------------------------------------
----- Get Multiple-Keyword Interests for Prospects EXCLUDING Registration Data -----
------------------------------------------------------------------------------------

select distinct A.Email, A.Email_Acronym, A.Product_Acronym, count(*) as Records
from			Users.dbo.Keyword_SourceCodeData A
					left outer join Users.dbo.Keyword_RegistrationData B
						on A.Email_Acronym = B.Email_Acronym
where			B.Email_Acronym is null
group by		A.Email, A.Email_Acronym, A.Product_Acronym
having			count(*) > 1
order by		A.Email, Records desc

--Excel File: Existing_Keyword_Interests_Count_byEmail_HighVolume_Apriori.csv

select * from Users.dbo.Keyword_SourceCodeData  where email = 'hans-martin.mueller@merck.com'
select * from Users.dbo.Keyword_RegistrationData where prospect_email = 'hans-martin.mueller@merck.com'

select * from Users.dbo.Keyword_SourceCodeData  where email = 'jmattis@formulapharma.com'
select * from Users.dbo.Keyword_RegistrationData where prospect_email = 'jmattis@formulapharma.com'

select * from Users.dbo.Keyword_SourceCodeData  where email = 'moshe@medison.co.il' order by modified desc
select * from Users.dbo.Keyword_RegistrationData where prospect_email = 'moshe@medison.co.il'

select * from Users.dbo.Keyword_SourceCodeData  where email = 'sue_tempest@merck.com' order by modified desc
select * from Users.dbo.Keyword_RegistrationData where prospect_email = 'sue_tempest@merck.com'


---------------------------------------------------------------------------------
------- Check Unique Combinations of Registration Email-PRODUCT Keyword ---------
---------------------------------------------------------------------------------

select distinct Email_Acronym, count(*) as Records
from			Users.dbo.Keyword_RegistrationData
group by		Email_Acronym
having			count(*) = '1'
--310,948


---------------------------------------------------------------------------------
-------- Check Unique Combinations of SourceCode Email-PRODUCT Keyword ----------
---------------------------------------------------------------------------------

select distinct Email_Acronym, count(*) as Records
from			Users.dbo.Keyword_SourceCodeData
group by		Email_Acronym
having			count(*) = '1'
--1,696,116


select * from chi.dbo.intkey where keyword = 'BNE'
select * from chi.dbo.intkey where keyword = 'W20'
select * from chi.dbo.intkey where keyword = 'W20'
select * from chi.dbo.intkey where keyword = 'PM2'
select * from chi.dbo.intkey where keyword = 'PH2'
select * from chi.dbo.intkey where keyword = 'PH42'
select * from chi.dbo.intkey where keyword = 'PHV'
select * from chi.dbo.intkey where keyword = 'reg'
select * from chi.dbo.intkey where keyword = 'dsf'
select * from chi.dbo.intkey where keyword = 'bnw'
select * from chi.dbo.intkey where keyword = 'mdx'
select * from chi.dbo.intkey where keyword = 'bit'



--------------------------------------------------------------------------------------------------
------- Generate Dataset for Association Analysis (Apriori Model) for Commercial Attendees -------
--------------------------------------------------------------------------------------------------

--select top 2 * from Users.dbo.Keyword_ExistingInterests
--select top 2 * from Users.dbo.Keyword_RegistrationData

alter table Users.dbo.Keyword_ExistingInterests 
add Commercial_Attendee int 
go
update		A
set			Commercial_Attendee = 1
from		Users.dbo.Keyword_ExistingInterests A	
				join Users.dbo.Keyword_RegistrationData B
					on a.Email = B.prospect_email
					and a.product_acronym = b.product_acronym
					and b.registration_subcategory = 'Attendee'
					and b.Revenue >= 100
					and b.registration_category like 'Commercial%'

update	Users.dbo.Keyword_ExistingInterests
set		Commercial_Attendee = case when Commercial_Attendee = 1 then Commercial_Attendee else 0 end

--select distinct Commercial_Attendee from Users.dbo.Keyword_ExistingInterests
--select distinct registration_subcategory, min(Revenue), max(Revenue), sum(revenue) from Users.dbo.Keyword_RegistrationData group by registration_subcategory
--select count(*) from Users.dbo.Keyword_ExistingInterests where category = '1' and registration = '1'

select distinct Email, Product_Acronym, count(*) as Records
from			Users.dbo.Keyword_ExistingInterests
where			Commercial_Attendee = 1
group by		Email, Product_Acronym
order by		Records desc
--select count(*) from Users.dbo.Keyword_ExistingInterests where Commercial_Attendee = 1
--74,216 (Unique Email_Product Combinations)

--ALL RECORDS
select distinct prospect_email as Email, Product_Acronym, count(*) as Records
from			Users.dbo.Keyword_RegistrationData
where			registration_subcategory = 'Attendee'
and				Revenue >= 100
and				registration_category like 'Commercial%'
group by		prospect_email, Product_Acronym
order by		Records desc

--58,361 (Unique Emails)
--select * from Users.dbo.Keyword_RegistrationData where prospect_email = 'p.caduff@elsevier.com' /*and Product_Acronym  = 'NRO'*/ order by Revenue desc
--select distinct registration_category, sum(revenue) as Rev from Users.dbo.Keyword_RegistrationData where registration_category like 'Commercial%' group by registration_category order by rev desc


-->1 Purchase RECORDS
select distinct prospect_email as Email, Product_Acronym, count(*) as Records
from			Users.dbo.Keyword_RegistrationData
where			registration_subcategory = 'Attendee'
and				Revenue >= 100
and				registration_category like 'Commercial%'
group by		prospect_email, Product_Acronym
having			count(*) > 1
order by		Records desc
--5,890


-----------------------------------------------------------------------------------
---- Create Dataset for Prospects Registering for High Volume Common Products -----
-----------------------------------------------------------------------------------

--Run Network Analysis for High Volume Overlapping Products

select distinct Product_Acronym, count(distinct prospect_email) as Emails
from			Users.dbo.Keyword_RegistrationData
where			registration_subcategory = 'Attendee'
and				Revenue >= 100
and				registration_category like 'Commercial%'
group by		Product_Acronym		
having			count(distinct prospect_email) > 100 
order by		Emails desc

select * from chi.dbo.intkey where keyword = 'AGI'

--Create Prospect to Keyword Predictor Based on Network Analysis