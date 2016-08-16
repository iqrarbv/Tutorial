public class EditExpenseSheet_Controller 
{
	public decimal totalVAT {get; set;}
	public decimal totalGrossAmount {get; set;}
	public decimal totalNetAmount {get; set;}
	public decimal totalMiles {get; set;}
	public decimal totalUnitAmount {get; set;}
	public Expense_Sheet__c expenseSheetInfo {get; set;}
	public list<Expense_Sheet_Detail__c> lstExpenseSheetDetail {get; set;}
	public list<expenseSheetDetailWrapper> wrapexpenseSheet {get; set;}
	public Expense_Sheet_Detail__c lstExpenseSheetVar {get; set;} 
	public expenseSheetDetailWrapper wrapplstExpenseSheetVar {get; set;} 
	public List<Nominal_Account__c> nominalAllAccounts {get; set;}
	public list<Opportunity> allProjects {set; get;}
	public list<Opportunity> allSubProjects {set; get;}
	public map<Id , Id> nomAccountToTaxRate {set; get;}
	public list<Tax_Rate__c> taxRateList {get; set;}
	public map<Id , decimal> taxRateMap {get; set;}
	public string currencySymbol {get; set;}
	public boolean allowedit {get; set;}
	public boolean allreadyEdited {get; set;}
	public List<expenseSheetDetailWrapper> filteredExpenseSheet {get ; set;}
	public boolean filterSheet {get; set;}
	public boolean fullSheet {get; set;}
	public string project {get; set;}
	public string subProject {get; set;}
	public string activityCodess {get; set;}
	public string filterDate {get; set;}
	public string filterendDate {get; set;}
	public Id editId {get; set;}
	public EditExpenseSheet_Controller ( apexpages.Standardcontroller editExpenseSheet )
	{
		init();
	}
	public EditExpenseSheet_Controller (  )
	{
		
	}
	public void filterTimeSheet()
	{
		//newTimeSheet = [Select t.Index__c , t.Total_Miles__c, t.Total_Hours__c, t.Time_Sheet__c, t.Sub_Project__c, t.Status__c, t.Project__c, t.Narrative__c, t.Name_of_business_passenger__c, t.Name, t.LM_Status__c, t.Id, t.Day__c, t.Date__c, t.BH_Status__c, t.Activity_Code__c From Time_Sheet_Detail__c t where t.Project__c = :project AND t.Sub_Project__c = :subProject AND Activity_Code__c = :activityCodess]	;
		try
		{
			filteredExpenseSheet = new List<expenseSheetDetailWrapper>();
			if ( (project == null || project == '') &&  activityCodess == null && subProject == null && (filterDate ==null || filterDate =='') && (filterendDate ==null || filterendDate =='') )
			{
				fullSheet = true ;
				filterSheet = false ;
				apexpages.addMessage(new apexpages.Message(apexpages.severity.info , 'Please select filter values i-e Project, Sub Project etc.' , '')) ; // customexception('Please Select filter values i-e Project, Sub Project') ;
				return ;
			}
			else
			{
				fullSheet = false ;
				filterSheet = true ;
			}
			if (filterDate != null && filterDate != '')
			Date st = Date.parse(filterDate.trim());
			if (filterendDate != null && filterendDate != '')
				Date et = Date.parse(filterendDate.trim());	
			if (filterendDate != null && filterendDate != '' && filterDate != null && filterDate != '' )
			{
				if (Date.parse(filterendDate.trim()) < Date.parse(filterDate.trim()) )
					throw new customexception('End date must be greater than Start Date') ;
			}
			for (expenseSheetDetailWrapper ts : wrapexpenseSheet) 
			{
				//if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Sub_Project__c == subProject && ts.timeSheetDetail.Activity_Code__c == activityCodess )
				if (project != null && subProject == null && activityCodess == null && (filterDate == null || filterDate == '') )
				{
					if (ts.expenseSheetDetail.Project__c ==  project )	
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if (project != null && subProject != null && activityCodess == null && (filterDate == null && filterDate == '') )
				{
					if (ts.expenseSheetDetail.Project__c ==  project )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if (project != null && subProject != null && activityCodess == null && (filterDate == null || filterDate == '') )
				{
					if (ts.expenseSheetDetail.Project__c ==  project )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				// this is my code
				else if (project != null && activityCodess ==null && (filterDate!=null && filterDate!='') && (filterendDate!=null && filterendDate!=''))
				{
					if (ts.expenseSheetDetail.Project__c ==  project && ts.expenseSheetDetail.Date__c >= Date.parse(filterDate.trim()) && ts.expenseSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if (project != null && activityCodess ==null && (filterDate!=null && filterDate!='') )
				{
					if (ts.expenseSheetDetail.Project__c ==  project && ts.expenseSheetDetail.Date__c >= Date.parse(filterDate.trim()) )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if (project != null && activityCodess ==null  && (filterendDate!=null && filterendDate!=''))
				{
					if (ts.expenseSheetDetail.Project__c ==  project && ts.expenseSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				//this code is added
				else if (project != null && activityCodess !=null && (filterDate!=null && filterDate!='') && (filterendDate!=null && filterendDate!='') )
				{
					if (ts.expenseSheetDetail.Project__c ==  project && ts.expenseSheetDetail.Nominal_Account__c == activityCodess && ts.expenseSheetDetail.Date__c >= Date.parse(filterDate) && ts.expenseSheetDetail.Date__c <= Date.parse(filterendDate))
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if (project != null && activityCodess !=null && (filterDate!=null || filterDate!=''))
				{
					if (ts.expenseSheetDetail.Project__c ==  project && ts.expenseSheetDetail.Nominal_Account__c == activityCodess )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if (project == null && activityCodess !=null )
				{
					if (ts.expenseSheetDetail.Nominal_Account__c == activityCodess )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if( (filterDate!=null && filterDate !='' && filterendDate!=null && filterendDate !='' )  && project == null && activityCodess ==null ) 
				{
					if (ts.expenseSheetDetail.Date__c >= Date.parse(filterDate) && ts.expenseSheetDetail.Date__c <= Date.parse(filterendDate))
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);		
				}
				else if( (filterDate!=null && filterDate !='' && filterendDate ==null || filterendDate =='' )  && project == null && activityCodess ==null ) 
				{
					if (ts.expenseSheetDetail.Date__c >= Date.parse(filterDate.trim()) )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);		
				}
				else if( (filterendDate !=null && filterendDate != '')  && project == null && activityCodess ==null ) 
				{
					if (ts.expenseSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);		
				}
					
			}
			if (filteredExpenseSheet.size() == 0 && filterSheet ==true )
			{
				totalVAT = 0.00 ;
				totalGrossAmount = 0.00 ;
				totalNetAmount = 0.00 ;
				totalMiles  = 0.00 ; 
				totalUnitAmount = 0.00 ;
			}	
			else if (filteredExpenseSheet.size() > 0 && filterSheet ==true)
				this.filteredtotalvalues();
			else
				totalvalues() ;
		}
		catch (Exception Te)
		{
			apexpages.addMessages(Te);	
		}	
	}
	public void filterSubProject()
	{
		if (project != null )
			allSubProjects = [select Id , Name from Opportunity where Sub_Project__c = :project and StageName  != 'Closed Won' and  StageName != 'Closed Lost' order by Name limit 1000 ] ;
		else
			allSubProjects = [select Id , Name from Opportunity where Sub_Project__c != null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 0 ] ;	
	}
	public void init()
	{
		try
		{
			fullSheet = true;
			filterSheet = false ;
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			EditId = apexpages.currentPage().getParameters().get('id');
			expenseSheetInfo = [Select  e.type__c , e.CreatedDate, e.OwnerId ,e.Status__c , e.Month_Number__c , e.Year__c , e.Total_VAT__c, e.Total_Net__c, e.Total_Gross__c, e.Name, e.Month__c, e.Id, e.Claim_No__c From Expense_Sheet__c e where e.Id =:EditId ];
			if (expenseSheetInfo.OwnerId != userinfo.getUserId())
			{
				allowedit = false ;
				throw new CustomException('You are not Authorized to edit Expense Sheet: ' + expenseSheetInfo.Name );
				return ;	
			}
			else if(expenseSheetInfo.Status__c == 'Submitted_For_Approval' || expenseSheetInfo.Status__c == 'Approved' )
			{	
				allowedit = false ;
				throw new CustomException('Expense Sheet: ' + expenseSheetInfo.Name + ' is '+ expenseSheetInfo.Status__c +' You cannot change its contents');
				return ;
			}			
			allowedit = true ;
			lstExpenseSheetDetail = [Select e.Tax_Rate__r.Tax_Rate__c , e.Miles__c , e.Business_Passenger__c, e.Unit_Amount__c , e.Account__c , e.Total_VAT__c, e.Total_Net__c, e.Total_Gross__c, e.Tax_Rate__c, e.Status__c, e.Quantity__c, e.Project__c, e.Nominal_Account__c, e.Narrative__c, e.Name, e.Id, e.Expense_Sheet__c, e.Day__c, e.Date__c, e.Date_String__c From Expense_Sheet_Detail__c e where e.Expense_Sheet__c = :expenseSheetInfo.Id Order by Date__c Asc ];
			wrapexpenseSheet = new list<expenseSheetDetailWrapper> ();
			for (Expense_Sheet_Detail__c exp :  lstExpenseSheetDetail)
			{
				expenseSheetDetailWrapper expense = new expenseSheetDetailWrapper(exp);
				expense.Index = wrapexpenseSheet.size();
				expense.taxRate = exp.Tax_Rate__r.Tax_Rate__c ;
				wrapexpenseSheet.add(expense);
			}
			totalvalues();
			lstExpenseSheetVar = new Expense_Sheet_Detail__c();
			addLineItem();
			nominalAllAccounts  = [select Id , Name ,Tax_Rate__c, Account_Code__c , Nominal_Code__c from Nominal_Account__c   Order By Nominal_Code__c Asc limit 1000];
			allprojects = [select Id , Name from Opportunity where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ];
			allSubprojects = [select Id , Name from Opportunity where Sub_Project__c != null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 0 ];
			taxRateList = [select Id , Name ,Tax_Rate__c from Tax_Rate__c  Order By Name limit 1000];
			nomAccountToTaxRate = new map<Id , Id>();
			taxRateMap = new map<Id , decimal>();
			if (taxRateList.size()==0)
				throw new customexception('No Tax Rates Found,  Please Insert Tax Rate for Expenses Type from Administrative setup');
			for (Nominal_Account__c nm : nominalAllAccounts)
			{
				nomAccountToTaxRate.put(nm.Id , nm.Tax_Rate__c );	
			}
			for (Tax_Rate__c tx : taxRateList)
			{
				taxRateMap.put(tx.Id , tx.Tax_Rate__c);	
			}
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public pagereference back()
	{
		return new pagereference ('/' +  editId ) ;	
	}
	public void editListItems()
	{
		integer editId ;
	 	if (ApexPages.currentPage().getParameters().get('editId') != null || ApexPages.currentPage().getParameters().get('editId') != '')
	 	{
	 		if (allreadyEdited == true)
	 			addExpenseSheetItem();	
	 		allreadyEdited = true ;
	 		editId = ExpenseSheet_Model.getListIndex(ApexPages.currentPage().getParameters().get('editId'));
	 		lstExpenseSheetVar.Date__c  = wrapexpenseSheet[editId].expenseSheetDetail.Date__c ;
			lstExpenseSheetVar.Nominal_Account__c  = wrapexpenseSheet[editId].expenseSheetDetail.Nominal_Account__c ;
			lstExpenseSheetVar.Narrative__c  = wrapexpenseSheet[editId].expenseSheetDetail.Narrative__c ;
			lstExpenseSheetVar.Quantity__c  = wrapexpenseSheet[editId].expenseSheetDetail.Quantity__c ;
			lstExpenseSheetVar.Total_Gross__c  = wrapexpenseSheet[editId].expenseSheetDetail.Total_Gross__c ;
			lstExpenseSheetVar.Total_VAT__c  = wrapexpenseSheet[editId].expenseSheetDetail.Total_VAT__c ;
			lstExpenseSheetVar.Total_Net__c  = wrapexpenseSheet[editId].expenseSheetDetail.Total_Net__c ;
			lstExpenseSheetVar.Project__c  = wrapexpenseSheet[editId].expenseSheetDetail.Project__c ;
			lstExpenseSheetVar.Tax_Rate__c  = wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c ;
			lstExpenseSheetVar.Account__c  = wrapexpenseSheet[editId].expenseSheetDetail.Account__c ;
			lstExpenseSheetVar.Business_Passenger__c  = wrapexpenseSheet[editId].expenseSheetDetail.Business_Passenger__c ;
			lstExpenseSheetVar.Miles__c  = wrapexpenseSheet[editId].expenseSheetDetail.Miles__c ;
			lstExpenseSheetVar.Unit_Amount__c  = wrapexpenseSheet[editId].expenseSheetDetail.Unit_Amount__c ;
			//if (taxRateMap.keyset().contains(wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c))
				//gtaxrate = taxRateMap.get(wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c);
			//else
				//gtaxrate = [Select Tax_Rate__c from Tax_Rate__c where Id = : wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c].Tax_Rate__c;	
			gtaxrate = wrapexpenseSheet[editId].taxRate ;
			//ExpenseSheet_Model.getUpdateExpenseSheetList(lstExpenseSheetDetail);
			getUpdateExpenseSheetList(wrapexpenseSheet ,getListIndex(ApexPages.currentPage().getParameters().get('editId')) );
			wrapexpenseSheet.remove(getListIndex(ApexPages.currentPage().getParameters().get('editId')));
			totalvalues();
			if (filterSheet == true )
				filterTimeSheet();
		}	
	}
	public void CloneEntry()
	{
		integer editId ;
		if (ApexPages.currentPage().getParameters().get('cloneId') != null || ApexPages.currentPage().getParameters().get('cloneId') != '')
	 	{
	 		editId = ExpenseSheet_Model.getListIndex(ApexPages.currentPage().getParameters().get('cloneId'));
	 		Expense_Sheet_Detail__c tmptimesheet = new Expense_Sheet_Detail__c();
			tmptimesheet.Date__c = wrapexpenseSheet[editId].expenseSheetDetail.Date__c ;
			tmptimesheet.Day__c = ExpenseSheet_Model.getDayString(wrapexpenseSheet[editId].expenseSheetDetail.Date__c) ; 
			tmptimesheet.Date_String__c = ExpenseSheet_Model.getDateWithMonth(wrapexpenseSheet[editId].expenseSheetDetail.Date__c); 
			tmptimesheet.Narrative__c = wrapexpenseSheet[editId].expenseSheetDetail.Narrative__c;
			tmptimesheet.Quantity__c = wrapexpenseSheet[editId].expenseSheetDetail.Quantity__c ;
			tmptimesheet.Total_Gross__c = wrapexpenseSheet[editId].expenseSheetDetail.Total_Gross__c ;
			tmptimesheet.Total_VAT__c = wrapexpenseSheet[editId].expenseSheetDetail.Total_VAT__c ;
			tmptimesheet.Total_Net__c = wrapexpenseSheet[editId].expenseSheetDetail.Total_Net__c ;
			tmptimesheet.Project__c = wrapexpenseSheet[editId].expenseSheetDetail.Project__c ;
			tmptimesheet.Unit_Amount__c = wrapexpenseSheet[editId].expenseSheetDetail.Unit_Amount__c;
			tmptimesheet.Business_Passenger__c = wrapexpenseSheet[editId].expenseSheetDetail.Business_Passenger__c;
			tmptimesheet.Miles__c = wrapexpenseSheet[editId].expenseSheetDetail.Miles__c;
			tmptimesheet.Account__c = wrapexpenseSheet[editId].expenseSheetDetail.Account__c;
			tmptimesheet.Nominal_Account__c = wrapexpenseSheet[editId].expenseSheetDetail.Nominal_Account__c ;
			tmptimesheet.Tax_Rate__c = wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c ;
			
			expenseSheetDetailWrapper tmwrapp = new expenseSheetDetailWrapper(tmptimesheet) ;
			tmwrapp.Index = wrapexpenseSheet.size();
			tmwrapp.taxRate = wrapexpenseSheet[editId].taxRate ;
			wrapexpenseSheet.add( tmwrapp );
			totalvalues() ;
			if (filterSheet == true )
				filterTimeSheet();
		}	
	}
	public void clearfilter()
	{
		project = null ;
		subProject = null ;
		activityCodess = null ;
		filterDate = null ;
		filterendDate = null ;
		fullSheet = true ;
		filterSheet = false ;	
		totalvalues() ;
		filterSubProject();
	}
	public void totalvalues()
	{
		totalVAT = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'VAT');
		totalGrossAmount = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'GROSS');
		totalNetAmount = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'NET');
		totalMiles = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'MILES');
		totalUnitAmount =  ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'UNITAMOUNT');
	}
	public void filteredtotalvalues()
	{
		totalVAT = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'VAT');
		totalGrossAmount = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'GROSS');
		totalNetAmount = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'NET');
		totalMiles = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'MILES');
		totalUnitAmount =  ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'UNITAMOUNT');
	}
	public void deletListItems()
	{
		if (ApexPages.currentPage().getParameters().get('deletId') != null || ApexPages.currentPage().getParameters().get('deletId') != '')
	 	{
	 		wrapexpenseSheet.remove(getListIndex(ApexPages.currentPage().getParameters().get('deletId')));	
	 		getUpdateExpenseSheetList(wrapexpenseSheet , getListIndex(ApexPages.currentPage().getParameters().get('deletId')));
	 		totalvalues();
	 		if (filterSheet == true )
				filterTimeSheet();
	 	}	
	}
	public void getUpdateExpenseSheetList(List<expenseSheetDetailWrapper> expenseSheetOld , integer listIndex)
	{
		List<expenseSheetDetailWrapper> tmpSheet  = new List<expenseSheetDetailWrapper>();
		for (expenseSheetDetailWrapper tc : wrapexpenseSheet)
		{
			if( tc.Index > listIndex )
				tc.Index -= 1 ;
			tmpSheet.add(tc);	
		}
		wrapexpenseSheet = tmpSheet ;
	}
	public integer getListIndex(string sIndex)
	{
		decimal index = decimal.valueof(sIndex);
		integer intIndex = integer.valueof(string.valueof(index.divide(1,0,system.roundingmode.UNNECESSARY)));
		system.debug(intIndex);
		return intIndex ;
	}
	public void addExpenseSheetItem()
	{
		try
		{
			ExpenseSheet_Model.validate_expenseSheetDetails(wrapplstExpenseSheetVar.expenseSheetDetail , integer.valueof(expenseSheetInfo.Month_Number__c) , integer.valueof(expenseSheetInfo.Year__c) );
			Expense_Sheet_Detail__c tmpSheet = new Expense_Sheet_Detail__c();
			tmpSheet.Date__c = wrapplstExpenseSheetVar.expenseSheetDetail.Date__c ;
			tmpSheet.Date_String__c = ExpenseSheet_Model.getDateWithMonth(wrapplstExpenseSheetVar.expenseSheetDetail.Date__c);
			tmpSheet.Tax_Rate__c = wrapplstExpenseSheetVar.expenseSheetDetail.Tax_Rate__c ;
			tmpSheet.Day__c = ExpenseSheet_Model.getDayString(wrapplstExpenseSheetVar.expenseSheetDetail.Date__c);
			tmpSheet.Nominal_Account__c = wrapplstExpenseSheetVar.expenseSheetDetail.Nominal_Account__c ;
			tmpSheet.Narrative__c = wrapplstExpenseSheetVar.expenseSheetDetail.Narrative__c ;
			tmpSheet.Quantity__c = wrapplstExpenseSheetVar.expenseSheetDetail.Quantity__c ;
			tmpSheet.Total_Gross__c = wrapplstExpenseSheetVar.expenseSheetDetail.Total_Gross__c ;
			tmpSheet.Unit_Amount__c = wrapplstExpenseSheetVar.expenseSheetDetail.Unit_Amount__c ;
			tmpSheet.Business_Passenger__c =  wrapplstExpenseSheetVar.expenseSheetDetail.Business_Passenger__c ;
			tmpSheet.Account__c = wrapplstExpenseSheetVar.expenseSheetDetail.Account__c ;
			tmpSheet.Miles__c = wrapplstExpenseSheetVar.expenseSheetDetail.Miles__c ;
			tmpSheet.Total_VAT__c = wrapplstExpenseSheetVar.expenseSheetDetail.Total_VAT__c ;
			tmpSheet.Total_Net__c = wrapplstExpenseSheetVar.expenseSheetDetail.Total_Net__c ;
			tmpSheet.Project__c = wrapplstExpenseSheetVar.expenseSheetDetail.Project__c ;
			expenseSheetDetailWrapper tmwrapp = new expenseSheetDetailWrapper(tmpSheet) ;
			tmwrapp.Index = wrapexpenseSheet.size();
			tmwrapp.taxRate = gtaxrate ;
			wrapexpenseSheet.add( tmwrapp );
			clearExpenseSheetValues();
			totalvalues();
			allreadyEdited = false ;
			if (filterSheet == true )
				filterTimeSheet();
					
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public void clearExpenseSheetValues()
	{
		lstExpenseSheetVar.Date__c  = date.today() ;
		lstExpenseSheetVar.Nominal_Account__c  = null ;
		lstExpenseSheetVar.Narrative__c  = 'Item name' ;
		lstExpenseSheetVar.Quantity__c  = 1 ;
		lstExpenseSheetVar.Total_Gross__c  = 0.00 ;
		lstExpenseSheetVar.Total_VAT__c  = 0.00 ;
		lstExpenseSheetVar.Total_Net__c  = 0.00 ;
		lstExpenseSheetVar.Project__c  = null ;
		lstExpenseSheetVar.Tax_Rate__c  = null ;
		lstExpenseSheetVar.Unit_Amount__c = 0.00 ;
		lstExpenseSheetVar.Account__c = null  ;
		lstExpenseSheetVar.Miles__c = null  ;
		lstExpenseSheetVar.Business_Passenger__c = '' ; 
		gtaxrate = 0.00 ;
		wrapplstExpenseSheetVar = new expenseSheetDetailWrapper(lstExpenseSheetVar);
	}
	public void addLineItem()
	{
		lstExpenseSheetVar.Date__c = date.today();
		lstExpenseSheetVar.Narrative__c  = 'Item name' ;
		lstExpenseSheetVar.Quantity__c  = 1 ;
		lstExpenseSheetVar.Total_Gross__c  = 0.00 ;
		lstExpenseSheetVar.Total_VAT__c  = 0.00 ;
		lstExpenseSheetVar.Total_Net__c  = 0.00 ;
		lstExpenseSheetVar.Unit_Amount__c  = 0.00 ;
		lstExpenseSheetVar.Miles__c  = 0.00 ;
		lstExpenseSheetVar.Business_Passenger__c  = '' ;
		lstExpenseSheetVar.Account__c = null ;
		lstExpenseSheetVar.Date__c = date.today();
		gtaxrate = 0.00 ;
		wrapplstExpenseSheetVar = new expenseSheetDetailWrapper(lstExpenseSheetVar);
		
	}
	public list<selectoption> getNominalAccounts()
	{
		list<selectoption> NominalAccounts = new list<selectoption>();
		NominalAccounts.add(new selectoption( '' , 'Select Nominal Code' ));
		if (nominalAllAccounts.size()>0)
		{
			string code = '' ;
			for (Nominal_Account__c nm : nominalAllAccounts)
			{
				if (nm.Nominal_Code__c != null)
					code = nm.Nominal_Code__c + ' - ' + nm.Name;
				else
					code = nm.Name ; 
				NominalAccounts.add( new selectoption( nm.Id , code ) );	
			}
		}
		else 
			throw new customexception('No Nominal Account Found, Please Eneter Nominal Acocunt');
		return NominalAccounts;
		//return Functions.getNominalAccounts();
	}
	public list<selectoption> getProjects()
	{
		list<selectoption> Projects = new list<selectoption>();
		Projects.add(new selectoption( '' , 'Select Opportunity' ));
		if (allProjects.size() > 0)
		{
			string code  = '' ;
			for (Opportunity nm : allProjects)
			{
				Projects.add( new selectoption( nm.Id , nm.Name ) );	
			}
		}
		else 
			throw new customexception('No Opportunity Exist , Please Opportunity Projects');
		return Projects;
		//return Functions.getNominalAccounts();
	}
	public list<selectoption> getAllTaxRates()
	{
		list<selectoption> AllTaxRates = new list<selectoption> ();
		AllTaxRates.add(new selectoption( '' , 'Select Tax Rate' ));
		if (taxRateList.size() > 0)
		{
			for (Tax_Rate__c tx : taxRateList)
			{
				AllTaxRates.add(new selectoption( tx.Id , tx.Tax_Rate__c + ' % ' + tx.Name ));	
			} 
		}
		//else 
			//throw new customexception('Tax Rate Not Entered, Please Enter Tax Rate for your Organisation');
		return AllTaxRates ; 
	}
	public PageReference saveTimeSheet()
	{
		Savepoint sp = Database.setsavepoint();
		try
		{
			ExpenseSheet_Model expObject = new ExpenseSheet_Model(expenseSheetInfo);
			expObject.saveExpenseSheet(wrapexpenseSheet, expenseSheetInfo, 'UPDATE');
			return new pageReference('/' + expObject.expenseSheet.Id );
		}
		catch(exception e)
		{
			Database.rollback(sp);
			//apexpages.addMessage( new apexpages.Message( apexpages.severity.info , e.getMessage()  , '') );	
			apexpages.addMessages(e);
			return null ;
		}
	}
	public decimal gtaxrate {get; set;}
	public void getTaxPrice()
	{
		decimal taxRate = 0 ;
		try
		{
			if (lstExpenseSheetVar.Nominal_Account__c != null)
			{
				//validate_AmountnQuantity();
				lstExpenseSheetVar.Total_VAT__c  = 0 ;
				lstExpenseSheetVar.Total_Gross__c = 0 ;
				Id taxRateId = nomAccountToTaxRate.get(lstExpenseSheetVar.Nominal_Account__c);
				//lstExpenseSheetVar.Tax_Rate__c = nomAccountToTaxRate.get(lstExpenseSheetVar.Nominal_Account__c);
				if (nomAccountToTaxRate.keyset().contains(lstExpenseSheetVar.Nominal_Account__c))
					lstExpenseSheetVar.Tax_Rate__c = nomAccountToTaxRate.get(lstExpenseSheetVar.Nominal_Account__c);
				else
					lstExpenseSheetVar.Tax_Rate__c = [select Id from Tax_Rate__c where Id IN(Select Tax_Rate__c from Nominal_Account__c where id= : lstExpenseSheetVar.Nominal_Account__c) ].Id;
				if (taxRateMap.keyset().contains(taxRateId))
					taxRate = taxRateMap.get(taxRateId);
				else
					taxrate = 0.00;
					//taxrate = [Select Tax_Rate__r.Tax_Rate__c from Nominal_Account__c where Id = : lstExpenseSheetVar.Nominal_Account__c].Tax_Rate__r.Tax_Rate__c;
				//taxRate = taxRateMap.get(taxRateId);
				gtaxrate = taxRate ;
				//lstExpenseSheetVar.Total_VAT__c = lstExpenseSheetVar.Total_Net__c.divide(100,3,system.roundingmode.up) * taxRate  ;
				lstExpenseSheetVar.Total_VAT__c = ((lstExpenseSheetVar.Unit_Amount__c/100) * taxRate) * lstExpenseSheetVar.Quantity__c ;
				lstExpenseSheetVar.Total_Net__c = (lstExpenseSheetVar.Unit_Amount__c * lstExpenseSheetVar.Quantity__c );
				lstExpenseSheetVar.Total_Gross__c = lstExpenseSheetVar.Total_VAT__c + lstExpenseSheetVar.Total_Net__c ;
			}
			else 
			{
				gtaxrate = 0 ;
				lstExpenseSheetVar.Total_VAT__c = 0 ;
				lstExpenseSheetVar.Total_Gross__c = lstExpenseSheetVar.Unit_Amount__c * lstExpenseSheetVar.Quantity__c ;
			}	
		}
		catch(exception e)
		{
			apexpages.addMessages(e);	
		}
	}
	public void changeTaxRate()
	{
		decimal taxRate = 0 ;
		try
		{
			if (lstExpenseSheetVar.Tax_Rate__c != null)
			{
				lstExpenseSheetVar.Total_VAT__c  = 0 ;
				lstExpenseSheetVar.Total_Gross__c = 0 ;
				taxRate = taxRateMap.get(lstExpenseSheetVar.Tax_Rate__c);
				gtaxrate = taxRate ;
				//lstExpenseSheetVar.Total_VAT__c = lstExpenseSheetVar.Total_Net__c.divide(100,3,system.roundingmode.up) * taxRate  ;
				lstExpenseSheetVar.Total_VAT__c = ((lstExpenseSheetVar.Unit_Amount__c/100) * taxRate) * lstExpenseSheetVar.Quantity__c ;
				lstExpenseSheetVar.Total_Net__c = (lstExpenseSheetVar.Unit_Amount__c * lstExpenseSheetVar.Quantity__c );
				lstExpenseSheetVar.Total_Gross__c = lstExpenseSheetVar.Total_VAT__c + lstExpenseSheetVar.Total_Net__c ;
			}
			else 
			{
				gtaxrate = 0 ;
				lstExpenseSheetVar.Total_VAT__c = 0 ;
				lstExpenseSheetVar.Total_Gross__c = lstExpenseSheetVar.Unit_Amount__c * lstExpenseSheetVar.Quantity__c ;
			}	
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public void validate_AmountnQuantity()
	{
		if (lstExpenseSheetVar.Quantity__c == null )
			throw new customexception('Please Enter Quantity');
		else if (lstExpenseSheetVar.Quantity__c == 0 )
			throw new customexception('Quantity Must be Greater then 1');
		else if (lstExpenseSheetVar.Total_Net__c == null )
			throw new customexception( 'Please Enter Expense Amount');
		else if (lstExpenseSheetVar.Total_Net__c == 0 )
			throw new customexception( 'Amount Must be Greater then 1 ');
	}
	
	// This is starting of Test Classes
	private static testMethod void expenseOntrollerTest()
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
		//Nominal_Account__c nm = [Select Id , Sub_Category__c, Tax_Rate__c from Nominal_Account__c where  Expense__c = true limit 1 ];	
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		Opportunity subOp = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , Sub_Project__c =op.Id , CloseDate = date.today().addDays(5));
		insert subOp;
		Expense_Sheet__c esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		esinfo.Type__c = 'Credit Card' ;
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
		exp.Tax_Rate__c = tx.id ;
		exp.Expense_Sheet__c = esinfo.Id ;
		insert exp;
		
		apexpages.currentPage().getParameters().put('id' , esinfo.Id);
		EditExpenseSheet_Controller obj = new EditExpenseSheet_Controller();
		obj.init();
		obj.lstExpenseSheetDetail = new list<Expense_Sheet_Detail__c>();
		obj.lstExpenseSheetVar = new Expense_Sheet_Detail__c();
		obj.lstExpenseSheetVar.Date__c = date.today();
		obj.lstExpenseSheetVar.Nominal_Account__c = nm.Id;
		obj.lstExpenseSheetVar.Quantity__c =  1 ;
		obj.lstExpenseSheetVar.Narrative__c = 'test Code';
		obj.lstExpenseSheetVar.Total_Net__c = 15 ;
		obj.lstExpenseSheetVar.Total_VAT__c = 10 ;
		obj.lstExpenseSheetVar.Total_Gross__c = 20 ;
		obj.lstExpenseSheetVar.Project__c = op.Id ;
		obj.lstExpenseSheetVar.Tax_Rate__c = tx.id ;
		obj.lstExpenseSheetDetail.add(obj.lstExpenseSheetVar);
		obj.getTaxPrice();
		obj.changeTaxRate();
		obj.lstExpenseSheetVar.Nominal_Account__c = null ;
		obj.lstExpenseSheetVar.Tax_Rate__c = null ;
		obj.changeTaxRate();
		obj.getTaxPrice();
		obj.addExpenseSheetItem();
		ApexPages.currentPage().getParameters().put('cloneId' , '0');
		obj.CloneEntry();
		ApexPages.currentPage().getParameters().put('editId' , '0');
		obj.editListItems();
		obj.addLineItem();
		obj.addLineItem();
		obj.addLineItem();
		obj.clearExpenseSheetValues();
		list<selectoption> nominalAccounts = obj.getNominalAccounts();
		list<selectoption> projects = obj.getProjects();
		list<selectoption> textrate = obj.getAllTaxRates();
		obj.filterSubProject();
		obj.project = op.Id ; 
		obj.filterDate = '3/26/2011';
		obj.filterTimeSheet();
		obj.filterDate = '3/26/2011';
		obj.filterendDate = '3/29/2011';
		try
		{
			obj.filterTimeSheet();
		}
		catch (exception e)
		{
			system.assertEquals('End date must be greater than Start Date', e.getMessage());
		}
        // null test
        obj.filterDate = null;
		obj.filterendDate = '3/29/2011';
		obj.filterTimeSheet();
		obj.filterDate = '3/26/2011';
		obj.filterendDate = null;
		obj.filterTimeSheet();
		obj.totalvalues();
        obj.clearfilter();
        obj.project = null ;
        obj.filterTimeSheet();
        obj.project = op.Id ;
        obj.filterDate = null;
        obj.filterTimeSheet();
		obj.saveTimeSheet();
		obj.lstExpenseSheetVar.Quantity__c = null ;
		try
		{
			obj.validate_AmountnQuantity();
		}
		catch(exception e)
		{
			system.assertEquals('Please Enter Quantity', e.getMessage());
		}
		obj.lstExpenseSheetVar.Quantity__c = 0 ;
		try
		{
			obj.validate_AmountnQuantity();
		}
		catch(exception e)
		{
			system.assertEquals('Quantity Must be Greater then 1', e.getMessage());
		}
		obj.lstExpenseSheetVar.Quantity__c = 1 ;
		obj.lstExpenseSheetVar.Total_Net__c = null ;
		try
		{
			obj.validate_AmountnQuantity();
		}
		catch(exception e)
		{
			system.assertEquals('Please Enter Expense Amount', e.getMessage());
		}
		obj.lstExpenseSheetVar.Total_Net__c = 0 ;
		try
		{
			obj.validate_AmountnQuantity();
		}
		catch(exception e)
		{
			system.assertEquals('Amount Must be Greater then 1 ', e.getMessage());
		}
		esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		esinfo.Status__c = 'Submitted_For_Approval';
		esinfo.Type__c = 'Credit Card' ;
		insert esinfo;
		apexpages.currentPage().getParameters().put('id' , esinfo.Id);
		obj.init();
		obj.saveTimeSheet();
		apexpages.currentPage().getParameters().put('id' , null );
		obj.init();
		obj.lstExpenseSheetVar = null ;
		obj.changeTaxRate();
		obj.getTaxPrice();
	}
}