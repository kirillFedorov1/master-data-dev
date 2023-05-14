--Данные для уведомлений об авторасчете зарплаты
create or alter view onboarding.vw_BillNotification
as
select
	eqb.ID_mdt_Principal as ID_PrincipalTo
	,p.Email as EmailTo
	,eqb.ID_mdt_Event as [Event]
	,m.LongName as EventTime
	,eqb.ID_RecordTarget as ID_Record
from ntf.EventQueueBuffer as eqb
	inner join mdt.Principal as p on p.ID = eqb.ID_mdt_Principal
	inner join onboarding.Bill as b on b.ID = eqb.ID_RecordTarget
	inner join calendar.Month as m on m.ID = b.ID_calendar_Month
