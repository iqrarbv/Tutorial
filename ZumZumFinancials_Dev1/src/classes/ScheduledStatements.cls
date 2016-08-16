global class ScheduledStatements implements Schedulable
{
	public ScheduledStatements()
	{
		
	}
	
	global void Execute(SchedulableContext sc)
	{
		List<Schedule_Statements__c> schList = [select id, send_statements_if_balance_is_zero__c from Schedule_Statements__c where (Day__c=:string.valueof(date.today().day()) and Frequency__c='Monthly') or (Day__c=:string.valueof(date.Today().Month()) and Month__c=:string.valueof(date.Today().Month()) and Frequency__c='Yearly') order by Month__c desc limit 1];
		if(schList.Size()>0)
		{
			boolean nonZeroBalance = schList[0].send_statements_if_balance_is_zero__c; 	
			List<AsyncApexJob> lst = [Select a.TotalJobItems, a.Status, a.JobType, a.JobItemsProcessed, a.Id, a.ApexClass.Name, a.ApexClassId From AsyncApexJob a Where Status in ('Processing','Queued') and JobType='BatchApex'];
    		if(lst.size()<5)
    		{
    			StatementsBatchEmails obj = new StatementsBatchEmails(nonZeroBalance);
				database.ExecuteBatch(obj,100);	
    		}
    		else
    		{
    			User u = [select Email from User where Id=:UserInfo.getUserId()];
    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); //instantiate a new message object
				String[] toAddresses = new String[] {u.Email}; //denote the email address for receiving the message
				mail.setToAddresses(toAddresses); //to
				mail.setSubject('Scheduled Statements Failed Due to inavailability of batch job slot.'); //subject
				mail.setPlainTextBody('Scheduled Statements Failed Due to inavailability of batch job slot.'); //body
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); //send
    		}			
		}	
	}
	
	
	// start of test functions
	private static TestMethod void statusChecker()
	{
		
		Account act = new Account(Name='ABC Company',Type='Supplier' , AccountNumber = 'SCTEST' , Credit__c = 500 , Debit__c = 100 , Country__c = 'UNITED KINGDOM' );
		insert act;
		
		Contact cT = new Contact(Email= 'test@test.com', Description = 'This is test Contact', Department = 'ZumZum' , AccountId = act.Id , LastName = 'TEST');
		insert cT ;
		
		List<Schedule_Statements__c> SStatments = new List<Schedule_Statements__c>();
		SStatments.add(new Schedule_Statements__c(Day__c = string.valueof(date.today().day()) ,
																		Frequency__c = 'Monthly ',
																		Month__c = string.valueof(date.Today().Month()) ,
																		send_statements_if_balance_is_zero__c = true
																		 ))	;
																		 
		SStatments.add(new Schedule_Statements__c(Day__c = string.valueof(date.today().day()) ,
																		Frequency__c = 'Yearly ',
																		Month__c = string.valueof(date.Today().Month()) ,
																		send_statements_if_balance_is_zero__c = true
																		 ))	;
																		 																		 
		insert 	SStatments ;
		
		String CRON_EXP = '0 5 * * * ?'; 
		String jobId = System.schedule('testBasicScheduledApex',CRON_EXP, new ScheduledStatements());
		ScheduledStatements obj = new ScheduledStatements();
		obj.Execute(null);
		
		
		/*jobId = System.schedule('testBasicScheduledApex1',CRON_EXP, new ScheduledStatements());
		jobId = System.schedule('testBasicScheduledApex2',CRON_EXP, new ScheduledStatements());
		jobId = System.schedule('testBasicScheduledApex3',CRON_EXP, new ScheduledStatements());
		jobId = System.schedule('testBasicScheduledApex4',CRON_EXP, new ScheduledStatements());
		jobId = System.schedule('testBasicScheduledApex5',CRON_EXP, new ScheduledStatements());
		jobId = System.schedule('testBasicScheduledApex6',CRON_EXP, new ScheduledStatements());
		jobId = System.schedule('testBasicScheduledApex7',CRON_EXP, new ScheduledStatements());
		jobId = System.schedule('testBasicScheduledApex8',CRON_EXP, new ScheduledStatements());
		obj.Execute(null);
		*/
	}
	
	// end of test functions
}