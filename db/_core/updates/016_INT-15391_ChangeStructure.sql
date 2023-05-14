--Тип заявлений
if Object_ID('onboarding.ApplicationType') is null
begin
	create table onboarding.ApplicationType (ID int not null identity(1,1))
	alter table onboarding.ApplicationType add constraint PK_ApplicationType primary key clustered(ID)
	alter table onboarding.ApplicationType add Code varchar(255) not null
	alter table onboarding.ApplicationType add constraint UK_ApplicationType_Code unique (Code)
	alter table onboarding.ApplicationType add Title varchar(255) not null
	alter table onboarding.ApplicationType add MDT_DateCreate datetime not null
	alter table onboarding.ApplicationType add constraint DF_ApplicationType_MDT_DateCreate default getdate() for MDT_DateCreate
	alter table onboarding.ApplicationType add MDT_ID_PrincipalCreatedBy int not null
	alter table onboarding.ApplicationType add constraint FK_ApplicationType_MDT_ID_PrincipalCreatedBy_Principal foreign key (MDT_ID_PrincipalCreatedBy) references mdt.Principal(ID)
	alter table onboarding.ApplicationType add constraint DF_ApplicationType_MDT_ID_PrincipalCreatedBy default mdt.ID_User() for MDT_ID_PrincipalCreatedBy
end

--Ссылка на таблицу Тип заявлений
exec mdt.usp_SafeAddColumn
	@Table = 'onboarding.Application'
	,@Column = 'ID_ApplicationType'
	,@Type = 'int'
	,@RefTable = 'onboarding.ApplicationType'
	,@FlagRequired = 1

--Дата начала отпуска
exec mdt.usp_SafeAddColumn
	@Table = 'onboarding.Application'
	,@Column = 'DateBegin'
	,@Type = 'date'
	,@FlagRequired = 0

--Дата окончания отпуска
exec mdt.usp_SafeAddColumn
	@Table = 'onboarding.Application'
	,@Column = 'DateEnd'
	,@Type = 'date'
	,@FlagRequired = 0
