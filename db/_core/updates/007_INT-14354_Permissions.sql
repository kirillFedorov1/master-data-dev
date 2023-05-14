insert into mdt.Principal (Code, Title, ID_PrincipalType)
select
	v.Code
	,v.Title
	,v.ID_PrincipalType
from (
	values
		('employee', 'Сотрудник', 'r')
) as v (Code, Title, ID_PrincipalType)
	left join mdt.Principal as mp on mp.Code = v.Code
where mp.Code is null

exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'onboarding.Employee', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'onboarding.Application', @Permission = 'RW', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'onboarding.Position', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'onboarding.Bill', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'onboarding.SalaryType', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'onboarding.SalaryBonus', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'onboarding.MonthPeriod', @Permission = 'RW', @Override = 1

exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'calendar.Month', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.History', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.Schedule', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.ScheduleType', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.ScheduleType_ext', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.Status', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.Task', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.Type', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.Type_ext', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.XNotification', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.XNotificationRecipient', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.XSP', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.XSP', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.XSPType', @Permission = 'R', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'employee', @ObjectCode = 'job.XTemplate', @Permission = 'R', @Override = 1