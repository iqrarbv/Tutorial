public class SendTimeSheettoEmail 
{
	public string emailAddresses {get; set;}
	public boolean sendBack {get; set;}
	public boolean sendEmailtoViewer {set; get;}
	public boolean showPage {get; set;}
	public SendTimeSheettoEmail( apexpages.Standardcontroller sendTimeSheetToEmail )
	{
		
	}
	public SendTimeSheettoEmail( )
	{
		
	}
	public pageReference init()
	{
		try
		{
			User ur =[ select Email from user where Id = : userinfo.getUserId()];
			Id timeSheetId = apexpages.currentPage().getParameters().get('id');
			Time_Sheet__c ts = [Select Status__c , Name from Time_Sheet__c where Id = :timeSheetId ];
			if (ts.Status__c != 'Approved')
			{
				showPage = false ;
				sendBack = true ;
				throw new CustomException (ts.Name +' is not Approved, It cannot be Send as Email')	;
			}
			showPage = true ;
			if ( ur.Email != null )
			 	emailAddresses = ur.Email ;
			return null;
		}
		catch (exception e)
		{
			apexpages.addMessages(e);
			return null ;
		}
	}
	public pageReference sendEmail()
	{
		try
		{
			String[] emails = new String[]{};
			string[] invalidAddresses = new string[]{};
			for(string em : emailAddresses.split(',' , 0))
			{
				if(OrderValidation.emailvalidate(em) ==true )
				{
					emails.add(em);
				}
				else
				{
					invalidAddresses.add(em);
					break;
				}
			}
			if (invalidAddresses.size() > 0 )
			{
				apexpages.addMessage( new apexpages.Message ( apexpages.Severity.error , invalidAddresses[0] , ' is an Invalid Email Address' ) );
				return null; 
			}
			if (emails.size() == 0)
			{
				apexpages.addMessage( new apexpages.Message ( apexpages.Severity.error , 'No email Selected' , 'Please Enter Email Address' ) );
				return null; 	
			}
			Id timeSheetId = apexpages.currentPage().getParameters().get('id');
			Time_Sheet__c ts = [Select Id , Owner.Email ,  Name , OwnerId from Time_Sheet__c where Id = :timeSheetId];
			PageReference pdf = page.Time_Sheet_Pdf_View;     
	        //pdf.getParameters().put('generatePdf','1');  
	        pdf.getParameters().put('id',ts.Id);    
	        pdf.setRedirect(true);     
	        // Grab it!      
	        Blob b = pdf.getContent();
	        // Create an email attachment 
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			string userEmail = [select Email from user where Id = : userinfo.getUserId()].Email; 
			if (sendEmailtoViewer == true && ( userEmail !=null || userEmail !='' ))
				mail.setBccAddresses(new String[] {userEmail });
			mail.setToAddresses(emails);
			mail.setSenderDisplayName('Zumzum RDI Application');
			mail.setSubject('Please Check Time Sheet Information :' + ts.Name );
			mail.setHtmlBody('Please Check Time Sheet Information for your Time Sheet:'+ ts.Name  + ' <br/><a href=https://c.cs0.visual.force.com/apex/Recievegoods?id='+ts.Id+'>click here</a>'  );
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();     
	        efa.setFileName('Time Sheet Info.pdf'); // neat - set name of PDF     
	        efa.setBody(b);	
			mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			sendBack = true ;
			system.debug('at the end');
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Email is sent' , '' ));
			return null; 
		}
		catch(exception e)
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , e.getMessage() , '' ));
			return null ;
		}
	}
	public pageReference back()
	{
		return new pagereference( '/' + apexpages.currentPage().getParameters().get('id') );
	}
	private static TestMethod void emailTimeSheetinvalidemail()
	{
		Account act = new Account(Name='ABC Company',Type='Customer - Direct');
		insert act;
		Contact cnt = new Contact(LastName = 'test Contact' , AccountId =act.Id ,Email ='test@test.com' );
		insert cnt;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Activity_Code__c ac = new Activity_Code__c(Name = 'Activity 1' , Code__c = 'Activity 1');
		insert ac ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, S_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Time_Sheet__c tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year(); 
		tsinfo.Status__c = 'Approved';
		insert tsinfo ;
		Time_Sheet_Detail__c tsd = new Time_Sheet_Detail__c();
		tsd.Activity_Code__c  = ac.Id ;
		tsd.Date__c = date.today();
		//tsd.Index__c =  0 ;
		tsd.Narrative__c = 'test Code';
		tsd.Total_Hours__c = 15 ;
		//tsd.Total_Miles__c = 0 ;
		tsd.Activity_Code__c = ac.id ;
		tsd.Project__c = op.Id ;
		tsd.Time_Sheet__c = tsinfo.Id;
		insert tsd ;
		
		ApexPages.currentPage ().getParameters ().put ('id', tsinfo.id);
		SendTimeSheettoEmail obj  = new SendTimeSheettoEmail();
        obj.init();
        obj.emailAddresses = 'test@test.com,test2@test.com';//'test@test.com,test2@test.com,785783647r';
		obj.sendEmail();
		obj.back();
		tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year(); 
		tsinfo.Status__c = 'Pending';
		insert tsinfo ;
		try
		{
			obj.init();
		}
		catch(exception e)
		{
			system.assertEquals(tsinfo.Name +' is not Approved, It cannot be Send as Email', e.getMessage());
		}
	}
	
	private static TestMethod void emailTimeSheetinvalidemailnull()
	{
		SendTimeSheettoEmail obj  = new SendTimeSheettoEmail();
        obj.init();
		obj.sendEmail();
		obj.back();
	}
}