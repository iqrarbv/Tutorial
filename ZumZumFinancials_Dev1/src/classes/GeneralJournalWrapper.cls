public class GeneralJournalWrapper {			
	public string Code{get;set;}
	public string Name{get;set;}
	public string Narrative{get;set;}
	public string Tax{get;set;}
	public decimal Debit{get;set;}
	public decimal Credit{get;set;}
	public integer ind{get;set;}
	public Id idNominal{get;set;}
	public Id idTax{get;set;}				
	public GeneralJournalWrapper(string NominalId, string TaxId, string Narrativ, string d, string c, string t, integer i)
	{
		try
		{			
			Name= Functions.getNominalAccountNameByID(NominalId);			
			Tax = t;				
			idNominal = NominalId;
			idTax = TaxId;				
			Code = Functions.getAccountCodeById(NominalId);
			Narrative = Narrativ;				
			Debit = Decimal.valueOf(d);
			Credit = Decimal.valueOf(c);
			ind = i; 
		}		
		catch(exception ex)
		{
			throw new CustomException('Unable to Save\nWrapper Exception\n'+ex.getMessage());
		}
	}
}