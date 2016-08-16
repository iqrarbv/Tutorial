//trigger defaultTax on Tax_Rate__c (before insert, before update) {
trigger defaultTax on Tax_Rate__c (before insert, before update) {
  public list<Tax_Rate__c> lstTax = [select Tax_Rate__c ,is_default__c , Name from Tax_Rate__c where is_default__c = true];
  for(Tax_Rate__c tx : Trigger.New)
    for(Tax_Rate__c tax : lstTax)
    	if(tx.Name != tax.Name)         
      		if((tx.is_default__c == true) && (tax.is_default__c == true))      
      			tx.addError('Another Tax Rate has already been selected as default');
        //throw new CustomException('Another Tax Rate has already been selected as default');      
}