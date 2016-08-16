public class PurchaseReportWrapper {
	public string monthNyearReport {get;set;}	
	public decimal purchase{get;set;}
	public decimal creditNotes{get;set;}		
	public PurchaseReportWrapper(Date n , decimal p, decimal c)
	{		
		monthNyearReport = Functions.getMonth(n);	
		purchase = p;
		creditNotes = c;
	}	

}