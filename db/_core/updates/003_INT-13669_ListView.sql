insert into mdt.ListView (FlagShared, Title, ID_Object, MDT_ID_PrincipalCreatedBy, Settings, Code)
select
	s.FlagShared
	,s.Title
	,s.ID_Object
	,s.MDT_ID_PrincipalCreatedBy
	,s.Settings
	,s.Code
from (
		values (1, 'Дни рождения', mdt.ID_Object('onboarding.Employee'), -1, '{"sorting":[],"columnOrder":["FullName","Birthday","DateEmployment","DateDismissal","Statement_o2m/Text","Vacation_o2m$","Position_hist/ID_Position$","FlagWorking_o2o$"],"hiddenColumns":["DateEmployment","DateDismissal","Statement_o2m/Text","Vacation_o2m$","Position_hist/ID_Position$"]}', 4)
	) as s (FlagShared, Title, ID_Object, MDT_ID_PrincipalCreatedBy, Settings, Code)
	left join mdt.ListView as l on l.Title = s.Title
		and l.ID_Object = s.ID_Object
where l.ID is null
