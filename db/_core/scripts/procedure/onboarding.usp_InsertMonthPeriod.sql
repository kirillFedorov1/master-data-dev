create or alter procedure onboarding.usp_InsertMonthPeriod
as
begin
	truncate table onboarding.MonthPeriod
	
	insert into onboarding.MonthPeriod (ID_calendar_Month)
	select m.ID
	from calendar.Month as m
end
