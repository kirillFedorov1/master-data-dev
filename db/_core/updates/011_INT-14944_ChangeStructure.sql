exec mdt.usp_SafeAddColumn
	@Table = 'onboarding.Bill'
	,@Column = 'ID_status_Status'
	,@Type = 'int'
	,@RefTable = 'status.Status'

exec mdt.usp_SafeAddColumn
	@Table = 'onboarding.Employee'
	,@Column = 'ID_mdt_Principal'
	,@Type = 'int'
	,@RefTable = 'mdt.Principal'
