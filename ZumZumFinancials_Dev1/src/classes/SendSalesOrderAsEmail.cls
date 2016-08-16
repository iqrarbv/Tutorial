public class SendSalesOrderAsEmail 
{
	/*
	public list<emailStruct> emaillist {get; set;}
	public string customEmails {get; set;}
	public Sales_Order__c sO {get; set;}
	public boolean sendBack {get; set;}
	public boolean showPage {get; set;}
	public boolean sendEmailtoViewer {set; get;}
	public SendSalesOrderAsEmail ( apexpages.Standardcontroller sendPurchaseOrderAsEmail )
	{
	
	}
	public SendSalesOrderAsEmail ( )
	{
	
	}
	public pagereference init()
	{
		try
		{
			Id orderId = apexpages.currentPage().getParameters().get('id');
			sO = [Select Id , Status__c, Name , Account__r.Entity_Email__c from  Sales_Order__c where Id = :orderId ];
			if (sO.Status__c != 'Approved')
			{
				showPage = false ;
				sendBack = true ;
				throw new CustomException(sO.Name +' is not Approved, It cannot be Send as Email');
			}
			showPage = true;
			emaillist = new list<emailStruct> ();
			for ( Contact con : [Select c.Email, c.FirstName, c.LastName,  c.Department, c.AccountId From Contact c where c.AccountId = :sO.Account__c AND c.Email != null order By Name ASC limit 1000] )
			{
				emaillist.add( new emailStruct(con.Email ,  con.FirstName+' '+con.LastName , false  ) );	
			}
			system.debug('this is email list' + emaillist);
			return null;
		}
		catch(exception e)
		{
			//apexpages.addMessages(e);
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , e.getMessage() , '' ));
			return null ;
		}
	}
	public pagereference back()
	{
		return new pagereference('/' + apexpages.currentPage().getParameters().get('id') );
	}
	public pagereference sendEmails()
	{
		try
		{
			String[] emails = new String[]{};
			for (emailStruct em : emaillist )
			{
				if ( em.isSelected == true )	
					emails.add(em.Email)	;
			}
			string[] invalidAddresses = new string[]{};
			for(string em : customEmails.split(',' , 0))
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
			if (emails.size() == 0)
			{
				apexpages.addMessage( new apexpages.Message ( apexpages.Severity.error , 'No email Selected' , 'Please Enter Email Address' ) );
				return null; 	
			}
			if (invalidAddresses.size() > 0 )
			{
				apexpages.addMessage( new apexpages.Message ( apexpages.Severity.error , invalidAddresses[0] , ' is an Invalid Email Address' ) );
				return null; 
			}
			List<SalesOrderApprovals__c> approveStatus = [select Status__c from SalesOrderApprovals__c where Sales_Order__c = :sO.Id limit 1];
			string emailAddress = '' ;
			PageReference pdf = page.Sales_Order_Pdf_Veiw;     
            //pdf.getParameters().put('generatePdf','1');  
            pdf.getParameters().put('id',sO.Id);    
            pdf.setRedirect(true);     
            // Grab it!      
            Blob b = pdf.getContent();
            // Create an email attachment
            string userEmail = [select Email from user where Id = : userinfo.getUserId()].Email; 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (sendEmailtoViewer == true && ( userEmail !=null || userEmail !='' ))
				mail.setBccAddresses(new String[] {userEmail });
			mail.setToAddresses(emails);
			mail.setSenderDisplayName('Zumzum RDI Application');
			mail.setSubject('Please Check Sales Order :' + sO.Name );
			mail.setHtmlBody('Please Check Sales Order information for your Sales order:'+ sO.Name  + ' <br/><a href=https://c.cs0.visual.force.com/apex/Recievegoods?id='+sO.Id+'>click here</a>'  );
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();     
            efa.setFileName('Sales Order Info.pdf'); // neat - set name of PDF     
            efa.setBody(b);	
			mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			sendBack  = true ;
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Email is sent to Sales Order Account' , '' ));
			return null;
		}	
		catch(exception e)
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , e.getMessage() , '' ));	
			return null; 	
		}	
	}
	public class emailStruct
	{
		public string Email {get; set;}
		public Boolean isSelected {get; set;}
		public string contactName {get; set;}
		public emailStruct(string contactEmail , string name , boolean emailSelected)
		{
			Email = contactEmail ;
			isSelected = emailSelected ;
			contactName = name ;	
		} 
	}
	private static TestMethod void emailSalesOrder()
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
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, S_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Sales_Order__c Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 150 , Status__c = 'Approved' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		
		Sales_Order_Line_Items__c tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Sales_Order__c = Cont.Id ;
		insert tmpline ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SendSalesOrderAsEmail obj  = new SendSalesOrderAsEmail();
        obj.init();
		obj.emaillist[0].isSelected = true;
		obj.customEmails = 'test@test.com,test2@test.com';
		obj.sendEmails();
		obj.back();
	}
	private static TestMethod void emailSalesOrderinvalidemail()
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
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, S_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Sales_Order__c Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 150 , Status__c = 'Pending' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		
		Sales_Order_Line_Items__c tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Sales_Order__c = Cont.Id ;
		insert tmpline ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SendSalesOrderAsEmail obj  = new SendSalesOrderAsEmail();
        try
        {
        	obj.init();
        }
        catch(exception e)
        {
        	system.assertEquals(Cont.Name +' is not Approved, It cannot be Send as Email', e.getMessage());
        }
		obj.customEmails = 'test@test.com,test2@test.com,785783647r';
		obj.sendEmails();
		obj.back();
	}
	
	private static TestMethod void emailSalesOrdernull()
	{
		//ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        //ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SendSalesOrderAsEmail obj  = new SendSalesOrderAsEmail();
        obj.init();
		obj.sendEmails();
		obj.back();
	}
	*/
}