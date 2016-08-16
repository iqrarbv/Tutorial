global class TimeSheetStatusChecker implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		map<integer , string> monthCodes = new map<integer , string>{
													1 => 'January' ,
											        2 => 'February' ,
											        3 => 'March' ,
											        4 => 'April' ,
											        5 => 'May' ,
											        6 => 'June' ,
											        7 => 'Jully' ,
											        8 => 'August' ,
											        9 => 'September' ,
											       10 => 'October' ,
											       11 => 'November' ,
											       12 => 'December' 
											       };
		date datee = date.today().addMonths(-1);
		integer provmonth = datee.month();
		integer year = datee.year();
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {};
		mail.setSenderDisplayName('Zumzum RDI Application');
		mail.setSubject('Reminder: Please submit your ' + monthCodes.get(provmonth)+'/ '+year+' timesheet.' );
		mail.setHtmlBody('Please Submitt Your Time Sheet for month : '+ monthCodes.get(provmonth)  + '/ '+year+ ' for Approval.'  );
		system.debug('at the end');
		//list<Time_Sheet__c> ts = [select Name,Owner.Email from Time_Sheet__c where Month__c = :provmonth AND Status__c in ('Pending','Rejected')  ];
		for (Time_Sheet__c tss : [select Name,Owner.Email from Time_Sheet__c where Month__c = :provmonth AND Year__c = : year AND Status__c in ('Pending','Rejected')  ] )
		{
			system.debug('this is email ' + tss);
			if (tss.Owner.Email != null || tss.Owner.Email != '')
				toAddresses.add(tss.Owner.Email);	
		}
		system.debug('this is to address ' + toAddresses);
		mail.setToAddresses(toAddresses);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	}
	private static TestMethod void statusChecker()
	{
		//Time_Sheet__c ts = new Time_Sheet__c(Month__c = date.today().addMonths(-1)  , year__c = date.today().year() , Status__c ='Pending');
		//TimeSheetStatusChecker obj = new TimeSheetStatusChecker();
		Time_Sheet__c tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().addMonths(-1).month();
		tsinfo.Year__c = date.today().year();
		tsinfo.Status__c = 'Pending';
		insert tsinfo;
		String CRON_EXP = '0 15 * * * ?'; 
		String jobId = System.schedule('testBasicScheduledApex',CRON_EXP, new TimeSheetStatusChecker());
		TimeSheetStatusChecker obj = new TimeSheetStatusChecker();
		obj.execute(null);
	}
}