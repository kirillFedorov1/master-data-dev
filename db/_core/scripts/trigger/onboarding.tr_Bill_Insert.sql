create or alter trigger onboarding.tr_Bill_Insert on onboarding.Bill
after insert
as
begin
	update b
	set ID_status_Status = s.ID
	from onboarding.Bill as b
		inner join status.Status as s on s.Code = 'onboarding.Bill.CALC'
		inner join inserted as i on i.Id = b.Id
end
