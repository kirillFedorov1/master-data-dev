create or alter view onboarding.vw_BillNotification
as
select 1 as ID
go

declare @ID_Module int = (select ID from ver.[Module] where Code = 'onboarding')
	,@ID_LabelStyle int = (select ID from mdt.LabelStyle where Code = 'info')

-- Событие отправки уведомления о зарплатной ведомости
insert into mdt.Event(Title, ID_LogType, ID_Module, ID_ObjectTarget)
select
	s.Title as Title
	,s.ID_LogType as ID_LogType
	,s.ID_Module as ID_Module
	,o.ID as ID_ObjectTarget
from (
	values ('Bill notification', @ID_LabelStyle, @ID_Module)
) as s (Title, ID_LogType, ID_Module)
	left join mdt.Object as o on o.ID_ver_Module = s.ID_Module
		and o.Code = 'onboarding.Bill'
	left join mdt.Event as e on e.Title = s.Title
		and e.ID_Module = s.ID_Module
		and e.ID_ObjectTarget = o.ID
where e.Title is null

-- Шаблон уведомления о зарплатной ведомости
insert into mdt.Template (Code, Title, ID_ver_Module)
select
	s.Code as Code
	,s.Title as Title
	,s.ID_ver_Module as ID_ver_Module
from (
	values ('onboarding.BillNotification', 'Уведомление об автоматическом расчете зарплатной ведомости', @ID_Module)
) as s (Code, Title, ID_ver_Module)
	left join mdt.Template as t on t.Code = s.Code
where t.Code is null

-- Таблица связи шаблона и представления для авторасчета
insert into ntf.NotificationSource (ID_mdt_ObjectSource, ID_mdt_Template, ID_NotificationType)
select
	mdt.ID_Object('onboarding.vw_BillNotification') as ID_mdt_ObjectSource
	,t.ID as ID_mdt_Template
	,nt.ID as ID_NotificationType
from mdt.Template as t
	inner join ntf.NotificationType as nt on nt.Code = 'Event'
	left join ntf.NotificationSource as ns on ns.ID_mdt_ObjectSource = ID_mdt_ObjectSource
		and ns.ID_mdt_Template = t.ID
		and ns.ID_NotificationType = nt.ID
where t.Code = 'onboarding.BillNotification'
	and ns.ID is null

--настройки почтового сервера
update s
set Value = case

			when Code = 'mdti.ntf.mail.host'
				then 'smtp.yandex.ru'
			when Code = 'mdti.ntf.mail.address'
				then 'mdrbics@yandex.ru'
			when Code = 'mdti.ntf.mail.login'
				then 'mdrbics@yandex.ru'
			when Code = 'mdti.ntf.mail.password'
				then '123zxc%%%73'
			when Code = 'mdti.ntf.mail.enableSSL'
				then 'true'
			when Code = 'mdti.ntf.mail.port'
				then '465'

			when Code = 'mail.login'
				then 'mdrbics@yandex.ru'
			when Code = 'mail.address'
				then 'mdrbics@yandex.ru'
			when Code = 'mail.password'
				then '123zxc%%%73'
			when Code = 'mail.smtpserver'
				then 'smtp.yandex.ru:587'
			else Value
		end
from mdt.Settings as s

--рабочий инстанс
insert into mdt.GlobalVar(Code, Value, Description)
select
	s.Code as Code
	,s.Value as Value
	,s.Description as Description
from (
	values ('mdtUrl', 'https://stage2.ics-it.ru/onboarding/dev_4', 'URL инстанса')
) as s (Code, Value, Description)
	left join mdt.GlobalVar as gv on gv.Code = s.Code
where gv.Code is null
