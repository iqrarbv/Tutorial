public class CutomerActivity 
{
	public Account ac {get; set;}
	public Decimal pAmount {get;set;}
	public Decimal turnPver {get;set;}
	public string currencySymbol {get; set;}
	public string typeAcctt {get; set;}
	public Decimal balance {get; set;}
	public CutomerActivity(apexpages.standardcontroller stdCon )
	{
		init() ;
	}
	public void init()
	{
		try
		{
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			integer fiscalMonth = [Select o.FiscalYearStartMonth From Organization o].FiscalYearStartMonth ; 
	 		Id customerID = apexpages.currentPage().getParameters().get('id');
			ac = [select AccountNumber ,Balance__c , Type from Account where id =: customerID ] ;
			balance = ac.Balance__c ; 
			string AccountType = '';
			string tyAccount = '';
			string tyCredit = '';
			string tyDiscount = '';
			if(ac.Type == 'Customer' || ac.Type == 'Customer - Direct' || ac.Type == 'Customer - Channel')
			{
				AccountType = 'SI';
				tyAccount = 'SA';
				tyCredit = 'SC';
				tyDiscount = 'SD';	
				typeAcctt = 'Customer';
			}
			else if(ac.Type == 'Supplier' )
			{
				AccountType = 'PI';
				tyAccount = 'PA';
				tyCredit = 'PC';
				tyDiscount = 'PD';	
				typeAcctt = 'Supplier';	
			}	
			AggregateResult SIpaidAmount = [select  Sum(Amount__c) paidAmount from Ledger__c where Type__c = :AccountType And Sub_Account__c = : ac.AccountNumber and Paid__c = 'Y'];
 			AggregateResult SA = [select  Sum(Amount__c) SA from Ledger__c where Type__c = :tyAccount And Sub_Account__c = : ac.AccountNumber ];
 			AggregateResult SC = [select  Sum(Amount__c) SC from Ledger__c where Type__c = :tyCredit And Sub_Account__c = : ac.AccountNumber];
 			AggregateResult SD = [select  Sum(Amount__c) SD from Ledger__c where Type__c = :tyDiscount And Sub_Account__c = : ac.AccountNumber ];
 			AggregateResult turnOver ;
 			if(fiscalMonth > date.today().month())
 			{	
 				date fiscalstart = date.newInstance(date.today().year()-1, fiscalMonth , 1 );
 				system.debug('in 1st loop ' + fiscalstart);
 				turnOver = [select  Sum(Net__c) turnOver from Ledger__c where Type__c = :AccountType And Sub_Account__c = :ac.AccountNumber  and Trans_Date__c >= :fiscalstart and Trans_Date__c <= :date.today() and Show_On_Transaction__c =1];
 			}
 			else
 			{	
 				date fiscalstart = date.newInstance(date.today().year(), fiscalMonth , 1 );
 				system.debug('in 2nd loop ' + fiscalstart);
 				turnOver = [select  Sum(Net__c) turnOver from Ledger__c where Type__c = :AccountType And Sub_Account__c = :ac.AccountNumber  and Trans_Date__c >= :fiscalstart and Trans_Date__c <= :date.today() and Show_On_Transaction__c =1];
 			}
 			system.debug('this is turn over: ' + turnOver);
 			system.debug('this is SI Paid: ' + SIpaidAmount);
 			system.debug('this is SA: ' + SA);
 			system.debug('this SC: ' + SC);
 			system.debug('this is SD: ' + SD);
 			decimal PA =  SIpaidAmount.get('paidAmount')==null?0:(decimal)SIpaidAmount.get('paidAmount');
 			decimal SAA =  SA.get('SA')==null?0:(decimal)SA.get('SA');
 			decimal SCA =  SC.get('SC')==null?0:(decimal)SC.get('SC');
 			decimal SDA =  SD.get('SD')==null?0:(decimal)SD.get('SD');
 			system.debug('this is SI PaidA: ' + PA);
 			system.debug('this is SAA: ' + SAA);
 			system.debug('this SCA: ' + SCA);
 			system.debug('this is SDA: ' + SDA);
 			decimal tmp1 = (SCA - SDA); 
 			decimal tmp2 = (SAA - tmp1) ;
 			//pAmount = (PA - tmp2) ;
 			pAmount = PA + SAA - SCA - SDA ;
 			turnPver = turnOver.get('turnOver')==null?0:(Decimal)turnOver.get('turnOver');
 			system.debug('this is paid amount: ' + pAmount);
		}
		catch (exception e)
		{
			apexpages.addMessages(e);
		}
	}
	
	
	// starting of test fucntions
	private static testmethod void TestCustomerActivity()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier' , AccountNumber = 'TESTSUP' );
		insert act;
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(new Ledger__c());
		Apexpages.currentPage().getParameters().put('id' , act.id);
		CutomerActivity obj = new CutomerActivity(std);
		
		act = new Account(Name='ABC Company',Type='Customer' , AccountNumber = 'TESTSUP' );
		insert act;
		
		Apexpages.currentPage().getParameters().put('id' , act.id);
		obj = new CutomerActivity(std);
	}
	// end of test functions
}