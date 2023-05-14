insert into mdt.NamedFilter (FlagShared, Title, ID_Object, MDT_ID_PrincipalCreatedBy, Settings, Code)
select 
	s.FlagShared
	,s.Title
	,s.ID_Object
	,s.MDT_ID_PrincipalCreatedBy
	,s.Settings
	,s.Code
from (
	values (1, 'Работает', mdt.ID_Object('onboarding.Employee'), -1, '{"extended":{"op":"and","groups":[{"p1":"FlagWorking_o2o","p2":true,"op":"eq","type":"boolean","$table":"Filter"}],"$table":"FilterGroup"}}', 'onboarding.WorkingFilter')
) as s (FlagShared, Title, ID_Object, MDT_ID_PrincipalCreatedBy, Settings, Code)
	left join mdt.NamedFilter as l on l.Code = s.Code
		and l.ID_Object = s.ID_Object
where l.ID is null
