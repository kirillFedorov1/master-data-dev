--Создание службы для загрузки данных по премиям
exec job.usp_AddTask
	@Code = 'LoadBonusData'
	,@Script = 'onboarding.LoadBonusData'
	,@Title = 'Загрузка данных по премиям'
	,@FlagActive = 1
	,@RunPeriod = 'D'
	,@RunEvery = 1
	,@StartTime = '2023-03-21 08:00'
	,@Module = 'onboarding'
