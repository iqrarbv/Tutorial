global class ScheduledRecurringTransactions implements Schedulable 
{
	global ScheduledRecurringTransactions()
	{
		
	}
	
	global void Execute(SchedulableContext sc)
	{
		List<AsyncApexJob> lst = [Select a.TotalJobItems, a.Status, a.JobType, a.JobItemsProcessed, a.Id, a.ApexClass.Name, a.ApexClassId From AsyncApexJob a Where Status in ('Processing','Queued') and JobType='BatchApex'];
		if(lst.size()<5)
		{
			RecurringTransactionBatchProcess obj = new RecurringTransactionBatchProcess();
			database.ExecuteBatch(obj,100);	
		}
		else
		{
			User u = [select Email from User where Id=:UserInfo.getUserId()];
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); //instantiate a new message object
			String[] toAddresses = new String[] {u.Email}; //denote the email address for receiving the message
			mail.setToAddresses(toAddresses); //to
			mail.setSubject('Bank Recurring Transaction Service Failed Due to inavailability of batch job slot.'); //subject
			mail.setPlainTextBody('Bank Recurring Transaction Service Failed Due to inavailability of batch job slot.'); //body
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); //send
		}	
	}
}