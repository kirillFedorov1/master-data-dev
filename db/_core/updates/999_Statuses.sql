--Статусы для зарплатных ведомостей
insert into status.Status (Code, ID_Object, Name, ID_LabelStyle)
select
	s.Code as Code
	,o.ID as ID_Object
	,s.Name as Name
	,ls.ID as ID_LabelStyle
from (
	values
		('onboarding.bill.CALC', 'onboarding.Bill', 'Рассчитано', 'info')
		,('onboarding.bill.APRV', 'onboarding.Bill', 'Утверждено сотрудником', 'success')
		,('onboarding.bill.RJCT', 'onboarding.Bill', 'Отклонено сотрудником', 'danger')
		,('onboarding.bill.AUTOAPRV', 'onboarding.Bill', 'Утверждено автоматически', 'success')
	) as s (Code, Object, Name, LabelStyle)
	inner join mdt.Object as o on o.Code = s.Object
	inner join mdt.LabelStyle as ls on ls.Code = s.LabelStyle
	left join status.Status as s_mdt on s_mdt.Code = s.Code
where s_mdt.ID is null

--Переходы статусов
insert into status.Status_NextStatus (ID_StatusFrom, ID_StatusTo, ID_Principal, FlagCommentAvailable, FlagCommentRequired)
select
	sf.ID as ID_StatusFrom
	,st.ID as ID_StatusTo
	,p.ID as ID_Principal
	,sns.FlagCommentAvailable as FlagCommentAvailable
	,sns.FlagCommentRequired as FlagCommentRequired
from (
	values
		('onboarding.bill.CALC', 'onboarding.bill.APRV', 'employee', 1, 0)
		,('onboarding.bill.CALC', 'onboarding.bill.RJCT', 'employee', 1, 1)
		,('onboarding.bill.APRV', 'onboarding.bill.CALC', 'employee', 1, 1)
		,('onboarding.bill.RJCT', 'onboarding.bill.CALC', 'employee', 1, 1)
		,('onboarding.bill.CALC', 'onboarding.bill.APRV', 'administrators', 1, 0)
		,('onboarding.bill.CALC', 'onboarding.bill.RJCT', 'administrators', 1, 1)
		,('onboarding.bill.APRV', 'onboarding.bill.CALC', 'administrators', 1, 1)
		,('onboarding.bill.RJCT', 'onboarding.bill.CALC', 'administrators', 1, 1)
		,('onboarding.bill.AUTOAPRV', 'onboarding.bill.CALC', 'employee', 1, 1)
		,('onboarding.bill.AUTOAPRV', 'onboarding.bill.CALC', 'administrators', 1, 1)
	) as sns (StatusFrom, StatusTo, Principal, FlagCommentAvailable, FlagCommentRequired)
	inner join status.Status as sf on sf.Code = sns.StatusFrom
	inner join status.Status as st on st.Code = sns.StatusTo
	inner join mdt.Principal as p on p.Code = sns.Principal
	left join status.Status_NextStatus as sns_mdt on sns_mdt.ID_StatusFrom = sf.ID
		and sns_mdt.ID_StatusTo = st.ID
		and sns_mdt.ID_Principal = p.ID
where sns_mdt.ID_StatusFrom is null
	and sns_mdt.ID_StatusTo is null
	and sns_mdt.ID_Principal is null
