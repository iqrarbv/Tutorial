global class ReminderBatchEmails implements Database.batchable<sObject>
{
	global Map<date,Id> dueDateTemplateIdMap;
	
	global ReminderBatchEmails(Map<date,Id> templateMap)
	{
		dueDateTemplateIdMap = templateMap;
	}
	
	global Database.QueryLocator Start(Database.BatchableContext bc)
	{
		set<Date> dateSet = dueDateTemplateIdMap.keySet();
		string str = '';
		for(Date s : DateSet)
		{
			str +=','+s.format();
		}
		//throw new customException('dateSet str= '+str);
		
		return  Database.GetQueryLocator([Select Id,Billing_Contact__c,
										  (Select Id, Name, Invoice_Due_Date__c, Type__c, Status__c From Sales_Invoices__r Where Invoice_Due_Date__c in : dateSet and Paid__c='N') 
										  From Account 
										  Where Id in 
										  (
											Select s.Account__c 
											From Sales_Invoice__c s
											Where s.Invoice_Due_Date__c in : dateSet 
											and Paid__c='N'
										  ) and Billing_Contact__c != null]);		
	}
	
	global void Execute(Database.BatchableContext bc, List<SObject> scope)
	{		
		Messaging.SingleEmailMessage[] mailingList = new Messaging.SingleEmailMessage[]{};
		Map<Id, Set<Date>> accountInvoiceDates = new Map<Id, Set<Date>>();
		for(Account acc : (List<Account>) scope)
        {        	
        	Set<Date> dateSet = new Set<Date>();
        	for(Sales_Invoice__c si : acc.Sales_Invoices__r)
        	{        		
        		dateSet.add(si.Invoice_Due_Date__c);
        	}
        	for(Date d : dateSet)
        	{        		
        		Messaging.SingleEmailMessage mail = new Messaging.singleEmailMessage();        
		        mail.setTargetObjectId(acc.Billing_Contact__c);
		        system.debug('billing contact :'+acc.Billing_Contact__c);
		        mail.setWhatId(acc.Id);
				// here i gave the id of the email template to be executed by this class
		        mail.setTemplateId(dueDateTemplateIdMap.get(d));
		        system.debug('billing contact :'+dueDateTemplateIdMap.get(d));                       
		        mail.setBccSender(false);
		        mail.setUseSignature(false);
		        mail.setSenderDisplayName(System.UserInfo.GetName());
		        mail.setSaveAsActivity(false);
		        mailingList.add(mail);	        		
        	}           
        }
        Messaging.sendEmail(mailingList);
	}
	
	global void Finish(Database.BatchableContext bc)
	{		
	}	
	private static testMethod void ReminderBatchEmails_Test()
	{
		EmailTemplate lstEml = [Select Id, Name From EmailTemplate where Folder.DeveloperName = 'Invoice_Reminders'];
		Schedule_Reminders__c srObj = new Schedule_Reminders__c(Frequency__c = 2, Reminder_Criteria__c = 'Before Invoice Due Date' , EmailTemplateId__c = lstEml.id , zero_val__c = true);
		insert srObj;
		Map<Date, Id> invTmplt = new Map<Date, Id>();
		set<Date> ds = new set<Date>();		
		ds.add(Date.today());
		invTmplt.put(Date.newInstance(2011,7,19),srObj.EmailTemplateId__c);
		
		ReminderBatchEmails obj = new ReminderBatchEmails(invTmplt);
		
		obj.dueDateTemplateIdMap = invTmplt;
		Database.BatchableContext b;
				
		obj.Start(b);
		
		
		set<Date> dateSet = obj.dueDateTemplateIdMap.keySet();
		string str = '';
		for(Date s : DateSet)
		{
			str +=','+s.format();
		}
		
		List<SObject> lstAct = [Select Id,Billing_Contact__c,
										  (Select Id, Name, Invoice_Due_Date__c, Type__c, Status__c From Sales_Invoices__r Where Invoice_Due_Date__c in : dateSet and Paid__c='N') 
										  From Account 
										  Where Id in 
										  (
											Select s.Account__c 
											From Sales_Invoice__c s
											Where s.Invoice_Due_Date__c in : dateSet 
											and Paid__c='N'
										  ) and Billing_Contact__c != null limit 100];										  
		
		
		obj.Execute(b, lstAct);
		
		obj.Finish(b);
		
	}  
}