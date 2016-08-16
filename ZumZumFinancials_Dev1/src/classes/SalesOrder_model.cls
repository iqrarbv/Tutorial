public class SalesOrder_model 
{
	private List<General_Setup__c> Gsetup {get; set;}
	public string errorMessage {get; set;}
	public Sales_Order__c so ;
	
	public SalesOrder_model()
	{
		
	}
	public SalesOrder_model(Sales_Order__c s)
	{	
		so = s ;		
	}
	public static decimal getTotalAmount(List<SOLineItemWrapper> PoLineItems)
	{
		decimal PoAmount = 0 ; 
		for (SOLineItemWrapper a: PoLineItems)
		{
		 	PoAmount += a.salesOrderLineItems.Total_Amount__c ;  
		}
		return PoAmount ;
	}
	public static decimal getTotalNetAmount(List<SOLineItemWrapper> PoLineItems)
	{
		decimal totalNet = 0 ; 
		for (SOLineItemWrapper a: PoLineItems)
		{
		 	totalNet += a.salesOrderLineItems.Total_Net__c ;  
		}
		return totalNet ;
	}
	public static decimal getToTalTax(List<SOLineItemWrapper> PoLineItems)
	{
		decimal totalTax = 0 ;
		for (SOLineItemWrapper a: PoLineItems)
		{
		 	totalTax += (a.salesOrderLineItems.VAT_Amount__c) ;
		}
		return totalTax ;	
	}
	public static decimal getTotalAmountExcludingTax(List<SOLineItemWrapper> PoLineItems)
	{
		decimal wtAmount = 0 ;
		for (SOLineItemWrapper a: PoLineItems)
		{
		 	wtAmount += (a.salesOrderLineItems.Amount__c) * a.salesOrderLineItems.Quantity__c ;
		}
		return wtAmount ;	
	}
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Sales Order' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting SO Transaction #. & current document number in GENERAL SETUP');
			else if (Gsetup[0].Current_Document_Number__c == -1)
			{
				ordernumber  = 	integer.valueof(Gsetup[0].Starting_Document_No__c) ; 
			}
			else 
			{
				string dc_curentno = string.valueof(Gsetup[0].Current_Document_Number__c);
                ordernumber  = 	integer.valueof(dc_curentno) ;
                ordernumber += 1 ;	
			}
		}
		else
		{
			throw new customException('Please enter starting SO#. in GENERAL SETUP for Sales Orders');
		}
		return ordernumber ;
	}
	public static string getOrderNo(string orderNo)
	{
		if (orderNo.length() < 6)
		{
			integer ln = 6 - orderNo.length();
			for (integer i=0 ; i<ln ; i++)
			{
				orderNo  = '0'+ orderNo;
			}
		}
		return orderNo ;
	}
	public void updateOrderNo(integer currentOrderNo)
	{
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Sales Order' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	public void SaveOrder(Sales_Order__c order , list<SOLineItemWrapper> sOLineItems , string operationType)
	{
		//SavePoint sp = Database.setsavepoint();
		try 
		{
			if (operationType == 'INSERT')
			{
				valid_OrderInfo(so);
				if (sOLineItems.size() <= 0)
					throw new customexception('No Line Item in Sales Order, Please Enter Line Items');
				list<Sales_Order_Line_Items__c> lineItems = new  list<Sales_Order_Line_Items__c>();
				lineItems = getWrapperToObject(sOLineItems);
				so.Status__c = 'Pending' ;
				integer orderNo = getOrderNumber() ;
				so.Name = string.valueOf(orderNo) ;
				so.Name = getOrderNo(so.Name) ;
				upsert so ;
			    updateOrderNo(orderNo);
			    lineItems = getSalesLineItems(lineItems , so.Id);
			    insert lineItems;
			}
			else if (operationType == 'UPDATE')
			{
				if (sOLineItems.size() <= 0)
					throw new customexception('No Line Item in Sales Order, Please Enter Line Items');
				list<Sales_Order_Line_Items__c> soLine = [select Id from Sales_Order_Line_Items__c where Sales_Order__c = :order.id ];
				if(soLine.size() > 0)
					delete soLine;
				list<Sales_Order_Line_Items__c> lineItems = new  list<Sales_Order_Line_Items__c>();
				lineItems = getWrapperToObject(sOLineItems);
				so.Status__c = 'Pending' ;
				upsert so ;
			    lineItems = getSalesLineItems(lineItems , so.Id);
			    upsert lineItems;
			}
			
		}
		catch (exception e )
		{
			//Database.rollback(sp);
			so.clone(false,true);
			throw new CustomException( e.getMessage());
		}
	}
	public list<Sales_Order_Line_Items__c> getSalesLineItems(list<Sales_Order_Line_Items__c> sOLineItems , Id orderId)
	{
		for (Sales_Order_Line_Items__c item : sOLineItems)
		{
			item.Sales_Order__c = orderId ;
		}
		system.debug(sOLineItems);
		return sOLineItems ; 
	}
	// start of validation Function
	private static void valid_OrderInfo(Sales_Order__c sOrderInfo)
	{
		if (sOrderInfo.Order_Date__c == null )
			throw new CustomException('Please Enter Order Date');
		if (sOrderInfo.Order_Date__c < date.today())
			throw new CustomException('Please Enter Valid Date');
		else if (sOrderInfo.Account__c == null)
			throw new CustomException('Please Enter Customer Name');	
		/*
		else if (sOrderInfo.Customer_Order_No__c == '' || sOrderInfo.Customer_Order_No__c == null)
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Customer Order No' , '') );
			return false;	
		}
		*/
		else if (sOrderInfo.Customer_Order_No__c != '' && sOrderInfo.Customer_Order_No__c != null)
		{
			Pattern a=Pattern.compile('^[a-zA-Z0-9 ]+$');
	        Matcher m=a.matcher(sOrderInfo.Customer_Order_No__c);
	        boolean adit_info=m.matches();
	       	if(adit_info == false)
	        	throw new CustomException('Customer Name Contains Invalid Characters');
	    }
	}
	private List<Sales_Order_Line_Items__c> getWrapperToObject(List<SOLineItemWrapper> wrappervalues)
	{	
		List<Sales_Order_Line_Items__c> lineItems = new List<Sales_Order_Line_Items__c>();
		for (SOLineItemWrapper wrO :  wrappervalues)
		{
			Sales_Order_Line_Items__c lineitem = new Sales_Order_Line_Items__c();
			lineitem.Name = wrO.salesOrderLineItems.Narrative__c.length()>80?(wrO.salesOrderLineItems.Narrative__c.substring(0,75)+' ...'):wrO.salesOrderLineItems.Narrative__c ;
			lineitem.Narrative__c = wrO.salesOrderLineItems.Narrative__c ;
			string nomAccounrt = wrO.salesOrderLineItems.Nominal_Account__c ; 
			if (nomAccounrt == 'SelectAccount')
				throw new CustomException('Please Select Nominal Account for Line Item ' + wrO.salesOrderLineItems.Serial_No__c);
			lineitem.Nominal_Account__c = wrO.salesOrderLineItems.Nominal_Account__c;
			lineitem.Quantity__c = wrO.salesOrderLineItems.Quantity__c ;
			if (lineitem.Quantity__c <= 0)
				throw new CustomException('Quantity Must Be Greater then 1 for Line Item' + wrO.salesOrderLineItems.Serial_No__c);			
			lineitem.Amount__c = wrO.salesOrderLineItems.Amount__c ;
			if (lineitem.Amount__c <= 0)
				throw new CustomException('Amount Must Be Greater then 1 for Line Item' + wrO.salesOrderLineItems.Serial_No__c);
			lineitem.Serial_No__c= wrO.salesOrderLineItems.Serial_No__c ;
			lineitem.VAT_Amount__c = wrO.salesOrderLineItems.VAT_Amount__c ;
			lineitem.Tax_Rate__c = wrO.salesOrderLineItems.Tax_Rate__c ;
			lineitem.Total_Amount__c = wrO.salesOrderLineItems.Total_Amount__c ;
			lineitem.Project__c = wrO.salesOrderLineItems.Project__c ;
			lineitem.Total_Net__c = wrO.salesOrderLineItems.Total_Net__c ;
			lineitem.Product__c =  wrO.salesOrderLineItems.Product__c ;
			lineItems.add(lineitem);
		}
		return lineItems ;
	}
	public static void validateLineDetails(SOLineItemWrapper siItem)
	{
		if (siItem.salesOrderLineItems.Product__c == null )
			throw new CustomException('Please Select Product For Line Item');
		else if (siItem.salesOrderLineItems.Narrative__c == null || siItem.salesOrderLineItems.Narrative__c == '')
			throw new CustomException('Please Enter Narrative Description For Line Item');
		else if (siItem.salesOrderLineItems.Quantity__c == null || siItem.salesOrderLineItems.Quantity__c <= 0 )
			throw new CustomException('Quantity must be Greater than Zero');
		else if (siItem.salesOrderLineItems.Amount__c == null || siItem.salesOrderLineItems.Amount__c <= 0)
			throw new CustomException('Amount Must be Greator then Zero');
		else if (siItem.salesOrderLineItems.Tax_Rate__c == null )
			throw new CustomException('Please Select Tax Rate For Line Item');
	}
	// end of Validation functions
	/*
	public void SendApprovals()
	{
		
		List<Sales_Order_Line_Items__c> soLine = [Select s.Sales_Order__c, Total_Gross__c  ,s.Project__c,s.Project__r.Name, s.Name From Sales_Order_Line_Items__c s where s.Sales_Order__c =: so.Id]; // 'a0JT0000001gKGU'
		system.debug('line items Map:'+getProjectAmount(soLine));
		Map<Id, ProjectApproval> totalAmountMap = getProjectAmount(soLine);
		for(ID projectID : totalAmountMap.keyset())
		{
			string ProjectName = totalAmountMap.get(projectId).ProjectName;
			if(totalAmountMap.get(projectID).POAmount <= 15000)
			{
				SendApprovalToProjectDirector(projectID,ProjectName);
			}
			else if(totalAmountMap.get(projectID).POAmount > 15000 && totalAmountMap.get(projectID).POAmount <= 50000 )
			{
				SendApprovalToDirector(projectID,ProjectName) ;	
			}
			else if(totalAmountMap.get(projectID).POAmount > 50000 )
			{
				SendApprovalAllDirectors(projectID,ProjectName) ;
			}
		}
		
	}
	public void SendApprovalToProjectDirector(Id projectId, String projectName)
	{
		List<User> projectOwner = [Select u.Username, u.Name, u.Id, u.FirstName, u.Email, 
									u.Department, u.CompanyName, u.Budget_Holder__c, 
									u.AccountId From User u where Id IN (Select OwnerId 
									from Opportunity o where o.Id =: projectId)];
		SendPOApprovals('Level1' , projectOwner , projectId, projectName);
		system.debug('in Pd function:' + projectOwner );	
					
	}
	public void SendApprovalToDirector(Id projectId, String projectName)
	{
		List<User> projectOwner = [Select u.UserRoleId , u.Username, u.Name, u.Id, u.FirstName, u.Email, 
									u.Department, u.CompanyName, u.Budget_Holder__c, 
									u.AccountId From User u where Id IN (Select OwnerId 
									from Opportunity o where o.Id =: projectId) limit 1];
		List<User> Director = FindDirectors(projectOwner[0].UserRoleId);
		SendPOApprovals('Level2' , Director , projectId, projectName);
	}
	public void SendApprovalAllDirectors(Id projectId, String projectName)
	{
		List<User> allDirectors = [Select u.UserRoleId , u.Username, u.Name, u.Id, u.FirstName, u.Email, 
									u.Department, u.CompanyName, u.Budget_Holder__c, 
									u.AccountId From User u where u.UserRole.ParentRoleId = null ];
		SendPOApprovals('Level3' , allDirectors , projectId, projectName);
	}
	
	private void SendPOApprovals(string sLevel,List<User> ulist , Id ProjectId, String projectName)
	{
		List<SalesOrderApprovals__c> soalist = new List<SalesOrderApprovals__c>();
		List<SalesOrderStatusHistory__c> sohistory = new List<SalesOrderStatusHistory__c>();
		List<Messaging.SingleEmailMessage> maillist = new List<Messaging.SingleEmailMessage>();
		
		for(User u : ulist)
		{
			system.debug('in sendPoApprovel');
			system.debug('fucntion parameters: ' + ulist + sLevel);
			string status = '';
			string sendTo = '';
			if (sLevel == 'Level1')
			{
				sendTo =  'Approval request sent to Project Director for Project: '+projectName;
				status='Approval request sent to Project Director '+u.Name+' on '+datetime.now().format('dd/MM/yyyy hh:mm:ss');
			}
			else if(sLevel == 'Level2')
			{
				sendTo =  'Approval request sent to Director for Project: '+projectName;
				status='Sales Order Amount Exceeds 15000 for Project: '+projectName+'. Approval request sent to Director '+u.Name+' on '+datetime.now().format('dd/MM/yyyy hh:mm:ss');
			}
			else if(sLevel == 'Level3')
			{
				sendTo =  'Approval request sent to Company Director ' +  u.Name+' for Project: '+projectName;
				status='Sales Order Amount Exceeds 50000 for Project: '+projectName+'. Approval request sent to Company Director '+u.Name+' on '+datetime.now().format('dd/MM/yyyy hh:mm:ss');
			}	
			SalesOrderApprovals__c soApproval = new SalesOrderApprovals__c(Name=sLevel+' approval for '+u.Name,Sales_Order__c=so.Id,Level__c=sLevel,User__c=u.Id,Date_Approval_Sent__c=Datetime.now() , Project__c = ProjectId , Status__c = 'Pending');
			insert soApproval ;
			sendTo = sendTo.length()>80?sendTo.substring(0,78)+'..':sendTo;
			sohistory.add(new SalesOrderStatusHistory__c(Sales_Order__c=so.Id,Name=sendTo , Status__c = status));
			if(u.email!=null)
			{
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String[] toAddresses = new String[] {u.email};
				mail.setToAddresses(toAddresses);
				mail.setSenderDisplayName('Zumzum RDI Application');
				mail.setSubject('Sales Order '+sLevel+' Approval Request for SO#: '+so.Name);
				//string body = '<p>Dear '+u.Name+'</p><p>Please visit the following link to approve or reject SO#: '+so.Name+'</p>';
				//body += '<p><a href="'+serverURL+'/apex/SalesOrderApprovalLevel1?Id='+soApproval.Id+'&Level='+sLevel+'">Click here to approve/reject Sales order</a></p>';
				//mail.setHtmlBody(body);
				system.debug('this is approvalId' + soApproval.Id);
				mail.setHtmlBody(getEmailBody(u.Name , sLevel , soApproval.Id ));
				maillist.add(mail);
			}			
		}
		insert soalist;
		insert sohistory;
		Messaging.sendEmail(maillist);
	}
	
	public Map<Id, ProjectApproval> getProjectAmount(List<Sales_Order_Line_Items__c> lineitems )
	{
		Map<Id , ProjectApproval> projectMap = new Map<Id , ProjectApproval>();
		for(Sales_Order_Line_Items__c so: lineitems)
		{
			if (!projectMap.keyset().contains(so.Project__c))
		    {
		        projectMap.put(so.Project__c , new ProjectApproval(so.Project__r.Name,so.Project__c,so.Total_Gross__c));
		    	//return projectMap ;
		    }
			else
		    {
				decimal total = 0 ;
				projectMap.get(so.Project__c).POAmount += so.Total_Gross__c ;					
				//return projectMap ;	
		    }		    
		}
		return projectMap ;
	}
	private static List<User> FindDirectors(Id RoleId)
	{
		UserRole ur = [Select u.ParentRoleId, u.Name, u.Id From UserRole u where Id=:RoleId];
		if(ur.ParentRoleId==null)
		{
			return [Select u.Name, u.IsActive, u.Id, u.Email From User u Where UserRoleId=:ur.Id];
		}
		else
		{
			return FindDirectors(ur.ParentRoleId);
		}
	}
	private void ApproveSO()
	{
		InsertApprovalHistory('Sales Order Approved');
		so.Status__c='Approved';
		system.debug('so in Approved' + so);
		update so;
	}
	
	private void RejectSO()
	{
		InsertApprovalHistory('Sales Order Rejected');
		system.debug('before : '+so );
		so.Status__c='Rejected';
		system.debug('after : '+so );
		update so;
		List<SalesOrderApprovals__c> soApprovalList = [Select Is_Archived__c from SalesOrderApprovals__c where Sales_Order__c = :so.Id ] ;
		system.debug('approval list' +soApprovalList );
		if (soApprovalList.size() > 0)
		{
			for (SalesOrderApprovals__c soAp : soApprovalList)
			{
				soAp.Is_Archived__c = true ;		
			}
			update soApprovalList ;
		}
	}
	private void InsertApprovalHistory(string message)
	{
		string status=message;
		status+=' - '+datetime.now().format('dd/MM/yyyy hh:mm:ss');
		insert new SalesOrderStatusHistory__c(Sales_Order__c=so.Id,Name=status);
	}
	public void ProjectDirectorApprove(User ui ,Id approvalId)
	{
		//list<SalesOrderApprovals__c> sOList = [select Id,Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level1' and Is_Archived__c = false AND Id = : approvalId];
		list<SalesOrderApprovals__c> sOList = [select Id, Is_Archived__c , Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level1' AND Id = : approvalId];
		if(sOList.size() > 0)
		{
			SalesOrderApprovals__c soa = sOList[0];
			if (soa.Is_Archived__c == true)
				throw new CustomException('This Approval has been archieved. You cannot Approve or Reject it anymore');
			soa.Status__c = 'Approved';
			soa.Date_Approved__c = DateTime.now();
			update soa ;
			InsertApprovalHistory('Approved By Project Director'+ui.Name);
			List<SalesOrderApprovals__c> unApprovedRequests = [select Id from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and Status__c in ('Pending','Rejected') and Is_Archived__c = false];
			if(unApprovedRequests.size()==0)
			{
				ApproveSO();
			}	
		}	
	}
	public void ProjectDirectorReject(User ui , Id approvalId)
	{
		//list<SalesOrderApprovals__c> sOList = [select Id,Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level1' and Is_Archived__c = false];
		list<SalesOrderApprovals__c> sOList = [select Id, Is_Archived__c , Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level1' AND Id = :approvalId ];
		if(sOList.size() > 0)
		{
			SalesOrderApprovals__c soa = sOList[0];
			if (soa.Is_Archived__c == true)
				throw new CustomException('This Approval has been archieved. You cannot Approve or Reject it anymore');
			soa.Status__c = 'Reject';
			update soa ;
			InsertApprovalHistory('Rejected By Project Director'+ui.Name);
			RejectSO();
		}	
	}
	public void DirectorApprove(User ui , Id approvalId)
	{
		list<SalesOrderApprovals__c> sOList = [select Id,Is_Archived__c , Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level2' and Id = :approvalId];
		system.debug('this is from director approval' + sOList ) ;
		if(sOList.size() > 0)
		{
			
			SalesOrderApprovals__c soa = sOList[0];
			if (soa.Is_Archived__c == true)
				throw new CustomException('This Approval has been archieved. You cannot Approve or Reject it anymore');
			soa.Status__c = 'Approved';
			soa.Date_Approved__c = DateTime.now();
			update soa ;
			InsertApprovalHistory('Approved By Director '+ui.Name);
			List<SalesOrderApprovals__c> unApprovedRequests = [select Id from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and Status__c in ('Pending','Rejected') and Is_Archived__c = false];
			if(unApprovedRequests.size()==0)
			{
				ApproveSO();
			}	
		}	
	}
	public void DirectorReject(User ui , Id approvalId)
	{
		list<SalesOrderApprovals__c> sOList = [select Id, Is_Archived__c , Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level2' and Id = :approvalId ];
		if(sOList.size() > 0)
		{
			SalesOrderApprovals__c soa = sOList[0];
			if (soa.Is_Archived__c == true)
				throw new CustomException('This Approval has been archieved. You cannot Approve or Reject it anymore');
			soa.Status__c = 'Rejected';
			update soa ;
			InsertApprovalHistory('Rejected By Director '+ui.Name);
			RejectSO();
		}	
	}
	public void OrganisationDirectorsApprove(User ui , Id approvalId)
	{
		
		//list<SalesOrderApprovals__c> sOList = [select Id,Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level3' and Is_Archived__c = false AND Id = :approvalId];
		list<SalesOrderApprovals__c> sOList = [select Id, Is_Archived__c ,Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level3' and Id = :approvalId];
		system.debug('user id' + ui + ' soId '+ so.Id );
		system.debug('approva;l list' + sOList );
		if(sOList.size() > 0)
		{
			SalesOrderApprovals__c soa = sOList[0];
			if (soa.Is_Archived__c == true)
				throw new CustomException('This Approval has been archieved. You cannot Approve or Reject it anymore');
			soa.Status__c = 'Approved';
			soa.Date_Approved__c = DateTime.now();
			update soa ;
			InsertApprovalHistory('Approved By Director '+ui.Name);
			
			List<SalesOrderApprovals__c> unApprovedRequests = [select Id from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and Status__c in ('Pending','Rejected') and Is_Archived__c = false];
			system.debug('uapprequest' + unApprovedRequests);
			if(unApprovedRequests.size()==0)
			{
				ApproveSO();
			} 	
		}	
	}
	public void OrganisationDirectorsReject(User ui , Id approvalId )
	{
		system.debug('fdfdfds' + [select Id , Is_Archived__c ,Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level3' and Is_Archived__c = false]);
		//list<SalesOrderApprovals__c> sOList = [select Id,Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level3' and Is_Archived__c = false];
		list<SalesOrderApprovals__c> sOList = [select Id,Is_Archived__c , Date_Approved__c,Status__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level3' and Id = :approvalId];
		system.debug('df35ffg' + sOList);
		if(sOList.size() > 0)
		{
			SalesOrderApprovals__c soa = sOList[0];
			if (soa.Is_Archived__c == true)
				throw new CustomException('This Approval has been archieved. You cannot Approve or Reject it anymore');
			soa.Status__c = 'Rejected';
			update soa ;
			InsertApprovalHistory('Rejected By Director '+ui.Name);
			RejectSO();
		}	
	}
	public Boolean authorOrderViewer(Id ur)
	{
		Sales_Order__c sOrder = [select Name ,id , Order_By__c , Status__c from Sales_Order__c where Id = : so.Id ];
		if(sOrder != null)
		{
			if (sOrder.Order_By__c != ur)
			{
				errorMessage = 'Invalid User' ;	
				return false ;
			}
			else if( sOrder.Status__c == 'Submitted_For_Approval'  )
			{
				errorMessage = 'Sales Order SO#'+sOrder.Name+' is Submited for Approval, you Can\'t Change Its Content';
				return false ; 	
			}
			else if( sOrder.Status__c == 'Approved'  )
			{
				errorMessage = 'Sales Order SO#'+sOrder.Name+' is Already Approved, you Can\'t Change Its Content';
				return false ; 	
			}
			else 
			{
				return true ; 
			}
		}	
		else 
		{
			errorMessage = 'Invalid Sales Order' ;		
			return false ;
		}
	}
	// Testin Wrapper
	public static decimal getTotalAmountt(List<SOLineItemWrapper> SoLineItems)
	{
		decimal PoAmount = 0 ; 
		for (SOLineItemWrapper a: SoLineItems)
		{
		 	PoAmount += a.salesOrderLineItems.Total_Gross__c ;  
		}
		return PoAmount ;
	}
	public static decimal getToTalTaxx(List<SOLineItemWrapper> SoLineItems)
	{
		decimal totalTax = 0 ;
		for (SOLineItemWrapper a: SoLineItems)
		{
		 	totalTax += (a.salesOrderLineItems.VAT_Amount__c)  * a.salesOrderLineItems.Quantity__c ;  
		}
		return totalTax ;	
	}
	public static decimal getTotalAmountExcludingTaxx(List<SOLineItemWrapper> SoLineItems)
	{
		decimal wtAmount = 0 ;
		for (SOLineItemWrapper a: SoLineItems)
		{
		 	wtAmount += (a.salesOrderLineItems.Amount__c) * a.salesOrderLineItems.Quantity__c ;
		}
		return wtAmount ;	
	}
	// end of Wrapper
	
public string getEmailBody(String name , string level , Id approvalId)
	{
		//Id pOId = 'a0IT00000012ytDMAQ';
		//Purchase_Order__c po = [select Name , Id , Order_Date__c , Owner.Name , Account__r.Name from  Purchase_Order__c where id =:pOId  ]  ;
		list<Sales_Order_Line_Items__c> SOLineItems = [Select Total_Gross__c, VAT_Amount__c, Sub_Project__c , Sub_Project__r.Name , Quantity__c, Sales_Order__c, Project__c ,Project__r.Name , OwnerId , Nominal_Account__c , Nominal_Account__r.Name , Narrative__c, Name, Id, Delete__c, Amount__c , Tax_Rate__c , Tax_Rate__r.Name , Serial_No__c From Sales_Order_Line_Items__c where Sales_Order__c = :SO.Id and Project__c in (select Project__c from SalesOrderApprovals__c where Id=:approvalId)];
		Map<Id, ProjectApproval> totalAmountMap = getProjectAmount(SOLineItems);
		date stdt = date.newInstance(SO.Order_Date__c.Year() , SO.Order_Date__c.Month() , 1 );
		system.debug(stdt);
		date endt = SO.Order_Date__c ;
		string body = '<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /><title>Untitled Document</title></head>'+
		'<body>'+
		'<div style="background:#000;color:#fff;padding:10px;"><img src="https://'+serverURL+'/resource/ZeeZee__EmailLogo'+'" width="195" height="52" vspace="6" hspace="10" />'+		
		'<style>'+ 
		'th{color:#008e4f; font-size:18px;}'+
		'a{color:#CCC}'+
		'a:hover{color:#fff;}'+
		'</style>'+
		'<table width="100%" border="0" style="font-size:12px;font-family:Arial, Helvetica, sans-serif;border:2px solid #666" cellspacing="0" cellpadding="4" >'+
		'<th style="color:#008e4f; font-size:18px;" colspan="2" align="left" >SO Detail</th><tr><td width="150">SO#:</td><td>'+ SO.Name +'</td></tr>'+
		'<tr><td>Order Date: </td><td>'+SO.Order_Date__c+'</td></tr><tr><td>Placed By: </td><td>'+ so.Order_By__r.Name +'</td>'+
		  '</tr>'+
		 '<tr>'+
		    '<td>Account:</td>'+
		    '<td>'+ SO.Account__r.Name +'</td>'+
		    '</tr>'+
		    '<tr>'+
		    '<td>Approval Request to:</td>'+
		    '<td>'+ name +'</td>'+
		    '</tr>'+
		    '<tr>'+
		    '<td>level:</td>'+
		    '<td>'+ level +'</td>'+
		  '</tr>'+
		'</table>'+
		'<p>&nbsp;</p>';

		body += '<table width="100%" border="0" style="font-size:12px;font-family:Arial, Helvetica, sans-serif;border:2px solid #666" cellspacing="0" cellpadding="4" >'+
		'<th style="color:#008e4f; font-size:18px;" colspan="9" align="left" >SO Budget Details</th>'+
		              '<tr>'+
		                '<td width="25%" height="25"><strong>Project Name</strong></td>'+
		                '<td width="25%" height="25"><strong>Amount Spent</strong></td>'+		                
		              '</tr>'+
		              '<br/>';
		          //  '<apex:repeat value="{!budgetInformation}" var="o">'+
		          //    '<!-- {!o.Name} || {!o.ProjectName} || {!o.SubCatagoryName} || {!o.Amount} || {!o.PoAmount}|| <br/> -->'+
			for(Id pid : totalAmountMap.keyset())
			{               
			               body +='<tr>'+
			                    '<td width="25%" height="25"><strong>'+totalAmountMap.get(pid).ProjectName+'</strong></td>'+
			                    '<td width="25%" height="25"><strong>'+totalAmountMap.get(pid).POAmount+'</strong></td>'+			                    
							'</tr>';
			} 
		            body += '</table>'+
					'<p>&nbsp;</p>';
			
		body +=  '<table width="100%" border="0" style="font-size:12px;font-family:Arial, Helvetica, sans-serif;border:2px solid #666" cellspacing="0" cellpadding="4" >'+
		'<th style="color:#008e4f; font-size:18px;" colspan="9" align="left" >SO Line Items</th>'+
		'<tr>'+
		                    '<td>Serial No</td>'+
		                    '<td>Nominal Account</td>'+
		                    '<td>Narrative</td>'+
		                    '<td>Quantity</td>'+
		                    '<td>Amount</td>'+
		                    '<td>Tax Rate</td>'+
		                    '<td>Tax Amount</td>'+
		                    '<td>Project</td>'+
		                    '<td>Sub Project</td>'+
		                    '<td>Total Amount</td>'+
		                '</tr>';
		for (Sales_Order_Line_Items__c lItems: SOLineItems)
		{
			body +='<tr>';
			body +='<td>'+lItems.Serial_No__c+'</td>'+
		                    '<td>'+lItems.Nominal_Account__r.Name+'</td>'+
		                    '<td>'+lItems.Narrative__c+'</td>'+
		                    '<td>'+lItems.Quantity__c+'</td>'+
		                    '<td>'+lItems.Amount__c+'</td>'+
		                    '<td>'+lItems.Tax_Rate__r.Name+'</td>'+
		                    '<td>'+lItems.VAT_Amount__c+'</td>'+
		                    '<td>'+lItems.Project__r.Name+'</td>';
		                    if (lItems.Sub_Project__r.Name != null)
		                    	body +='<td>'+lItems.Sub_Project__r.Name+'</td>';
		                    else 
		                    	body +='<td></td>';	
		                    body +='<td>'+lItems.Total_Gross__c+'</td>';
		     body +='</tr>';               
		}
		body +='</table>';
		body += '<p>&nbsp;</p>'+
		'<table width="100%" border="0" style="font-size:12px; font-family:Arial, Helvetica, sans-serif; border:2px solid #FF8000" cellspacing="0" cellpadding="4">'+
		'<tr>';
		//if (level == 'Level1')
			body += '<td style="font-size:16px; width:50%; padding-right:25" align="right"><a style="color:#CCC; text-decoration:none;"  href="https://'+serverURL+'/apex/SalesOrderApprovalLevel1?Id='+approvalId+'&Level='+level+'&action=Approve">Approve</a></td>';
		//else
			//body += '<td style="font-size:16px; width:50%; padding-right:25" align="right"><a href="https://'+serverURL+'/apex/SalesOrderApprovalLevel1?Id='+approvalId+'&Level='+level+'&action=Approve">Approve</a></td>';
		//if (level == 'Level1')
			body +='<td style="font-size:16px; width:50%; padding-left:25" align="left"><a style="color:#CCC; text-decoration:none;"  href="https://'+serverURL+'/apex/SalesOrderApprovalLevel1?Id='+approvalId+'&Level='+level+'&action=Reject">Reject</a></td>';	
		//else
			//body +='<td style="font-size:16px; width:50%; padding-left:25" align="left"><a href="https://'+serverURL+'/apex/SalesOrderApprovalLevel1?Id='+approvalId+'&Level='+level+'&action=Reject">Reject</a></td>';			
		body += '</tr>'+
		'</table>'+
		'</div>';
		body +='</body>'+
		'</html>';
		return body;
	}
	
	public class ProjectApproval
	{
		public string ProjectName {get;set;}
		public string ProjectId {get;set;}
		public Decimal POAmount {get;set;}
		
		public ProjectApproval(string pName, Id pId, decimal pAmount)
		{
			ProjectName = pName;
			ProjectId = pId;
			POAmount = pAmount;
		} 
	}
	*/
	/*
	// Approval Code Commited on 12-1-2011
	public void SendApprovals()
	{
		if(CheckLevel1ApprovalRequired()==true)
		{
			SendLevel1Approval();//sendto pprove level 1 function call
			return;
		}
		else 
		{
			InsertApprovalHistory('Level 1 approval not required');
			if(CheckLevel2ApprovalRequired()==true)
			{
				SendLevel2Approval();//sendto pprove level 2 function call
			}
			else
			{
				InsertApprovalHistory('Level 2 approval not required');
				ApprovePO();//No Approval is required
			}
		}
	}
	private void SendLevel1Approval()
	{
		List<User> ulist = FindUsersWithApprovalLimit(system.userInfo.getUserRoleId());
		if(ulist.size()>0)
		{
			SendPOApprovals('Level1',ulist);
		}
		else
		{
			if(CheckLevel2ApprovalRequired()==true)
			{
				SendLevel2Approval();
			}
			else
			{
				InsertApprovalHistory('Level 2 approval not required');
				ApprovePO();
			}
		}		
	}
	private List<User> FindUsersWithApprovalLimit(Id RoleId)
	{
		List<Approval_Limit__c> alist = [select id,Amount__c,RoleId__c from Approval_Limit__c where RoleId__c=:RoleId and Amount__c<=:so.Total_Gross__c AND Type__c = 'SalesOrder'];
		
		if(alist.size()>0)
		{
			//role has approval limit coverred
			//return list of users associated with this job role
			return [Select u.Name, u.IsActive, u.Id, u.Email From User u Where UserRoleId=:RoleId];
		}
		else
		{
			//role does not have approval limit
			//check for the parent role that this job role reports to
			UserRole ur = [Select u.ParentRoleId, u.Name, u.Id From UserRole u where Id=:RoleId];
			
			if(ur.ParentRoleId==null || ur.Name.contains('CD'))
			{
				//this job role doesnot report to anyone or it is company directory
				//return users with this job role.
				return [Select u.Name, u.IsActive, u.Id, u.Email From User u Where UserRoleId=:ur.Id];
			}
			else
			{
				//not a top most job
				//check if parent role has limits covered.
				return FindUsersWithApprovalLimit(ur.ParentRoleId);
			}	
		}
	}
	private void SendLevel2Approval()
	{
		List<User> ulist = FindDirectors(system.userInfo.getUserRoleId());
		if(ulist.size()>0)
		{
			SendPOApprovals('Level2',ulist);
		}
		else
		{
			ApprovePO();
		}
	}
	private static List<User> FindDirectors(Id RoleId)
	{
		UserRole ur = [Select u.ParentRoleId, u.Name, u.Id From UserRole u where Id=:RoleId];
		if(ur.ParentRoleId==null)
		{
			return [Select u.Name, u.IsActive, u.Id, u.Email From User u Where UserRoleId=:ur.Id];
		}
		else
		{
			return FindDirectors(ur.ParentRoleId);
		}
	}
	private boolean CheckLevel1ApprovalRequired()
	{
		List<Approval_Limit__c> alist = [select id,Amount__c from Approval_Limit__c where roleId__c=:system.userInfo.getUserRoleId() AND Type__c = 'SalesOrder' ];
		system.debug('list: '+ alist);
		if(alist.size()>0)
		{
			system.debug('Potatal Amount: ' + so.Total_Gross__c);
			system.debug('approval limit: ' + alist[0].Amount__c);
			if(so.Total_Gross__c>alist[0].Amount__c)
			{
				return true;
			}
			else
			{
				return false;
			}	
		}
		return false;
	}
	private boolean CheckLevel2ApprovalRequired()
	{
		for(Sales_Order_Line_Items__c li : [Select l.Total_Gross__c, l.Sales_Order__c, Sales_Order__r.CreatedDate, l.Project__c, 
								l.Nominal_Account__r.Sub_Category__c, l.Nominal_Account__c, l.Id 
								From Sales_Order_Line_Items__c l 
								where Sales_Order__c=:so.Id])
		{
			Date startDate = li.Sales_Order__r.CreatedDate.Date().toStartOfMonth();
			DateTime endDate = li.Sales_Order__r.CreatedDate;
			AggregateResult arlist = [select sum(Total_Gross__c) from Sales_Order_Line_Items__c l where l.Nominal_Account__r.Sub_Category__c=:li.Nominal_Account__r.Sub_Category__c and l.Project__c=:li.Project__c and l.Sales_Order__r.CreatedDate>=:startDate and l.Sales_Order__r.CreatedDate<=:endDate];
			double totalSpent = (double) arlist.get('expr0');
			Integer Month = startDate.Month();
			Integer Year = startDate.Year();
			List<Project_Budget__c> projectBudgetList = [Select p.Year__c, p.Sub_Category__c, p.Project_Name__c, p.Name, p.Month__c, p.Id, p.Budget_Amount__c From Project_Budget__c p Where p.Project_Name__c=:li.Project__c and Sub_Category__c=:li.Nominal_Account__r.Sub_Category__c and month__c=:month and year__c=:year and Budget_Amount__c<=:totalSpent];
			if(projectBudgetList.size()>0)
			{
				return true;
			}
		}
		return false;
	}
	private void ApprovePO()
	{
		InsertApprovalHistory('Sales Order Approved');
		so.Status__c='Approved';
		update so;
	}
	
	private void RejectPO()
	{
		InsertApprovalHistory('Sales Order Rejected');
		so.Status__c='Rejected';
		update so;
	}
	private void InsertApprovalHistory(string message)
	{
		string status=message;
		status+=' - '+datetime.now().format('dd/MM/yyyy hh:mm:ss');
		insert new SalesOrderStatusHistory__c(Sales_Order__c=so.Id,Name=status);
	}
	public void ApproveLevel1(User ui)
	{
		List<SalesOrderApprovals__c> soalist = [select Id,Date_Approved__c,Is_Approved__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level1'];
		if(soalist.size()>0)
		{
			SalesOrderApprovals__c soa = soalist[0];
			soa.Is_Approved__c=true;
			soa.Date_Approved__c=Datetime.now();
			system.debug(soa);
			update soa;
			InsertApprovalHistory('Level 1 approved by '+ui.Name);
			List<SalesOrderApprovals__c> unApprovedRequests = [select Id from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and Level__c='Level1' and Is_Approved__c=false];	
			if(unApprovedRequests.size()==0)
			{
				if(CheckLevel2ApprovalRequired()==true)
				{
					SendLevel2Approval();
				}
				else
				{
					InsertApprovalHistory('Level 2 approval not required');
					ApprovePO();
				}
			}				
		}
		else
		{
			throw new CustomException('User \''+ui.Name+'\' is not authorized for Level 1 approval for SO#: '+so.Name);
		}	
	}
	public void RejectLevel1(User ui)
	{
		List<SalesOrderApprovals__c> soalist = [select Id,Date_Approved__c,Is_Approved__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level1'];
		if(soalist.size()>0)
		{
			SalesOrderApprovals__c soa = soalist[0];
			soa.Is_Approved__c=false;			
			update soa;
			InsertApprovalHistory('Level 1 rejected by '+ui.Name);
			RejectPO();	
		}
		else
		{
			throw new CustomException('User \''+ui.Name+'\' is not authorized for Level 1 approval for SO#: '+so.Name);
		}	
	}
	public void ApproveLevel2(User ui)
	{
		List<SalesOrderApprovals__c> soalist = [select Id,Date_Approved__c,Is_Approved__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level2'];
		if(soalist.size()>0)
		{
			SalesOrderApprovals__c soa = soalist[0];
			soa.Is_Approved__c=true;
			soa.Date_Approved__c=Datetime.now();
			update soa;
			InsertApprovalHistory('Level 2 approved by '+ui.Name);
			List<SalesOrderApprovals__c> unApprovedRequests = [select Id from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and Is_Approved__c=false];	
			if(unApprovedRequests.size()==0)
			{
				ApprovePO();
			}				
		}
		else
		{
			throw new CustomException('User \''+ui.Name+'\' is not authorized for Level 2 approval for SO#: '+so.Name);
		}
	}
	public void RejectLevel2(User ui)
	{
		List<SalesOrderApprovals__c> soalist = [select Id,Date_Approved__c,Is_Approved__c from SalesOrderApprovals__c Where Sales_Order__c=:so.Id and User__c=:ui.Id and Level__c='Level2'];
		if(soalist.size()>0)
		{
			SalesOrderApprovals__c soa = soalist[0];
			soa.Is_Approved__c=false;			
			update soa;
			InsertApprovalHistory('Level 2 rejected by '+ui.Name);
			RejectPO();				
		}
		else
		{
			throw new CustomException('User \''+ui.Name+'\' is not authorized for Level 2 approval for SO#: '+so.Name);
		}	
	}
	*/
}