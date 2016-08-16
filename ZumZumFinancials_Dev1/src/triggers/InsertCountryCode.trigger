trigger InsertCountryCode on Account (before insert , before update) 
{
	try
	{
		Account myAccount = trigger.new[0];
		string[] countryCode = new string[]{};
		if(myAccount.Country__c !=null)
		{
			countryCode = Functions.getRegionWithCode(myAccount.Country__c);
			myAccount.Region__c = countryCode[0];
			myAccount.Country_Code__c = countryCode[1];
		}
	}
	catch (Exception e)
	{
		apexpages.addMessages(e);
	}
	//insert myAccount ;
	/*
	for (Account a : Trigger.new)
	{
		string[] countryCode = new string[]{};
		countryCode = Functions.getRegionWithCode(a.Country__c);
		//myAccount.Region__c = 'Asia' ;// countryCode[0];
		a.Country_Code__c = countryCode[1];
		insert a ;	
	}
	*/  
}