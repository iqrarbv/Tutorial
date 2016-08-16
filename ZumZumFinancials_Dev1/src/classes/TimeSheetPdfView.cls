public class TimeSheetPdfView 
{
	public Time_Sheet__c timeSheetInfo {get; set;}
	public List<timsheetDetailWrapper> timeSheetDetail {get; set;}
	public string managerCode {get; set;}
	public boolean showPdf {get; set;} 
	public Invoice_Template__c invoiceTmpl {get; set;}
	public string imageUrl {get; set;}
	public TimeSheetPdfView( apexpages.Standardcontroller pdfView )
	{
		init();	
	}
	public TimeSheetPdfView(  )
	{
		
	}
	public void init()
	{
		try
		{
			Id viewId = apexpages.currentPage().getParameters().get('id');
			timeSheetInfo = [select Id , ownerid ,Status__c ,  Name , Total_Hours__c , Owner.Name from Time_Sheet__c where Id = :viewId];
			if (timeSheetInfo.Status__c != 'Approved' )
			{
				showPdf = false;
				throw new CustomException( timeSheetInfo.Name + ' is not Approved, You cannot See Time Sheet information');	
			}
			List<Invoice_Template__c> invTmpl = [Select i.Footer_Text__c  , i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, i.Heading_Text__c, i.Font_Size__c, i.Font_Face__c From Invoice_Template__c i where Is_Default__c = true];
			if(invTmpl.size() == 0)
				throw new CustomException('No Default Template Found , Please select Template as default');
			else
				invoiceTmpl = invTmpl[0] ;
			List<Attachment> att = [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body From Attachment a where a.ParentId = : invoiceTmpl.id  limit 1];
			if(att.size() > 0 )
				imageUrl = 'https://'+apexpages.currentPage().getHeaders().get('host').substring(0 ,apexpages.currentPage().getHeaders().get('host').indexOf('.',2))+'.content.force.com/servlet/servlet.FileDownload?file='+string.valueof(att[0].id) ;
			else
				throw new CustomException('No Invoice Logo Found for Default Template, Please Upload Logo for Default Template');
			showPdf = true;
			timeSheetDetail = new List<timsheetDetailWrapper>();
			for(Time_Sheet_Detail__c td : [Select t.Account__c , t.Date_String__c ,  t.Total_Hours__c, t.Time_Sheet__c, t.Project__c , t.Narrative__c, t.Name_of_business_passenger__c, t.Name,t.Id, t.Day__c, t.Date__c, t.Activity_Code__c From Time_Sheet_Detail__c t where t.Time_Sheet__c = :timeSheetInfo.Id ])
			{
				string status = timeSheetInfo.Status__c!='pending'
								&& timeSheetInfo.Status__c!='rejected'
								? 'Approved'
								: timeSheetInfo.Status__c;
				
				 
				timeSheetDetail.add(new timsheetDetailWrapper(td,status));		
			}
			system.debug(timeSheetDetail);
		}	
		catch ( exception e)
		{
			apexpages.addMessages(e);		
		}
	}
	// This is Test Codes
	public static TestMethod void timeSheetPdfView()
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
		tsd.Narrative__c = 'test Code';
		tsd.Total_Hours__c = 15 ;
		tsd.Activity_Code__c = ac.id ;
		tsd.Project__c = op.Id ;
		tsd.Time_Sheet__c = tsinfo.Id;
		insert tsd ;
		ApexPages.currentPage ().getParameters ().put ('id', tsinfo.id);
		TimeSheetPdfView obj  = new TimeSheetPdfView();
        obj.init();	
        tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year();
		tsinfo.Status__c = 'Approved';
		insert tsinfo ;	
		ApexPages.currentPage ().getParameters ().put ('id', tsinfo.id);
		try
		{
			obj.init();
		}
		catch(exception e)
		{
			system.assertEquals(tsinfo.Name + ' is not Approved, You cannot See Expense Sheet information', e.getMessage());	
		}
		ApexPages.currentPage ().getParameters ().put ('id', null);
		obj.init();
	}
}