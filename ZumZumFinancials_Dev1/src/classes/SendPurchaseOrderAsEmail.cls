public class SendPurchaseOrderAsEmail 
{
	/*
	public list<emailStruct> emaillist {get; set;}
	public string customEmails {get; set;}
	public Purchase_Order__c pO {get; set;}
	public boolean sendBack {get; set;}
	public boolean showPage {get; set;}
	public boolean sendEmailtoViewer {set; get;}
	public SendPurchaseOrderAsEmail ( apexpages.Standardcontroller sendPurchaseOrderAsEmail )
	{
	
	}
	public SendPurchaseOrderAsEmail ( )
	{
	
	}
	public pagereference init()
	{
		try
		{
			Id orderId = apexpages.currentPage().getParameters().get('id');
			pO = [Select Id , Status__c, Name , Project__c, OwnerId, Order_By__c,  Account__r.Name  , Account__r.Entity_Email__c from  Purchase_Order__c where Id = :orderId ];
			if (pO.Status__c != 'Approved')
			{
				showPage = false;
				sendBack = true ;
				throw new CustomException(pO.Name +' is not Approved, It cannot be Send as Email');
			}	
			showPage = true ;
			emaillist = new list<emailStruct> ();
			for ( Contact con : [Select c.Email, c.FirstName, c.LastName,  c.Department, c.AccountId From Contact c where c.AccountId = :pO.Account__c AND c.Email != null order By Name ASC limit 1000 ] )
			{
				emaillist.add( new emailStruct(con.Email ,  con.FirstName+' '+con.LastName , false  ) );	
			}
			system.debug('this is email list' + emaillist);
			return null ;
		}
		catch(exception e)
		{
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
			PageReference pdf = page.Purchase_Order_Pdf_View;     
            pdf.getParameters().put('id',pO.Id);    
            pdf.setRedirect(true);     
            // Grab it!      
            Blob b = pdf.getContent();
            // Create an email attachment 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(emails);
			string userEmail = [select Email from user where Id = : userinfo.getUserId()].Email; 
			if (sendEmailtoViewer == true && ( userEmail !=null || userEmail !='' ))
				mail.setBccAddresses(new String[] {userEmail }); 
			mail.setSenderDisplayName('Zumzum RDI Application');
			mail.setSubject('Please Check Purchase order :' + pO.Name );
			mail.setHtmlBody('Please Check Purchase order information for your Purchase order:'+ pO.Name  + ' <br/><a href=https://c.cs0.visual.force.com/apex/Recievegoods?id='+pO.Id+'>click here</a>'  );
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();     
            efa.setFileName('Purchase Order Info.pdf'); // neat - set name of PDF     
            efa.setBody(b);	
			mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			system.debug('at the end');
			sendBack = true ;
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Email is sent to Purchase Order Account' , '' ));
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
	private static TestMethod void emailPurchaseOrder()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Contact cnt = new Contact(LastName = 'test Contact' , AccountId =act.Id ,Email ='test@test.com' );
		insert cnt;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Purchase_Order__c Cont = new Purchase_Order__c(Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 150 , Status__c = 'Approved' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		
		Purchase_Order_Line_Items__c tmpline = new Purchase_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Purchase_Order__c = Cont.Id ;
		insert tmpline ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SendPurchaseOrderAsEmail obj  = new SendPurchaseOrderAsEmail();
        obj.init();
		obj.emaillist[0].isSelected = true;
		obj.customEmails = 'test@test.com,test2@test.com';
		obj.sendEmails();
		obj.back();
	}
	private static TestMethod void emailPurchaseOrderInvalid()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Contact cnt = new Contact(LastName = 'test Contact' , AccountId =act.Id ,Email ='test@test.com' );
		insert cnt;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Purchase_Order__c Cont = new Purchase_Order__c(Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 150 , Status__c = 'Pending' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		
		Purchase_Order_Line_Items__c tmpline = new Purchase_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Purchase_Order__c = Cont.Id ;
		insert tmpline ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SendPurchaseOrderAsEmail obj  = new SendPurchaseOrderAsEmail();
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
	
	private static TestMethod void emailPurchaseOrdernull()
	{
		//ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        //ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SendPurchaseOrderAsEmail obj  = new SendPurchaseOrderAsEmail();
        obj.init();
		obj.sendEmails();
		obj.back();
	}
	*/
}