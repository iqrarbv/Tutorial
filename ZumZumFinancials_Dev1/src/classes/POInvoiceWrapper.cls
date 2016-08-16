public class POInvoiceWrapper 
{
	public Purchase_Invoice_Line_Item__c purchaseInvoiceLineItems {get; set;}
	public boolean taxselected {get; set;} 
	public integer serialNumber {get; set;}
	public decimal taxRate  {get; set;}
	public POInvoiceWrapper(Purchase_Invoice_Line_Item__c poInvoiceLineItems)
	{
		purchaseInvoiceLineItems = new Purchase_Invoice_Line_Item__c();
		purchaseInvoiceLineItems = poInvoiceLineItems ;
		taxselected = false ;
	}
	public string NominalAccount
	{
		get
		{
			if (purchaseInvoiceLineItems.Nominal_Account__c !=null)
			{
				if (AllNominalAccountMap.keyset().contains(purchaseInvoiceLineItems.Nominal_Account__c) )
					return AllNominalAccountMap.get(purchaseInvoiceLineItems.Nominal_Account__c).Nominal_Code__c + ' - ' + AllNominalAccountMap.get(purchaseInvoiceLineItems.Nominal_Account__c).Name ;
				else if (!AllNominalAccountMap.keyset().contains(purchaseInvoiceLineItems.Nominal_Account__c) )
				{
					Nominal_Account__c NonAccount = [Select Nominal_Code__c , Name From Nominal_Account__c where Id = : purchaseInvoiceLineItems.Nominal_Account__c limit 1] ;
					return NonAccount.Nominal_Code__c + ' - ' + NonAccount.Name ;
				}
				else
					return null;
			}
			else
				return null; 	
		}
		set;
	}
	public string NominalCode
	{
		get
		{
			if (purchaseInvoiceLineItems.Nominal_Account__c !=null)
			{
				if (AllNominalAccountMap.keyset().contains(purchaseInvoiceLineItems.Nominal_Account__c) )
					return AllNominalAccountMap.get(purchaseInvoiceLineItems.Nominal_Account__c).Nominal_Code__c;
				else if (!AllNominalAccountMap.keyset().contains(purchaseInvoiceLineItems.Nominal_Account__c) )
				{
					Nominal_Account__c NonAccount = [Select Nominal_Code__c , Name From Nominal_Account__c where Id = : purchaseInvoiceLineItems.Nominal_Account__c limit 1] ;
					return NonAccount.Nominal_Code__c ;
				}
				else
					return null;
			}
			else
				return null; 	
		}
		set;
	}
	public string OppName
	{
		get
		{
			if (purchaseInvoiceLineItems.Opportunity__c != null )
			{
				if (ALLOpportunities.keyset().contains(purchaseInvoiceLineItems.Opportunity__c))
					return  ALLOpportunities.get(purchaseInvoiceLineItems.Opportunity__c).Name ;
				else if(!ALLOpportunities.keyset().contains(purchaseInvoiceLineItems.Opportunity__c))
				{
					Opportunity nm = [Select Name From Opportunity where id =:purchaseInvoiceLineItems.Opportunity__c];
					return nm.Name ;
				}
				else
					return null ;
			}
			else
				return null; 	
		}
		set;
	}
	public string totalTax
	{
		get
		{
			if (purchaseInvoiceLineItems.Total_VAT__c ==null || purchaseInvoiceLineItems.Total_VAT__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(purchaseInvoiceLineItems.Total_VAT__c.setScale(2));
			}
		}
	}
	public string totalNet
	{
		get
		{
			if (purchaseInvoiceLineItems.Total_Net__c == null || purchaseInvoiceLineItems.Total_Net__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(purchaseInvoiceLineItems.Total_Net__c.setScale(2));
			}
		}
	}
	public string totalAmount
	{
		get
		{
			if (purchaseInvoiceLineItems.Total_Gross__c ==null || purchaseInvoiceLineItems.Total_Gross__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(purchaseInvoiceLineItems.Total_Gross__c.setScale(2));
			}
		}
	}
	public string strTaxRate
	{
		get
		{
			if (purchaseInvoiceLineItems.Tax_Rate__c != null )
			{
				if (AllTaxRateMap.keyset().contains(purchaseInvoiceLineItems.Tax_Rate__c))
					return  AllTaxRateMap.get(purchaseInvoiceLineItems.Tax_Rate__c).Name + ' - ' + string.valueof(AllTaxRateMap.get(purchaseInvoiceLineItems.Tax_Rate__c).Tax_Rate__c) + ' %'  ; // + ALLOpportunities.get(purchaseInvoiceLineItems.Opportunity__c).Name ;
				else if(!AllTaxRateMap.keyset().contains(purchaseInvoiceLineItems.Tax_Rate__c))
				{
					Tax_Rate__c nm = [Select Tax_Rate__c , Name From Tax_Rate__c where id =: purchaseInvoiceLineItems.Tax_Rate__c];
					return nm.Name + ' - ' +  string.valueof(nm.Tax_Rate__c) + ' %'  ;// + nm.Name ;
				}
				else 
					return null ;		
			}
			else
				return null;	
		}
		set;
	}
	public static map<Id , Nominal_Account__c> AllNominalAccountMap = new map<Id , Nominal_Account__c>([Select Nominal_Code__c , Name From Nominal_Account__c limit 10000]);
	public static map<Id , Opportunity> ALLOpportunities = new map<Id , Opportunity>([Select o.StageName, o.Name, o.Id From Opportunity o where StageName  != 'Closed Won' and  StageName != 'Closed Lost' ]);
	public static map<Id , Tax_Rate__c> AllTaxRateMap = new map<Id , Tax_Rate__c>([Select Tax_Rate__c , Name From Tax_Rate__c limit 10000]);
	/*
	public static validateLineItems(POInvoiceWrapper PiLineItems)
	{
		
		for (POInvoiceWrapper pr: PiLineItems)
		{
			if (pr.Purchase_Invoice_Line_Item__c.Nominal_Account__c == null)
				throw new customexception('')
		}
	}*/
}