--Временная таблица для загрузки премий
if Object_ID('onboarding.sa_SalaryBonus') is null
begin
	create table onboarding.sa_SalaryBonus (ID int not null identity(1,1))
	alter table onboarding.sa_SalaryBonus add Employee varchar(255) null
	alter table onboarding.sa_SalaryBonus add Position varchar(255) null
	alter table onboarding.sa_SalaryBonus add SalaryType varchar(255) null
	alter table onboarding.sa_SalaryBonus add Payroll decimal(18, 2) null
end