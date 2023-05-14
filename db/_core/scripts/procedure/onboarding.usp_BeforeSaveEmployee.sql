create or alter procedure onboarding.usp_BeforeSaveEmployee
	@ID int
	,@DiffXML xml
	,@Type varchar(255)
as
begin try
	declare
		@Birthday date
		,@DateEmployment date
		,@DateDismissal date

	select
		@Birthday = coalesce(
			d.n.value('(Birthday)[1]', 'date')
			,e.Birthday
		)

		,@DateEmployment = coalesce(
			d.n.value('(DateEmployment)[1]', 'date')
			,e.DateEmployment
			--Текущая дата также проставляется в DateEmployment в usp_AfterSaveEmployee,
			--если DateEmployment не задана пользователем
			,cast(getdate() as date)
		)

		,@DateDismissal = coalesce(
			--При стирании дат в mdt проставляется '1900-01-01'
			iif(
				d.n.value('(DateDismissal)[1]', 'date') = '1900-01-01'
				,'2100-01-01'
				,d.n.value('(DateDismissal)[1]', 'date')
			)
			,e.DateDismissal
			,'2100-01-01'
		)
	from @DiffXML.nodes('/Record') as d(n)
		left join onboarding.Employee as e on e.ID = @ID

	if @DateDismissal < @Birthday
	begin
		raiserror('Дата увольнения не может быть раньше даты рождения', 2, 1)
		return
	end

	if @DateDismissal < @DateEmployment
	begin	
		raiserror('Дата увольнения не может быть раньше даты приема на работу', 2, 1)
		return
	end
end try
begin catch
	;throw
end catch
