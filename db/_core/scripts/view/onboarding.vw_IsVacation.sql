create or alter view onboarding.vw_IsVacation
as
select
	a.ID as ID_Application
	,iif(at.Code = 'LA', 1, 0) as FlagVacation
from onboarding.Application as a
	inner join onboarding.ApplicationType as at on at.ID = a.ID_ApplicationType
