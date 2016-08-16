trigger ZeroTax on Tax_Rate__c (before insert, before update) {
	public list<Tax_Rate__c> lstTax = [select Tax_Rate__c , Name, is_no_tax__c from Tax_Rate__c where is_no_tax__c = true];
	for(Tax_Rate__c tx : Trigger.New)
		for(Tax_Rate__c tax : lstTax)					
			if((tx.is_no_tax__c == true) && (tax.is_no_tax__c == true))
				tx.addError('Another Tax Rate has already been selected to no tax');
				//throw new CustomException('Another Tax Rate has already been selected to no tax');				
}