public class SOLineItemWrapper 
{
	public Sales_Order_Line_Items__c salesOrderLineItems {get; set;}
	public boolean taxselected {get; set;} 
	public integer serialNumber {get; set;}
	public decimal taxRate  {get; set;}
	public SOLineItemWrapper(Sales_Order_Line_Items__c soLineItems)
	{
		salesOrderLineItems = new Sales_Order_Line_Items__c();
		salesOrderLineItems = soLineItems ;	
		taxselected = false ;	
	}
	/*
	public List<selectoption> SubProjectList
	{
		get
		{
			list<selectoption> subProjectlist = new list<selectoption>();
			for (Opportunity op: [select Id, Name from Opportunity where Sub_Project__c = :salesOrderLineItems.Project__c AND Sub_Project__c != null Order By Name Asc limit 1000])
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
			if (salesOrderLineItems.VAT_Amount__c ==null || salesOrderLineItems.VAT_Amount__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(salesOrderLineItems.VAT_Amount__c.setScale(2));
			}
		}
	}
	public string totalNet
	{
		get
		{
			if (salesOrderLineItems.Total_Net__c ==null || salesOrderLineItems.Total_Net__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(salesOrderLineItems.Total_Net__c.setScale(2));
			}
		}
	}
	public string totalAmount
	{
		get
		{
			if (salesOrderLineItems.Total_Amount__c ==null || salesOrderLineItems.Total_Amount__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(salesOrderLineItems.Total_Amount__c.setScale(2));
			}
		}
	}
	public string ProducName
	{
		get
		{
			if (salesOrderLineItems.Product__c !=null)
			{
				if (AllProductsMap.keyset().contains(salesOrderLineItems.Product__c) )
					return AllProductsMap.get(salesOrderLineItems.Product__c).ProductCode + ' - ' + AllProductsMap.get(salesOrderLineItems.Product__c).Name ;
				else if (!AllProductsMap.keyset().contains(salesOrderLineItems.Product__c) )
				{
					Product2 Product = [Select p.ProductCode, p.Name From Product2 p where Id = : salesOrderLineItems.Product__c];
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
			if (salesOrderLineItems.Project__c != null )
			{
				if (ALLOpportunities.keyset().contains(salesOrderLineItems.Project__c))
					return  ALLOpportunities.get(salesOrderLineItems.Project__c).Name ;
				else if(!ALLOpportunities.keyset().contains(salesOrderLineItems.Project__c))
				{
					Opportunity Opp = [Select o.StageName, o.Name, o.Id From Opportunity o where Id =:salesOrderLineItems.Project__c ];
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
	public static map<Id , Opportunity> ALLOpportunities = new map<Id , Opportunity>([Select o.StageName, o.Name, o.Id From Opportunity o where StageName  != 'Closed Won' and  StageName != 'Closed Lost']);
	
}