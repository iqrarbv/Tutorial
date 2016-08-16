global class ScheduledReminders implements Schedulable
{
	public ScheduledReminders()
	{
		
	}
	
	global void Execute(SchedulableContext sc)
	{
		Map<Date, Id> invoiceTemplates = new Map<Date, Id>();
		for(Schedule_Reminders__c sr : [Select s.zero_val__c, s.Reminder_Criteria__c, s.Id, s.Frequency__c, s.EmailTemplateId__c 
										From Schedule_Reminders__c s])
		{			
			if(sr.zero_val__c==true)
			{
				invoiceTemplates.put(date.Today(),sr.EmailTemplateId__c);				
			}
			else if(sr.Frequency__c!=null)
			{
				integer days = integer.valueof(string.valueof(sr.Frequency__c));
				if(sr.Reminder_Criteria__c=='After Invoice Due Date')
					days = days * -1;				
				invoiceTemplates.put(date.Today().addDays(days),sr.EmailTemplateId__c);
			}			
		}
		if(invoiceTemplates.Size()>0)
		{
			List<AsyncApexJob> lst = [Select a.TotalJobItems, a.Status, a.JobType, a.JobItemsProcessed, a.Id, a.ApexClass.Name, a.ApexClassId From AsyncApexJob a Where Status in ('Processing','Queued') and JobType='BatchApex'];
    		if(lst.size()<5)
    		{
    			ReminderBatchEmails obj = new ReminderBatchEmails(invoiceTemplates);
				database.ExecuteBatch(obj,100);	
    		}
    		else
    		{
    			User u = [select Email from User where Id=:UserInfo.getUserId()];
    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); //instantiate a new message object
				String[] toAddresses = new String[] {u.Email}; //denote the email address for receiving the message
				mail.setToAddresses(toAddresses); //to
				mail.setSubject('Invoice Reminders Failed Due to inavailability of batch job slot.'); //subject
				mail.setPlainTextBody('Invoice Reminders Failed Due to inavailability of batch job slot.'); //body
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); //send
    		}			
		}	
	}
	private static testMethod void ScheduledReminders_Test()
	{				
		EmailTemplate lstEml = [Select Id, Name From EmailTemplate where Folder.DeveloperName = 'Invoice_Reminders'];
		Schedule_Reminders__c srObj = new Schedule_Reminders__c(Frequency__c = 2, Reminder_Criteria__c = 'After Invoice Due Date' , EmailTemplateId__c = lstEml.id , zero_val__c = false);
		insert srObj;
		
		integer days = integer.valueof(string.valueof(srObj.Frequency__c));
		Map<Date, Id> invTemp = new Map<Date, Id>();
		invTemp.put(date.Today().addDays(days),srObj.EmailTemplateId__c);
		
		ScheduledReminders srCls = new ScheduledReminders();
		SchedulableContext sc ;// new SchedulableContext;		
		srCls.Execute(sc);	
		
		srObj = new Schedule_Reminders__c(Frequency__c = 2, Reminder_Criteria__c = 'Before Invoice Due Date' , EmailTemplateId__c = lstEml.id , zero_val__c = true);
		insert srObj;
		
		ReminderBatchEmails obj = new ReminderBatchEmails(invTemp);
		database.ExecuteBatch(obj,100);
		
		obj = new ReminderBatchEmails(invTemp);
		database.ExecuteBatch(obj,100);		
		
		obj = new ReminderBatchEmails(invTemp);
		database.ExecuteBatch(obj,100);
		
		obj = new ReminderBatchEmails(invTemp);
		database.ExecuteBatch(obj,100);
		
		srCls = new ScheduledReminders();			
		srCls.Execute(sc);					
	}
	
}