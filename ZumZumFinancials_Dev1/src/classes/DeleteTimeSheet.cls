public class DeleteTimeSheet 
{
	public boolean disableDelete {get; set;}
	private id deleteId {get; set;}
	public DeleteTimeSheet( apexpages.Standardcontroller deleteTimeSheet )
	{
		deleteId = apexpages.currentPage().getParameters().get('delId');
		apexpages.addMessage(new apexpages.Message( apexpages.Severity.info , 'Are you Sure to Delete this Time Sheet?', '' ) );  
		disableDelete = true ;
	}
	public DeleteTimeSheet( )
	{
	
	}
	public pagereference init()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			Time_Sheet__c ts = [select Id , Status__c , Name from Time_Sheet__c where Id =:deleteId];
			if ( ts.Status__c == 'Submitted_For_Approval' || ts.Status__c == 'Approved')
			{
				disableDelete = false ;
				throw new CustomException('Time Sheet TS#' + ts.Name + ' is ' + ts.Status__c + ' Its can\'t Be Deleted' );
				return null ;
			}
			else 
			{
				delete ts;
				return new pagereference ( '/' + apexpages.currentPage().getParameters().get('retURL') );	
			}
		}
		catch (exception e )
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null ;
		} 
	}
	public pagereference back()	
	{
		return new pagereference ('/' + deleteId );
	}
	public static testMethod void deleteTimeSheet()
	{
		Time_Sheet__c tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year();
		tsinfo.Status__c = 'Pending';
		insert tsinfo ;
		ApexPages.currentPage().getParameters ().put ('delId', tsinfo.id);
		DeleteTimeSheet obj  = new DeleteTimeSheet();
		obj.init();
		tsinfo = new Time_Sheet__c();
		tsinfo.Month__c = date.today().month();
		tsinfo.Year__c = date.today().year();
		tsinfo.Status__c = 'Submitted_For_Approval';
		insert tsinfo ;
		ApexPages.currentPage().getParameters ().put ('delId', tsinfo.id);
		try
		{
			obj.init();	
		}
		catch(exception e)
		{
			system.assertEquals('Time Sheet TS#' + tsinfo.Name + ' is ' + tsinfo.Status__c + ' Its can\'t Be Deleted', e.getMessage());
		}
		ApexPages.currentPage().getParameters ().put ('delId', null );
		obj.init();	
		obj.back();
	}
}