create or alter procedure onboarding.usp_CalculateSalary
	@ID_Params int = null
as
begin try
	declare
		@ID_Month int
		,@ID_status_CALC int = status.ID_Status('onboarding.Bill', 'onboarding.Bill.CALC')
		,@ID_status_RJCT int = status.ID_Status('onboarding.Bill', 'onboarding.Bill.RJCT')
		,@ID_status_AUTOAPRV int = status.ID_Status('onboarding.Bill', 'onboarding.Bill.AUTOAPRV')

	if exists (
		select 1
		from mdt.Principal
		where Code = 'system' or Code = 'etl'
			and ID = mdt.ID_ImpersonateUser()
	)
	begin
		--Запускается в фоне и берется предыдущий месяц
		set @ID_Month = (
			select m.ID
			from calendar.Month as m
			where cast(dateadd(month, -1, getdate()) as date) between m.DateBegin and m.DateEnd
		)
	end
	else
	begin
		--Запускаем вручную и выбираем месяц
		set @ID_Month = (
			select mp.ID_calendar_Month
			from onboarding.MonthPeriod as mp
			where mp.ID = @ID_Params
		)
	end

	if @ID_Month is not null
	begin
		create table #status_update (ID_Record int null, ID_newStatus int null, ID_oldStatus int null)

		--Активные сотрудники
		;with cte_ActiveEmployee as (
			select
				e.ID as ID_Employee
			from onboarding.Employee as e
				inner join calendar.Month as m on m.ID = @ID_Month
				left join onboarding.Bill as b on b.ID_Employee = e.ID
				left join status.Status as s on s.ID = b.ID_status_Status
			where e.DateEmployment <= m.DateEnd
				and isnull(e.DateDismissal, '2100-01-01') >= m.DateBegin
				and (
					--Статусы Рассчитано и Отклонено сотрудником
					s.Code in ('onboarding.bill.CALC', 'onboarding.bill.RJCT')
						--Ведомость не создана
						or b.ID_status_Status is null
				)
		)
		--Оклад
		,cte_salary as (
			select
				ae.ID_Employee as ID_Employee
				,p.Salary as Salary
				--Нумерация должностей сотрудника, от последней по времени
				,row_number() over (partition by ae.ID_Employee order by pe.DateBegin desc) as PosHist
			from cte_ActiveEmployee as ae
				inner join onboarding.Position_Employee as pe on pe.ID_Employee = ae.ID_Employee
				inner join onboarding.Position as p on p.ID = pe.ID_Position
				inner join calendar.Month as m on m.ID = @ID_Month
			where pe.DateBegin <= m.DateEnd
				and pe.DateEnd >= m.DateBegin
		)
		--Последнее регулярное доп. начисление (пролонгируется на текущий месяц)
		,cte_SalaryBonusReg as (
			select
				ae.ID_Employee as ID_Employee
				,sb.Payroll as Payroll
				--Нумерация регулярных доп. начислений, от последнего по времени
				,row_number() over (partition by ae.ID_Employee order by m.DateBegin desc) as PayrollHist
			from cte_ActiveEmployee as ae
				inner join onboarding.SalaryBonus as sb on sb.ID_Employee = ae.ID_Employee
				inner join onboarding.SalaryType as st on st.ID = sb.ID_SalaryType
				-- месяц рег. начисления
				inner join calendar.Month as m on m.ID = sb.ID_calendar_Month
				-- месяц расчета
				inner join calendar.Month as calcm on calcm.ID = @ID_Month
			-- регулярные начисления
			where st.Code = 'Reg'
				and sb.Payroll is not null
				and m.DateBegin <= calcm.DateEnd
		)
		--Все разовые доп. начисления за месяц
		,cte_SalaryBonusOnetime as (
			select
				ae.ID_Employee as ID_Employee
				,sum(sb.Payroll) as Payroll
			from cte_ActiveEmployee as ae
				inner join onboarding.SalaryBonus as sb on sb.ID_Employee = ae.ID_Employee
				inner join onboarding.SalaryType as st on st.ID = sb.ID_SalaryType
				inner join calendar.Month as m on m.ID = @ID_Month
			where sb.ID_calendar_Month = @ID_Month
				--разовые начисления
				and st.Code = 'OneTime'
			group by ae.ID_Employee
		)
		--Расчёт оклада и премий за указанный месяц
		merge onboarding.Bill as b
		using (
			select
				s.ID_Employee as ID_Employee
				,s.Salary as Salary
				,isnull(sbr.Payroll, 0) + isnull(sbo.Payroll, 0) as SalaryBonus
				,s.Salary + isnull(sbr.Payroll, 0) + isnull(sbo.Payroll, 0) as Total
			from cte_salary as s
				--Берем только последнее регулярное доп. начисление (пролонгирование)
				left join cte_SalaryBonusReg as sbr on sbr.ID_Employee = s.ID_Employee and sbr.PayrollHist = 1
				left join cte_SalaryBonusOnetime as sbo on sbo.ID_Employee = s.ID_Employee
			--Берем только последнюю по времени должность
			where s.PosHist = 1
		) as ssb on b.ID_Employee = ssb.ID_Employee
			and b.ID_calendar_Month = @ID_Month
		when matched and b.ID_status_Status in (@ID_status_RJCT, @ID_status_CALC) then
			update
			set
				Salary = ssb.Salary
				,Bonus = ssb.SalaryBonus
				,Total = ssb.Total
				,ID_status_Status = @ID_status_CALC
		when not matched then
			insert (ID_calendar_Month, ID_Employee, Salary, Bonus, Total, ID_status_Status)
			values (@ID_Month, ssb.ID_Employee, ssb.Salary, ssb.SalaryBonus, ssb.Total, @ID_status_CALC)
		when not matched by source and b.ID_status_Status = @ID_status_CALC then
			update
			set
				ID_status_Status = @ID_status_AUTOAPRV
			output
				inserted.ID as ID_Record
				,inserted.ID_status_Status as ID_newStatus
				,deleted.ID_status_Status as ID_oldStatus
			into #status_update (ID_Record, ID_newStatus, ID_oldStatus);
	end

	if @ID_status_AUTOAPRV in (select ID_newStatus from #status_update)
	begin
		-- Ставим в очередь событий для рассылки писем об автоматическом подтверждении зарплаты
		insert into ntf.EventQueueBuffer (ID_mdt_Event, EventTime, ID_mdt_Principal, ID_mdt_Object, ID_RecordTarget)
		select
			ev.ID as ID_mdt_Event
			,m.DateBegin as EventTime
			,emp.ID_mdt_Principal
			,mdt.ID_Object('onboarding.Bill') as ID_mdt_Object
			,su.ID_Record as ID_RecordTarget
		from #status_update as su
			inner join mdt.Event as ev on ev.Title = 'Bill notification'
			inner join onboarding.Bill as b on b.ID = su.ID_Record
			inner join onboarding.Employee as emp on emp.ID = b.ID_Employee
			inner join calendar.Month as m on m.ID = b.ID_calendar_Month
		where su.ID_newStatus = @ID_status_AUTOAPRV
			and su.ID_oldStatus = @ID_status_CALC
			and emp.ID_mdt_Principal is not null
	end
	
	drop table #status_update
end try
begin catch
	;throw
end catch
