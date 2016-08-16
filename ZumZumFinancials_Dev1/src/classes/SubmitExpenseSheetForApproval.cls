public class SubmitExpenseSheetForApproval 
{
	/*
	public Id expenseSheetId {get; set;}
	public User ur {get; set;}
	public boolean sendBack {get; set;}
	public SubmitExpenseSheetForApproval( apexpages.Standardcontroller submitExpenseSheet )
	{
		
	}
	public SubmitExpenseSheetForApproval()
	{
		
	}
	public void submitExpenseSheet()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			expenseSheetId = apexpages.currentPage().getParameters().get('id');
			Expense_Sheet__c expSheetinfo = [Select e.Total_VAT__c, e.Total_Net__c, e.Total_Gross__c, e.Status__c, e.OwnerId, e.Name, e.Month__c, e.Id, e.Claim_No__c From Expense_Sheet__c e where e.Id = :expenseSheetId ];
			if (expSheetinfo != null)
			{
				ur = [select Id , Name , Email , UserRoleId from User where id = :Userinfo.getUserId() limit 1 ];
					ExpenseSheet_Model exp = new ExpenseSheet_Model(expSheetinfo.Id) ;
					exp.SubmitForApproval(ur);
					expSheetinfo.Status__c = 'Submitted_For_Approval';
					update(expSheetinfo);
					apexpages.addMessage( new apexpages.Message( apexpages.Severity.CONFIRM , 'Expense Sheet '+ expSheetinfo.Name + ' is submitted for approval' ,''  ) );
					sendBack = true ;
					return ;
			}	
		}	
		catch(exception e)
		{
			sendBack = true ;
			Database.rollback(sp);
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.error , e.getMessage() ,''  ) );
		}
	}
	public pagereference back()
	{
		return new pagereference('/' + apexpages.currentPage().getParameters().get('id')) ;
	}
	/*
	if (expSheetinfo.OwnerId != userinfo.getUserId())
			{
				apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Your are not authorized to view '+ expSheetinfo.Name , ''  ) );
				return ;	
			}
			else if (expSheetinfo.Status__c == 'Approved')
			{
				apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Expense Sheet '+ expSheetinfo.Name + ' is Already approved' ,'' ) );
				return ;
			}
			else if (expSheetinfo.Status__c == 'Submitted_For_Approval')
			{
				apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Expense Sheet '+ expSheetinfo.Name + ' is Already submitted for approval' , '' ) );
				return ;	
			}
			else
			{
	
	public static TestMethod void submittExpenseSheet()
	{
		
		/*
		User ur = [Select Id , Name , Email From User where Id = '00590000000GMWn'];
		System.runAs(ur)
		{
			Account act = new Account(Name='ABC Company',Type='Supplier');
			insert act;
			Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
			insert tx ;
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
			insert esinfo;
			Expense_Sheet_Detail__c lstExpenseSheetVar = new Expense_Sheet_Detail__c();
			lstExpenseSheetVar.Date__c = date.today();
			lstExpenseSheetVar.Nominal_Account__c = nm.Id;
			lstExpenseSheetVar.Index__c =  0 ;
			lstExpenseSheetVar.Quantity__c =  1 ;
			lstExpenseSheetVar.Narrative__c = 'test Code';
			lstExpenseSheetVar.Total_Net__c = 15 ;
			lstExpenseSheetVar.Total_VAT__c = 2 ;
			lstExpenseSheetVar.Total_Gross__c = 17 ;
			lstExpenseSheetVar.Project__c = op.Id ;
			lstExpenseSheetVar.Expense_Sheet__c = esinfo.Id ;
			insert lstExpenseSheetVar ;
			apexpages.currentPage().getParameters().put('id' , esinfo.Id);
			SubmitExpenseSheetForApproval obj = new SubmitExpenseSheetForApproval();
			obj.submitExpenseSheet();
			obj.back();
			esinfo = new Expense_Sheet__c();
			esinfo.Month_Number__c = date.today().month();
			esinfo.Year__c = date.today().year();
			esinfo.Status__c = 'Submitted_For_Approval';
			insert esinfo;
			apexpages.currentPage().getParameters().put('id' , null);
			obj.submitExpenseSheet();
		}
		
	}
	public static TestMethod void submittExpenseSheetNormalUser()
	{
		
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
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
		insert esinfo;
		Expense_Sheet_Detail__c lstExpenseSheetVar = new Expense_Sheet_Detail__c();
		lstExpenseSheetVar.Date__c = date.today();
		lstExpenseSheetVar.Nominal_Account__c = nm.Id;
		lstExpenseSheetVar.Quantity__c =  1 ;
		lstExpenseSheetVar.Narrative__c = 'test Code';
		lstExpenseSheetVar.Total_Net__c = 15 ;
		lstExpenseSheetVar.Total_VAT__c = 2 ;
		lstExpenseSheetVar.Total_Gross__c = 17 ;
		lstExpenseSheetVar.Project__c = op.Id ;
		lstExpenseSheetVar.Expense_Sheet__c = esinfo.Id ;
		insert lstExpenseSheetVar ;
		apexpages.currentPage().getParameters().put('id' , esinfo.Id);
		SubmitExpenseSheetForApproval obj = new SubmitExpenseSheetForApproval();
		obj.submitExpenseSheet();
		obj.back();
		esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		esinfo.Status__c = 'Submitted_For_Approval';
		insert esinfo;
		apexpages.currentPage().getParameters().put('id' , null);
		obj.submitExpenseSheet();
	}
	*/
}