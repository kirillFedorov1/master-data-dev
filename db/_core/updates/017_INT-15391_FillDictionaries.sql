-- Заполнение справочника "Тип заявлений"
insert into onboarding.ApplicationType (Code, Title)
select
	s.Code as Code
	,s.Title as Title
from (
	values ('LA','Заявление на отпуск')
		,('AS','Произвольное заявление')
) as s (Code, Title)
	left join onboarding.ApplicationType as appt on appt.Code = s.Code
where appt.ID is null
