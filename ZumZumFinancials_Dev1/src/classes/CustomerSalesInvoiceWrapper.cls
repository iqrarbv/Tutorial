public class CustomerSalesInvoiceWrapper {
	public string Month{get;set;}
	public decimal Invoices{get;set;}
	public decimal Credits{get;set;}
	public decimal Balances{get;set;}
	public decimal Receipts{get;set;}
	public decimal Payments{get;set;}
	
	public CustomerSalesInvoiceWrapper(Date m, decimal i, decimal c, decimal r, decimal p)
	{ 
		Month = Functions.getMonth(m);
		Invoices = i;
		Credits = c;
		Balances = Invoices - Credits ;
		Receipts = r;
		Payments = p;
	}
}