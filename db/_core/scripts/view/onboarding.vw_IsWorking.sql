-- View для вычисления факта работы сотрудника
create or alter view onboarding.vw_IsWorking
as
select e.ID as ID_Employee
	,cast(iif(cast(getdate() as date) between e.DateEmployment and isnull(e.DateDismissal, '2100-01-01'), 1, 0) as bit) as FlagWorking
from onboarding.Employee as e
