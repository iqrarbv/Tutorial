public class wrapperBankReceipt {
	public string codeNom{get;set;}
	public string NomAcctt{get;set;}
	public id NominalId{get;set;}
	public id TaxId{get;set;}
	public string taxName{get;set;}
	public id BankId{get;set;}	
	public string bnkAcctt{get;set;}
	public string Reference{get;set;}
	public string Details{get;set;}
	public decimal Amount{get;set;}
	public decimal Rate{get;set;}
	public decimal Tax{get;set;}
	public decimal Net{get;set;}
	public integer index{get;set;}
	public wrapperBankReceipt(string nom,Id tId, string tName, Id bId, string bName, string r, string d, decimal a, decimal rt, decimal t, decimal n, integer i)
	{
			NominalId = nom;
			codeNom = Functions.getAccountCodeById(nom);
			NomAcctt = Functions.getNominalAccountNameByID(nom); 
			
			TaxId = tId;
			taxName = tName;
			BankId = bId;
			bnkAcctt = bName;
			
			Reference = r;
			Details = d;
			
			Amount = a;
			Rate = rt;
			Tax = t;
			Net = n;
			index = i;
	} 
}