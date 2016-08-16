public class SalesByContactWrapper{
	public string Customer {get;set;}
	public List<decimal> sales{get;set;}	
	public SalesByContactWrapper(string c , List<decimal>  s)
	{		
		sales = new List<decimal>();
		Customer = c;		
		sales = s;	
	}
}