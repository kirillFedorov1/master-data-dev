create or alter procedure onboarding.usp_BeforeSavePosition
	@ID int
	,@DiffXML xml
as
begin try
	if @DiffXML.value('(/Record/Code)[1]', 'varchar(255)') like '%[^A-Za-z]%'
		raiserror('Поле "Код" может содержать только латинские символы', 2, 1)
end try
begin catch
	;throw
end catch
