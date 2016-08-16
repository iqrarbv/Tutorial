public class DaysSalesOutstandingController {
	public List<Ledger__c> listLedger {get;set;}
	public List<AggregateResult> aresult  {get;set;}
	public decimal aggResult1  {get;set;}
	public decimal aggResult2  {get;set;}
	public decimal aggResult3  {get;set;}
	public decimal aggResult4 {get;set;}
	public decimal aggResult5  {get;set;}
	
	public  string enumNo {get;set;}
	public DaysSalesOutstandingController ()
	{
		
	}
	public void Calculate()
	{
		
		Date SDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
				
		aresult = [Select Sum(Net__c)  From Ledger__c  where Trans_Date__c >=: sDate.addDays(-30) and Trans_Date__c <=: Date.today() and type__c = 'SI' and Is_Deleted__c = false and Show_On_Transaction__c = 1 ];
		if(aresult.size() > 0)
			aggResult1  = aresult[0].get('expr0')== null ? 0.00 :(decimal)aresult[0].get('expr0');
		else
			aggResult1 = 0.0;
			
		aresult = [Select Sum(Net__c)  From Ledger__c  where Trans_Date__c >=: sDate.addDays(-30) and Trans_Date__c <=: sDate.addDays(-60) and type__c = 'SI' and Is_Deleted__c = false and Show_On_Transaction__c = 1 ];
		if(aresult.size() > 0)
			aggResult2  = aresult[0].get('expr0')== null ? 0.00 : (decimal)aresult[0].get('expr0');
		else
			aggResult2 = 0.0;
			
		aresult = [Select Sum(Net__c)  From Ledger__c  where Trans_Date__c >=: sDate.addDays(-60) and Trans_Date__c <=: sDate.addDays(-90) and type__c = 'SI' and Is_Deleted__c = false and Show_On_Transaction__c = 1 ];
		if(aresult.size() > 0)
			aggResult3  = aresult[0].get('expr0')== null ? 0.00 : (decimal)aresult[0].get('expr0');
		else
			aggResult3 = 0.0;
			
		aresult = [Select Sum(Net__c)  From Ledger__c  where Trans_Date__c >=: sDate.addDays(-90) and Trans_Date__c <=: sDate.addDays(-120) and type__c = 'SI' and Is_Deleted__c = false and Show_On_Transaction__c = 1 ];
		if(aresult.size() > 0)
			aggResult4  = aresult[0].get('expr0')== null ? 0.00 : (decimal)aresult[0].get('expr0');
		else
			aggResult4 = 0.0;
			
		aresult = [Select Sum(Net__c)  From Ledger__c  where Trans_Date__c <=: sDate.addDays(-120) and type__c = 'SI' and Is_Deleted__c = false and Show_On_Transaction__c = 1 ];
		if(aresult.size() > 0)
		aggResult5  = aresult[0].get('expr0')== null ? 0.00 : (decimal)aresult[0].get('expr0');
		else
			aggResult5 = 0.0;
		
		
		
		
		
		 
		system.debug('aresult :'+ aresult);
		//system.debug('aggResult :'+ aggResult);		
	}
	public List<SelectOption> getTaxRate()
	{
		List<SelectOption> options = new List<SelectOption>();	    		    		    
    	options.add(new SelectOption('1','Less than 30 days'));    				      
    	options.add(new SelectOption('2','30 - 59 days'));
    	options.add(new SelectOption('3','60 - 89 days'));
    	options.add(new SelectOption('4','90 - 119 days'));
    	options.add(new SelectOption('5','120 days or more'));
        return options;	    	
    }
}