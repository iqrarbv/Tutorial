public class RemindersController {
	
	public Schedule_Reminders__c objectReminder{get;set;}
	public Schedule_Reminders__c saveReminder{get;set;}
	public list<EmailTemplate> listEmailTemplates{get;set;}
	public string emailID{get;set;}
	public string retURL{get;set;}
	
	public RemindersController(apexPages.standardController std) 
	{
		retURL ='https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/Setup';
		objectReminder = new Schedule_Reminders__c();
		listEmailTemplates = [Select Id, Name From EmailTemplate where Folder.DeveloperName = 'Invoice_Reminders'];
	}
	public List<SelectOption> getEmailTemplates()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--Select--'));
		EmailTemplate em = new EmailTemplate();
		for(integer i=0; i<listEmailTemplates.size(); i++)
		{
			em = (EmailTemplate)listEmailTemplates[i];
			options.add(new SelectOption(em.Id,em.Name));
		}
		return options;
	}
	public void validationRules()
	{
		if(objectReminder.Frequency__c == null || objectReminder.Reminder_Criteria__c == null)
			throw new CustomException('You must select criteria');
		if(emailID == null || emailID == '')
			throw new CustomException('You must select an email template');
	}
    public PageReference Save()
    {
    	Savepoint sp =  DataBase.setSavepoint();
    	try
    	{
    		validationRules();
	    	saveReminder = new Schedule_Reminders__c(Frequency__c = objectReminder.Frequency__c,Reminder_Criteria__c = objectReminder.Reminder_Criteria__c,EmailTemplateId__c = emailID,zero_val__c = objectReminder.zero_val__c);
	    	insert saveReminder;    	 
	    	return new PageReference(retURL);
    	}  
    	catch(exception e)
		{
			Database.rollback(sp);			
			apexPages.addMessages(e);
			return null;
		}
    }
    public PageReference Discard()
    {
    	return new PageReference(retURL);    	
    }
    private static testMethod void RemindersController_Test()
	{
		EmailTemplate lstEml = [Select Id, Name From EmailTemplate where Folder.DeveloperName = 'Invoice_Reminders'];
		Schedule_Reminders__c sr = new Schedule_Reminders__c(Frequency__c = 2, Reminder_Criteria__c = 'Before Invoice Due Date' , EmailTemplateId__c = lstEml.id , zero_val__c = true);		
		insert sr;
		
		RemindersController rc = new RemindersController(new ApexPages.standardController(new Schedule_Reminders__c()));
		List<SelectOption> etmplates = rc.getEmailTemplates();
		rc.Discard();
		try
		{
			rc.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must select criteria');
		}
		rc.objectReminder.Frequency__c = sr.Frequency__c;
		try
		{
			rc.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must select criteria');
		}
		rc.objectReminder.Reminder_Criteria__c = sr.Reminder_Criteria__c;
		try
		{
			rc.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must select an email template');
		}
		rc.objectReminder.EmailTemplateId__c = sr.EmailTemplateId__c;
		rc.objectReminder.zero_val__c  = sr.zero_val__c;
		rc.Save();						
	}		
}