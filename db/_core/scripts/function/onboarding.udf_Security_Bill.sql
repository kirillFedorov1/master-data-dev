create or alter function onboarding.udf_Security_Bill(
	@ID_User int
)
returns table
as
return(
	--Руководители и подчиненные
	with cte_Employee as(
		select 
			e.ID as ID_Employee
			,e.ID_Supervisor as ID_Supervisor
			,e.ID_mdt_Principal as ID_Principal
		from onboarding.Employee as e
		where e.ID_mdt_Principal = @ID_User

		union all

		select 
			e.ID as ID_Employee
			,e.ID_Supervisor as ID_Supervisor
			,e.ID_mdt_Principal as ID_Principal
		from cte_Employee as cte
			inner join onboarding.Employee as e on e.ID_Supervisor = cte.ID_Employee
	)
	select
		b.ID as ID
		,case
			--Сотрудник может видеть только свои зарплатные ведомости и ведомости своих подчиненных
			when b.ID_Employee = cte.ID_Employee
				and p.Code is null
				then mdt.udf_PermissionMask('R')
			else mdt.udf_PermissionMask('RWAD')
		end as [$Record]
		,case
			--Переход из статусов Расчитано/Утверждено сотрудником доступен только самому сотруднику
			when cte.ID_Principal = @ID_User and (
				s.Code = 'onboarding.bill.CALC'
					or s.Code = 'onboarding.bill.APRV'
			--Переход из статуса Отклонено сотрудником доступен только руководителям сотрудника
			) or s.Code = 'onboarding.bill.RJCT'
				then mdt.udf_PermissionMask('RW')
			else null
		end as ID_status_Status
	from onboarding.Bill as b
		inner join status.Status as s on s.ID = b.ID_status_Status
		left join cte_Employee as cte on cte.ID_Employee = b.ID_Employee
		left join mdt.Principals(@ID_User) as p on p.Code = 'administrators'
	--Либо сотрудник и его руководители, либо админ
	where cte.ID_Employee is not null
		or p.ID is not null
)
