create or alter procedure onboarding.usp_BeforeSaveSalaryBonus
	@ID int
	,@DiffXML xml
	,@Type varchar(255)
as
begin try
	declare
		@EmployeeName varchar(255)
		,@MonthName varchar(255)
	--Проверка наличия регулярной выплаты 
	--Если рег. выплата на сотрудника в рамках одного периода уже есть, выдается ошибка

	--Если значения int и его еще нет, то приходит 0 -> обрабатывать как null
	--Если значение не изменилось, то приходит null -> обрабатывать как существующее
	--Если значение изменилось -> брать новое значение
	;with cte_SalaryBonusData as (
	select
		case isnull(d.n.value('(ID_Employee)[1]', 'int'), sb.ID_Employee)
			when 0 then null
			else isnull(d.n.value('(ID_Employee)[1]', 'int'), sb.ID_Employee)
		end as ID_Employee
		,case isnull(d.n.value('(ID_calendar_Month)[1]', 'int'), sb.ID_calendar_Month)
			when 0 then null
			else isnull(d.n.value('(ID_calendar_Month)[1]', 'int'), sb.ID_calendar_Month)
		end as ID_Month
		,case isnull(d.n.value('(ID_SalaryType)[1]', 'int'), sb.ID_SalaryType)
			when 0 then null
			else isnull(d.n.value('(ID_SalaryType)[1]', 'int'), sb.ID_SalaryType)
		end as ID_SalaryType
	from @DiffXml.nodes('/Record') as d(n)
		left join onboarding.SalaryBonus as sb on sb.ID_Employee = @ID
	)
	select
		@EmployeeName = e.FullName
		,@MonthName = m.LongName
	from cte_SalaryBonusData as sbd
		inner join onboarding.SalaryBonus as sb on sb.ID_Employee = sbd.ID_Employee
			and sb.ID_calendar_Month = sbd.ID_Month
			and sb.ID_SalaryType = sbd.ID_SalaryType
		inner join onboarding.Employee as e on sb.ID_Employee = e.ID
		inner join calendar.Month as m on sb.ID_calendar_Month = m.ID
		inner join onboarding.SalaryType as st on sb.ID_SalaryType = st.ID
	where st.Code = 'Reg'

	if @EmployeeName is not null
		and @MonthName is not null
	begin
		raiserror('Регулярная выплата на сотрудника %s за месяц %s уже имеется', 2, 1, @EmployeeName, @MonthName)

		return
	end
end try
begin catch
	;throw
end catch
