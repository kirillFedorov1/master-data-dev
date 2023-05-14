--Проставление статуса "Утверждено сотрудником" существующим записям
update b
set ID_status_Status = s.ID
from onboarding.Bill as b
	inner join status.Status as s on s.Code = 'onboarding.Bill.APRV'
