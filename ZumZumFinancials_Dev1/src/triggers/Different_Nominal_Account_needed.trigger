trigger Different_Nominal_Account_needed on Bank_Account__c (before insert, before update)
{
	List<Bank_Account__c> listBankAccount = [select id, Name, Nominal_Account__c from Bank_Account__c];
	for(Bank_Account__c bnk : Trigger.New)
	{
		for(Bank_Account__c b : listBankAccount)
		{
			if(bnk.id != null)
			{
				if(bnk.id != b.id )
					if(bnk.Nominal_Account__c == b.Nominal_Account__c)			
					//throw new CustomException('This Nominal Account already selected into another Bank Account');
					bnk.addError('This Nominal Account already selected into another Bank Account');
			}
			else
			{
				if(bnk.Nominal_Account__c == b.Nominal_Account__c)			
				//throw new CustomException('This Nominal Account already selected into another Bank Account');
				bnk.addError('This Nominal Account already selected into another Bank Account');
			}			
			
			
		}
	}

}