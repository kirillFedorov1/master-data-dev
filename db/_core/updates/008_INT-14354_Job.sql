create or alter procedure onboarding.usp_InsertMonthPeriod
as select 1
go

create or alter procedure onboarding.usp_CalculateSalary
as select 1
go

--Установка даты начала генерации календаря
update p
--Берется 6 месяцев до текущей даты
set Value = cast(dateadd(month, -6, getdate()) as date)
from sync.Parameter as p
where p.Code = 'DateBegin'

--Синхронизация календаря немедленно
exec job.usp_Start 'calendar.sync'

--Синхронизация таблицы с параметрами по расписанию
exec job.usp_AddTask
	@Code = 'InsertMonthPeriod'
	,@Procedure = 'onboarding.usp_InsertMonthPeriod'
	,@Title = 'Заполнение настроечной таблицы с месяцами'
	,@Force = 1
	,@FlagActive = 1
	,@RunPeriod = 'M'
	,@RunEvery = 1
	,@StartTime = '2023-02-04 12:00'
	,@Module = 'onboarding'

--Синхронизация таблицы с параметрами немедленно
exec job.usp_Start 'InsertMonthPeriod'

--Создание службы для расчета зарплаты
exec job.usp_AddTask
	@Code = 'CalculateSalary'
	,@Procedure = 'onboarding.usp_CalculateSalary'
	,@Title = 'Расчёт оклада и премий за указанный месяц'
	,@Params = 'onboarding.MonthPeriod'
	,@FlagActive = 1
	,@RunPeriod = 'M'
	,@RunEvery = 1
	,@StartTime = '2023-02-05 12:00'
	,@Module = 'onboarding'

