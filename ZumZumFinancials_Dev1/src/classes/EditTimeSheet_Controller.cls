public class EditTimeSheet_Controller 
{
	public Time_Sheet__c timeSheetInfo {get; set;}
	public List<Time_Sheet_Detail__c> timeSheetDetail {get; set;}
	public list<Opportunity> allProjects {get; set;}
	public list<Opportunity> allSubProjects {get; set;}
	private List<Opportunity> filterSubOpportunities {get; set;}
	public list<Activity_Code__c> Activities {get; set;}  
	public list<timsheetDetailWrapper> wrapTimeSheet{get; set;}
	public timsheetDetailWrapper tsDetails {get; set;}
	public boolean allowedit {get; set;}
	public Time_Sheet_Detail__c timeSheetDetailval {get; set ;}
	public decimal totalMiles {get; set;}
	public decimal totalHours {get; set;}
	public map<decimal , timsheetDetailWrapper> timesheetMap{get; set;}	
	public boolean allreadyEdited {get; set;}
	public string project {get; set;}
	public string subProject {get; set;}
	public string activityCodess {get; set;}
	public string filterDate {get; set;}
	public string filterendDate {get; set;}
	public List<timsheetDetailWrapper> filteredTimeSheet {get ; set;}
	public boolean filterSheet {get; set;}
	public boolean fullSheet {get; set;}
	public Id viewId {get; set;}
	public EditTimeSheet_Controller( apexpages.Standardcontroller editTimeSheet )
	{
		//init();
	}
	public EditTimeSheet_Controller()
	{
		
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
	public void filterTimeSheet()
	{
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
	public void filteredTotals()
	{
		totalHours = 0;	
		for (timsheetDetailWrapper tc : filteredTimeSheet)
		{
			if (tc.timeSheetDetail.Total_Hours__c != null)
				totalHours +=  tc.timeSheetDetail.Total_Hours__c ;	
		}
	}
	public void filterSubProject()
	{
		if (project != null )
			filterSubOpportunities = [select Id , Name from Opportunity where Sub_Project__c = :project and StageName  != 'Closed Won' and  StageName != 'Closed Lost' order by Name limit 1000 ] ;
		else
			filterSubOpportunities = [select Id , Name from Opportunity where Sub_Project__c != null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 0 ] ;	
	}
	public void init()
	{
		try
		{
			filterSubOpportunities = new list<Opportunity>();
			allProjects = [select Id , Name from Opportunity where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000];
			allSubProjects = [select Id , Name from Opportunity where Sub_Project__c != null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 0];
			Activities = [select Id, Code__c , Name from Activity_Code__c order By Code__c Asc limit 100];
			viewId = Apexpages.currentPage().getParameters().get('id');
			timeSheetDetailval = new Time_Sheet_Detail__c();
			tsDetails = new timsheetDetailWrapper(new Time_Sheet_Detail__c());
			wrapTimeSheet = new list<timsheetDetailWrapper>();
			if ( viewId != null || viewId != '')
			{
				timeSheetInfo = [Select Id , CreatedDate , Name ,  Year__c , Month__c ,Status__c ,Total_Hours__c , OwnerId from Time_Sheet__c where Id = :viewId ];
				if (timeSheetInfo.OwnerId != userinfo.getUserId())
				{
					allowedit = false;
					Apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'You are not Authorized to edit Time Sheet: '+timeSheetInfo.Name , '' ));
					return ;	
				}
				else if (timeSheetInfo.Status__c == 'Submitted_For_Approval' ||  timeSheetInfo.Status__c == 'Approved')
				{
					allowedit = false;
					throw new customexception('This Time Sheet is Approved or Submitted for Approval ' + 'you Can\'t Change this Time Sheet');
					return ;	
				}
				fullSheet =true ;
				filterSheet = false;
				allowedit = true ;
				timesheetMap = new map<decimal , timsheetDetailWrapper>();
				for(Time_Sheet_Detail__c tsD : [Select t.Account__c , t.Date_String__c , t.CreatedDate ,  t.Total_Hours__c, t.Time_Sheet__c,  t.Project__c, t.Narrative__c, t.Name_of_business_passenger__c, t.Name, t.Id, t.Day__c, t.Date__c,  t.Activity_Code__c From Time_Sheet_Detail__c t where t.Time_Sheet__c = :timeSheetInfo.Id Order by Date__c Asc ])	
				{
					timsheetDetailWrapper exSheetitems = new timsheetDetailWrapper(tsD);
					exSheetitems.Index = wrapTimeSheet.size();
					wrapTimeSheet.add(exSheetitems);
				}
			}
			else 
			{
				Apexpages.addMessage(new apexpages.Message( apexpages.Severity.info , 'No Time Sheet Found for this Id' , '' ));	
			}	
		}
		catch (exception e)
		{
			Apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , e.getMessage() , '' ));	
		}
	}
	public pagereference back()
	{
		return new pagereference ('/' +  viewId ) ;	
	}
	public list<selectoption> getProjects()
	{
		list<selectoption> Projects = new list<selectoption>();
		Projects.add(new selectoption( '' , 'Select Project' ));
		string code  = '' ;
		for (Opportunity pr: allProjects)
		{
			Projects.add(new selectoption( pr.Id , pr.Name  ));	
		}
		return Projects;
	}
	
	public list<selectOption> getActivityCodes()
	{
		list<selectOption> ActivityCodes = new list<selectOption>();
		ActivityCodes.add(new selectoption( '' , 'Select Activity Code' ));
		if (Activities.size() > 0)
		{
			string code  = '' ;
			for (Activity_Code__c acc : Activities)	
			{
				if (acc.Code__c != null)
					code = acc.Code__c + ' - ' + acc.Name;
				else
					code = acc.Name;
				ActivityCodes.add(new selectoption( acc.Id , code ));	
			}
		}
		else
			throw new CustomException('No Activities found, please insert Activity Codes');
		return ActivityCodes ;
	}
	public PageReference save_editedTimeSheet() 
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			TimeSheet_Model tsObject = new TimeSheet_Model(timeSheetInfo);
			tsObject.ValidateTSOnSave(wrapTimeSheet, integer.valueof(timeSheetInfo.month__c) , integer.valueof(timeSheetInfo.Year__c));
			timeSheetDetail = getWraperToObject(wrapTimeSheet) ;
			tsObject.saveTimeSheetRecord(timeSheetDetail, timeSheetInfo , 'UPDATE');
			return new PageReference('/' + tsObject.timeSheet.Id ) ;
		}
		catch(exception e)
		{
			Database.rollback(sp);
			Apexpages.addMessages(e);
			return null ;		
		}
	}
	public void getSubProjectsChanged()
	{
		if (timeSheetDetailval.Project__c != null)
			allSubProjects = [select Id , Name from Opportunity where Sub_Project__c = :timeSheetDetailval.Project__c and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000];		
		else
			allSubProjects = [select Id , Name from Opportunity where Sub_Project__c = :timeSheetDetailval.Project__c and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 0];
	}
	public void addTimeSheetItem()
	{
		try
		{
			timsheetDetailWrapper.validateTimeSheetDetail( tsDetails.timeSheetDetail , integer.valueof(timeSheetInfo.Month__c) , integer.valueof(timeSheetInfo.Year__c));
			Time_Sheet_Detail__c tmptimesheet = new Time_Sheet_Detail__c();
			tmptimesheet.Name = timeSheetInfo.Name ;
			tmptimesheet.Date__c =  tsDetails.timeSheetDetail.Date__c ;
			tmptimesheet.Day__c = timsheetDetailWrapper.getDayString( tsDetails.timeSheetDetail.Date__c) ; 
			tmptimesheet.Date_String__c = timsheetDetailWrapper.getDateWithMonth( tsDetails.timeSheetDetail.Date__c); 
			tmptimesheet.Narrative__c =  tsDetails.timeSheetDetail.Narrative__c;
			tmptimesheet.Total_Hours__c =  tsDetails.timeSheetDetail.Total_Hours__c ;
			tmptimesheet.Project__c =  tsDetails.timeSheetDetail.Project__c ;
			tmptimesheet.Account__c = tsDetails.timeSheetDetail.Account__c ;
			tmptimesheet.Activity_Code__c =  tsDetails.timeSheetDetail.Activity_Code__c ;
			
			timsheetDetailWrapper tmwrapper = new timsheetDetailWrapper(tmptimesheet);
			tmwrapper.Index  = wrapTimeSheet.size() ;
			wrapTimeSheet.add(tmwrapper);
			//newTimeSheet.add(tmptimesheet);	
			cancelTimeSheetItem();
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
	public void CloneEntry()
	{
		integer editId ;
		if (ApexPages.currentPage().getParameters().get('cloneId') != null || ApexPages.currentPage().getParameters().get('cloneId') != '')
	 	{
	 		editId = timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('cloneId'));
	 		Time_Sheet_Detail__c tmptimesheet = new Time_Sheet_Detail__c();
			tmptimesheet.Date__c = wrapTimeSheet[editId].timeSheetDetail.Date__c ;
			tmptimesheet.Name = timeSheetInfo.Name ;
			tmptimesheet.Created_Date__c = datetime.now();
			tmptimesheet.Day__c = timsheetDetailWrapper.getDayString(wrapTimeSheet[editId].timeSheetDetail.Date__c) ; 
			tmptimesheet.Date_String__c = timsheetDetailWrapper.getDateWithMonth(wrapTimeSheet[editId].timeSheetDetail.Date__c); 
			tmptimesheet.Narrative__c = wrapTimeSheet[editId].timeSheetDetail.Narrative__c;
			tmptimesheet.Total_Hours__c = wrapTimeSheet[editId].timeSheetDetail.Total_Hours__c ;
			tmptimesheet.Account__c = wrapTimeSheet[editId].timeSheetDetail.Account__c ;
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
	public void cancelTimeSheetItem()
	{
		 tsDetails.timeSheetDetail.Date__c = date.today();
		 tsDetails.timeSheetDetail.Narrative__c = '' ;
		 tsDetails.timeSheetDetail.Total_Hours__c = null ;
		 tsDetails.timeSheetDetail.Project__c = null ;
		 tsDetails.timeSheetDetail.Activity_Code__c = null ;
		 tsDetails.timeSheetDetail.Name_of_business_passenger__c = null ;
		 tsDetails.timeSheetDetail.Account__c  = null ;
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
				tmptimesheet.Name = timeSheetInfo.Name ; 
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
	public void deleteTimeSheetItem()
	{
		
		if (ApexPages.currentPage().getParameters().get('deletId') != null || ApexPages.currentPage().getParameters().get('deletId') != '')
	 	{
	 		wrapTimeSheet.remove(timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('deletId')));	
	 		getUpdateTimeSheetList(wrapTimeSheet ,timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('deletId')));
	 		totalvalues() ;
	 		if (filterSheet == true)
				filterTimeSheet();
	 	}
	}
	public void editTimeSheetItem()
	{
		integer editId ;
	 	if (ApexPages.currentPage().getParameters().get('editId') != null || ApexPages.currentPage().getParameters().get('editId') != '')
	 	{
	 		TimeSheet_Controller ts = new TimeSheet_Controller();
	 		if (allreadyEdited == true)
	 			addTimeSheetItem();	
	 		allreadyEdited = true ;
	 		editId = timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('editId'));
	 		tsDetails.timeSheetDetail.Date__c = wrapTimeSheet[editId].timeSheetDetail.Date__c ;
	 		tsDetails.timeSheetDetail.Day__c =  timsheetDetailWrapper.getDayString(wrapTimeSheet[editId].timeSheetDetail.Date__c);
	 		tsDetails.timeSheetDetail.Narrative__c = wrapTimeSheet[editId].timeSheetDetail.Narrative__c ;
			tsDetails.timeSheetDetail.Total_Hours__c = wrapTimeSheet[editId].timeSheetDetail.Total_Hours__c ;
			tsDetails.timeSheetDetail.Account__c = wrapTimeSheet[editId].timeSheetDetail.Account__c ;
			tsDetails.timeSheetDetail.Project__c = wrapTimeSheet[editId].timeSheetDetail.Project__c ;
			tsDetails.timeSheetDetail.Activity_Code__c = wrapTimeSheet[editId].timeSheetDetail.Activity_Code__c ;
			wrapTimeSheet.remove(timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('editId')));
			getUpdateTimeSheetList(wrapTimeSheet , timsheetDetailWrapper.getListIndex(ApexPages.currentPage().getParameters().get('editId')));
			totalvalues() ;
			if (filterSheet == true)
				filterTimeSheet();
		}
	}
	public void getUpdateTimeSheetList(List<timsheetDetailWrapper> timesheetOld , integer listIndex)
	{
		List<timsheetDetailWrapper> tmpSheet  = new List<timsheetDetailWrapper>();
		for (timsheetDetailWrapper tc : timesheetOld)
		{
			if ( tc.Index > listIndex )
				tc.Index -= 1 ;
			tmpSheet.add(tc);
		}
		wrapTimeSheet = tmpSheet;
	}
	public void totalvalues()
	{
		totalHours = 0;	
		for (timsheetDetailWrapper tc : wrapTimeSheet)
		{
			if (tc.timeSheetDetail.Total_Hours__c !=null)
				totalHours +=  tc.timeSheetDetail.Total_Hours__c ;	
		}
	}
	// This is starting of test code
	private static testMethod void testEditTimeSheetController()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Activity_Code__c ac = new Activity_Code__c(Name = 'Activity 1' , Code__c = 'Activity 1');
		insert ac ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		Opportunity subOp = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , Sub_Project__c =op.Id , CloseDate = date.today().addDays(5));
		insert subOp;
		Time_Sheet__c tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year(); 
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
		
		
		apexpages.currentPage().getParameters().put('id' , tsinfo.Id );
		EditTimeSheet_Controller obj = new EditTimeSheet_Controller();
		obj.init();	
		obj.wrapTimeSheet.add(new timsheetDetailWrapper(tsd));
		obj.filterDate = '3/26/2011';
		//List<SelectOption> getOpportunities = obj.getProjects();
		//List<SelectOption> getSubOpportunities = obj.getSubProjects(); 
		List<SelectOption> getActivityCodes = obj.getActivityCodes();
		
		obj.save_editedTimeSheet();
		ApexPages.currentPage().getParameters ().put ('deletId', '0' );
		ApexPages.currentPage().getParameters ().put ('editId', '0' );
		obj.wrapTimeSheet.add(new timsheetDetailWrapper(tsd));
		ApexPages.currentPage().getParameters ().put ('cloneId', '0' );
		obj.CloneEntry();
		obj.deleteTimeSheetItem();
		obj.editTimeSheetItem();
		obj.addTimeSheetItem();
		obj.cancelTimeSheetItem();
		obj.getSubProjectsChanged();
		obj.filterSubProject();
		obj.project = op.Id ; 
		obj.filterDate = '3/26/2011';
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
		obj.timeSheetDetailval.Date__c = null  ;
		try
		{
			obj.addTimeSheetItem();		
		}
		catch (exception e)
		{
			system.assertEquals('Please Select Date', e.getMessage());
		}
		obj.timeSheetDetailval.Date__c = date.today()  ;
		obj.timeSheetDetailval.Narrative__c = null ;
		try
		{
			obj.addTimeSheetItem();		
		}
		catch (exception e)
		{
			system.assertEquals('Please Insert Narrative Name', e.getMessage());
		}
		obj.timeSheetDetailval.Narrative__c = 'sdfdsf' ;
		obj.timeSheetDetailval.Project__c = null  ;
		try
		{
			obj.addTimeSheetItem();		
		}
		catch (exception e)
		{
			system.assertEquals('Please Select Project', e.getMessage());
		}
		obj.timeSheetDetailval.Project__c = op.Id  ;
		obj.timeSheetDetailval.Total_Hours__c = 85;
		try
		{
			obj.addTimeSheetItem();		
		}
		catch (exception e)
		{
			system.assertEquals('Please Enter Valid Time', e.getMessage());
		}
		obj.timeSheetDetailval.Total_Hours__c = 10;
		obj.timeSheetDetailval.Name_of_business_passenger__c = '1212fsdf';
		try
		{
			obj.addTimeSheetItem();		
		}
		catch (exception e)
		{
			system.assertEquals('Passenger name Contain Invalid character', e.getMessage());
		}
		//obj.getSubProjectsChanged();
		//obj.changeSubProject();
		//getSubOpportunities = obj.getFilterSubProjects();
		obj.project = op.id;
		//getSubOpportunities = obj.getFilterSubProjects();
		obj.filterTimeSheet();
	}
	private static testMethod void testEditTimeSheetControllernull()
	{
		EditTimeSheet_Controller obj = new EditTimeSheet_Controller();
		obj.save_editedTimeSheet();	
		
	}
	
}