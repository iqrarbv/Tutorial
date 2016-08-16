public class AgedRecieveables 
{
	public List<AgedPayablestruct> payable {get; set;}
	public map<string , AgedPayablestruct> monthlyMap {get; set;}
	public map<string , AgedPayablestruct> oldPaymnets {get; set;}
	public List<AgedPayablestruct> lstPayable {get; set;}
	public Ledger__c leg {get; set;}
	public string firstMonth {get;set;}
	public string secondMonth {get;set;}
	public string thirdMonth {get;set;}
	public set<string> uniqueAccounts {get; set;}
	public boolean showreport {get; set;}
	
	public decimal thisMonthGrandTotal {get; set;}
	public decimal secMonthGrandTotal {get; set;}
	public decimal thrdMonthGrandTotal {get; set;}
	public decimal olderGrandTotal {get; set;}
	public decimal futureMonthGrandTotal {get; set;}
	
	public AgedRecieveables(apexpages.standardcontroller stdCon)
	{
		leg =new Ledger__c();
		leg.Trans_Date__c = date.today();
		thisMonthGrandTotal = 0.00 ;
		secMonthGrandTotal = 0.00 ;
		thrdMonthGrandTotal = 0.00 ;
		olderGrandTotal = 0.00 ;
		futureMonthGrandTotal = 0.00 ;
		
	}
	public AgedRecieveables()
	{
		/*
		leg =new Ledger__c();
		leg.Trans_Date__c = date.today();
		thisMonthGrandTotal = 0.00 ;
		secMonthGrandTotal = 0.00 ;
		thrdMonthGrandTotal = 0.00 ;
		olderGrandTotal = 0.00 ;
		futureMonthGrandTotal = 0.00 ;
		GenerateReport();
		*/
	}	
	public void CreatDashBoardReport()
	{
			
	}
	public void ExcelReport()
	{
		leg =new Ledger__c();
		leg.Trans_Date__c = date.valueof(apexpages.currentPage().getParameters().get('reportDate')); 
		thisMonthGrandTotal = 0.00 ;
		secMonthGrandTotal = 0.00 ;
		thrdMonthGrandTotal = 0.00 ;
		olderGrandTotal = 0.00 ;
		futureMonthGrandTotal = 0.00 ;
		GenerateReport();
	}
	public void GenerateReport()
	{
		try
		{
			if(leg.Trans_Date__c ==null )
				throw new customexception('Please Select A valid Date');
		 	showreport = true ;
		 	monthlyMap = new map<string , AgedPayablestruct>();
		 	oldPaymnets = new map<string , AgedPayablestruct>();
		 	uniqueAccounts = new set<string>();
		 	lstPayable = new List<AgedPayablestruct>();
		 	AggregateResult[] SItransaction = [select Sum(Net__c) totalAmount, Trans_Date__c trDate,Sub_Account__c accountName from Ledger__c where Type__c = 'PI' and Trans_Date__c >= :leg.Trans_Date__c.adddays(-90) and Show_On_Transaction__c =1 and Is_Deleted__c = false group by Sub_Account__c,  Trans_Date__c];	
			system.debug('this is agrr result: ' + SItransaction);
			string log = '';
			for( AggregateResult  ar :SItransaction)
			{
				if( (date)ar.get('trDate') >= leg.Trans_Date__c.adddays(-90) && (date)  ar.get('trDate') < leg.Trans_Date__c.adddays(-60))
				{
					log +='\n This is transaction Date: ' + ar.get('trDate') + ' 90 days ending date : ' + leg.Trans_Date__c.adddays(-90).format() + ' 60 days starting date ' + leg.Trans_Date__c.adddays(-60).format() + '\n';
					if(monthlyMap.keyset().contains((string)ar.get('accountName')))
					{
						monthlyMap.get((string)ar.get('accountName')).days90 += (decimal)ar.get('totalAmount') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Debit = ar.get('debit')==null?0:(decimal)ar.get('debit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Credit = ar.get('credit')==null?0:(decimal)ar.get('credit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).PaidAmount = 0.00 ;
			 			uniqueAccounts.add((string)ar.get('accountName'));	
			 			thrdMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;
					}
					else
					{
						
			 			monthlyMap.put((string)ar.get('accountName') , new AgedPayablestruct((string)ar.get('accountName'), 0.00 , 0.00 , (decimal)ar.get('totalAmount') , 0.00 , 0.00 ));
						uniqueAccounts.add((string)ar.get('accountName'));	
						thrdMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;
					}
				}
				if ((date) ar.get('trDate') >= leg.Trans_Date__c.adddays(-60) && (date) ar.get('trDate') < leg.Trans_Date__c.adddays(-30))
				{
					log +='This is transaction Date: ' + ar.get('trDate') + ' 60 days ending date : ' + leg.Trans_Date__c.adddays(-60).format() + ' 60 days starting date ' + leg.Trans_Date__c.adddays(-30).format()+ '\n';
					if(monthlyMap.keyset().contains((string)ar.get('accountName')))
					{
						monthlyMap.get((string)ar.get('accountName')).days60 += (decimal)ar.get('totalAmount') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Debit = ar.get('debit')==null?0:(decimal)ar.get('debit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Credit = ar.get('credit')==null?0:(decimal)ar.get('credit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).PaidAmount = 0.00 ;
			 			uniqueAccounts.add((string)ar.get('accountName'));
			 			secMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;	
					}
					else
					{
						
			 			monthlyMap.put((string)ar.get('accountName') , new AgedPayablestruct((string)ar.get('accountName'), 0.00 , (decimal)ar.get('totalAmount') , 0.00 , 0.00 , 0.00 ));
						uniqueAccounts.add((string)ar.get('accountName'));	
						secMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;	
					}
				}	
				if( (date) ar.get('trDate') >= leg.Trans_Date__c.adddays(-30) && (date) ar.get('trDate') <= leg.Trans_Date__c)	
				{
					log +='This is transaction Date: ' + ar.get('trDate') + ' 30 days ending date : ' + leg.Trans_Date__c.adddays(-30).format() + ' 60 days starting date ' + leg.Trans_Date__c.format()+ '\n';
					if(monthlyMap.keyset().contains((string)ar.get('accountName')))
					{
						monthlyMap.get((string)ar.get('accountName')).days30 += (decimal)ar.get('totalAmount') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Debit = ar.get('debit')==null?0:(decimal)ar.get('debit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Credit = ar.get('credit')==null?0:(decimal)ar.get('credit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).PaidAmount = 0.00 ;
			 			uniqueAccounts.add((string)ar.get('accountName'));
			 			thisMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;	
					}
					else
					{
						
			 			monthlyMap.put((string)ar.get('accountName') , new AgedPayablestruct((string)ar.get('accountName'), (decimal)ar.get('totalAmount') , 0.00 , 0.00 , 0.00 , 0.00 ));
						uniqueAccounts.add((string)ar.get('accountName'));	
						thisMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;
					}
				}
				if( (date) ar.get('trDate') > leg.Trans_Date__c )
				{
					log += 'these are future entries: ' + ar.get('trDate') + '\n'; 
					if(monthlyMap.keyset().contains((string)ar.get('accountName')))
					{
						monthlyMap.get((string)ar.get('accountName')).featureAmount += (decimal)ar.get('totalAmount') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Debit = ar.get('debit')==null?0:(decimal)ar.get('debit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).Credit = ar.get('credit')==null?0:(decimal)ar.get('credit') ;
			 			//monthlyMap.get((string)ar.get('accountName')).PaidAmount = 0.00 ;
			 			uniqueAccounts.add((string)ar.get('accountName'));	
			 			futureMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;
					}
					else
					{
						
			 			monthlyMap.put((string)ar.get('accountName') , new AgedPayablestruct((string)ar.get('accountName'), 0.00 , 0.00 , 0.00 , 0.00 , (decimal)ar.get('totalAmount') ));
						uniqueAccounts.add((string)ar.get('accountName'));
						futureMonthGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;	
					}
				}
			}
			for( AggregateResult  ar :[select Sum(Net__c) totalAmount, Trans_Date__c trDate, Sub_Account__c accountName from Ledger__c where Type__c = 'PI' and Trans_Date__c < :leg.Trans_Date__c.adddays(-90) and Show_On_Transaction__c =1 group by Sub_Account__c ,Trans_Date__c ])
			{
				log += 'these are old entries: ' + ar.get('trDate')+ '\n';
				if(oldPaymnets.keyset().contains((string)ar.get('accountName')))
				{
					oldPaymnets.get((string)ar.get('accountName')).olderAmount += (decimal)ar.get('totalAmount') ;
		 			//monthlyMap.get((string)ar.get('accountName')).Debit = ar.get('debit')==null?0:(decimal)ar.get('debit') ;
		 			//monthlyMap.get((string)ar.get('accountName')).Credit = ar.get('credit')==null?0:(decimal)ar.get('credit') ;
		 			//monthlyMap.get((string)ar.get('accountName')).PaidAmount = 0.00 ;
		 			uniqueAccounts.add((string)ar.get('accountName'));	
		 			olderGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;
				}
				else
				{
					oldPaymnets.put((string)ar.get('accountName') , new AgedPayablestruct((string)ar.get('accountName'), 0.00 , 0.00 , 0.00 , (decimal)ar.get('totalAmount') , 0.00 ));
					uniqueAccounts.add((string)ar.get('accountName'));
					olderGrandTotal += ar.get('totalAmount')==null?0.00:(decimal)ar.get('totalAmount') ;	
				}
			}
			system.debug('this is map: ' + monthlyMap) ;
			system.debug('this is older map: ' + oldPaymnets) ;
			for(string st : uniqueAccounts)
		 	{
		 		
		 		//if(monthlyMap.size()>0 && monthlyMap.keyset().contains(st))
		 		if(monthlyMap.keyset().contains(st) && oldPaymnets.keyset().contains(st) )
		 		{	
		 			system.debug('this is in new map');
		 			lstPayable.add(new AgedPayablestruct(monthlyMap.get(st).AccountName , monthlyMap.get(st).days30==null?0: monthlyMap.get(st).days30 , monthlyMap.get(st).days60==null?0: monthlyMap.get(st).days60 , monthlyMap.get(st).days90==null?0: monthlyMap.get(st).days90 , oldPaymnets.get(st).olderAmount==null?0: oldPaymnets.get(st).olderAmount , monthlyMap.get(st).featureAmount==null?0: monthlyMap.get(st).featureAmount ));
		 		}
		 		//else if(oldPaymnets.size()>0 && oldPaymnets.keyset().contains(st))
		 		else if(monthlyMap.keyset().contains(st))
		 		{
			 		system.debug('this is in old map');
			 		lstPayable.add(new AgedPayablestruct(monthlyMap.get(st).AccountName , monthlyMap.get(st).days30==null?0: monthlyMap.get(st).days30 , monthlyMap.get(st).days60==null?0: monthlyMap.get(st).days60 , monthlyMap.get(st).days90==null?0: monthlyMap.get(st).days90 , 0.00 , monthlyMap.get(st).featureAmount==null?0: monthlyMap.get(st).featureAmount ));
		 		}
		 		else if(oldPaymnets.keyset().contains(st))
		 		{
			 		system.debug('this is in old map');
			 		lstPayable.add(new AgedPayablestruct(oldPaymnets.get(st).AccountName , 0.00 , 0.00 ,0.00 , oldPaymnets.get(st).olderAmount==null?0: oldPaymnets.get(st).olderAmount , 0.00  )  );
		 		}	
		 	}
		 	system.debug('this is date records: ' + log);
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public class AgedPayablestruct
	{
		public Decimal days30 {get; set;}
		public Decimal days60 {get; set;}
		public Decimal days90 {get; set;}
		public Decimal olderAmount {get; set;}
		public Decimal featureAmount {get; set;}
		public String AccountName {get; set;}
		public decimal Balance {get; set;}
		public decimal Credit {get; set;}
		public decimal Debit {get; set;}
		public decimal PaidAmount {set; get;}
		public decimal turnOver {get; set;}
		//public AgedPayablestruct(string acName , decimal amt1 ,  decimal amt2 , decimal amt3 , decimal amt4 , decimal amtcredit , decimal amtdebit , decimal amtPaid , decimal turnOver)
		public AgedPayablestruct(string acName , decimal amtdays30 ,  decimal amtdays60 , decimal amtdays90 , decimal amtolder , decimal amtfeature )
		{
			AccountName = acName ;
			days30 = amtdays30 ;
			days60 = amtdays60 ;
			days90 = amtdays90 ;
			olderAmount = amtolder ;
			featureAmount = amtfeature ;
			//Credit = amtcredit ;
			//Debit = amtdebit ;
			//PaidAmount =  amtPaid ;
			//turnOver = turnOver ;
		}
		/*
		public decimal totalAmount
		{
			get
			{
				return days30 + days60 + days90 + olderAmount ; 
			}
			set ;
		}
		public decimal totalBalance
		{
			get
			{
				if (Debit - Credit != null || Debit - Credit != 0 )
					return Debit - Credit ;
				else
					return 0.00;
			}
			set ;
		}
		*/
		
	}
	
	// This is test code
	private static testmethod void Test_AgedPayable()
	{
		// Inserting Test Date to ledger
		Ledger__c journal = new Ledger__c();
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		AgedRecieveables obj = new AgedRecieveables(std);
		try
		{
			obj.GenerateReport();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Please Select A valid Date');	
		}
		obj.leg.Trans_Date__c = date.today();
		obj.GenerateReport();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ; 
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-4) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-3) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-2) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-1) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today() , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(1) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ; 
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(2) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(3) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(4) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(6) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'CD656092', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().adddays(-6) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;							
		// Entries with another account code
		
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ; 
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-4) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-3) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-2) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-1) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today() , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(1) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ; 
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(2) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(3) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(4) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(6) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'AKS51', Details__c = 'Purchase Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().adddays(-6) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		
		obj.GenerateReport();
		
		apexpages.currentPage().getParameters().put('reportDate' , '2011-07-5');
		obj.ExcelReport();
	}
}