public class SubmitTimeSheetForApproval 
{
	/*
	public id timeSheetId  {get; set;}
	public User ur {get; set;}
	public Time_Sheet__c ts {get; set;}
	public String outHouredProjects {get; set;}
	public boolean sureSubmitt {get; set;}
	public boolean sendBack {get; set;}
	public SubmitTimeSheetForApproval ( apexpages.Standardcontroller submitTimeSheet )
	{
		
	}
	public SubmitTimeSheetForApproval ( )
	{
		
	}
	public void init()
	{
		timeSheetId = apexpages.currentPage().getParameters().get('id') ;
		Savepoint sp = Database.setsavepoint();
		try
		{
			if (timeSheetId != null )
			{
				ts = [select Month__c , Owner.Name ,Year__c, Total_Miles__c, Total_Hours__c, Status__c, OwnerId, Name, Id  from Time_Sheet__c where id = : timeSheetId limit 1]  ;
				if (ts.OwnerId != userinfo.getUserId())
				{
					sendBack = true ;
					throw new CustomException('You are Not Authorized to View & Submit this Time Sheet');	
				}
				if(ts.Status__c != 'Approved' && ts.Status__c != 'Submitted_For_Approval' )
				{
					TimeSheet_Model tsObject = new TimeSheet_Model(ts.Id);
					Set<Id> pIds = tsObject.GetProjectsForLevel2Approval();
					system.debug('pids++ '+pIds);
					if(pIds.size() > 0)
					{
						for (Opportunity pr : [select Name from Opportunity where Id IN :pIds] )
						{
							if (outHouredProjects == null )
								outHouredProjects = pr.Name;
							else 			
								outHouredProjects += ' ,' + pr.Name; 	
						}
						apexpages.addMessage( new apexpages.Message( apexpages.Severity.warning , 'Your Contracted Hours for these projects are Exceeded: ' + outHouredProjects  , ' Are you sure to submit this Time Sheet?' ) );
						sureSubmitt = true ; 
					}
					else
					{
						confirmSubmitt() ;
					}
				}
				else if (ts.Status__c == 'Approved')
				{
					sendBack = true ;
					throw new CustomException('Time Sheet is Already Approved' + 'You Can\'t Send it for Approval');	
				}
				else if(ts.Status__c == 'Submitted_For_Approval')
				{
					sendBack = true ;
					throw new CustomException('Time Sheet is Already Submitted for Approval');	
				}
			}
			else
			{
				throw new CustomException('No Time Sheet Exist for this Id');	
			}
		}
		catch (exception e)
		{
			sendBack = true ;
			Database.rollback(sp);
			apexpages.addMessage( new apexpages.Message( Apexpages.Severity.error , e.getMessage() , '' )  );
		}
	}
	public void confirmSubmitt()
	{
		ur = [select Id , Name , Email , UserRoleId from User where id = :Userinfo.getUserId() limit 1 ];
		TimeSheet_Model tsSubmit = new TimeSheet_Model(ts.Id);
		tsSubmit.SubmitForApproval(ur);
		ts.Status__c = 'Submitted_For_Approval';
		update ts;
		sureSubmitt = false ;
		sendBack = true ;
		apexpages.addMessage( new apexpages.Message( Apexpages.Severity.info , 'Time Sheet Submitted for Approval' , '' )  );
	}
	public pagereference back()
	{
		return new pagereference('/' + apexpages.currentPage().getParameters().get('id')) ;
	}
	public static TestMethod void submitForApproval()
	{
		/*
		User ur = [Select Id , Email , Name from User where Id = : '00590000000GMT5'];
		system.runAs(ur)
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
			insert tsinfo ;
			Time_Sheet_Detail__c tsd = new Time_Sheet_Detail__c();
			tsd.Activity_Code__c  = ac.Id ;
			tsd.Date__c = date.today();
			tsd.Index__c =  0 ;
			tsd.Narrative__c = 'test Code';
			tsd.Total_Hours__c = 15 ;
			tsd.Total_Miles__c = 20 ;
			tsd.Activity_Code__c = ac.id ;
			tsd.Project__c = op.Id ;
			tsd.Time_Sheet__c = tsinfo.Id;
			insert tsd ;
			Project_Hours__c pH= new Project_Hours__c(Year__c =date.today().year() , User__c = tsinfo.OwnerId , Total_Hours__c = 8 , Project__c = op.Id, Month__c = date.today().month());
			insert pH ;
			system.debug('this is timeSheet ' + tsinfo );
			system.debug('this is Project Pudject: ' + tsd);
			system.debug('this is budget ' + [Select p.Year__c, p.Project__c, p.Name, p.Month__c, p.Id, p.Total_Hours__c From Project_Hours__c p Where p.Project__c=:op.id and User__c=:tsinfo.OwnerId and month__c=:tsinfo.Month__c and year__c=:tsinfo.Year__c limit 1]) ;
			ApexPages.currentPage ().getParameters ().put ('id', tsinfo.id);
			SubmitTimeSheetForApproval obj  = new SubmitTimeSheetForApproval();
			obj.ts = tsinfo ;
	        obj.init();
	       // obj.confirmSubmitt();
	       	obj.back();
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
				system.assertEquals('Time Sheet is Already Approved' + 'You Can\'t Send it for Approval', e.getMessage());
			}
			tsinfo = new Time_Sheet__c();
			tsinfo.Month__c = date.today().month();
			tsinfo.Year__c = date.today().year(); 
			tsinfo.Status__c = 'Submitted_For_Approval';
			insert tsinfo ;
			ApexPages.currentPage ().getParameters ().put ('id', tsinfo.id);
			try
			{
				obj.init();
			}
			catch(exception e)
			{
				system.assertEquals('Time Sheet is Already Submitted for Approval', e.getMessage());
			}
			try
	        {	
	        	obj.confirmSubmitt();
	        }
	        catch(exception e)
	        {
	        	system.assertEquals(tsinfo.Status__c+' time Sheet cannot be submitted for approval.', e.getMessage());	
	        }
		}
			
	}
	*/
}