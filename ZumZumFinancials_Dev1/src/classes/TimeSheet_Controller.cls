public class TimeSheet_Controller 
{
	public List<Time_Sheet_Detail__c> newTimeSheet {get ; set;}
	public list<timsheetDetailWrapper> wrapTimeSheet{get; set;}
	public timsheetDetailWrapper tsDetails {get; set;}
	public Time_Sheet__c newTimeSheetinfo {get ; set;}
	private List<Opportunity> AllOpportunities {get; set;}
	private List<Opportunity> AllSubOpportunities {get; set;}
	private List<Opportunity> filterSubOpportunities {get; set;}
	private map<Id,String> activityMap {get; set;}
	public List<Activity_Code__c> activityCodes {get; set;}
	public string project {get; set;}
	public string subProject {get; set;} 
	public string activityCodess {get; set;}
	public string filterDate {get; set;}
	public Time_Sheet_Detail__c timeSheetDetailval {get; set ;}
	public string sheetName {get; set;}
	public string indexName {get; set;}
	public decimal totalMiles {get; set;}
	public decimal totalHours {get; set;}
	public List<timsheetDetailWrapper> filteredTimeSheet {get ; set;}
	public boolean filterSheet {get; set;}
	public string filterendDate {get; set;}
	public boolean fullSheet {get; set;}
	public boolean allreadyEdited {get; set;}
	public string monthName {get; set;}
	public string yearName {get; set;}
	public TimeSheet_Controller( apexpages.Standardcontroller timeSheetController )
	{
		//init();
	}
	public TimeSheet_Controller()
	{
		
	}
	public static map<integer , string> monthCodes = new map<integer , string>{1 => 'Janurery' ,
											   2 => 'February' ,
											   3 => 'March' ,
											   4 => 'April' ,
											   5 => 'May' ,
											   6 => 'June' ,
											   7 => 'July' ,
											   8 => 'August' ,
											   9 => 'September' ,
											   10 => 'October' ,
											   11 => 'November' ,
											   12 => 'December' 
											  };
	public PageReference init()
	{
		fullSheet =true ;
		filterSheet = false;
		createNewTimeSheet();
		return null;
	}
	public PageReference timeSheetExist()
	{
		return null;
	}
	public PageReference createNewTimeSheet()
	{
		try
		{
			newTimeSheet = new List<Time_Sheet_Detail__c>();
			timeSheetDetailval = new Time_Sheet_Detail__c() ;
			timeSheetDetailval.Date__c = date.today();
			tsDetails = new timsheetDetailWrapper(new Time_Sheet_Detail__c());
			newTimeSheetinfo = new Time_Sheet__c();
			newTimeSheetinfo.Name = Functions.getMonth(date.today());
			monthName = string.valueOf(date.today().month());
			yearName = string.valueOf(date.today().year()); 
			activityMap = new map<Id,String>();
			wrapTimeSheet = new list<timsheetDetailWrapper> ();
			filterSubOpportunities = new list<Opportunity>();
			AllOpportunities = [select Id , Name from Opportunity where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ] ; 
			activityCodes = [select Id,  Code__c ,Name from Activity_Code__c Order By Code__c Asc limit 1000] ;
			totalvalues() ;
			if (activityCodes.size()>0)
			{
				for (Activity_Code__c acc : activityCodes)
				{
					activityMap.put(acc.Id , acc.Name);	
				}
			}	
			return null;
		}
		catch (exception e)
		{
			apexpages.addMessages(e);
			return null;
		}
	}
	public List<selectoption> getProjects()
	{
		list<selectoption> Projects = new list<selectoption>();
		try
		{
			Projects.add(new selectoption( '' , 'Select Project' ));
			if (AllOpportunities.size()  > 0)
			{
				string code  = '' ;
				for (Opportunity op : AllOpportunities)
				{
					Projects.add(new selectoption( op.Id ,op.Name ));
				}
			}
			else 
				throw new customexception('No project Exist , Please Enter Projects');
		}
		catch (exception e)
		{
			apexpages.addMessages(e);
		}
		return 	Projects ;
	}
	public list<selectoption> getActivityList()
	{
		list<selectoption> ActivityList = new list<selectoption>();
		ActivityList.add(new selectoption( '' , 'Select Activity Code' ));
		if (activityCodes.size() > 0)
		{
			string code  = '' ;
			for(Activity_Code__c acc : activityCodes)
			{
				if (acc.Code__c != null)
					code = acc.Code__c + ' - ' + acc.Name;
				else
					code = acc.Name;
				ActivityList.add(new selectoption(acc.Id,code))	;
			}
		}
		else
			throw new CustomException('No Activity Code found, please insert Activity Codes');
		return ActivityList ;
		
			
	}
	public Pagereference saveTimeSheet()
	{
		Savepoint sp = Database.setsavepoint();
		try
		{
			newTimeSheetinfo.Month__c  = Integer.valueof(monthName) ;
			newTimeSheetinfo.Year__c =  Integer.valueof(yearName) ;
			newTimeSheetinfo.Name =  ExpenseSheet_Model.getMonth(integer.valueof(monthName) , yearName);
			TimeSheet_Model tsObject = new TimeSheet_Model(newTimeSheetinfo);
			tsObject.ValidateTSOnSave(wrapTimeSheet, integer.valueof(monthName) , integer.valueof(yearName));
			tsObject.saveTimeSheetRecord(getWraperToObject(wrapTimeSheet) , newTimeSheetinfo , 'INSERT');  
			return new PageReference('/' + tsObject.timeSheet.Id ) ;
		}	
		catch (exception e )
		{
			Database.rollback(sp);
			apexpages.addMessages(e );	
			return null ;
		}
	}
	public void addTimesheetToList()
	{
		try
		{
			system.debug('this is narrative: ' + tsDetails.timeSheetDetail.Narrative__c);
			timsheetDetailWrapper.validateTimeSheetDetail(tsDetails.timeSheetDetail , integer.valueOf(monthName) , integer.valueOf(yearName) );
			Time_Sheet_Detail__c tmptimesheet = new Time_Sheet_Detail__c();
			tmptimesheet.Date__c = tsDetails.timeSheetDetail.Date__c ;
			tmptimesheet.Name = newTimeSheetinfo.Name ;
			tmptimesheet.Created_Date__c = datetime.now();
			tmptimesheet.Day__c = timsheetDetailWrapper.getDayString(tsDetails.timeSheetDetail.Date__c) ; 
			tmptimesheet.Date_String__c = timsheetDetailWrapper.getDateWithMonth(tsDetails.timeSheetDetail.Date__c); 
			tmptimesheet.Narrative__c = tsDetails.timeSheetDetail.Narrative__c;
			tmptimesheet.Total_Hours__c = tsDetails.timeSheetDetail.Total_Hours__c ;
			tmptimesheet.Account__c = tsDetails.timeSheetDetail.Account__c ;
			tmptimesheet.Project__c = tsDetails.timeSheetDetail.Project__c ;
			tmptimesheet.Activity_Code__c = tsDetails.timeSheetDetail.Activity_Code__c ;
			timsheetDetailWrapper tmwrapper = new timsheetDetailWrapper(tmptimesheet);
			tmwrapper.Index  = wrapTimeSheet.size() ;
			wrapTimeSheet.add(tmwrapper);	
			clearTimeSheetvalues();
			allreadyEdited = false ;
			totalvalues() ;
			if (filterSheet == true)
				filterTimeSheet();
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public void clearTimeSheetvalues()
	{
		tsDetails.timeSheetDetail.Date__c = null ;
		tsDetails.timeSheetDetail.Narrative__c = null ;
		tsDetails.timeSheetDetail.Total_Hours__c = null ;
		tsDetails.timeSheetDetail.Project__c = null ;
		tsDetails.timeSheetDetail.Activity_Code__c = null ;
		tsDetails.timeSheetDetail.Name_of_business_passenger__c = null ;
		tsDetails.timeSheetDetail.Account__c  = null ;
	}
	public void deletListItems()
	{
	 	if (ApexPages.currentPage().getParameters().get('deletId') != null || ApexPages.currentPage().getParameters().get('deletId') != '')
	 	{
	 		wrapTimeSheet.remove(timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('deletId')));	
	 		getUpdateTimeSheetList(wrapTimeSheet , timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('deletId')) );
	 		totalvalues() ;
	 		if (filterSheet == true)
				filterTimeSheet();
	 	}
	}
	public void editListItems()
	{
	 	integer editId ;
	 	if (ApexPages.currentPage().getParameters().get('editId') != null || ApexPages.currentPage().getParameters().get('editId') != '')
	 	{
	 		if (allreadyEdited == true)
	 			addTimesheetToList();	
	 		allreadyEdited = true ;
	 		editId = timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('editId'));
	 		tsDetails.timeSheetDetail.Date__c = wrapTimeSheet[editId].timeSheetDetail.Date__c ;
	 		tsDetails.timeSheetDetail.Day__c =  timsheetDetailWrapper.getDayString(wrapTimeSheet[editId].timeSheetDetail.Date__c);
			tsDetails.timeSheetDetail.Narrative__c = wrapTimeSheet[editId].timeSheetDetail.Narrative__c ;
			tsDetails.timeSheetDetail.Total_Hours__c = wrapTimeSheet[editId].timeSheetDetail.Total_Hours__c ;
			tsDetails.timeSheetDetail.Project__c = wrapTimeSheet[editId].timeSheetDetail.Project__c ;
			tsDetails.timeSheetDetail.Activity_Code__c = wrapTimeSheet[editId].timeSheetDetail.Activity_Code__c ;
			tsDetails.timeSheetDetail.Account__c = wrapTimeSheet[editId].timeSheetDetail.Account__c ;
			getUpdateTimeSheetList(wrapTimeSheet , timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('editId')));
			wrapTimeSheet.remove(timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('editId')));
			totalvalues() ;
			if (filterSheet == true)
				filterTimeSheet();
		}
	}
	public void CloneEntry()
	{
		integer editId ;
		if (ApexPages.currentPage().getParameters().get('cloneId') != null || ApexPages.currentPage().getParameters().get('cloneId') != '')
	 	{
	 		editId = timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('cloneId'));
	 		system.debug('this is clone Id: ' + editId );
	 		Time_Sheet_Detail__c tmptimesheet = new Time_Sheet_Detail__c();
			tmptimesheet.Date__c = wrapTimeSheet[editId].timeSheetDetail.Date__c ;
			tmptimesheet.Name = newTimeSheetinfo.Name ;
			tmptimesheet.Created_Date__c = datetime.now();
			tmptimesheet.Day__c = timsheetDetailWrapper.getDayString(wrapTimeSheet[editId].timeSheetDetail.Date__c) ; 
			tmptimesheet.Date_String__c = timsheetDetailWrapper.getDateWithMonth(wrapTimeSheet[editId].timeSheetDetail.Date__c); 
			tmptimesheet.Narrative__c = wrapTimeSheet[editId].timeSheetDetail.Narrative__c;
			tmptimesheet.Account__c = wrapTimeSheet[editId].timeSheetDetail.Account__c ;
			tmptimesheet.Total_Hours__c = wrapTimeSheet[editId].timeSheetDetail.Total_Hours__c ;
			tmptimesheet.Project__c = wrapTimeSheet[editId].timeSheetDetail.Project__c ;
			tmptimesheet.Activity_Code__c = wrapTimeSheet[editId].timeSheetDetail.Activity_Code__c ;
			timsheetDetailWrapper tmwrapper = new timsheetDetailWrapper(tmptimesheet);
			tmwrapper.Index  = wrapTimeSheet.size() ;
			wrapTimeSheet.add(tmwrapper);
			totalvalues() ;	
			if (filterSheet == true)
				filterTimeSheet();
		}	
	}
	public void totalvalues()
	{
		totalHours = 0;	
		for (timsheetDetailWrapper tc : wrapTimeSheet)
		{
			if (tc.timeSheetDetail.Total_Hours__c != null)
				totalHours +=  tc.timeSheetDetail.Total_Hours__c ;	
		}
	}
	public void filteredTotals()
	{
		totalMiles = 0;
		totalHours = 0;	
		for (timsheetDetailWrapper tc : filteredTimeSheet)
		{
			totalHours +=  tc.timeSheetDetail.Total_Hours__c ;	
		}
	}
	/*
	public void getSubProjectsChanged()
	{
		if (timeSheetDetailval.Project__c != null)
			AllSubOpportunities = [select Id , Code__c  , Name from Opportunity where Sub_Project__c = :timeSheetDetailval.Project__c and StageName  != 'Closed Won' and  StageName != 'Closed Lost' and Code__c != null order by  Code__c limit 1000 ] ; 	
		else
			AllSubOpportunities = [select Id , Code__c  , Name from Opportunity where Sub_Project__c = :timeSheetDetailval.Project__c and StageName  != 'Closed Won' and  StageName != 'Closed Lost' and Code__c != null order by  Code__c limit 0 ] ; 		
	}
	public void filterSubProject()
	{
		if (project != null )
			filterSubOpportunities = [select Id , Name , Code__c from Opportunity where Sub_Project__c = :project and StageName  != 'Closed Won' and  StageName != 'Closed Lost' and Code__c != null order by Code__c limit 1000 ] ;
		else
			filterSubOpportunities = [select Id , Code__c ,Name from Opportunity where Sub_Project__c != null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' and Code__c != null Order By Code__c Asc limit 0 ] ;
				 	
	}
	*/
	public void filterTimeSheet()
	{
		//newTimeSheet = [Select t.Index__c , t.Total_Miles__c, t.Total_Hours__c, t.Time_Sheet__c, t.Sub_Project__c, t.Status__c, t.Project__c, t.Narrative__c, t.Name_of_business_passenger__c, t.Name, t.LM_Status__c, t.Id, t.Day__c, t.Date__c, t.BH_Status__c, t.Activity_Code__c From Time_Sheet_Detail__c t where t.Project__c = :project AND t.Sub_Project__c = :subProject AND Activity_Code__c = :activityCodess]	;
		try
		{
		filteredTimeSheet = new List<timsheetDetailWrapper>();
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
		for (timsheetDetailWrapper ts : wrapTimeSheet) 
		{
			//if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Sub_Project__c == subProject && ts.timeSheetDetail.Activity_Code__c == activityCodess )
			if (project != null && activityCodess == null && (filterDate == null || filterDate == '') )
			{
				if (ts.timeSheetDetail.Project__c ==  project )	
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project != null && activityCodess == null && (filterDate == null && filterDate == '') )
			{
				if (ts.timeSheetDetail.Project__c ==  project  )
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project != null && activityCodess == null && (filterDate == null || filterDate == '') )
			{
				if (ts.timeSheetDetail.Project__c ==  project )
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			// this is my code
			else if (project != null  && activityCodess ==null && (filterDate!=null && filterDate!='') && (filterendDate!=null && filterendDate!=''))
			{
				if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Date__c >= Date.parse(filterDate.trim()) && ts.timeSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project != null && activityCodess ==null && (filterDate!=null && filterDate!='') )
			{
				if (ts.timeSheetDetail.Project__c ==  project  && ts.timeSheetDetail.Date__c >= Date.parse(filterDate.trim()) )
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project != null  && activityCodess ==null  && (filterendDate!=null && filterendDate!=''))
			{
				if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			//this code is added
			else if (project != null && activityCodess !=null && (filterDate!=null && filterDate!='') && (filterendDate!=null && filterendDate!=''))
			{
				if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Activity_Code__c == activityCodess && ts.timeSheetDetail.Date__c >= Date.parse(filterDate.trim()) && ts.timeSheetDetail.Date__c >= Date.parse(filterendDate.trim()))
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project != null && activityCodess !=null && (filterDate!=null && filterDate!='') )
			{
				if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Activity_Code__c == activityCodess && ts.timeSheetDetail.Date__c >= Date.parse(filterDate.trim()))
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project != null && activityCodess !=null && (filterendDate!=null && filterendDate!='') )
			{
				if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Activity_Code__c == activityCodess && ts.timeSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project != null && activityCodess !=null && (filterDate!=null || filterDate!=''))
			{
				if (ts.timeSheetDetail.Project__c ==  project && ts.timeSheetDetail.Activity_Code__c == activityCodess )
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if (project == null && subProject == null && activityCodess !=null )
			{
				if (ts.timeSheetDetail.Activity_Code__c == activityCodess )
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);	
			}
			else if( (filterDate!=null && filterDate !='' && filterendDate!=null && filterendDate !='')  && project == null && activityCodess ==null ) 
			{
				if (ts.timeSheetDetail.Date__c >= Date.parse(filterDate.trim()) && ts.timeSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);		
			}
			else if( (filterDate!=null && filterDate !='' && filterendDate ==null || filterendDate =='' )  && project == null && activityCodess ==null ) 
			{
				if (ts.timeSheetDetail.Date__c >= Date.parse(filterDate.trim()) )
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);		
			}
			else if( (filterendDate !=null && filterendDate != '')  && project == null && subProject == null && activityCodess ==null ) 
			{
				if (ts.timeSheetDetail.Date__c <= Date.parse(filterendDate.trim()))
					filteredTimeSheet.add(ts); //filteredTimeSheet.add(ts);		
			}
												
		}
		if (filteredTimeSheet.size() == 0 && filterSheet ==true )
		{
			totalHours = 0;
		}	
		else if (filteredTimeSheet.size() > 0 && filterSheet ==true)
			filteredTotals();
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
		//filterSubProject();
	}
	private list<Time_Sheet_Detail__c> getWraperToObject(list<timsheetDetailWrapper> wrapperVAlues)
	{
		list<Time_Sheet_Detail__c> objValues = new list<Time_Sheet_Detail__c>();
		if (wrapperVAlues.size() > 0)
		{
			for (timsheetDetailWrapper wr : wrapperVAlues)
			{
				TimeSheet_Controller ts = new TimeSheet_Controller();
				Time_Sheet_Detail__c tmptimesheet = new Time_Sheet_Detail__c();
				tmptimesheet.Date__c = wr.timeSheetDetail.Date__c ;
				tmptimesheet.Name = newTimeSheetinfo.Name ; 
				if (wr.timeSheetDetail.Id != null )
					tmptimesheet.Created_Date__c = wr.timeSheetDetail.CreatedDate ;
				else 
					tmptimesheet.Created_Date__c = datetime.now();	 
				tmptimesheet.Day__c = timsheetDetailWrapper.getDayString(wr.timeSheetDetail.Date__c) ; 
				tmptimesheet.Date_String__c = timsheetDetailWrapper.getDateWithMonth(wr.timeSheetDetail.Date__c); 
				tmptimesheet.Narrative__c = wr.timeSheetDetail.Narrative__c;
				tmptimesheet.Total_Hours__c = wr.timeSheetDetail.Total_Hours__c ;
				tmptimesheet.Project__c = wr.timeSheetDetail.Project__c ;
				tmptimesheet.Account__c = wr.timeSheetDetail.Account__c ;
				tmptimesheet.Activity_Code__c = wr.timeSheetDetail.Activity_Code__c ;
				objValues.add(tmptimesheet);
			}
			return objValues ;
		}
		else
			return null ;
	}
	
	public void getUpdateTimeSheetList(List<timsheetDetailWrapper> timesheetOld , integer listIndex)
	{
		List<Time_Sheet_Detail__c> tmpSheet  = new List<Time_Sheet_Detail__c>();
		for (timsheetDetailWrapper tc : wrapTimeSheet)
		{
			if( tc.Index > listIndex )
				tc.Index -= 1 ;
		}
	}
	
	// This is starting of test code   
	private static testMethod void testTimeSheetController()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Activity_Code__c ac = new Activity_Code__c(Name = 'Activity 1' , Code__c = 'Activity 1');
		insert ac ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		
		TimeSheet_Controller obj = new TimeSheet_Controller();
		obj.init();	
		obj.createNewTimeSheet();
		Time_Sheet_Detail__c tsd = new Time_Sheet_Detail__c();
		tsd.Activity_Code__c  = ac.Id ;
		tsd.Date__c = date.today();
		tsd.Narrative__c = 'test Code';
		tsd.Total_Hours__c = 15 ;
		tsd.Activity_Code__c = ac.id ;
		tsd.Project__c = op.Id ;
		obj.newTimeSheet.add(tsd);
		obj.newTimeSheet.add(tsd);
		obj.timeSheetDetailval = tsd ;
		obj.tsDetails.timeSheetDetail = tsd ;
		obj.addTimesheetToList();
		
		List<SelectOption> getNomAccounts = obj.getActivityList();
		obj.project = op.id ; 
		
		Time_Sheet__c tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year();
		obj.saveTimeSheet();
		obj.timeSheetExist();
		
		ApexPages.currentPage().getParameters ().put ('editId', '0' );
		obj.editListItems();
		
		obj.addTimesheetToList();
		
		ApexPages.currentPage().getParameters ().put ('cloneId', '0' );
		obj.CloneEntry();
		
		ApexPages.currentPage().getParameters ().put ('deletId', '0' );
		obj.deletListItems();
		
		
		//obj.getSubProjectsChanged();
		//obj.filterSubProject();
		obj.project = op.Id ; 
		obj.filterDate = '3/26/2011';
		obj.filterendDate = '3/29/2011';
		obj.filterTimeSheet();    
		obj.totalvalues();
        obj.clearfilter();
        obj.project = null ;
        obj.filterTimeSheet();
        obj.project = op.Id ;
        obj.filterDate = null;
        obj.filterTimeSheet();
        // endtime sheet is less then start dat
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
        obj.project = null ;
        obj.subProject = null ;
        obj.activityCodess = null ;
        obj.filterDate = null ;
        obj.filterendDate = null ;
        obj.filterDate = null;
        obj.filterTimeSheet();
        obj.filteredTotals();
		obj.newTimeSheetinfo = null ;
		obj.saveTimeSheet();
		tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year();
		insert tsinfo ;
		
		//ApexPages.StandardController stdCon = new ApexPages.StandardController (tsinfo);
		//InvalidOperationTS invObj = new InvalidOperationTS(stdCon);
		
	}
}