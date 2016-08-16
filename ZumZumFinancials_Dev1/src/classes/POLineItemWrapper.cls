public class POLineItemWrapper 
{
	public Purchase_Order_Line_Items__c purchaseOrderLineItems {get; set;}
	public boolean taxselected {get; set;} 
	public integer serialNumber {get; set;}
	public decimal taxRate  {get; set;}
	public POLineItemWrapper(Purchase_Order_Line_Items__c poLineItems)
	{
		purchaseOrderLineItems = new Purchase_Order_Line_Items__c();
		purchaseOrderLineItems = poLineItems ;	
		taxselected = false ;	
	}
	/*
	public List<selectoption> SubProjectList
	{
		get
		{
			list<selectoption> subProjectlist = new list<selectoption>();
			for (Opportunity op: [select Id, Name from Opportunity where Sub_Project__c = :purchaseOrderLineItems.Project__c  AND Sub_Project__c != null Order By Name Asc limit 1000])
			{
				subProjectlist.add(new selectoption (op.Id , op.Name  ));	
			}
			if (SubProjectList.size() == 0)
			{
				SubProjectList.add(new selectoption('' , 'Select Sub Project'));
			}
			return subProjectlist ;
		}
		set;
	}
	*/
	public string totalTax
	{
		get
		{
			if (purchaseOrderLineItems.Total_VAT__c ==null || purchaseOrderLineItems.Total_VAT__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(purchaseOrderLineItems.Total_VAT__c.setScale(2));
			}
		}
	}
	public string totalAmount
	{
		get
		{
			if (purchaseOrderLineItems.Total_Gross__c ==null || purchaseOrderLineItems.Total_Gross__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(purchaseOrderLineItems.Total_Gross__c.setScale(2));
			}
		}
	}
	public string ProducName
	{
		get
		{
			if (purchaseOrderLineItems.Product__c !=null)
			{
				if (AllProductsMap.keyset().contains(purchaseOrderLineItems.Product__c) )
					return AllProductsMap.get(purchaseOrderLineItems.Product__c).ProductCode + ' - ' + AllProductsMap.get(purchaseOrderLineItems.Product__c).Name ;
				else if (!AllProductsMap.keyset().contains(purchaseOrderLineItems.Product__c) )
				{
					Product2 Product = [Select p.ProductCode, p.Name From Product2 p where Id = : purchaseOrderLineItems.Product__c];
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
	
	public static map<Id , Opportunity> ALLOpportunities = new map<Id , Opportunity>([Select o.StageName, o.Name, o.Id From Opportunity o where StageName  != 'Closed Won' and  StageName != 'Closed Lost']);
	
	public string OppName
	{
		get
		{
			if (purchaseOrderLineItems.Opportunity__c != null )
			{
				if (ALLOpportunities.keyset().contains(purchaseOrderLineItems.Opportunity__c))
					return  ALLOpportunities.get(purchaseOrderLineItems.Opportunity__c).Name ;
				else if(!ALLOpportunities.keyset().contains(purchaseOrderLineItems.Opportunity__c))
				{
					Opportunity Opp = [Select o.StageName, o.Name, o.Id From Opportunity o where Id =:purchaseOrderLineItems.Opportunity__c ];
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
			if (purchaseOrderLineItems.Tax_Rate__c != null )
			{
				if (AllTaxRateMap.keyset().contains(purchaseOrderLineItems.Tax_Rate__c))
					return  AllTaxRateMap.get(purchaseOrderLineItems.Tax_Rate__c).Name + ' - ' + string.valueof(AllTaxRateMap.get(purchaseOrderLineItems.Tax_Rate__c).Tax_Rate__c) + ' %'  ; // + ALLOpportunities.get(purchaseInvoiceLineItems.Opportunity__c).Name ;
				else if(!AllTaxRateMap.keyset().contains(purchaseOrderLineItems.Tax_Rate__c))
				{
					Tax_Rate__c nm = [Select Tax_Rate__c , Name From Tax_Rate__c where id =: purchaseOrderLineItems.Tax_Rate__c];
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
}