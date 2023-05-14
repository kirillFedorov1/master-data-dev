--Заполнение справочника Тип начислений
insert into onboarding.SalaryType (Code, Title)
select
	st.Code
	,st.Title
from (
	values
		('Reg', 'Регулярное')
		,('OneTime', 'Разовое')
) as st (Code, Title)
	left join onboarding.SalaryType as st_mdt on st_mdt.Code = st.Code
where st_mdt.ID is null
