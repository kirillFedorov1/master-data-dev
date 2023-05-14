create or alter procedure onboarding.usp_AfterSaveEmployee
	@ID int
	,@Type varchar(255)
as
begin try
	declare
		@CurrentDate date = cast(getdate() as date)
		
	if @Type = 'Insert'
	begin
		insert into onboarding.Position_Employee (ID_Employee, ID_Position, DateBegin, DateEnd)
		select 
			e.ID as ID_Employee
			,p.ID as ID_Position
			,coalesce(e.DateEmployment, @CurrentDate) as DateBegin
			,coalesce(e.DateDismissal, '2100-01-01') as DateEnd
		from onboarding.Employee e
			left join onboarding.Position_Employee p_e on p_e.ID_Employee = e.ID
			inner join onboarding.Position as p on p.Code = 'SOP_DEV'
		where e.ID = @ID 
			and p_e.ID is null

		update e
		set DateEmployment = @CurrentDate
		from onboarding.Employee as e
		where e.ID = @ID 
			and e.DateEmployment is null
	end
end try
begin catch
	;throw
end catch
