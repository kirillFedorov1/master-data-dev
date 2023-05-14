if not exists (select 1 from sys.schemas where name = 'onboarding')
begin
	exec('create schema onboarding');
end

-- Создание справочника "Сотрудники"
if object_id('onboarding.Employee') is null
begin
	create table onboarding.Employee (ID int not null identity(1,1))
	alter table onboarding.Employee add constraint PK_Employee primary key clustered(ID)
	alter table onboarding.Employee add EmployeeNumber as ('E' + cast(ID as varchar(255))) persisted;
	alter table onboarding.Employee add FullName varchar(255) not null
	alter table onboarding.Employee add Birthday date not null
	alter table onboarding.Employee add DateEmployment date null
	alter table onboarding.Employee add DateDismissal date null
	alter table onboarding.Employee add MDT_DateCreate datetime not null
	alter table onboarding.Employee add constraint DF_Employee_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.Employee add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.Employee add constraint FK_Employee_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.Employee add constraint DF_Employee_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- Создание справочника "Должность"
if object_id('onboarding.Position') is null
begin
	create table onboarding.Position (ID int not null identity(1,1))
	alter table onboarding.Position add constraint PK_Position primary key clustered(ID)
	alter table onboarding.Position add Code varchar(255) not null
	alter table onboarding.Position add constraint UK_Position_Code unique (Code)
	alter table onboarding.Position add Title varchar(255) not null
	alter table onboarding.Position add MDT_DateCreate datetime not null
	alter table onboarding.Position add constraint DF_Position_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.Position add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.Position add constraint FK_Position_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.Position add constraint DF_Position_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- Таблица связи между сотрудниками и должностями
if object_id('onboarding.Position_Employee') is null
begin
	create table onboarding.Position_Employee (ID int not null identity(1,1))
	alter table onboarding.Position_Employee add constraint PK_Position_Employee primary key clustered(ID)
	alter table onboarding.Position_Employee add ID_Employee int not null
	alter table onboarding.Position_Employee add constraint FK_Position_Employee_ID_Employee_Employee foreign key (ID_Employee) references onboarding.Employee(ID)
	alter table onboarding.Position_Employee add ID_Position int not null
	alter table onboarding.Position_Employee add constraint FK_Position_Employee_ID_Position_Position foreign key (ID_Position) references onboarding.Position(ID)
	alter table onboarding.Position_Employee add DateBegin date null
	alter table onboarding.Position_Employee add DateEnd date null
	alter table onboarding.Position_Employee add MDT_DateCreate datetime not null
	alter table onboarding.Position_Employee add constraint DF_Position_Employee_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.Position_Employee add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.Position_Employee add constraint FK_Position_Employee_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.Position_Employee add constraint DF_Position_Employee_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- Создание таблицы "Заявления"
if object_id('onboarding.Application') is null
begin
	create table onboarding.Application (ID int not null identity(1,1))
	alter table onboarding.Application add constraint PK_Application primary key clustered(ID)
	alter table onboarding.Application add ID_Employee int not null
	alter table onboarding.Application add constraint FK_Application_ID_Employee_Employee foreign key (ID_Employee) references onboarding.Employee(ID)
	alter table onboarding.Application add [Date] date not null
	alter table onboarding.Application add Text varchar(5000) not null
	alter table onboarding.Application add MDT_DateCreate datetime not null
	alter table onboarding.Application add constraint DF_Application_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.Application add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.Application add constraint FK_Application_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.Application add constraint DF_Application_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

-- Создание таблицы "Отпуска"
if object_id('onboarding.Vacation') is null
begin
	create table onboarding.Vacation (ID int not null identity(1,1))
	alter table onboarding.Vacation add constraint PK_Vacation primary key clustered(ID)
	alter table onboarding.Vacation add ID_Employee int not null
	alter table onboarding.Vacation add constraint FK_Vacation_ID_Employee_Employee foreign key (ID_Employee) references onboarding.Employee(ID)
	alter table onboarding.Vacation add DateBegin date not null
	alter table onboarding.Vacation add DateEnd date not null
	alter table onboarding.Vacation add MDT_DateCreate datetime not null
	alter table onboarding.Vacation add constraint DF_Vacation_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.Vacation add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.Vacation add constraint FK_Vacation_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.Vacation add constraint DF_Vacation_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end