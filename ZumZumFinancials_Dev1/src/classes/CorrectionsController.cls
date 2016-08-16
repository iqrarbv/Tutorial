public class CorrectionsController { 
	
	public List<Ledger__c> listLedger{get;set;}
	public string numb{get;set;}
	public Ledger__c ledger {get;set;}
	public Ledger__c  objectLedger {get;set;}
	public string retURL{get;set;}
	public Nominal_Account__c objectNominal{get;set;}
	public Nominal_Account__c n{get;set;}
	public CustomerLookup__c LookupAccount{get;set;}
	public string editId{get;set;}	
	public Account o {get;set;} 
	public string AccttNum{get;set;}
	public string NomCode{get;set;}	 
	public CorrectionsController(apexpages.standardcontroller std) 
	{						
		//listLedger = [select Name , Trans_No__c , Type__c , Sub_Account__c ,Nominal__c , Details__c , Reference__c , Net__c , Tax__c , Tax_Code__c , Amount__c from Ledger__c where Show_On_Transaction__c = 1];			
		editId = apexpages.currentPage().getParameters().get('id');
		system.debug('editId : '+editId );
		if(editId != null && editId != '')
		{
			LookupAccount = new CustomerLookup__c();
			objectNominal = new Nominal_Account__c();
			objectLedger = [select Name , Sub_Account_Nominal__c, Trans_No__c , Type__c , Sub_Account__c ,Nominal__c , Details__c , Reference__c , Net__c , Tax__c , Tax_Code__c , Amount__c from Ledger__c where id=: editId];			
			if(objectLedger.Sub_Account__c != objectLedger.Sub_Account_Nominal__c)
			{
				o = [select AccountNumber , id, Name from Account where AccountNumber =: objectLedger.Sub_Account__c ];
				if(o.Id != null)
				{
					LookupAccount.CustomerAccount__c = o.id;
					AccttNum = o.AccountNumber;
				}
			}			
			n = [select Nominal_Code__c , id from Nominal_Account__c where Nominal_Code__c =: objectLedger.Sub_Account_Nominal__c];
			if(n.id != null)
			{	
				LookupAccount.Nominal_Account__c = n.id;
				NomCode = n.Nominal_Code__c ;
			}
		}
		else		
			objectLedger = new Ledger__c();
	}	
	public void SubAccountChanged()
	{		
		o = [select AccountNumber , id, Name from Account where id =: LookupAccount.CustomerAccount__c];
		if(o.Id != null)
		{
			AccttNum = o.AccountNumber;
		}
	}
	public void NominalAccountChanged()
	{
		n = [select Nominal_Code__c , id from Nominal_Account__c where id =: LookupAccount.Nominal_Account__c];
		if(n.id != null)
		{	
			NomCode = n.Nominal_Code__c ;
		}
	}
	public PageReference Mark()
	{ 		
		apexpages.currentPage().getHeaders().put('num',apexpages.currentPage().getParameters().get('num'));
		numb = apexpages.currentpage().getHeaders().get('num'); 
		//system.debug('num : '+ numb);
		retURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/CorrectionRecord?num='+numb;
		Ledger__c l = [select Type__c from Ledger__c where Name =: numb];
		if(l.Type__c != 'JC' && l.Type__c != 'JD')
			return new PageReference (retURL);
		else
			return null;
	}
	public void init()
	{  
		//editedIndex = integer.valueOf(ApexPages.currentPage().getParameters().get('paramEdit'));
		//decimal num = decimal.valueOf(apexpages.currentPage().getParameters().get('num'));
		numb = apexpages.currentPage().getParameters().get('Host');
		system.debug('init : '+numb );
		ledger = [select Trans_No__c , Type__c , Sub_Account__c ,Nominal__c , Details__c , Reference__c , Net__c , Tax__c , Tax_Code__c , Amount__c from Ledger__c where  Name =: numb];
	}
	
}