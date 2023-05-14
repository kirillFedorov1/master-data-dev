create or alter procedure onboarding.usp_BeforeDeleteEmployee
	@ID int
	,@pbConfirmDelete bit
as
begin try
	declare
		@Employee varchar(255)
		,@Message varchar(255)

	if not exists (select 1 from mdt.Principals(mdt.ID_User()) where Code = 'administrators')
		and (isnull(@pbConfirmDelete, 0) = 0)
	begin
		select @Employee = FullName
		from onboarding.Employee
		where ID = @ID

		select @Message = 'Вы уверены, что хотите удалить сотрудника ' + @Employee + '?'

		select
			'Да' as [$Title]
			,'danger' as [$Type]
			,'pbConfirmDelete' as [$Param]
			,'true' as [$ParamValue]
			
		raiserror(@Message, 2, 1)
		return
	end
end try
begin catch
	;throw
end catch
