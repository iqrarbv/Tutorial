public class ExpenseSheet_Controller 
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
	public List<expenseSheetDetailWrapper> filteredExpenseSheet {get ; set;}
	public boolean filterSheet {get; set;}
	public boolean fullSheet {get; set;}
	public string project {get; set;}
	public string subProject {get; set;}
	public string activityCodess {get; set;}
	public string filterDate {get; set;}
	public string filterendDate {get; set;}
	public string monthName {get; set;}
	public string yearName {get; set;}
	public ExpenseSheet_Controller (  )
	{
		
	}
	public ExpenseSheet_Controller ( apexpages.Standardcontroller expenseSheetController )
	{
		nominalAllAccounts = new List<Nominal_Account__c> ();
		init();
	}
	public void filterTimeSheet()
	{
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
				else if (project != null  && activityCodess == null && (filterDate == null && filterDate == '') )
				{
					if (ts.expenseSheetDetail.Project__c ==  project  )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				else if (project != null && activityCodess == null && (filterDate == null || filterDate == '') )
				{
					if (ts.expenseSheetDetail.Project__c ==  project )
						filteredExpenseSheet.add(ts); //filteredTimeSheet.add(ts);	
				}
				// this is my code
				else if (project != null && activityCodess ==null && (filterDate!=null && filterDate!='') && (filterendDate!=null && filterendDate!=''))
				{
					if (ts.expenseSheetDetail.Project__c ==  project  && ts.expenseSheetDetail.Date__c >= Date.parse(filterDate.trim()) && ts.expenseSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
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
				else if( (filterendDate !=null && filterendDate != '')  && project == null && subProject == null && activityCodess ==null ) 
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
				totalMiles = 0.00;
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
	public void filterSubProject()
	{
		if (project != null )
			allSubProjects = [select Id , Name from Opportunity where Sub_Project__c = :project and StageName  != 'Closed Won' and  StageName != 'Closed Lost' order by Name limit 1000 ] ;
		else
			allSubProjects = [select Id , Name from Opportunity where Sub_Project__c != null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 0 ] ;	
	}
	/*
	public List<selectoption> getFilterSubProjects()
	{
		list<selectoption> SubProjects = new list<selectoption>();
		SubProjects.add(new selectoption( '' , 'Select Sub Project' ));
		if (allSubProjects.size()  > 0)
		{
			string code  = '' ;
			for (Opportunity op : allSubProjects)
			{
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				SubProjects.add(new selectoption( op.Id , code ));
			}
		}
		return 	SubProjects ;
	}
	*/
	public void init()
	{
		try
		{
			fullSheet =true ;
			filterSheet = false ;
			list<Expense_Sheet__c> tmpSheet = [select Name from Expense_Sheet__c where Name = : Functions.getMonth(date.today())];
			if (tmpSheet.size() > 0)
			{
				//apexpages.addMessage( new apexpages.Message( apexpages.Severity.Error , 'Expense Sheet Already Exist' , '' ) );
				createNewExpenseSheet();
			}
			else
			{
				//apexpages.addMessage( new apexpages.Message( apexpages.Severity.Error , 'Expense Sheet Not Exist' , '' ) );
				createNewExpenseSheet();	
			}
		}
		catch( exception e )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , e.getMessage() , '' ) );
		}
		
	}
	public PageReference ExpenseSheetExist()
	{
		return null ;		
	}
	public void getClaimNumber ()
	{
		//expenseSheetInfo.Name = ExpenseSheet_Model.getOrderNo(string.valueof(ExpenseSheet_Model.getOrderNumber('Expenses')));
		//ExpenseSheet_Model.updateOrderNo(integer.valueof(expenseSheetInfo.Name));
	}
	public PageReference createNewExpenseSheet()
	{
		try
		{
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			expenseSheetInfo = new Expense_Sheet__c() ;
			expenseSheetInfo.Month_Number__c = date.today().month();
			expenseSheetInfo.Year__c = date.today().year();
			//expenseSheetInfo.Month__c = ExpenseSheet_Model.getMonth(date.today());
			expenseSheetInfo.Name = ExpenseSheet_Model.getOrderNo(string.valueof(ExpenseSheet_Model.getOrderNumber('Expenses')));
			//ExpenseSheet_Model.updateOrderNo(integer.valueof(expenseSheetInfo.Name));
			expenseSheetInfo.Claim_No__c = expenseSheetInfo.Name ;
			allProjects = new List<Opportunity>();
			allSubprojects = new List<Opportunity>();
			taxRateList = new List<Tax_Rate__c>();
			nominalAllAccounts = new List<Nominal_Account__c>();
			monthName = string.valueOf(date.today().month());
			yearName = string.valueOf(date.today().year());
			lstExpenseSheetVar = new Expense_Sheet_Detail__c();
			addLineItem();
			lstExpenseSheetDetail = new list<Expense_Sheet_Detail__c>();
			wrapexpenseSheet = new list<expenseSheetDetailWrapper> ();
			totalvalues();
			nominalAllAccounts  = [select Id , Name ,Tax_Rate__c, Account_Code__c , Nominal_Code__c from Nominal_Account__c   Order By Nominal_Code__c Asc limit 1000];
			allprojects = [select Id , Name from Opportunity where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ];
			allSubprojects = [select Id , Name from Opportunity where Sub_Project__c != null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 0 ];
			//taxRateList = [select Id , Name ,Tax_Rate__c from Tax_Rate__c where Expense__c = true Order By Name Asc limit 1000];
			taxRateList = [select Id , Name ,Tax_Rate__c from Tax_Rate__c Order By Name Asc limit 1000];
			if (taxRateList.size()==0)
				throw new customexception('No Tax Rates Found,  Please Insert Tax Rate for Expenses Type from Administrative setup');
			nomAccountToTaxRate = new map<Id , Id>();
			taxRateMap = new map<Id , decimal>();
			if ( nominalAllAccounts.size() > 0 )
			{
				for (Nominal_Account__c nm : nominalAllAccounts)
				{
					nomAccountToTaxRate.put(nm.Id , nm.Tax_Rate__c );	
				}
			}
			if (taxRateList.size() > 0)
			{
				for (Tax_Rate__c tx : taxRateList)
				{
					taxRateMap.put(tx.Id , tx.Tax_Rate__c);	
				}
			}
			return null ;
		}
		catch (exception e)
		{
			apexpages.addMessages(e);
			return null ;
		}
	}
	public PageReference saveTimeSheet()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			expenseSheetInfo.Month_Number__c = integer.valueof(monthName) ;
			expenseSheetInfo.Year__c = integer.valueof(yearName) ; 
			expenseSheetInfo.Month__c =  ExpenseSheet_Model.getMonth(integer.valueof(monthName) , yearName);
			ExpenseSheet_Model expObject = new ExpenseSheet_Model(expenseSheetInfo);
			expObject.saveExpenseSheet(wrapexpenseSheet, expenseSheetInfo, 'INSERT');
			return new pageReference('/' + expObject.expenseSheet.Id );
		}
		catch(exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);	
			return null ;
		}
	}
	public void validateInfo()
	{
		if (!Pattern.matches('^[0-9]+$', yearName))
			throw new CustomException('Invalid Year Entered');
		if ( yearName.length() < 4  )
			throw new CustomException('Please Select Valid Year');
		if ( integer.valueof(yearName) < 1900 || integer.valueof(yearName) > 3000 )
			throw new CustomException('Year Range Must be between 1900-2999');
		if (integer.valueof(monthName) > date.today().month() || integer.valueof(yearName) > date.today().year())
			throw new CustomException('You can not Select Feature Months & Year ');	
	}
	/*
	public list<selectoption> getMonthList()
	{
		list<selectoption> months = new list<selectoption>();
		map<integer , string> monthCOdes = ExpenseSheet_Model.monthCodes;
		for(integer ks: monthCOdes.keyset())
		{
			months.add( new selectoption( ks , monthCOdes.get(ks)) );		
		}
		return null ;
	}*/
	public list<selectoption> getNominalAccounts()
	{
		list<selectoption> NominalAccounts = new list<selectoption>();
		system.debug('this is nominal account ' + nominalAllAccounts);
		NominalAccounts.add(new selectoption( '' , 'Select Nominal Code' ));
		if (nominalAllAccounts.size() > 0)
		{
			string code  = '' ;
			for (Nominal_Account__c nm : nominalAllAccounts)
			{
				NominalAccounts.add( new selectoption( nm.Id , nm.Name ) );	
			}
		}
		else 
			throw new customexception('No Nominal Found Please Enter Nominal Account');
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
				Projects.add( new selectoption( nm.Id , nm.Name) );	
			}
		}
		else 
			throw new customexception('No Opportunity Exist , Please Enter Opportunity');
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
				AllTaxRates.add(new selectoption( tx.Id , tx.Tax_Rate__c + ' % ' + tx.Name  ));	
			} 
		}
		//else 
			//throw new customexception('Tax Rate Not Entered, Please Enter Tax Rate for your Organisation');
		return AllTaxRates ; 
	}
	public void addExpenseSheetItem()
	{
		try
		{
			validateInfo() ;
			ExpenseSheet_Model.validate_expenseSheetDetails(wrapplstExpenseSheetVar.expenseSheetDetail , integer.valueOf(monthName) , integer.valueOf(yearName));
			//changeTaxRate();
			Expense_Sheet_Detail__c tmpSheet = new Expense_Sheet_Detail__c();
			//tmpSheet.Index__c = wrapexpenseSheet.size();
			tmpSheet.Date__c = wrapplstExpenseSheetVar.expenseSheetDetail.Date__c ;
			tmpSheet.Date_String__c = ExpenseSheet_Model.getDateWithMonth(wrapplstExpenseSheetVar.expenseSheetDetail.Date__c);
			tmpSheet.Tax_Rate__c = wrapplstExpenseSheetVar.expenseSheetDetail.Tax_Rate__c ;
			tmpSheet.Day__c = ExpenseSheet_Model.getDayString(wrapplstExpenseSheetVar.expenseSheetDetail.Date__c);
			tmpSheet.Nominal_Account__c = wrapplstExpenseSheetVar.expenseSheetDetail.Nominal_Account__c ;
			tmpSheet.Account__c = wrapplstExpenseSheetVar.expenseSheetDetail.Account__c ;
			tmpSheet.Miles__c = wrapplstExpenseSheetVar.expenseSheetDetail.Miles__c ;
			tmpSheet.Unit_Amount__c = wrapplstExpenseSheetVar.expenseSheetDetail.Unit_Amount__c ;
			tmpSheet.Narrative__c = wrapplstExpenseSheetVar.expenseSheetDetail.Narrative__c ;
			tmpSheet.Quantity__c = wrapplstExpenseSheetVar.expenseSheetDetail.Quantity__c ;
			tmpSheet.Total_Gross__c = wrapplstExpenseSheetVar.expenseSheetDetail.Total_Gross__c ;
			tmpSheet.Total_VAT__c = wrapplstExpenseSheetVar.expenseSheetDetail.Total_VAT__c ;
			tmpSheet.Total_Net__c = (wrapplstExpenseSheetVar.expenseSheetDetail.Quantity__c * wrapplstExpenseSheetVar.expenseSheetDetail.Unit_Amount__c ) ;
			tmpSheet.Project__c = wrapplstExpenseSheetVar.expenseSheetDetail.Project__c ;
			tmpSheet.Business_Passenger__c = wrapplstExpenseSheetVar.expenseSheetDetail.Business_Passenger__c ;
			//lstExpenseSheetDetail.add(tmpSheet);
			expenseSheetDetailWrapper tmwrapp = new expenseSheetDetailWrapper(tmpSheet) ;
			tmwrapp.taxRate = gtaxrate ;
			tmwrapp.Index = wrapexpenseSheet.size();
			wrapexpenseSheet.add( tmwrapp );
			clearExpenseSheetValues();
			totalvalues();
			if (filterSheet == true)
				filterTimeSheet();
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}	
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
		totalVAT = ExpenseSheet_Model.getTotal(filteredExpenseSheet, 'VAT');
		totalGrossAmount = ExpenseSheet_Model.getTotal(filteredExpenseSheet, 'GROSS');
		totalNetAmount = ExpenseSheet_Model.getTotal(filteredExpenseSheet, 'NET');
		totalMiles = ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'MILES');
		totalUnitAmount =  ExpenseSheet_Model.getTotal(wrapexpenseSheet, 'UNITAMOUNT');
	}
	public void addLineItem()
	{
		try
		{
			lstExpenseSheetVar.Date__c = date.today();
			lstExpenseSheetVar.Narrative__c  = '' ;
			lstExpenseSheetVar.Quantity__c  = 1 ;
			lstExpenseSheetVar.Total_Gross__c  = 0 ;
			lstExpenseSheetVar.Total_VAT__c  = 0 ;
			lstExpenseSheetVar.Unit_Amount__c  = 0 ;
			lstExpenseSheetVar.Total_Net__c  = 0 ;
			lstExpenseSheetVar.Miles__c  = 0 ;
			lstExpenseSheetVar.Business_Passenger__c = '' ;	
			lstExpenseSheetVar.Date__c = date.today();
			gtaxrate = 0.00;
			wrapplstExpenseSheetVar = new expenseSheetDetailWrapper(lstExpenseSheetVar);
		}
		catch (exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public void clearExpenseSheetValues()
	{
		lstExpenseSheetVar.Date__c = date.today();
		lstExpenseSheetVar.Nominal_Account__c  = null ;
		lstExpenseSheetVar.Narrative__c  = '' ;
		lstExpenseSheetVar.Quantity__c  = 1 ;
		lstExpenseSheetVar.Total_Gross__c  = 0 ;
		lstExpenseSheetVar.Total_VAT__c  = 0 ;
		lstExpenseSheetVar.Total_Net__c  = 0 ;
		lstExpenseSheetVar.Unit_Amount__c  = 0 ;
		lstExpenseSheetVar.Project__c  = null ;
		lstExpenseSheetVar.Account__c  = null ;
		lstExpenseSheetVar.Tax_Rate__c  = null ;
		lstExpenseSheetVar.Miles__c  = 0.00 ;
		gtaxrate = 0.00;
		wrapplstExpenseSheetVar = new expenseSheetDetailWrapper(lstExpenseSheetVar);
	}
	public decimal gtaxrate {get; set;}
	public void getTaxPrice()
	{
		if (lstExpenseSheetVar.Nominal_Account__c != null)
		{
			decimal taxRate = 0 ;
			lstExpenseSheetVar.Total_VAT__c  = 0 ;
			lstExpenseSheetVar.Total_Gross__c = 0 ;
			Id taxRateId = nomAccountToTaxRate.get(lstExpenseSheetVar.Nominal_Account__c);
			if (nomAccountToTaxRate.keyset().contains(lstExpenseSheetVar.Nominal_Account__c))
				lstExpenseSheetVar.Tax_Rate__c = nomAccountToTaxRate.get(lstExpenseSheetVar.Nominal_Account__c);
			else
				lstExpenseSheetVar.Tax_Rate__c = [select Id from Tax_Rate__c where Id IN(Select Tax_Rate__c from Nominal_Account__c where id= : lstExpenseSheetVar.Nominal_Account__c) ].Id;	
			if (taxRateMap.keyset().contains(taxRateId))
				taxRate = taxRateMap.get(taxRateId);
			else
				taxrate = 0.00 ;
				//taxrate = [Select Tax_Rate__r.Tax_Rate__c from Nominal_Account__c where Id = : lstExpenseSheetVar.Nominal_Account__c].Tax_Rate__r.Tax_Rate__c;
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
	public void changeTaxRate()
	{
		if (lstExpenseSheetVar.Tax_Rate__c != null)
		{
			decimal taxRate = 0 ;
			lstExpenseSheetVar.Total_VAT__c  = 0 ;
			lstExpenseSheetVar.Total_Gross__c = 0 ;
			if (taxRateMap.keyset().contains(lstExpenseSheetVar.Tax_Rate__c))
				taxRate = taxRateMap.get(lstExpenseSheetVar.Tax_Rate__c);
			else
				taxrate = [Select Tax_Rate__c from Tax_Rate__c where Id = : lstExpenseSheetVar.Tax_Rate__c].Tax_Rate__c;
			gtaxrate = taxRate ;
			//lstExpenseSheetVar.Total_VAT__c = lstExpenseSheetVar.Total_Net__c.divide(100,3,system.roundingmode.up) * taxRate  ;
			lstExpenseSheetVar.Total_VAT__c = ((lstExpenseSheetVar.Unit_Amount__c/100) * taxRate) * lstExpenseSheetVar.Quantity__c ;
			lstExpenseSheetVar.Total_Net__c = (lstExpenseSheetVar.Unit_Amount__c * lstExpenseSheetVar.Quantity__c );
			lstExpenseSheetVar.Total_Gross__c = lstExpenseSheetVar.Total_VAT__c + lstExpenseSheetVar.Total_Net__c ;
			//lstExpenseSheetVar.Total_VAT__c = lstExpenseSheetVar.Total_VAT__c * lstExpenseSheetVar.Quantity__c ;
		}
		else 
		{
			gtaxrate = 0 ;
			lstExpenseSheetVar.Total_VAT__c = 0 ;
			lstExpenseSheetVar.Total_Gross__c = lstExpenseSheetVar.Unit_Amount__c * lstExpenseSheetVar.Quantity__c ;
		}	
	}
	/*
	public boolean validate_AmountnQuantity()
	{
		if (lstExpenseSheetVar.Quantity__c == null )
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.error , 'Please Enter Quantity' , '' ) );
			return false ;	
		}
		else if (lstExpenseSheetVar.Quantity__c == 0 )
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.error , 'Quantity Must be Greater then 1' , '' ) );
			return false ;	
		}
		else if (lstExpenseSheetVar.Total_Net__c == null )
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.error , 'Please Enter Expense Amount' , '' ) );
			return false ;	
		}
		else if (lstExpenseSheetVar.Total_Net__c == 0 )
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.error , 'Amount Must be Greater then 1 ' , '' ) );
			return false ;	
		}
		else
		{
			return true ;
		}	
	}
	*/
	public void editListItems()
	{
		integer editId ;
	 	if (ApexPages.currentPage().getParameters().get('editId') != null || ApexPages.currentPage().getParameters().get('editId') != '')
	 	{
	 		//newTimeSheet.remove(getListIndex(ApexPages.currentPage().getParameters().get('editId')));	
	 		editId = ExpenseSheet_Model.getListIndex(ApexPages.currentPage().getParameters().get('editId'));
	 		lstExpenseSheetVar.Date__c  = wrapexpenseSheet[editId].expenseSheetDetail.Date__c ;
			lstExpenseSheetVar.Nominal_Account__c  = wrapexpenseSheet[editId].expenseSheetDetail.Nominal_Account__c ;
			lstExpenseSheetVar.Narrative__c  = wrapexpenseSheet[editId].expenseSheetDetail.Narrative__c ;
			lstExpenseSheetVar.Quantity__c  = wrapexpenseSheet[editId].expenseSheetDetail.Quantity__c ;
			lstExpenseSheetVar.Account__c = wrapexpenseSheet[editId].expenseSheetDetail.Account__c ;
			lstExpenseSheetVar.Unit_Amount__c = wrapexpenseSheet[editId].expenseSheetDetail.Unit_Amount__c ; 
			lstExpenseSheetVar.Business_Passenger__c = wrapexpenseSheet[editId].expenseSheetDetail.Business_Passenger__c ;
			lstExpenseSheetVar.Miles__c = wrapexpenseSheet[editId].expenseSheetDetail.Miles__c ; 
			lstExpenseSheetVar.Total_Gross__c  = wrapexpenseSheet[editId].expenseSheetDetail.Total_Gross__c ;
			lstExpenseSheetVar.Total_VAT__c  = wrapexpenseSheet[editId].expenseSheetDetail.Total_VAT__c ;
			lstExpenseSheetVar.Total_Net__c  = wrapexpenseSheet[editId].expenseSheetDetail.Total_Net__c ;
			lstExpenseSheetVar.Project__c  = wrapexpenseSheet[editId].expenseSheetDetail.Project__c ;
			lstExpenseSheetVar.Tax_Rate__c  = wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c ;
			//gtaxrate = taxRateMap.get(wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c);
			gtaxrate = wrapexpenseSheet[editId].taxRate ; 
			getUpdateExpenseSheetList(wrapexpenseSheet , ExpenseSheet_Model.getListIndex(ApexPages.currentPage().getParameters().get('editId')));
			wrapexpenseSheet.remove(ExpenseSheet_Model.getListIndex(ApexPages.currentPage().getParameters().get('editId')));
			totalvalues();
			if (filterSheet == true)
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
			//tmptimesheet.Index__c = wrapexpenseSheet.size();
			tmptimesheet.Day__c = ExpenseSheet_Model.getDayString(wrapexpenseSheet[editId].expenseSheetDetail.Date__c) ; 
			tmptimesheet.Date_String__c = ExpenseSheet_Model.getDateWithMonth(wrapexpenseSheet[editId].expenseSheetDetail.Date__c); 
			tmptimesheet.Narrative__c = wrapexpenseSheet[editId].expenseSheetDetail.Narrative__c;
			tmptimesheet.Account__c = wrapexpenseSheet[editId].expenseSheetDetail.Account__c;
			tmptimesheet.Unit_Amount__c = wrapexpenseSheet[editId].expenseSheetDetail.Unit_Amount__c;
			tmptimesheet.Business_Passenger__c = wrapexpenseSheet[editId].expenseSheetDetail.Business_Passenger__c;
			tmptimesheet.Miles__c = wrapexpenseSheet[editId].expenseSheetDetail.Miles__c ;
			tmptimesheet.Quantity__c = wrapexpenseSheet[editId].expenseSheetDetail.Quantity__c ;
			tmptimesheet.Total_Gross__c = wrapexpenseSheet[editId].expenseSheetDetail.Total_Gross__c ;
			tmptimesheet.Total_VAT__c = wrapexpenseSheet[editId].expenseSheetDetail.Total_VAT__c ;
			tmptimesheet.Total_Net__c = wrapexpenseSheet[editId].expenseSheetDetail.Total_Net__c ;
			tmptimesheet.Project__c = wrapexpenseSheet[editId].expenseSheetDetail.Project__c ;
			tmptimesheet.Nominal_Account__c = wrapexpenseSheet[editId].expenseSheetDetail.Nominal_Account__c ;
			tmptimesheet.Tax_Rate__c = wrapexpenseSheet[editId].expenseSheetDetail.Tax_Rate__c ;
			expenseSheetDetailWrapper tmwrapp = new expenseSheetDetailWrapper(tmptimesheet) ;
			tmwrapp.Index = wrapexpenseSheet.size();
			tmwrapp.taxRate =  wrapexpenseSheet[editId].taxRate ;
			wrapexpenseSheet.add( tmwrapp );
			//wrapexpenseSheet.add( new expenseSheetDetailWrapper(tmptimesheet));
			totalvalues() ;	
			if (filterSheet == true)
				filterTimeSheet();
		}	
	}
	public void deletListItems()
	{
		if (ApexPages.currentPage().getParameters().get('deletId') != null || ApexPages.currentPage().getParameters().get('deletId') != '')
	 	{
	 		wrapexpenseSheet.remove(ExpenseSheet_Model.getListIndex(ApexPages.currentPage().getParameters().get('deletId')));	
	 		getUpdateExpenseSheetList(wrapexpenseSheet , ExpenseSheet_Model.getListIndex(ApexPages.currentPage().getParameters().get('deletId')));
	 		totalvalues();
	 		if (filterSheet == true)
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
	
	// This is start of test code	
	private static testMethod void expenseOntrollerTest()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier' , Credit__c = 500 , Debit__c = 100 , Country__c = 'UNITED KINGDOM' );
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
		ExpenseSheet_Controller obj = new ExpenseSheet_Controller();
		obj.init();
		obj.createNewExpenseSheet();
		obj.lstExpenseSheetDetail = new list<Expense_Sheet_Detail__c>();
		obj.lstExpenseSheetVar = new Expense_Sheet_Detail__c();
		obj.lstExpenseSheetVar.Date__c = date.today();
		obj.lstExpenseSheetVar.Nominal_Account__c = nm.Id;
		obj.lstExpenseSheetVar.Tax_Rate__c = tx.id ;
		obj.lstExpenseSheetVar.Unit_Amount__c = 10 ;
		obj.lstExpenseSheetVar.Quantity__c =  1 ;
		obj.lstExpenseSheetVar.Narrative__c = 'test Code';
		obj.lstExpenseSheetVar.Total_Net__c = 15 ;
		obj.lstExpenseSheetVar.Total_VAT__c = 2 ;
		obj.lstExpenseSheetVar.Total_Gross__c = 17 ;
		obj.lstExpenseSheetVar.Project__c = op.Id ;
		obj.lstExpenseSheetVar.Tax_Rate__c = tx.id ;
		op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		obj.lstExpenseSheetVar.Project__c = op.Id ;
		obj.lstExpenseSheetDetail.add(obj.lstExpenseSheetVar);
		obj.wrapexpenseSheet.add(new expenseSheetDetailWrapper(obj.lstExpenseSheetVar));
		obj.wrapexpenseSheet.add(new expenseSheetDetailWrapper(obj.lstExpenseSheetVar));
		obj.wrapplstExpenseSheetVar.expenseSheetDetail = obj.lstExpenseSheetVar ;
		obj.yearName = 'bnfghgf' ;
		try
		{
			obj.addExpenseSheetItem();
		}
		catch (exception e)
		{
			system.assertEquals(e.getMessage(), 'Invalid Year Entered');	
		}
		obj.yearName = '203' ;
		try
		{
			obj.addExpenseSheetItem();
		}
		catch (exception e)
		{
			system.assertEquals(e.getMessage(), 'Please Select Valid Year');	
		}
		obj.yearName = '3003' ;
		try
		{
			obj.addExpenseSheetItem();
		}
		catch (exception e)
		{
			system.assertEquals(e.getMessage(), 'Year Range Must be between 1900-2999');	
		}
		obj.yearName = '2011' ;
		obj.monthName = '5' ;
		
		obj.addExpenseSheetItem();
		obj.addExpenseSheetItem();
		obj.addExpenseSheetItem();
		obj.addExpenseSheetItem();
		
		
		Expense_Sheet__c esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		esinfo.Claim_No__c = '00000';
		esinfo.Type__c = 'Credit Card' ;
		obj.expenseSheetInfo = esinfo;
		obj.saveTimeSheet();
		list<selectoption> getNominalAccounts = obj.getNominalAccounts();
		list<selectoption> gettaxRate = obj.getAllTaxRates();
		list<selectoption> getProject = obj.getProjects();
		obj.getTaxPrice();
		obj.changeTaxRate();
		ApexPages.currentPage().getParameters().put('editId' , '0');
		ApexPages.currentPage().getParameters().put('deletId' , '0');
		ApexPages.currentPage().getParameters().put('cloneId' , '0');
		obj.CloneEntry();
		obj.editListItems();
		obj.deletListItems();
		obj.lstExpenseSheetDetail.add(obj.lstExpenseSheetVar);
		obj.lstExpenseSheetDetail.add(obj.lstExpenseSheetVar);
		obj.saveTimeSheet();
		esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		esinfo.Claim_No__c = '00000';
		insert esinfo ;
		obj.lstExpenseSheetVar.Nominal_Account__c = null ;
		obj.lstExpenseSheetVar.Tax_Rate__c = null ;
		obj.getTaxPrice();
		obj.changeTaxRate();
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
		obj.clearExpenseSheetValues();
		//ApexPages.StandardController stdCon = new ApexPages.StandardController (esinfo);
		//InvalidOperationES invObj = new InvalidOperationES(stdCon);
		//invObj.init();
	}
}