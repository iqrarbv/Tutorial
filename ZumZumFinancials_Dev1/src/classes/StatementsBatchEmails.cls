global class StatementsBatchEmails implements Database.batchable<sObject>
{
	private boolean nonZeroBalanceCondition = false;
	global StatementsBatchEmails(boolean nonZeroBalance)
	{
		nonZeroBalanceCondition = nonZeroBalance;
	}
	
	global Database.QueryLocator Start(Database.BatchableContext bc)
	{
		if(nonZeroBalanceCondition==false)
			return  Database.GetQueryLocator([select Id,Name,Billing_Contact__c from Account where accountNumber!=null and billing_Contact__r.Email!=null ]);
		else
			return  Database.GetQueryLocator([select Id,Name,Billing_Contact__c from Account where accountNumber!=null and billing_Contact__r.Email!=null and Balance__c!=0]);
	}
	
	global void Execute(Database.BatchableContext bc, List<SObject> scope)
	{
		Messaging.SingleEmailMessage[] mailingList = new Messaging.SingleEmailMessage[]{};
		Map<Id, Set<Date>> accountInvoiceDates = new Map<Id, Set<Date>>();
		List<EmailTemplate> etemp = [select id from EmailTemplate where name='Account Statement'];
		if(etemp.size()==0)
		{
			throw new CustomException('No email template found with name Account_Statement');
		} 
		for(Account acc : (List<Account>) scope)
        {
        	system.debug('ActId :'+acc);
        	Messaging.SingleEmailMessage mail = new Messaging.singleEmailMessage();        
	        mail.setTargetObjectId(acc.Billing_Contact__c);
	        mail.setWhatId(acc.Id);
			// here i gave the id of the email template to be executed by this class
	        mail.setTemplateId(etemp[0].Id);                       
	        mail.setSenderDisplayName(System.UserInfo.GetName());
	        mailingList.add(mail);	
        }
        if(mailingList.size()>0)
        	Messaging.sendEmail(mailingList);
	}
	
	global void Finish(Database.BatchableContext bc)
	{		
	}
	private static testMethod void StatementsBatchEmails_Test()
	{
		StatementsBatchEmails sttBatch = new StatementsBatchEmails(true);
		Database.BatchableContext b;		
		sttBatch.Start(b);
		List<SObject> lstAccount = [select Id,Name,Billing_Contact__c from Account where accountNumber!=null and billing_Contact__r.Email!=null];
		sttBatch.Execute(b, lstAccount);		
		sttBatch.Finish(b);
		//List<SObject> lstAccount1 = [select Id,Name,Billing_Contact__c from Account where accountNumber!=null and billing_Contact__r.Email!=null and Balance__c!=0];
		//sttBatch.Execute(b, lstAccount1);			
	} 	
}