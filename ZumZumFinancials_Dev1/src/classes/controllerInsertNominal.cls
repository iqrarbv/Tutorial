public class controllerInsertNominal {
	public boolean showbutton {get; set;}
	public controllerInsertNominal ()
	{	
		showbutton = true ;	
	}
	public void init ()
	{
		Savepoint sp = Database.setSavepoint();
		try
		{
			List<string> MainCategories = new List<string>();
			MainCategories.add('Sales');
			MainCategories.add('Purchases');
			MainCategories.add('Direct Expenses');
			MainCategories.add('Overheads');
			MainCategories.add('Fixed Assets');
			MainCategories.add('Current Assets');
			MainCategories.add('Current Liabilities');
			MainCategories.add('Long Term Liabilities');
			MainCategories.add('Capital & Reverses');
			list<Nominal_Categories__c> NomCategories = new list<Nominal_Categories__c>();
			for (string c: MainCategories)
			{
				NomCategories.add(new Nominal_Categories__c(Name = c));	
			}
			
			Map<string , List<NMSubCategories>> SubCategories = new Map<string , List<NMSubCategories>>();
			List<NMSubCategories> SalesList = new List<NMSubCategories>();
			SalesList.add(new NMSubCategories('Product Sales' , 4000 , 4099));
			SalesList.add(new NMSubCategories('Export Sales' , 4100 , 4199));
			SalesList.add(new NMSubCategories('Sales of Assets' , 4200 , 4299));
			SalesList.add(new NMSubCategories('Credit Charges (late Payments)' , 4400 , 4499));
			SalesList.add(new NMSubCategories('Other Sales' , 4900 , 4999));
			SubCategories.put('Sales' , SalesList);
			
			List<NMSubCategories> PurchaseList = new List<NMSubCategories>();
			PurchaseList.add(new NMSubCategories('Purchases' , 5000 , 5099));
			PurchaseList.add(new NMSubCategories('Purchases Charges' , 5100 , 5199 ));
			PurchaseList.add(new NMSubCategories('Stock' , 5200 , 5299));
			SubCategories.put('Purchases' , PurchaseList);
			
			List<NMSubCategories> Expenses = new List<NMSubCategories>();
			Expenses.add(new NMSubCategories('Labour' , 6000 , 6099));
			Expenses.add(new NMSubCategories('Commissions' , 6100 , 6199 ));
			Expenses.add(new NMSubCategories('Sales Promotions' , 6200 , 6299 ));
			Expenses.add(new NMSubCategories('Miscellaneous Expenses' , 6900 , 6999 ));
			SubCategories.put('Direct Expenses' , Expenses);
			
			List<NMSubCategories> OverHead = new List<NMSubCategories>();
			OverHead.add(new NMSubCategories('Gross Wages' , 7000 , 7099));
			OverHead.add(new NMSubCategories('Rent and Rates' , 7100 , 7199 ));
			OverHead.add(new NMSubCategories('Heat,Light and Power' , 7200 , 7299 ));
			OverHead.add(new NMSubCategories('Motor Expense' , 7300 , 7399 ));
			OverHead.add(new NMSubCategories('Travelling and Entertainment' , 7400 , 7499));
			OverHead.add(new NMSubCategories('Printing and Stationery' , 7500 , 7599 ));
			OverHead.add(new NMSubCategories('Professional Fees' , 7600 , 7699 ));
			OverHead.add(new NMSubCategories('Equipment Hire and Rental' , 7700 , 7799 ));
			OverHead.add(new NMSubCategories('Maintenance' , 7800 , 7899 ));
			OverHead.add(new NMSubCategories('Bank Charges and  Interest' , 7900 , 7999));
			OverHead.add(new NMSubCategories('Depreciation' , 8000 , 8099 ));
			OverHead.add(new NMSubCategories('Bad Debt' , 8100 , 8199 ));
			OverHead.add(new NMSubCategories('General Expenses' , 8200 , 8299 ));
			OverHead.add(new NMSubCategories('Suspense & Mispostings' , 9998 , 9998 ));
			SubCategories.put('Overheads' , OverHead);
			
			
			List<NMSubCategories> Assets = new List<NMSubCategories>();
			Assets.add(new NMSubCategories('Property' , 0010 , 0019));
			Assets.add(new NMSubCategories('Plant and Machinery' , 0020 , 0029 ));
			Assets.add(new NMSubCategories('Office Equipment' , 0030 , 0039 ));
			Assets.add(new NMSubCategories('Furniture and Fixtures' , 0040 , 0049 ));
			Assets.add(new NMSubCategories('Motor Vehicles' , 0050 , 0059 ));
			SubCategories.put('Fixed Assets' , Assets);
			
			List<NMSubCategories> CAssets = new List<NMSubCategories>();
			CAssets.add(new NMSubCategories('Stock' , 1000 , 1099));
			CAssets.add(new NMSubCategories('Debtors' , 1000 , 1099 ));
			CAssets.add(new NMSubCategories('Deposits and Cash' , 1200 , 1239 ));
			CAssets.add(new NMSubCategories('Credit Card (debators)' , 1250 , 1250 ));
			CAssets.add(new NMSubCategories('VAT Liability' , 2200 , 2299 ));
			SubCategories.put('Current Assets' ,CAssets);
								
								
			List<NMSubCategories> cLiabilities = new List<NMSubCategories>();
			cLiabilities.add(new NMSubCategories('Creditors: Short Term' , 2100 , 2199));
			cLiabilities.add(new NMSubCategories('Taxation' , 2210 , 2219 ));
			cLiabilities.add(new NMSubCategories('Wages' , 2220 , 2229 ));
			cLiabilities.add(new NMSubCategories('Credit Card (Creditors)' , 1240 , 1240 ));
			cLiabilities.add(new NMSubCategories('VAT Liability' , 2200 , 2299 ));
			SubCategories.put('Current Liabilities' , cLiabilities );	
			
			
			List<NMSubCategories> LTLiabilities = new List<NMSubCategories>();
			LTLiabilities.add(new NMSubCategories('Creditors: Long Term' , 2300 , 2399));
			SubCategories.put('Long Term Liabilities' , LTLiabilities );							
			
			List<NMSubCategories> Capitals = new List<NMSubCategories>();
			Capitals.add(new NMSubCategories('Share Capital' , 2300 , 2399));
			Capitals.add(new NMSubCategories('Reserves' , 3100 , 3299));
			SubCategories.put('Capital & Reserves' ,Capitals );
			system.debug('this is after puting values: ' + SubCategories) ;
			//this is nominal category map
			Map<string , List<NominalCodesValues>> NomCodes = new Map<string , List<NominalCodesValues>>();
			list<NominalCodesValues> NomAccount = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Sales North' , 4000));
			NomAccount.add(new NominalCodesValues('Sales South' , 4001));
			NomAccount.add(new NominalCodesValues('Sales Scotland' , 4002));
			NomAccount.add(new NominalCodesValues('Sales Wales' , 4003));
			NomAccount.add(new NominalCodesValues('Sales international' , 4004));
			NomAccount.add(new NominalCodesValues('Discounts Allowed' , 4009));
			NomCodes.put('Product Sales', NomAccount);
			
			list<NominalCodesValues> NomAccount1 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Export Sales' , 4100));
			NomCodes.put('Export Sales', NomAccount1);
			
			list<NominalCodesValues> NomAccount2 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Sales of Assets' , 4200));
			NomCodes.put('Sales of Assets', NomAccount2);
			
			list<NominalCodesValues> NomAccount3 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Credit Charges' , 4400));
			NomCodes.put('Credit Charges (late Payments)', NomAccount3);
			
			list<NominalCodesValues> NomAccount4 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Miscellaneous Income' , 4901));
			NomAccount.add(new NominalCodesValues('Royalties Received' , 4901));
			NomAccount.add(new NominalCodesValues('Commissions Received' , 4902));
			NomAccount.add(new NominalCodesValues('Insurance Claims' , 4903));
			NomAccount.add(new NominalCodesValues('Distribution and Carriage' , 4905));
			NomCodes.put('Other Sales', NomAccount4);
			
			list<NominalCodesValues> NomAccount5 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Materials Purchased' , 5000));
			NomAccount.add(new NominalCodesValues('Materials Imported' , 5001));
			NomAccount.add(new NominalCodesValues('Miscellaneous Purchases' , 5002));
			NomAccount.add(new NominalCodesValues('Packaging' , 5003));
			NomAccount.add(new NominalCodesValues('Discounts Taken' , 5009));
			NomCodes.put('Purchases', NomAccount5);
			
			list<NominalCodesValues> NomAccount6 = new list<NominalCodesValues>();	
			NomAccount.add(new NominalCodesValues('Carriage' , 5100));
			NomAccount.add(new NominalCodesValues('Import Duty' , 5101));
			NomAccount.add(new NominalCodesValues('Transport Insurance' , 5102));
			NomCodes.put('Purchases Charges', NomAccount6);
			
			list<NominalCodesValues> NomAccount7 = new list<NominalCodesValues>();		
			NomAccount.add(new NominalCodesValues('Opening Stock' , 5200));
			NomAccount.add(new NominalCodesValues('Closing Stock' , 5201));
			NomCodes.put('Stock', NomAccount7);
			
			list<NominalCodesValues> NomAccount8 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Productive Labour' , 6001));
			NomAccount.add(new NominalCodesValues('Cost of Sales Labour' , 6002));
			NomAccount.add(new NominalCodesValues('Sub-Contractors' , 6003));
			NomCodes.put('Labour', NomAccount8);
			
			list<NominalCodesValues> NomAccount9 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Sales Commissions' , 6199));
			NomCodes.put('Commissions', NomAccount9);
			
			list<NominalCodesValues> NomAccount10 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Sales Promotions' , 6200));
			NomAccount.add(new NominalCodesValues('Advertising' , 6201));
			NomAccount.add(new NominalCodesValues('Gifts and Samples' , 6202));
			NomAccount.add(new NominalCodesValues('P.R. (Literature & Brochures)' , 6203));
			NomCodes.put('Sales Promotions', NomAccount10);
			
			list<NominalCodesValues> NomAccount11 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Miscellaneous Expenses' , 6900));
			NomCodes.put('Miscellaneous Expenses', NomAccount11);
			
			list<NominalCodesValues> NomAccount12 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Gross Wages' , 7000));
			NomAccount.add(new NominalCodesValues('Directors Salaries' , 7001));
			NomAccount.add(new NominalCodesValues('Directors Remuneration' , 7002));
			NomAccount.add(new NominalCodesValues('Staff Salaries' , 7003));
			NomAccount.add(new NominalCodesValues('Wages - Regular' , 7004));
			NomAccount.add(new NominalCodesValues('Wages - Casual' , 7005));
			NomAccount.add(new NominalCodesValues('Employers N.I.' , 7006));
			NomAccount.add(new NominalCodesValues('Employers Pensions' , 7007));
			NomAccount.add(new NominalCodesValues('Recruitment Expenses' , 7008));
			NomAccount.add(new NominalCodesValues('Adjustments' , 7009));
			NomAccount.add(new NominalCodesValues('SSP Reclaimed' , 7010));
			NomAccount.add(new NominalCodesValues('SMP Reclaimed' , 7011));
			NomCodes.put('Gross Wages', NomAccount12);
			
			list<NominalCodesValues> NomAccount13 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Rent' , 7100));
			NomAccount.add(new NominalCodesValues('Water Rates' , 7101));
			NomAccount.add(new NominalCodesValues('General Rates' , 7102));
			NomAccount.add(new NominalCodesValues('Premises Insurance' , 7103));
			NomCodes.put('Rent and Rates', NomAccount13);
			
			list<NominalCodesValues> NomAccount14 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Electricity' , 7200));
			NomAccount.add(new NominalCodesValues('Gas' , 7201));
			NomAccount.add(new NominalCodesValues('Oil' , 7202));
			NomAccount.add(new NominalCodesValues('Other Heating Costs' , 7203));
			NomCodes.put('Heat,Light and Power', NomAccount14);
			
			list<NominalCodesValues> NomAccount15 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Fuel and Oil' , 7300));
			NomAccount.add(new NominalCodesValues('Repairs and Servicing' , 7301));
			NomAccount.add(new NominalCodesValues('Licences' , 7302));
			NomAccount.add(new NominalCodesValues('Vehicle Insurance' , 7303));
			NomAccount.add(new NominalCodesValues('Miscellaneous Motor Expenses' , 7304));
			NomAccount.add(new NominalCodesValues('Scale Charges' , 7350));
			NomCodes.put('Motor Expense', NomAccount15);
			
			list<NominalCodesValues> NomAccount16 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Travelling' , 7400));
			NomAccount.add(new NominalCodesValues('Car Hire' , 7401));
			NomAccount.add(new NominalCodesValues('Hotels' , 7402));
			NomAccount.add(new NominalCodesValues('U.K. Entertainment' , 7403));
			NomAccount.add(new NominalCodesValues('Overseas Entertainment' , 7404));////////
			NomAccount.add(new NominalCodesValues('Overseas Travelling' , 7405));
			NomAccount.add(new NominalCodesValues('Subsistence' , 7406));
			NomCodes.put('Motor Expense', NomAccount16);
			
			list<NominalCodesValues> NomAccount17 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Printing' , 7500));
			NomAccount.add(new NominalCodesValues('Postage and Carriage' , 7501));
			NomAccount.add(new NominalCodesValues('Telephone' , 7502));
			NomAccount.add(new NominalCodesValues('Telex/Telegram/Facsimile' , 7503));
			NomAccount.add(new NominalCodesValues('Office Stationery' , 7504));
			NomAccount.add(new NominalCodesValues('Books etc.' , 7505));
			NomCodes.put('Printing and Stationery', NomAccount17);
			
			list<NominalCodesValues> NomAccount18 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Legal Fees' , 7600));
			NomAccount.add(new NominalCodesValues('Audit and Accountancy Fees' , 7601));
			NomAccount.add(new NominalCodesValues('Consultancy Fees' , 7602));
			NomAccount.add(new NominalCodesValues('Professional Fees' , 7603));
			NomCodes.put('Professional Fees', NomAccount18);
			
			list<NominalCodesValues> NomAccount19 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Equipment Hire' , 7700));
			NomAccount.add(new NominalCodesValues('Office Machine Maintenance' , 7701));
			NomCodes.put('Equipment Hire and Rental', NomAccount19);
			
			list<NominalCodesValues> NomAccount20 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Repairs and Renewals' , 7800));
			NomAccount.add(new NominalCodesValues('Cleaning' , 7801));
			NomAccount.add(new NominalCodesValues('Laundry' , 7802));
			NomAccount.add(new NominalCodesValues('Premises Expenses' , 7803));
			NomCodes.put('Maintenance', NomAccount20);
			
			list<NominalCodesValues> NomAccount21 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Bank Interest Paid' , 7900));
			NomAccount.add(new NominalCodesValues('Bank Charges' , 7901));
			NomAccount.add(new NominalCodesValues('Currency Charges' , 7902));
			NomAccount.add(new NominalCodesValues('Loan Interest Paid' , 7903));
			NomAccount.add(new NominalCodesValues('H.P. Interest' , 7904));
			NomAccount.add(new NominalCodesValues('Credit Charges' , 7905));
			NomAccount.add(new NominalCodesValues('Exchange Rate Variance' , 7906));
			NomCodes.put('Bank Charges and  Interest', NomAccount21);
			
			list<NominalCodesValues> NomAccount22 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Depreciation' , 8000));
			NomAccount.add(new NominalCodesValues('Plant/Machinery Depreciation' , 8001));
			NomAccount.add(new NominalCodesValues('Furniture/Fitting Depreciation' , 8002));
			NomAccount.add(new NominalCodesValues('Vehicle Depreciation' , 8003));
			NomAccount.add(new NominalCodesValues('Office Equipment Depreciation' , 8004));
			NomCodes.put('Depreciation', NomAccount22);
			
			list<NominalCodesValues> NomAccount23 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Bad Debt Write Off' , 8100));
			NomAccount.add(new NominalCodesValues('Bad Debt Provision' , 8102));
			NomCodes.put('Bad Debt', NomAccount23);
			
			list<NominalCodesValues> NomAccount24 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Donations' , 8200));
			NomAccount.add(new NominalCodesValues('Subscriptions' , 8201));
			NomAccount.add(new NominalCodesValues('Clothing Costs' , 8202));
			NomAccount.add(new NominalCodesValues('Training Costs' , 8203));
			NomAccount.add(new NominalCodesValues('Insurance' , 8204));
			NomAccount.add(new NominalCodesValues('Refreshments' , 8205));
			NomAccount.add(new NominalCodesValues('Bank Interest Received' , 8206));
			NomCodes.put('General Expenses', NomAccount24);
			
			list<NominalCodesValues> NomAccount25 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Suspense Account' , 9998));
			NomAccount.add(new NominalCodesValues('Mispostings Account' , 9999));
			NomCodes.put('Suspense & Mispostings', NomAccount25);
			
			list<NominalCodesValues> NomAccount26 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Freehold Property' , 10));
			NomAccount.add(new NominalCodesValues('Leasehold Property' , 11));
			NomCodes.put('Property', NomAccount26);
			
			list<NominalCodesValues> NomAccount27 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Plant and Machinery' , 20));
			NomAccount.add(new NominalCodesValues('Plant/Machinery Depreciation' , 21));
			NomCodes.put('Plant and Machinery', NomAccount27);
			
			list<NominalCodesValues> NomAccount28 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Office Equipment' , 30));
			NomAccount.add(new NominalCodesValues('Office Equipment Depreciation' , 31));
			NomCodes.put('Office Equipment', NomAccount28);
			
			list<NominalCodesValues> NomAccount29 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Furniture and Fixtures' , 40));
			NomAccount.add(new NominalCodesValues('Furniture/Fixture Depreciation' , 41));
			NomCodes.put('Furniture and Fixtures', NomAccount29);
			
			list<NominalCodesValues> NomAccount30 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Motor Vehicles' , 50));
			NomAccount.add(new NominalCodesValues('Motor Vehicles Depreciation' , 51));
			NomCodes.put('Motor Vehicles', NomAccount30);
			
			list<NominalCodesValues> NomAccount31 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Stock' , 1001));
			NomAccount.add(new NominalCodesValues('Work in Progress' , 1002));
			NomAccount.add(new NominalCodesValues('Finished Goods' , 1003));
			NomCodes.put('Stock', NomAccount31);
			
			list<NominalCodesValues> NomAccount32 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Debtors Control Account' , 1100));
			NomAccount.add(new NominalCodesValues('Sundry Debtors' , 1101));
			NomAccount.add(new NominalCodesValues('Other Debtors' , 1102));
			NomAccount.add(new NominalCodesValues('Prepayments' , 1103));
			NomCodes.put('Debtors', NomAccount32);
			
			list<NominalCodesValues> NomAccount33 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Bank Deposit Account' , 1210));
			NomAccount.add(new NominalCodesValues('Building Society Account' , 1220));
			NomAccount.add(new NominalCodesValues('Petty Cash' , 1230));
			NomCodes.put('Deposit and Cash', NomAccount33);
			
			list<NominalCodesValues> NomAccount34 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Purchase Tax Control Account' , 2201));
			NomAccount.add(new NominalCodesValues('VAT Liability' , 2202));
			NomAccount.add(new NominalCodesValues('Manual Adjustments' , 2203));
			NomCodes.put('VAT Liability', NomAccount34);
			
			list<NominalCodesValues> NomAccount35 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Creditors Control Account' , 2100));
			NomAccount.add(new NominalCodesValues('Sundry Creditors' , 2101));
			NomAccount.add(new NominalCodesValues('Other Creditors' , 2102));
			NomAccount.add(new NominalCodesValues('Accruals' , 2109));
			NomCodes.put('Creditors: Short Term', NomAccount35);
			
			list<NominalCodesValues> NomAccount36 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('P.A.Y.E.' , 2210));
			NomAccount.add(new NominalCodesValues('National Insurance' , 2211));
			NomCodes.put('Taxation', NomAccount36);
			
			list<NominalCodesValues> NomAccount37 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Net Wages' , 2220));
			NomAccount.add(new NominalCodesValues('Pension Fund' , 2230));
			NomCodes.put('Wages', NomAccount37);
			
			list<NominalCodesValues> NomAccount38 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Company Credit Card' , 1240));
			NomCodes.put('Credit Card (Creditors)', NomAccount38);
			
			list<NominalCodesValues> NomAccount39 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Bank Current Account' , 1200));
			NomCodes.put('Bank Account)', NomAccount39);
			
			list<NominalCodesValues> NomAccount40 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Sales Tax Control Account' , 2200));
			NomAccount.add(new NominalCodesValues('VAT Liability' , 2202));
			NomAccount.add(new NominalCodesValues('Manual Adjustments' , 2204));
			NomCodes.put('VAT Liability', NomAccount40);
			
			list<NominalCodesValues> NomAccount41 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Loans' , 2300));
			NomAccount.add(new NominalCodesValues('Hire Purchase' , 2310));
			NomAccount.add(new NominalCodesValues('Corporation Tax' , 2320));
			NomAccount.add(new NominalCodesValues('Mortgages' , 2330));
			NomCodes.put('Creditors: Long Term', NomAccount41);
			
			list<NominalCodesValues> NomAccount42 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Ordinary Shares' , 3000));
			NomAccount.add(new NominalCodesValues('Preference Shares' , 3010));
			NomCodes.put('Share Capital', NomAccount42);
			
			list<NominalCodesValues> NomAccount43 = new list<NominalCodesValues>();
			NomAccount.add(new NominalCodesValues('Reserves' , 3100));
			NomAccount.add(new NominalCodesValues('Undistributed Reserves' , 3101));
			NomAccount.add(new NominalCodesValues('Profit and Loss Account' , 3200));
			NomAccount.add(new NominalCodesValues('Drawings' , 3201));
			NomCodes.put('Reserves', NomAccount43); 
			// end of Nominal Category map
			
			
			
			InsertChartOfAccount();
			List<Control_Account__c> cAccounts = new List<Control_Account__c>();
			cAccounts.add(new Control_Account__c(Name = 'Control Accounts' , 
												Debtors_Control__c = [select id from Nominal_account__c where Account_Code__c = 1100 limit 1 ].Id ,
												Creditors_Control__c = [select id from Nominal_account__c where Account_Code__c = 2100 limit 1 ].Id ,
												Default_Bank__c = [select id from Nominal_account__c where Account_Code__c = 1200 limit 1 ].Id , 
												VAT_on_Sales__c = [select id from Nominal_account__c where Account_Code__c = 2200 limit 1 ].Id , 
												VAT_on_Purchases__c = [select id from Nominal_account__c where Account_Code__c = 2201 limit 1 ].Id ,
												Sales_Discount__c = [select id from Nominal_account__c where Account_Code__c = 4009 limit 1 ].Id , 
												Purchase_Discount__c = [select id from Nominal_account__c where Account_Code__c = 5009 limit 1 ].Id ,
												Retained_Earnings__c = [select id from Nominal_account__c where Account_Code__c = 3200 limit 1 ].Id ,
												Default_Sales__c = [select id from Nominal_account__c where Account_Code__c = 4000 limit 1 ].Id ,
												Accruals__c = [select id from Nominal_account__c where Account_Code__c = 2109 limit 1 ].Id ,
												Prepayments__c = [select id from Nominal_account__c where Account_Code__c = 1103 limit 1 ].Id , 
												Bad_Debts__c = [select id from Nominal_account__c where Account_Code__c = 8100 limit 1 ].Id , 
												Mispostings__c = [select id from Nominal_account__c where Account_Code__c = 9999 limit 1 ].Id , 
												Suspense__c = [select id from Nominal_account__c where Account_Code__c = 9998 limit 1 ].Id , 
												Credit_Charges__c = [select id from Nominal_account__c where Account_Code__c = 9998 limit 1 ].Id,
												Exchange_Rate_Variance__c = [select id from Nominal_account__c where Account_Code__c = 4400 limit 1 ].Id ,
												VAT_Liability__c = [select id from Nominal_account__c where Account_Code__c = 2202 limit 1 ].Id,
												Manual_Adjustments__c = [select id from Nominal_account__c where Account_Code__c = 2204 limit 1 ].Id
												)) ;
			insert cAccounts ;
			Organization OrgInfo = [Select o.OrganizationType, o.Name, o.Id From Organization o limit 1];
			integer fiscalMonth = [Select o.FiscalYearStartMonth From Organization o limit 1].FiscalYearStartMonth ; 
			date locDate = date.newInstance(date.today().year(), (fiscalMonth+3) , 1 );
			Company_Setup__c CSetup = new Company_Setup__c(Name = OrgInfo.Name , Company_Registration_Number__c = 'XXXXXXXX' , 
															Account_Lock_Date__c = locDate , 
															Entity_Type__c = OrgInfo.OrganizationType , 
															VAT_Number__c = 'XXXXXXXX' , VatMethod__c = 'Accrual' );
			insert CSetup ;
			
			Invoice_Template__c invTemplate = new Invoice_Template__c( Font_Face__c = 'Arial' , Font_Size__c = '12' , 
																	   Footer_Text__c = 'ZumZum Financials Footer' , 
																	   Heading_Text__c = 'ZumZum Financials Heading' ,
																	   Margins_left_right_Inches__c = .5 ,
																	   Margins_top_bottom__c = .5 ,
																	   Name = 'ZumZum Sample Template');
											
			insert invTemplate;
			
			
			insertGSetup();			
			
			InsertTaxRates();
			
			InsertOrgnisationCurrency() ;
			
			InsertCountryCodes();
			
			InsertBankAccount() ;
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.Confirm , 'Application Data Succesfully Installed' , ''));
			//inserting nominal acounts
			showbutton = false;
		}
		catch(Exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
		}
	}
	private void InsertBankAccount()
	{
		try
		{
			list<Bank_Account__c> lstBankAccounts = new list<Bank_Account__c>();
			lstBankAccounts.add(new Bank_Account__c(Name = 'Bank Current Account' , Account_Number__c = 'xxxxxxxxx' , Nominal_Account__c = [select Id from Nominal_Account__c where Name = 'Bank Current Account' limit 1].id , 
													Status__c = 'Active' , Type__c = 'Current/Saving' ));
			lstBankAccounts.add(new Bank_Account__c(Name = 'Bank Deposit Account' , Account_Number__c = 'xxxxxxxxxx' , Nominal_Account__c = [select Id from Nominal_Account__c where Name = 'Bank Deposit Account' limit 1].id , 
													Status__c = 'Active' , Type__c = 'Current/Saving' ));
			lstBankAccounts.add(new Bank_Account__c(Name = 'Building Society Account' , Account_Number__c = 'xxxxxxxxxxx' , Nominal_Account__c = [select Id from Nominal_Account__c where Name = 'Building Society Account' limit 1].id , 
													Status__c = 'Active' , Type__c = 'Current/Saving' ));
			lstBankAccounts.add(new Bank_Account__c(Name = 'Petty Cash' , Account_Number__c = 'xxxxxxxxxxxx' , Nominal_Account__c = [select Id from Nominal_Account__c where Name = 'Petty Cash' limit 1].id , 
													Status__c = 'Active' , Type__c = 'Current/Saving' ));								
			
			lstBankAccounts.add(new Bank_Account__c(Name = 'Company Credit Card' , Account_Number__c = 'xxxxxxxxxxxxx' , Nominal_Account__c = [select Id from Nominal_Account__c where Name = 'Company Credit Card' limit 1].id , 
													Status__c = 'Active' , Type__c = 'Current/Saving' ));		
			insert lstBankAccounts ;
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);
		}
	}
	private void insertGSetup()
	{
		List<General_Setup__c> Gsetup = new List<General_Setup__c>();
		Gsetup.add(new General_Setup__c(Name = 'SOI' , Current_Document_Number__c = -1 , Object__c = 'Sales Invoice' , Starting_Document_No__c = '0'));
		Gsetup.add(new General_Setup__c(Name = 'SO' , Current_Document_Number__c = -1 , Object__c = 'Sales Order' , Starting_Document_No__c = '10000'));
		Gsetup.add(new General_Setup__c(Name = 'PO' , Current_Document_Number__c = -1 , Object__c = 'Purchase Order' , Starting_Document_No__c = '20000'));
		Gsetup.add(new General_Setup__c(Name = 'POI' , Current_Document_Number__c = -1 , Object__c = 'Purchase Invoice' , Starting_Document_No__c = '30000'));
		Gsetup.add(new General_Setup__c(Name = 'TS' , Current_Document_Number__c = -1 , Object__c = 'TS' , Starting_Document_No__c = '40000'));
		Gsetup.add(new General_Setup__c(Name = 'ES' , Current_Document_Number__c = -1 , Object__c = 'Expenses' , Starting_Document_No__c = '50000'));
		Gsetup.add(new General_Setup__c(Name = 'VAT' , Current_Document_Number__c = -1 , Object__c = 'VAT Transaction' , Starting_Document_No__c = '50000'));
		Gsetup.add(new General_Setup__c(Name = 'Reconcile' , Current_Document_Number__c = -1 , Object__c = 'Reconcile Transaction' , Starting_Document_No__c = '50000'));
		Gsetup.add(new General_Setup__c(Name = 'Ledger' , Current_Document_Number__c = -1 , Object__c = 'Ledger Transaction' , Starting_Document_No__c = '50000'));			
		insert Gsetup;	
	}
	private void InsertTaxRates()
	{
		try
		{
			List<Tax_Rate__c> TaxRates = new List<Tax_Rate__c>();
			TaxRates.add(new Tax_Rate__c(Name = 'T0' , Tax_Rate__c = 0.00  ) );
			TaxRates.add(new Tax_Rate__c(Name = 'T2' , Tax_Rate__c = 0.00  ) );
			TaxRates.add(new Tax_Rate__c(Name = 'T4' , Tax_Rate__c = 0.00 , is_EC_Sales__c = true ) );
			TaxRates.add(new Tax_Rate__c(Name = 'T1' , Tax_Rate__c = 17.50 , is_default__c = true  ) );  
			TaxRates.add(new Tax_Rate__c(Name = 'T9' , Tax_Rate__c = 0.00  , is_no_tax__c = true ) );
			TaxRates.add(new Tax_Rate__c(Name = 'T5' , Tax_Rate__c = 5.00  , is_no_tax__c = true ) );
			TaxRates.add(new Tax_Rate__c(Name = 'T7' , Tax_Rate__c = 0.00  , is_EC_Sales__c = true ) );
			TaxRates.add(new Tax_Rate__c(Name = 'T8' , Tax_Rate__c = 0.00  , is_no_tax__c = true ) );
			insert TaxRates ;
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);
		}
	}
	private void InsertOrgnisationCurrency()
	{
		try
		{
			Organisation_Currency__c Orgcurrency = new Organisation_Currency__c(Name = 'Default_Currency' , Currency_Name__c  = 'GBP', Currency_Symbol__c = '£');
			insert Orgcurrency ;
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);
		}
	}
	private void InsertCountryCodes()
	{
		try
		{
			List<ISO_Countries__c> isoCountries = new List<ISO_Countries__c>();
			/////////////////////////////////////////////////////////////////
			isoCountries.add(new ISO_Countries__c(Name = 'AF' , Country_Code__c = 'AF' , Country_Name__c = 'AFGHANISTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AX' , Country_Code__c = 'AX' , Country_Name__c = 'ÅLAND ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AL' , Country_Code__c = 'AL' , Country_Name__c = 'ALBANIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'DZ' , Country_Code__c = 'DZ' , Country_Name__c = 'ALGERIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AS' , Country_Code__c = 'AS' , Country_Name__c = 'AMERICAN SAMOA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AD' , Country_Code__c = 'AD' , Country_Name__c = 'ANDORRA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'AO' , Country_Code__c = 'AO' , Country_Name__c = 'ANGOLA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AI' , Country_Code__c = 'AI' , Country_Name__c = 'ANGUILLA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AQ' , Country_Code__c = 'AQ' , Country_Name__c = 'ANTARCTICA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AG' , Country_Code__c = 'AG' , Country_Name__c = 'ANTIGUA AND BARBUDA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AR' , Country_Code__c = 'AR' , Country_Name__c = 'ARGENTINA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AM' , Country_Code__c = 'AM' , Country_Name__c = 'ARMENIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'AW' , Country_Code__c = 'AW' , Country_Name__c = 'ARUBA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AU' , Country_Code__c = 'AU' , Country_Name__c = 'AUSTRALIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AT' , Country_Code__c = 'AT' , Country_Name__c = 'AUSTRIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'AZ' , Country_Code__c = 'AZ' , Country_Name__c = 'AZERBAIJAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BS' , Country_Code__c = 'BS' , Country_Name__c = 'BAHAMAS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BH' , Country_Code__c = 'BH' , Country_Name__c = 'BAHRAIN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BD' , Country_Code__c = 'BD' , Country_Name__c = 'BANGLADESH' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BB' , Country_Code__c = 'BB' , Country_Name__c = 'BARBADOS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BY' , Country_Code__c = 'BY' , Country_Name__c = 'BELARUS' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'BE' , Country_Code__c = 'BE' , Country_Name__c = 'BELGIUM' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BZ' , Country_Code__c = 'BZ' , Country_Name__c = 'BELIZE' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'BJ' , Country_Code__c = 'BJ' , Country_Name__c = 'BENIN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BM' , Country_Code__c = 'BM' , Country_Name__c = 'BERMUDA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BT' , Country_Code__c = 'BT' , Country_Name__c = 'BHUTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BO' , Country_Code__c = 'BO' , Country_Name__c = 'BOLIVIA, PLURINATIONAL STATE OF' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BQ' , Country_Code__c = 'BQ' , Country_Name__c = 'BONAIRE, SINT EUSTATIUS AND SABA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BA' , Country_Code__c = 'BA' , Country_Name__c = 'BOSNIA AND HERZEGOVINA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'BW' , Country_Code__c = 'BW' , Country_Name__c = 'BOTSWANA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BV' , Country_Code__c = 'BV' , Country_Name__c = 'BOUVET ISLAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BR' , Country_Code__c = 'BR' , Country_Name__c = 'BRAZIL' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'IO' , Country_Code__c = 'IO' , Country_Name__c = 'BRITISH INDIAN OCEAN TERRITORY' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BN' , Country_Code__c = 'BN' , Country_Name__c = 'BRUNEI DARUSSALAM' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BG' , Country_Code__c = 'BG' , Country_Name__c = 'BULGARIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BF' , Country_Code__c = 'BF' , Country_Name__c = 'BURKINA FASO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BI' , Country_Code__c = 'BI' , Country_Name__c = 'BURUNDI' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KH' , Country_Code__c = 'KH' , Country_Name__c = 'CAMBODIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CM' , Country_Code__c = 'CM' , Country_Name__c = 'CAMEROON' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CA' , Country_Code__c = 'CA' , Country_Name__c = 'CANADA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CV' , Country_Code__c = 'CV' , Country_Name__c = 'CAPE VERDE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KY' , Country_Code__c = 'KY' , Country_Name__c = 'CAYMAN ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CF' , Country_Code__c = 'CF' , Country_Name__c = 'CENTRAL AFRICAN REPUBLIC' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TD' , Country_Code__c = 'TD' , Country_Name__c = 'CHAD' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CL' , Country_Code__c = 'CL' , Country_Name__c = 'CHILE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CN' , Country_Code__c = 'CN' , Country_Name__c = 'CHINA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CX' , Country_Code__c = 'CX' , Country_Name__c = 'CHRISTMAS ISLAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CC' , Country_Code__c = 'CC' , Country_Name__c = 'COCOS (KEELING) ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CO' , Country_Code__c = 'CO' , Country_Name__c = 'COLOMBIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KM' , Country_Code__c = 'KM' , Country_Name__c = 'COMOROS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CG' , Country_Code__c = 'CG' , Country_Name__c = 'CONGO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CD' , Country_Code__c = 'CD' , Country_Name__c = 'CONGO, THE DEMOCRATIC REPUBLIC OF THE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CK' , Country_Code__c = 'CK' , Country_Name__c = 'COOK ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CR' , Country_Code__c = 'CR' , Country_Name__c = 'COSTA RICA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CI' , Country_Code__c = 'CI' , Country_Name__c = 'CÔTE D\'IVOIRE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'HR' , Country_Code__c = 'HR' , Country_Name__c = 'CROATIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'CU' , Country_Code__c = 'CU' , Country_Name__c = 'CUBA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CW' , Country_Code__c = 'CW' , Country_Name__c = 'CURAÇAO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'CY' , Country_Code__c = 'CY' , Country_Name__c = 'CYPRUS' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'CZ' , Country_Code__c = 'CZ' , Country_Name__c = 'CZECH REPUBLIC' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'DK' , Country_Code__c = 'DK' , Country_Name__c = 'DENMARK' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'DJ' , Country_Code__c = 'DJ' , Country_Name__c = 'DJIBOUTI' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'DM' , Country_Code__c = 'DM' , Country_Name__c = 'DOMINICA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'DO' , Country_Code__c = 'DO' , Country_Name__c = 'DOMINICAN REPUBLIC' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'EC' , Country_Code__c = 'EC' , Country_Name__c = 'ECUADOR' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'EG' , Country_Code__c = 'EG' , Country_Name__c = 'EGYPT' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SV' , Country_Code__c = 'SV' , Country_Name__c = 'EL SALVADOR' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GQ' , Country_Code__c = 'GQ' , Country_Name__c = 'EQUATORIAL GUINEA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ER' , Country_Code__c = 'ER' , Country_Name__c = 'ERITREA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'EE' , Country_Code__c = 'EE' , Country_Name__c = 'ESTONIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'ET' , Country_Code__c = 'ET' , Country_Name__c = 'ETHIOPIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'FK' , Country_Code__c = 'FK' , Country_Name__c = 'FALKLAND ISLANDS (MALVINAS)' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'FO' , Country_Code__c = 'FO' , Country_Name__c = 'FAROE ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'FJ' , Country_Code__c = 'FJ' , Country_Name__c = 'FIJI' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'FI' , Country_Code__c = 'FI' , Country_Name__c = 'FINLAND' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'FR' , Country_Code__c = 'FR' , Country_Name__c = 'FRANCE' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'GF' , Country_Code__c = 'GF' , Country_Name__c = 'FRENCH GUIANA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PF' , Country_Code__c = 'PF' , Country_Name__c = 'FRENCH POLYNESIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TF' , Country_Code__c = 'TF' , Country_Name__c = 'FRENCH SOUTHERN TERRITORIES' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GA' , Country_Code__c = 'GA' , Country_Name__c = 'GABON' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GM' , Country_Code__c = 'GM' , Country_Name__c = 'GAMBIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GE' , Country_Code__c = 'GE' , Country_Name__c = 'GEORGIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'DE' , Country_Code__c = 'DE' , Country_Name__c = 'GERMANY' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'GH' , Country_Code__c = 'GH' , Country_Name__c = 'GHANA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GI' , Country_Code__c = 'GI' , Country_Name__c = 'GIBRALTAR' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GR' , Country_Code__c = 'GR' , Country_Name__c = 'GREECE' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'GL' , Country_Code__c = 'GL' , Country_Name__c = 'GREENLAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GD' , Country_Code__c = 'GD' , Country_Name__c = 'GRENADA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GP' , Country_Code__c = 'GP' , Country_Name__c = 'GUADELOUPE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GU' , Country_Code__c = 'GU' , Country_Name__c = 'GUAM' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GT' , Country_Code__c = 'GT' , Country_Name__c = 'GUATEMALA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GG' , Country_Code__c = 'GG' , Country_Name__c = 'GUERNSEY' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GN' , Country_Code__c = 'GN' , Country_Name__c = 'GUINEA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GW' , Country_Code__c = 'GW' , Country_Name__c = 'GUINEA-BISSAU' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GY' , Country_Code__c = 'GY' , Country_Name__c = 'GUYANA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'HT' , Country_Code__c = 'HT' , Country_Name__c = 'HAITI' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'HM' , Country_Code__c = 'HM' , Country_Name__c = 'HEARD ISLAND AND MCDONALD ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'VA' , Country_Code__c = 'VA' , Country_Name__c = 'HOLY SEE (VATICAN CITY STATE)' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'HN' , Country_Code__c = 'HN' , Country_Name__c = 'HONDURAS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'HK' , Country_Code__c = 'HK' , Country_Name__c = 'HONG KONG' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'HU' , Country_Code__c = 'HU' , Country_Name__c = 'HUNGARY' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'IS' , Country_Code__c = 'IS' , Country_Name__c = 'ICELAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'IN' , Country_Code__c = 'IN' , Country_Name__c = 'INDIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ID' , Country_Code__c = 'ID' , Country_Name__c = 'INDONESIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'IR' , Country_Code__c = 'IR' , Country_Name__c = 'IRAN, ISLAMIC REPUBLIC OF' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'IQ' , Country_Code__c = 'IQ' , Country_Name__c = 'IRAQ' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'IE' , Country_Code__c = 'IE' , Country_Name__c = 'IRELAND' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'IM' , Country_Code__c = 'IM' , Country_Name__c = 'ISLE OF MAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'IL' , Country_Code__c = 'IL' , Country_Name__c = 'ISRAEL' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'IT' , Country_Code__c = 'IT' , Country_Name__c = 'ITALY' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'JM' , Country_Code__c = 'JM' , Country_Name__c = 'JAMAICA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'JP' , Country_Code__c = 'JP' , Country_Name__c = 'JAPAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'JE' , Country_Code__c = 'JE' , Country_Name__c = 'JERSEY' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'JO' , Country_Code__c = 'JO' , Country_Name__c = 'JORDAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KZ' , Country_Code__c = 'KZ' , Country_Name__c = 'KAZAKHSTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KE' , Country_Code__c = 'KE' , Country_Name__c = 'KENYA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KI' , Country_Code__c = 'KI' , Country_Name__c = 'KIRIBATI' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KP' , Country_Code__c = 'KP' , Country_Name__c = 'KOREA, DEMOCRATIC PEOPLE\'S REPUBLIC OF' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KR' , Country_Code__c = 'KR' , Country_Name__c = 'KOREA, REPUBLIC OF' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KW' , Country_Code__c = 'KW' , Country_Name__c = 'KUWAIT' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KG' , Country_Code__c = 'KG' , Country_Name__c = 'KYRGYZSTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LA' , Country_Code__c = 'LA' , Country_Name__c = 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LV' , Country_Code__c = 'LV' , Country_Name__c = 'LATVIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'LB' , Country_Code__c = 'LB' , Country_Name__c = 'LEBANON' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LS' , Country_Code__c = 'LS' , Country_Name__c = 'LESOTHO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LR' , Country_Code__c = 'LR' , Country_Name__c = 'LIBERIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LY' , Country_Code__c = 'LY' , Country_Name__c = 'LIBYAN ARAB JAMAHIRIYA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LI' , Country_Code__c = 'LI' , Country_Name__c = 'LIECHTENSTEIN' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'LT' , Country_Code__c = 'LT' , Country_Name__c = 'LITHUANIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LU' , Country_Code__c = 'LU' , Country_Name__c = 'LUXEMBOURG' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'MO' , Country_Code__c = 'MO' , Country_Name__c = 'MACAO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MK' , Country_Code__c = 'MK' , Country_Name__c = 'MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'MG' , Country_Code__c = 'MG' , Country_Name__c = 'MADAGASCAR' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MW' , Country_Code__c = 'MW' , Country_Name__c = 'MALAWI' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MY' , Country_Code__c = 'MY' , Country_Name__c = 'MALAYSIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MV' , Country_Code__c = 'MV' , Country_Name__c = 'MALDIVES' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ML' , Country_Code__c = 'ML' , Country_Name__c = 'MALI' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MT' , Country_Code__c = 'MT' , Country_Name__c = 'MALTA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'MH' , Country_Code__c = 'MH' , Country_Name__c = 'MARSHALL ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MQ' , Country_Code__c = 'MQ' , Country_Name__c = 'MARTINIQUE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MR' , Country_Code__c = 'MR' , Country_Name__c = 'MAURITANIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MU' , Country_Code__c = 'MU' , Country_Name__c = 'MAURITIUS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'YT' , Country_Code__c = 'YT' , Country_Name__c = 'MAYOTTE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MX' , Country_Code__c = 'MX' , Country_Name__c = 'MEXICO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'FM' , Country_Code__c = 'FM' , Country_Name__c = 'MICRONESIA, FEDERATED STATES OF' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MD' , Country_Code__c = 'MD' , Country_Name__c = 'MOLDOVA, REPUBLIC OF' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'MC' , Country_Code__c = 'MC' , Country_Name__c = 'MONACO' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'MN' , Country_Code__c = 'MN' , Country_Name__c = 'MONGOLIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ME' , Country_Code__c = 'ME' , Country_Name__c = 'MONTENEGRO' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'MS' , Country_Code__c = 'MS' , Country_Name__c = 'MONTSERRAT' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MA' , Country_Code__c = 'MA' , Country_Name__c = 'MOROCCO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MZ' , Country_Code__c = 'MZ' , Country_Name__c = 'MOZAMBIQUE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MM' , Country_Code__c = 'MM' , Country_Name__c = 'MYANMAR' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NA' , Country_Code__c = 'NA' , Country_Name__c = 'NAMIBIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NR' , Country_Code__c = 'NR' , Country_Name__c = 'NAURU' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NP' , Country_Code__c = 'NP' , Country_Name__c = 'NEPAL' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NL' , Country_Code__c = 'NL' , Country_Name__c = 'NETHERLANDS' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'NC' , Country_Code__c = 'NC' , Country_Name__c = 'NEW CALEDONIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NZ' , Country_Code__c = 'NZ' , Country_Name__c = 'NEW ZEALAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NI' , Country_Code__c = 'NI' , Country_Name__c = 'NICARAGUA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NE' , Country_Code__c = 'NE' , Country_Name__c = 'NIGER' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NG' , Country_Code__c = 'NG' , Country_Name__c = 'NIGERIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NU' , Country_Code__c = 'NU' , Country_Name__c = 'NIUE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NF' , Country_Code__c = 'NF' , Country_Name__c = 'NORFOLK ISLAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MP' , Country_Code__c = 'MP' , Country_Name__c = 'NORTHERN MARIANA ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'NO' , Country_Code__c = 'NO' , Country_Name__c = 'NORWAY' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'OM' , Country_Code__c = 'OM' , Country_Name__c = 'OMAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PK' , Country_Code__c = 'PK' , Country_Name__c = 'PAKISTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PW' , Country_Code__c = 'PW' , Country_Name__c = 'PALAU' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PS' , Country_Code__c = 'PS' , Country_Name__c = 'PALESTINIAN TERRITORY, OCCUPIED' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PA' , Country_Code__c = 'PA' , Country_Name__c = 'PANAMA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PG' , Country_Code__c = 'PG' , Country_Name__c = 'PAPUA NEW GUINEA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PY' , Country_Code__c = 'PY' , Country_Name__c = 'PARAGUAY' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PE' , Country_Code__c = 'PE' , Country_Name__c = 'PERU' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PH' , Country_Code__c = 'PH' , Country_Name__c = 'PHILIPPINES' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PN' , Country_Code__c = 'PN' , Country_Name__c = 'PITCAIRN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PL' , Country_Code__c = 'PL' , Country_Name__c = 'POLAND' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'PT' , Country_Code__c = 'PT' , Country_Name__c = 'PORTUGAL' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'PR' , Country_Code__c = 'PR' , Country_Name__c = 'PUERTO RICO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'QA' , Country_Code__c = 'QA' , Country_Name__c = 'QATAR' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'RE' , Country_Code__c = 'RE' , Country_Name__c = 'RÉUNION' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'RO' , Country_Code__c = 'RO' , Country_Name__c = 'ROMANIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'RU' , Country_Code__c = 'RU' , Country_Name__c = 'RUSSIAN FEDERATION' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'RW' , Country_Code__c = 'RW' , Country_Name__c = 'RWANDA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'BL' , Country_Code__c = 'BL' , Country_Name__c = 'SAINT BARTHÉLEMY' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SH' , Country_Code__c = 'SH' , Country_Name__c = 'SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'KN' , Country_Code__c = 'KN' , Country_Name__c = 'SAINT KITTS AND NEVIS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'LC' , Country_Code__c = 'LC' , Country_Name__c = 'SAINT LUCIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'MF' , Country_Code__c = 'MF' , Country_Name__c = 'SAINT MARTIN (FRENCH PART)' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'PM' , Country_Code__c = 'PM' , Country_Name__c = 'SAINT PIERRE AND MIQUELON' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'VC' , Country_Code__c = 'VC' , Country_Name__c = 'SAINT VINCENT AND THE GRENADINES' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'WS' , Country_Code__c = 'WS' , Country_Name__c = 'SAMOA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SM' , Country_Code__c = 'SM' , Country_Name__c = 'SAN MARINO' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'ST' , Country_Code__c = 'ST' , Country_Name__c = 'SAO TOME AND PRINCIPE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SA' , Country_Code__c = 'SA' , Country_Name__c = 'SAUDI ARABIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SN' , Country_Code__c = 'SN' , Country_Name__c = 'SENEGAL' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'RS' , Country_Code__c = 'RS' , Country_Name__c = 'SERBIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'SC' , Country_Code__c = 'SC' , Country_Name__c = 'SEYCHELLES' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SL' , Country_Code__c = 'SL' , Country_Name__c = 'SIERRA LEONE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SG' , Country_Code__c = 'SG' , Country_Name__c = 'SINGAPORE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SX' , Country_Code__c = 'SX' , Country_Name__c = 'SINT MAARTEN (DUTCH PART)' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SK' , Country_Code__c = 'SK' , Country_Name__c = 'SLOVAKIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'SI' , Country_Code__c = 'SI' , Country_Name__c = 'SLOVENIA' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'SB' , Country_Code__c = 'SB' , Country_Name__c = 'SOLOMON ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SO' , Country_Code__c = 'SO' , Country_Name__c = 'SOMALIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ZA' , Country_Code__c = 'ZA' , Country_Name__c = 'SOUTH AFRICA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GS' , Country_Code__c = 'GS' , Country_Name__c = 'SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ES' , Country_Code__c = 'ES' , Country_Name__c = 'SPAIN' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'LK' , Country_Code__c = 'LK' , Country_Name__c = 'SRI LANKA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SD' , Country_Code__c = 'SD' , Country_Name__c = 'SUDAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SR' , Country_Code__c = 'SR' , Country_Name__c = 'SURINAME' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SJ' , Country_Code__c = 'SJ' , Country_Name__c = 'SVALBARD AND JAN MAYEN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SZ' , Country_Code__c = 'SZ' , Country_Name__c = 'SWAZILAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'SE' , Country_Code__c = 'SE' , Country_Name__c = 'SWEDEN' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'CH' , Country_Code__c = 'CH' , Country_Name__c = 'SWITZERLAND' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'SY' , Country_Code__c = 'SY' , Country_Name__c = 'SYRIAN ARAB REPUBLIC' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TW' , Country_Code__c = 'TW' , Country_Name__c = 'TAIWAN, PROVINCE OF CHINA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TJ' , Country_Code__c = 'TJ' , Country_Name__c = 'TAJIKISTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TZ' , Country_Code__c = 'TZ' , Country_Name__c = 'TANZANIA, UNITED REPUBLIC OF' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TH' , Country_Code__c = 'TH' , Country_Name__c = 'THAILAND' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TL' , Country_Code__c = 'TL' , Country_Name__c = 'TIMOR-LESTE' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TG' , Country_Code__c = 'TG' , Country_Name__c = 'TOGO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TK' , Country_Code__c = 'TK' , Country_Name__c = 'TOKELAU' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TO' , Country_Code__c = 'TO' , Country_Name__c = 'TONGA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TT' , Country_Code__c = 'TT' , Country_Name__c = 'TRINIDAD AND TOBAGO' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TN' , Country_Code__c = 'TN' , Country_Name__c = 'TUNISIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TR' , Country_Code__c = 'TR' , Country_Name__c = 'TURKEY' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TM' , Country_Code__c = 'TM' , Country_Name__c = 'TURKMENISTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TC' , Country_Code__c = 'TC' , Country_Name__c = 'TURKS AND CAICOS ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'TV' , Country_Code__c = 'TV' , Country_Name__c = 'TUVALU' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'UG' , Country_Code__c = 'UG' , Country_Name__c = 'UGANDA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'UA' , Country_Code__c = 'UA' , Country_Name__c = 'UKRAINE' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'AE' , Country_Code__c = 'AE' , Country_Name__c = 'UNITED ARAB EMIRATES' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'GB' , Country_Code__c = 'GB' , Country_Name__c = 'UNITED KINGDOM' , Region__c = 'Europe'));
			isoCountries.add(new ISO_Countries__c(Name = 'US' , Country_Code__c = 'US' , Country_Name__c = 'UNITED STATES' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'UM' , Country_Code__c = 'UM' , Country_Name__c = 'UNITED STATES MINOR OUTLYING ISLANDS' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'UY' , Country_Code__c = 'UY' , Country_Name__c = 'URUGUAY' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'UZ' , Country_Code__c = 'UZ' , Country_Name__c = 'UZBEKISTAN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'VU' , Country_Code__c = 'VU' , Country_Name__c = 'VANUATU' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'VE' , Country_Code__c = 'VE' , Country_Name__c = 'VENEZUELA, BOLIVARIAN REPUBLIC OF' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'VN' , Country_Code__c = 'VN' , Country_Name__c = 'VIET NAM' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'VG' , Country_Code__c = 'VG' , Country_Name__c = 'VIRGIN ISLANDS, BRITISH' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'VI' , Country_Code__c = 'VI' , Country_Name__c = 'VIRGIN ISLANDS, U.S.' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'WF' , Country_Code__c = 'WF' , Country_Name__c = 'WALLIS AND FUTUNA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'EH' , Country_Code__c = 'EH' , Country_Name__c = 'WESTERN SAHARA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'YE' , Country_Code__c = 'YE' , Country_Name__c = 'YEMEN' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ZM' , Country_Code__c = 'ZM' , Country_Name__c = 'ZAMBIA' , Region__c = ''));
			isoCountries.add(new ISO_Countries__c(Name = 'ZW' , Country_Code__c = 'ZW' , Country_Name__c = 'ZIMBABWE' , Region__c = ''));
			/////////////////////////////////////////////////////////////////
			insert isoCountries ;
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);  
		}
	}
	public class NominalCodesValues
	{
		string NominalName;
		integer NominalCode ;
		public 	NominalCodesValues(string Name , integer Code)
		{
			NominalName = Name ;
			NominalCode = Code ;
		}
	}
	public class NMSubCategories
	{
		string CatgoryName;
		integer RFrom ;
		integer RTo ;
		public 	NMSubCategories (string cName , integer rFrm ,integer tToo)
		{
			CatgoryName = cName ;
			RFrom = rFrm ;
			RTo = tToo ;
		}
	}
	
	public static void InsertChartOfAccount()
	{
		Savepoint sp = database.setSavepoint();
		try
		{
			/*
			delete [select id from Nominal_Account__c];
			delete [select id from Control_Account__c];
			delete [select Id from General_Setup__c ];
			delete [select id from Sub_Category__c];
			delete [select id from Nominal_Categories__c];
			delete [select id from Tax_Rate__c];
			delete [select id from Organisation_Currency__c];
			*/

			List<string> MainCategories = new List<string>();
			MainCategories.add('Sales');
			MainCategories.add('Purchases');
			MainCategories.add('Direct Expenses');
			MainCategories.add('Overheads');
			MainCategories.add('Fixed Assets');
			MainCategories.add('Current Assets');
			MainCategories.add('Current Liabilities');
			MainCategories.add('Long Term Liabilities');
			MainCategories.add('Capital & Reserves');
			
			Map<string, Nominal_Categories__c> mc = new Map<string, Nominal_Categories__c>();
			for (string c: MainCategories)
			{
				mc.put(c, new Nominal_Categories__c(Name = c));
			}
			insert mc.values();
			
			Map<string , Sub_Category__c> SubCategories = new Map<string , Sub_Category__c>();
			
			Id mcId = mc.get('Sales').Id;		
			SubCategories.put('Product Sales', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Product Sales'  ,Range_From__c = 4000 , Range_To__c = 4099));
			SubCategories.put('Export Sales', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Export Sales'  ,Range_From__c = 4100 , Range_To__c = 4199));
			SubCategories.put('Sales of Assets', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Sales of Assets'  ,Range_From__c = 4200 , Range_To__c = 4299));
			SubCategories.put('Credit Charges (late Payments)', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Credit Charges (late Payments)'  ,Range_From__c = 4400 , Range_To__c = 4499));
			SubCategories.put('Other Sales', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Other Sales'  ,Range_From__c = 4900 , Range_To__c = 4999));
			
			mcId = mc.get('Purchases').Id;
			SubCategories.put('Purchases', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Purchases'  ,Range_From__c = 5000 , Range_To__c = 5099));
			SubCategories.put('Purchases Charges', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Purchases Charges'  ,Range_From__c = 5100 , Range_To__c = 5199));
			SubCategories.put('Purchases_Stock', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Stock'  ,Range_From__c = 5200 , Range_To__c = 5299));
			
			mcId = mc.get('Direct Expenses').Id;		
			SubCategories.put('Labour', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Labour'  ,Range_From__c = 6000 , Range_To__c = 6099));
			SubCategories.put('Commissions', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Commissions'  ,Range_From__c = 6100 , Range_To__c = 6199));
			SubCategories.put('Sales Promotions', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Sales Promotions'  ,Range_From__c = 6200 , Range_To__c = 6299));
			SubCategories.put('Miscellaneous Expenses', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Miscellaneous Expenses'  ,Range_From__c = 6900 , Range_To__c = 6999));
					
			mcId = mc.get('Overheads').Id;
			SubCategories.put('Gross Wages', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Gross Wages'  ,Range_From__c = 7000 , Range_To__c = 7099));
			SubCategories.put('Rent and Rates', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Rent and Rates'  ,Range_From__c = 7100 , Range_To__c = 7199));
			SubCategories.put('Heat,Light and Power', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Heat,Light and Power'  ,Range_From__c = 7200 , Range_To__c = 7299));
			SubCategories.put('Motor Expense', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Motor Expense'  ,Range_From__c = 7300 , Range_To__c = 7399));
			SubCategories.put('Travelling and Entertainment', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Travelling and Entertainment'  ,Range_From__c = 7400 , Range_To__c = 7499));
			SubCategories.put('Printing and Stationery', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Printing and Stationery'  ,Range_From__c = 7500 , Range_To__c = 7599));
			SubCategories.put('Professional Fees', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Professional Fees'  ,Range_From__c = 7600 , Range_To__c = 7699));
			SubCategories.put('Equipment Hire and Rental', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Equipment Hire and Rental'  ,Range_From__c = 7700 , Range_To__c = 7799));
			SubCategories.put('Maintenance', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Maintenance'  ,Range_From__c = 7800 , Range_To__c = 7899));
			SubCategories.put('Bank Charges and Interest', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Bank Charges and  Interest'  ,Range_From__c = 7900 , Range_To__c = 7999));
			SubCategories.put('Depreciation', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Depreciation'  ,Range_From__c = 8000 , Range_To__c = 8099));
			SubCategories.put('Bad Debt', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Bad Debt'  ,Range_From__c = 8100 , Range_To__c = 8199));
			SubCategories.put('General Expenses', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'General Expenses'  ,Range_From__c = 8200 , Range_To__c = 8299));
			SubCategories.put('Suspense & Mispostings', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Suspense & Mispostings'  ,Range_From__c = 9998 , Range_To__c = 9998));
					
			mcId = mc.get('Fixed Assets').Id;
			SubCategories.put('Property', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Property'  ,Range_From__c = 0010 , Range_To__c = 0019));
			SubCategories.put('Plant and Machinery', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Plant and Machinery'  ,Range_From__c = 0020 , Range_To__c = 0029));
			SubCategories.put('Office Equipment', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Office Equipment'  ,Range_From__c = 0030 , Range_To__c = 0039));
			SubCategories.put('Furniture and Fixtures', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Furniture and Fixtures'  ,Range_From__c = 0040 , Range_To__c = 0049));
			SubCategories.put('Motor Vehicles', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Motor Vehicles'  ,Range_From__c = 0050 , Range_To__c = 0059));
					
			mcId = mc.get('Current Assets').Id;
			SubCategories.put('Current Assets_Stock', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Stock'  ,Range_From__c = 1000 , Range_To__c = 1099));
			SubCategories.put('Debtors', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Debtors'  ,Range_From__c = 1000 , Range_To__c = 1099));
			SubCategories.put('Deposits and Cash', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Deposits and Cash'  ,Range_From__c = 1200 , Range_To__c = 1239));
			SubCategories.put('Credit Card (debators)', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Credit Card (debators)'  ,Range_From__c = 1250 , Range_To__c = 1250));
			SubCategories.put('VAT Liability', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'VAT Liability'  ,Range_From__c = 2200 , Range_To__c = 2299));
								
			mcId = mc.get('Current Liabilities').Id;
			SubCategories.put('Creditors: Short Term', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Creditors: Short Term'  ,Range_From__c = 2100 , Range_To__c = 2199));
			SubCategories.put('Taxation', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Taxation'  ,Range_From__c = 2210 , Range_To__c = 2219));
			SubCategories.put('Wages', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Wages'  ,Range_From__c = 2220 , Range_To__c = 2229));
			SubCategories.put('Credit Card (Creditors)', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Credit Card (Creditors)'  ,Range_From__c = 1240 , Range_To__c = 1240));
			SubCategories.put('VAT Liability', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'VAT Liability'  ,Range_From__c = 2200 , Range_To__c = 2299));
			
			mcId = mc.get('Long Term Liabilities').Id;
			SubCategories.put('Creditors: Long Term', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Creditors: Long Term'  ,Range_From__c = 2300 , Range_To__c = 2399));
			
			mcId = mc.get('Capital & Reserves').Id;
			SubCategories.put('Share Capital', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Share Capital'  ,Range_From__c = 2300 , Range_To__c = 2399));
			SubCategories.put('Reserves', new Sub_Category__c(Nominal_Categories__c =  mcId, Name = 'Reserves'  ,Range_From__c = 3100 , Range_To__c = 3299));
			
			insert SubCategories.values();
			
			//this is nominal category map
			List<Nominal_Account__c> NominalAccounts = new List<Nominal_Account__c>();
			
			Id scId = SubCategories.get('Product Sales').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c =  scId, Name = 'Sales North' , Account_Code__c = 4000));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales South' , Account_Code__c = 4001));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales Scotland' , Account_Code__c = 4002));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales Wales' , Account_Code__c = 4003));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales international' , Account_Code__c = 4004));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Discounts Allowed' , Account_Code__c = 4009));
			
			scId = SubCategories.get('Export Sales').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales export' , Account_Code__c = 4100));
			
			
			scId = SubCategories.get('Sales of Assets').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales of Assets' , Account_Code__c = 4200));
			
			
			scId = SubCategories.get('Credit Charges (late Payments)').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Credit Charges' , Account_Code__c = 4400));
			
			
			scId = SubCategories.get('Other Sales').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Miscellaneous Income' , Account_Code__c = 4901));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Royalties Received' , Account_Code__c = 4901));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Commissions Received' , Account_Code__c = 4902));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Insurance Claims' , Account_Code__c = 4903));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Distribution and Carriage' , Account_Code__c = 4905));
			
			
			scId = SubCategories.get('Purchases').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Materials Purchased' , Account_Code__c = 5000));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Materials Imported' , Account_Code__c = 5001));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Miscellaneous Purchases' , Account_Code__c = 5002));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Packaging' , Account_Code__c = 5003));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Discounts Taken' , Account_Code__c = 5009));
			
			
			scId = SubCategories.get('Purchases Charges').Id;	
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Carriage' , Account_Code__c = 5100));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Import Duty' , Account_Code__c = 5101));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Transport Insurance' , Account_Code__c = 5102));
			
			
			scId = SubCategories.get('Purchases_Stock').Id;		
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Opening Stock' , Account_Code__c = 5200));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Closing Stock' , Account_Code__c = 5201));
			
			
			scId = SubCategories.get('Labour').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Productive Labour' , Account_Code__c = 6001));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Cost of Sales Labour' , Account_Code__c = 6002));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sub-Contractors' , Account_Code__c = 6003));
			
			
			scId = SubCategories.get('Commissions').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales Commissions' , Account_Code__c = 6199));
			
			
			scId = SubCategories.get('Sales Promotions').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales Promotions' , Account_Code__c = 6200));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Advertising' , Account_Code__c = 6201));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Gifts and Samples' , Account_Code__c = 6202));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'P.R. (Literature & Brochures)' , Account_Code__c = 6203));
			
			
			scId = SubCategories.get('Miscellaneous Expenses').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Miscellaneous Expenses' , Account_Code__c = 6900));
			
			
			scId = SubCategories.get('Gross Wages').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Gross Wages' , Account_Code__c = 7000));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Directors Salaries' , Account_Code__c = 7001));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Directors Remuneration' , Account_Code__c = 7002));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Staff Salaries' , Account_Code__c = 7003));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Wages - Regular' , Account_Code__c = 7004));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Wages - Casual' , Account_Code__c = 7005));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Employers N.I.' , Account_Code__c = 7006));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Employers Pensions' , Account_Code__c = 7007));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Recruitment Expenses' , Account_Code__c = 7008));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Adjustments' , Account_Code__c = 7009));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'SSP Reclaimed' , Account_Code__c = 7010));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'SMP Reclaimed' , Account_Code__c = 7011));
			
			
			scId = SubCategories.get('Rent and Rates').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Rent' , Account_Code__c = 7100));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Water Rates' , Account_Code__c = 7101));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'General Rates' , Account_Code__c = 7102));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Premises Insurance' , Account_Code__c = 7103));
			
			
			scId = SubCategories.get('Heat,Light and Power').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Electricity' , Account_Code__c = 7200));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Gas' , Account_Code__c = 7201));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Oil' , Account_Code__c = 7202));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Other Heating Costs' , Account_Code__c = 7203));
			
			
			scId = SubCategories.get('Motor Expense').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Fuel and Oil' , Account_Code__c = 7300));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Repairs and Servicing' , Account_Code__c = 7301));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Licences' , Account_Code__c = 7302));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Vehicle Insurance' , Account_Code__c = 7303));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Miscellaneous Motor Expenses' , Account_Code__c = 7304));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Scale Charges' , Account_Code__c = 7350));
			
			
			scId = SubCategories.get('Motor Expense').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Travelling' , Account_Code__c = 7400));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Car Hire' , Account_Code__c = 7401));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Hotels' , Account_Code__c = 7402));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'U.K. Entertainment' , Account_Code__c = 7403));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Overseas Entertainment' , Account_Code__c = 7404));////////
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Overseas Travelling' , Account_Code__c = 7405));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Subsistence' , Account_Code__c = 7406));
			
			
			scId = SubCategories.get('Printing and Stationery').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Printing' , Account_Code__c = 7500));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Postage and Carriage' , Account_Code__c = 7501));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Telephone' , Account_Code__c = 7502));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Telex/Telegram/Facsimile' , Account_Code__c = 7503));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Office Stationery' , Account_Code__c = 7504));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Books etc.' , Account_Code__c = 7505));
			
			
			scId = SubCategories.get('Professional Fees').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Legal Fees' , Account_Code__c = 7600));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Audit and Accountancy Fees' , Account_Code__c = 7601));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Consultancy Fees' , Account_Code__c = 7602));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Professional Fees' , Account_Code__c = 7603));
			
			
			scId = SubCategories.get('Equipment Hire and Rental').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Equipment Hire' , Account_Code__c = 7700));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Office Machine Maintenance' , Account_Code__c = 7701));
			
			
			scId = SubCategories.get('Maintenance').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Repairs and Renewals' , Account_Code__c = 7800));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Cleaning' , Account_Code__c = 7801));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Laundry' , Account_Code__c = 7802));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Premises Expenses' , Account_Code__c = 7803));
			
			
			scId = SubCategories.get('Bank Charges and Interest').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bank Interest Paid' , Account_Code__c = 7900));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bank Charges' , Account_Code__c = 7901));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Currency Charges' , Account_Code__c = 7902));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Loan Interest Paid' , Account_Code__c = 7903));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'H.P. Interest' , Account_Code__c = 7904));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Credit Charges' , Account_Code__c = 7905));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Exchange Rate Variance' , Account_Code__c = 7906));
			
			
			scId = SubCategories.get('Depreciation').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Depreciation' , Account_Code__c = 8000));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Plant/Machinery Depreciation' , Account_Code__c = 8001));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Furniture/Fitting Depreciation' , Account_Code__c = 8002));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Vehicle Depreciation' , Account_Code__c = 8003));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Office Equipment Depreciation' , Account_Code__c = 8004));
			
			
			scId = SubCategories.get('Bad Debt').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bad Debt Write Off' , Account_Code__c = 8100));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bad Debt Provision' , Account_Code__c = 8102));
			
			
			scId = SubCategories.get('General Expenses').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Donations' , Account_Code__c = 8200));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Subscriptions' , Account_Code__c = 8201));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Clothing Costs' , Account_Code__c = 8202));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Training Costs' , Account_Code__c = 8203));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Insurance' , Account_Code__c = 8204));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Refreshments' , Account_Code__c = 8205));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bank Interest Received' , Account_Code__c = 8206));
			
			
			scId = SubCategories.get('Suspense & Mispostings').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Suspense Account' , Account_Code__c = 9998));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Mispostings Account' , Account_Code__c = 9999));
			
			
			scId = SubCategories.get('Property').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Freehold Property' , Account_Code__c = 10));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Leasehold Property' , Account_Code__c = 11));
			
			
			scId = SubCategories.get('Plant and Machinery').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Plant and Machinery' , Account_Code__c = 20));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Plant/Machinery Depreciation' , Account_Code__c = 21));
			
			
			scId = SubCategories.get('Office Equipment').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Office Equipment' , Account_Code__c = 30));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Office Equipment Depreciation' , Account_Code__c = 31));
			
			
			scId = SubCategories.get('Furniture and Fixtures').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Furniture and Fixtures' , Account_Code__c = 40));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Furniture/Fixture Depreciation' , Account_Code__c = 41));
			
			
			scId = SubCategories.get('Motor Vehicles').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Motor Vehicles' , Account_Code__c = 50));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Motor Vehicles Depreciation' , Account_Code__c = 51));
			
			
			scId = SubCategories.get('Current Assets_Stock').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Stock' , Account_Code__c = 1001));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Work in Progress' , Account_Code__c = 1002));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Finished Goods' , Account_Code__c = 1003));
			
			
			scId = SubCategories.get('Debtors').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Debtors Control Account' , Account_Code__c = 1100));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sundry Debtors' , Account_Code__c = 1101));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Other Debtors' , Account_Code__c = 1102));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Prepayments' , Account_Code__c = 1103));
			
			
			scId = SubCategories.get('Deposits and Cash').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bank Deposit Account' , Account_Code__c = 1210));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Building Society Account' , Account_Code__c = 1220));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Petty Cash' , Account_Code__c = 1230));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bank Current Account' , Account_Code__c = 1200));
			
			
			scId = SubCategories.get('VAT Liability').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Purchase Tax Control Account' , Account_Code__c = 2201));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'VAT Liability' , Account_Code__c = 2202));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Manual Adjustments' , Account_Code__c = 2203));
			
			
			scId = SubCategories.get('Creditors: Short Term').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Creditors Control Account' , Account_Code__c = 2100));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sundry Creditors' , Account_Code__c = 2101));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Other Creditors' , Account_Code__c = 2102));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Accruals' , Account_Code__c = 2109));
			
			
			scId = SubCategories.get('Taxation').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'P.A.Y.E.' , Account_Code__c = 2210));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'National Insurance' , Account_Code__c = 2211));
			
			
			scId = SubCategories.get('Wages').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Net Wages' , Account_Code__c = 2220));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Pension Fund' , Account_Code__c = 2230));
			
			
			scId = SubCategories.get('Credit Card (Creditors)').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Company Credit Card' , Account_Code__c = 1240));
			
			/*
			scId = SubCategories.get('Bank Account').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Bank Current Account' , Account_Code__c = 1200));
			*/
			
			scId = SubCategories.get('VAT Liability').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Sales Tax Control Account' , Account_Code__c = 2200));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'VAT Liability' , Account_Code__c = 2202));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Manual Adjustments' , Account_Code__c = 2204));
			
			
			scId = SubCategories.get('Creditors: Long Term').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Loans' , Account_Code__c = 2300));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Hire Purchase' , Account_Code__c = 2310));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Corporation Tax' , Account_Code__c = 2320));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Mortgages' , Account_Code__c = 2330));
			
			
			scId = SubCategories.get('Share Capital').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Ordinary Shares' , Account_Code__c = 3000));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Preference Shares' , Account_Code__c = 3010));
			
			
			scId = SubCategories.get('Reserves').Id;
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Reserves' , Account_Code__c = 3100));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Undistributed Reserves' , Account_Code__c = 3101));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Profit and Loss Account' , Account_Code__c = 3200));
			NominalAccounts.Add(new Nominal_Account__c(Sub_Category__c = scId, Name = 'Drawings' , Account_Code__c = 3201));
			 
			insert NominalAccounts;
		}
		Catch(Exception ex)
		{
			database.rollback(sp);
			throw ex;	
		}
	}
	
	
	// This is starting of test code
	private static testmethod void TestInsertNominal()
	{
		controllerInsertNominal obj = new controllerInsertNominal();
		obj.init();
		controllerInsertNominal.InsertChartOfAccount();
		try
		{
			obj.InsertTaxRates();   
		}
		catch(Exception e)
		{
			system.debug('this is testerror:'+e.getMessage());
			system.assertEquals(e.getMessage(), 'Insert failed. First exception on row 2; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Another Tax Rate has already been selected as default: []');	
		}
		
			obj.insertGSetup();
			
		try
		{
			obj.InsertCountryCodes();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_INTEGRITY_EXCEPTION, There is already an item in this list with the name AF: [Name]');	
		}	
		
		try
		{
			obj.InsertBankAccount();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, This Nominal Account already selected into another Bank Account: []');	
		}
	}
}