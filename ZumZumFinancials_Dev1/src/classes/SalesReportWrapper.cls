public class SalesReportWrapper {
	public string monthNyearReport {get;set;}
		
	public decimal sales{get;set;}
	public decimal creditNotes{get;set;}
	public integer mName{get;set;}
	public integer yName{get;set;}
	
	public SalesReportWrapper(Date n , integer m, integer y, decimal s, decimal c )
	{
		monthNyearReport = Functions.getMonth(n);
		mName = m;
		yName = y;				
		sales = s;
		creditNotes = c;
	}	
}