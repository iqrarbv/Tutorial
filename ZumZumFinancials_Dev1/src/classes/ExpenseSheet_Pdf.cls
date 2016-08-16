public class ExpenseSheet_Pdf 
{
	public Expense_Sheet__c expenseSheetInfo {get; set;}
	public list<ExpenseSheetDetailWrapper> lstExpenseSheetDetail {get; set;}
	public boolean showPdf {get; set;}
	public Invoice_Template__c invoiceTmpl {get; set;}
	public string imageUrl {get; set;}
	public ExpenseSheet_Pdf( apexpages.Standardcontroller expenseSheet_Pdf )
	{
		init();
	}
	public ExpenseSheet_Pdf(  )
	{
		
	}
	public void init()
	{
		try
		{
			Id expenseSheetId = apexpages.currentPage().getParameters().get('id');
			expenseSheetInfo = [Select e.Total_Miles__c  , e.Status__c , e.OwnerId ,e.Total_VAT__c, e.Total_Net__c, e.Total_Gross__c, e.Name, e.Month__c, e.Id, e.Claim_No__c From Expense_Sheet__c e where e.Id =:expenseSheetId ];
			if (expenseSheetInfo.Status__c != 'Approved' )
			{
				showPdf = false;
				throw new CustomException( expenseSheetInfo.Name + ' is not Approved, You cannot See Expense Sheet information');	
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
			lstExpenseSheetDetail = new list<ExpenseSheetDetailWrapper>();
			
			List<Expense_Sheet_Detail__c> detail_list = [Select e.Miles__c , e.UID__c , e.Business_Passenger__c , e.Unit_Amount__c , e.Total_VAT__c,  e.Total_Net__c, e.Total_Gross__c, e.Tax_Rate__c, e.Status__c, e.Quantity__c, e.Project__c, e.Nominal_Account__c, e.Narrative__c, e.Name, e.Id, e.Expense_Sheet__c, e.Day__c, e.Date__c, e.Date_String__c From Expense_Sheet_Detail__c e where e.Expense_Sheet__c = :expenseSheetInfo.Id ];
			for(Expense_Sheet_Detail__c det : detail_list)
			{
				string status = expenseSheetInfo.Status__c!='Pending'
								&& expenseSheetInfo.Status__c!='rejected'
								? 'Approved'
								: expenseSheetInfo.Status__c;
				lstExpenseSheetDetail.add(new ExpenseSheetDetailWrapper(det,status));
			}
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}
	}
	
	public class ExpenseSheetDetailWrapper
	{
		public Expense_Sheet_Detail__c detail {get;set;}
		public string status {get;set;}
		
		public ExpenseSheetDetailWrapper(Expense_sheet_detail__c det, string sts)
		{
			detail = det;
			status = sts;	
		}	
	}
	public static TestMethod void expenseSheetPDf()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		//Tax_Rate__c tx = [select Id , Tax_Rate__c from Tax_Rate__c limit 1];
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		Opportunity subOp = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , Sub_Project__c =op.Id , CloseDate = date.today().addDays(5));
		insert subOp;
		Expense_Sheet__c esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		esinfo.Status__c = 'Approved';
		insert esinfo;
		Expense_Sheet_Detail__c exp = new Expense_Sheet_Detail__c();
		exp.Date__c = date.today();
		exp.Nominal_Account__c = nm.Id;
		exp.Quantity__c =  1 ;
		exp.Narrative__c = 'test Code';
		exp.Total_Net__c = 15 ;
		exp.Total_VAT__c = 2 ;
		exp.Total_Gross__c = 17 ;
		exp.Project__c = op.Id ;
		exp.Expense_Sheet__c = esinfo.Id ;
		insert exp;
		apexpages.currentPage().getParameters().put('id' , esinfo.Id);
		ExpenseSheet_Pdf obj = new ExpenseSheet_Pdf();
		obj.init();
		esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		insert esinfo;
		apexpages.currentPage().getParameters().put('id' , esinfo.Id);
		try
		{
			obj.init();
		}
		catch(exception e)
		{
			system.assertEquals(esinfo.Name + ' is not Approved, You cannot See Expense Sheet information', e.getMessage());	
		}
		apexpages.currentPage().getParameters().put('id' , null );
		obj.init();
		
	}
}