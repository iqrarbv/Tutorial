public class SILineItemWrapper 
{
	public Sales_Invoice_Line_Item__c salesInvoiceLineItems {get; set;}
	public boolean taxselected {get; set;} 
	public integer serialNumber {get; set;}
	public decimal taxRate  {get; set;}
	
	public SILineItemWrapper(Sales_Invoice_Line_Item__c siLineItems)
	{
		salesInvoiceLineItems = new Sales_Invoice_Line_Item__c();
		salesInvoiceLineItems = siLineItems ;	
		taxselected = false ;	
	}
	public string totalTax
	{
		get
		{
			if (salesInvoiceLineItems.VAT_Amount__c ==null || salesInvoiceLineItems.VAT_Amount__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(salesInvoiceLineItems.VAT_Amount__c.setScale(2));
			}
		}
	}
	public string totalNet
	{
		get
		{
			if (salesInvoiceLineItems.Total_Net__c ==null || salesInvoiceLineItems.Total_Net__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(salesInvoiceLineItems.Total_Net__c.setScale(2));
			}
		}
	}
	public string totalAmount
	{
		get
		{
			if (salesInvoiceLineItems.Total_Gross__c ==null || salesInvoiceLineItems.Total_Gross__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(salesInvoiceLineItems.Total_Gross__c.setScale(2));
			}
		}
	}
	public string ProducName
	{
		get
		{
			if (salesInvoiceLineItems.Product__c !=null)
			{
				if (AllProductsMap.keyset().contains(salesInvoiceLineItems.Product__c) )
					return AllProductsMap.get(salesInvoiceLineItems.Product__c).ProductCode + ' - ' + AllProductsMap.get(salesInvoiceLineItems.Product__c).Name ;
				else if (!AllProductsMap.keyset().contains(salesInvoiceLineItems.Product__c) )
				{
					Product2 Product = [Select p.ProductCode, p.Name From Product2 p where Id = : salesInvoiceLineItems.Product__c];
					return Product.ProductCode + ' - ' + Product.Name ;
				}
				else
					return null;
			}
			else
				return null; 	
		}
		set;
	}
	public static map<Id , Product2> AllProductsMap = new map<Id , Product2>([Select p.ProductCode, p.Name From Product2 p where p.IsActive = true]);
	public string OppName
	{
		get
		{
			if (salesInvoiceLineItems.Opportunity__c != null )
			{
				if (ALLOpportunities.keyset().contains(salesInvoiceLineItems.Opportunity__c))
					return  ALLOpportunities.get(salesInvoiceLineItems.Opportunity__c).Name ;
				else if(!ALLOpportunities.keyset().contains(salesInvoiceLineItems.Opportunity__c))
				{
					Opportunity Opp = [Select o.StageName, o.Name, o.Id From Opportunity o where Id =:salesInvoiceLineItems.Opportunity__c ];
					return Opp.Name ;
				}
				else
					return null ;
			}
			else
				return null; 	
		}
		set;
	}
	public string strTaxRate
	{
		get
		{
			if (salesInvoiceLineItems.Tax_Rate__c != null )
			{
				if (AllTaxRateMap.keyset().contains(salesInvoiceLineItems.Tax_Rate__c))
					return  AllTaxRateMap.get(salesInvoiceLineItems.Tax_Rate__c).Name + ' - ' + string.valueof(AllTaxRateMap.get(salesInvoiceLineItems.Tax_Rate__c).Tax_Rate__c) + ' %'  ; // + ALLOpportunities.get(purchaseInvoiceLineItems.Opportunity__c).Name ;
				else if(!AllTaxRateMap.keyset().contains(salesInvoiceLineItems.Tax_Rate__c))
				{
					Tax_Rate__c nm = [Select Tax_Rate__c , Name From Tax_Rate__c where id =: salesInvoiceLineItems.Tax_Rate__c];
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
	public static map<Id , Tax_Rate__c> AllTaxRateMap = new map<Id , Tax_Rate__c>([Select Tax_Rate__c , Name From Tax_Rate__c limit 10000]);
	public static map<Id , Opportunity> ALLOpportunities = new map<Id , Opportunity>([Select o.StageName, o.Name, o.Id From Opportunity o where StageName  != 'Closed Won' and  StageName != 'Closed Lost']);
}