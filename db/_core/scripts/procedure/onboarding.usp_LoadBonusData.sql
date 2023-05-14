--Загрузка информации о премиях из внешнего файла
create or alter procedure onboarding.usp_LoadBonusData
as
set nocount on
begin try
	--Загружается в первые 5 дней каждого месяца
	if (day(getdate()) <= 5)
	begin
		merge onboarding.SalaryBonus as sb
		using (
			select
				cm.ID as ID_calendar_Month
				,e.ID as ID_Employee
				,st.ID as ID_SalaryType
				,sa.SalaryType AS SalaryType
				,isnull(cast(sa.Payroll as decimal(18,2)), 0) as Payroll
				,'Автоматически загружено' as Comment
			from onboarding.sa_SalaryBonus as sa
				inner join onboarding.Employee as e on e.EmployeeNumber = sa.Employee
				inner join onboarding.SalaryType as st on st.Code = sa.SalaryType
				--Сотрудник не уволен
				inner join onboarding.vw_IsWorking as iw on iw.ID_Employee = e.ID
					and iw.FlagWorking = 1
				--Прошлый месяц
				inner join calendar.Month as cm on cm.ID = cast(convert(varchar(6), dateadd(mm, -1, getdate()), 112) as int)
				--Должность привязана к сотруднику в месяц загрузки
				inner join onboarding.Position_Employee as pe on pe.ID_Employee = e.ID
					and pe.DateBegin <= cm.DateEnd
					and pe.DateEnd >= cm.DateBegin
				inner join onboarding.Position as p on p.ID = pe.ID_Position
					and p.Code = sa.Position
			--Премия не отрицательная и не пустая
			where isnull(sa.Payroll, 0) > 0
		) as s on s.ID_calendar_Month = sb.ID_calendar_Month
			and s.ID_Employee = sb.ID_Employee
			and s.ID_SalaryType = sb.ID_SalaryType
			and s.SalaryType = 'Reg'
		--Обновить регулярную выплату за месяц
		when matched then
			update
			set
				sb.Payroll = s.Payroll
				,sb.Comment = s.Comment
		--Добавить разовую выплату за месяц / добавить регулярную, если еще не имеется
		when not matched then
			insert (ID_calendar_Month, ID_Employee, Payroll, ID_SalaryType, Comment)
			values (s.ID_calendar_Month, s.ID_Employee, s.Payroll, s.ID_SalaryType, s.Comment);
	end
end try
begin catch
	;throw
end catch