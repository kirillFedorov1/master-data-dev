-- Зарплатная ведомость
if object_id('onboarding.Bill') is null
begin
	create table onboarding.Bill (ID int not null identity(1, 1))
	alter table onboarding.Bill add constraint PK_Bill primary key clustered (ID)
	alter table onboarding.Bill add ID_calendar_Month int not null
	alter table onboarding.Bill add constraint FK_Bill_ID_calendar_Month_Month foreign key (ID_calendar_Month) references calendar.Month(ID)
	alter table onboarding.Bill add ID_Employee int not null
	alter table onboarding.Bill add constraint FK_Bill_ID_Employee_Employee foreign key (ID_Employee) references onboarding.Employee(ID)
	alter table onboarding.Bill add Salary decimal(18, 2) null
	alter table onboarding.Bill add Bonus decimal(18, 2) null
	alter table onboarding.Bill add Total decimal(18, 2) null
	alter table onboarding.Bill add MDT_DateCreate datetime not null
	alter table onboarding.Bill add constraint DF_Bill_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.Bill add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.Bill add constraint FK_Bill_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.Bill add constraint DF_Bill_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- Справочник Тип начислений
if object_id('onboarding.SalaryType') is null
begin
	create table onboarding.SalaryType (ID int not null identity(1, 1))
	alter table onboarding.SalaryType add constraint PK_SalaryType primary key clustered (ID)
	alter table onboarding.SalaryType add Code varchar(255) not null
	alter table onboarding.SalaryType add constraint UK_SalaryType unique (Code)
	alter table onboarding.SalaryType add Title varchar(255) not null
	alter table onboarding.SalaryType add MDT_DateCreate datetime not null
	alter table onboarding.SalaryType add constraint DF_SalaryType_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.SalaryType add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.SalaryType add constraint FK_SalaryType_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.SalaryType add constraint DF_SalaryType_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- Дополнительные начисления
if object_id('onboarding.SalaryBonus') is null
begin
	create table onboarding.SalaryBonus (ID int not null identity(1, 1))
	alter table onboarding.SalaryBonus add constraint PK_SalaryBonus primary key clustered (ID)
	alter table onboarding.SalaryBonus add ID_calendar_Month int not null
	alter table onboarding.SalaryBonus add constraint FK_SalaryBonus_ID_calendar_Month_Month foreign key (ID_calendar_Month) references calendar.Month(ID)
	alter table onboarding.SalaryBonus add Payroll decimal(18, 2) not null
	alter table onboarding.SalaryBonus add ID_SalaryType int not null
	alter table onboarding.SalaryBonus add constraint FK_SalaryBonus_ID_SalaryType_SalaryType foreign key (ID_SalaryType) references onboarding.SalaryType(ID)
	alter table onboarding.SalaryBonus add ID_Employee int not null
	alter table onboarding.SalaryBonus add constraint FK_SalaryBonus_ID_Employee_Employee foreign key (ID_Employee) references onboarding.Employee(ID)
	alter table onboarding.SalaryBonus add Comment varchar(255) null
	alter table onboarding.SalaryBonus add MDT_DateCreate datetime not null
	alter table onboarding.SalaryBonus add constraint DF_SalaryBonus_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.SalaryBonus add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.SalaryBonus add constraint FK_SalaryBonus_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.SalaryBonus add constraint DF_SalaryBonus_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- Таблица с параметрами для запуска расчета зарплатных ведомостей
if object_id('onboarding.MonthPeriod') is null
begin
	create table onboarding.MonthPeriod (ID int not null identity(1, 1))
	alter table onboarding.MonthPeriod add constraint PK_MonthPeriod primary key clustered (ID)
	alter table onboarding.MonthPeriod add ID_calendar_Month int not null
	alter table onboarding.MonthPeriod add constraint FK_MonthPeriod_ID_calendar_Month_Month foreign key (ID_calendar_Month) references calendar.Month(ID)
	alter table onboarding.MonthPeriod add MDT_DateCreate datetime not null
	alter table onboarding.MonthPeriod add constraint DF_MonthPeriod_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.MonthPeriod add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.MonthPeriod add constraint FK_MonthPeriod_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.MonthPeriod add constraint DF_MonthPeriod_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- поле Оклад в таблице Должность
exec mdt.usp_SafeAddColumn
	@Table = 'onboarding.Position'
	,@Column = 'Salary'
	,@Type = 'decimal(18, 2)'

-- поле Руководитель в таблице Сотрудник
exec mdt.usp_SafeAddColumn
	@Table = 'onboarding.Employee'
	,@Column = 'ID_Supervisor'
	,@Type = 'int'
	,@RefTable = 'onboarding.Employee'
