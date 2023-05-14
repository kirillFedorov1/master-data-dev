insert into mdt.Principal (Code, Title, ID_PrincipalType)
select
	pr.Code
	,pr.Title
	,pr.ID_PrincipalType
from (
		values ('EmployeeManagement', 'Управление сотрудниками', 'r')
	)  as pr (Code, Title, ID_PrincipalType)
	left join mdt.Principal as p on p.Code = pr.Code
where p.ID is null

exec mdt.usp_SetPermission @PrincipalCode = 'EmployeeManagement', @ObjectCode = 'onboarding.Employee', @Permission = 'RWDA', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'EmployeeManagement', @ObjectCode = 'onboarding.Application', @Permission = 'RWDA', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'EmployeeManagement', @ObjectCode = 'onboarding.Vacation', @Permission = 'RWDA', @Override = 1
exec mdt.usp_SetPermission @PrincipalCode = 'EmployeeManagement', @ObjectCode = 'onboarding.Position', @Permission = 'R', @Override = 1
