public class SubProjectSelectorWrapper 
{
	public List<Opportunity> Projects {get; set;}
	private Id subProject {get; set;}
	public SubProjectSelectorWrapper(Id projectId)
	{
		//Projects = [select Id , Name from Opportunity limit 1000 ];
		this.subProject = projectId ;
	} 
	public list<selectoption> getSubProject()
	{
		list<selectoption> SubProject = new list<selectoption>();
		for (Opportunity td : [select Id , Name from Opportunity where Sub_Project__c = :this.subProject limit 1000 ])
		{
			SubProject.add(new selectoption( td.id , td.Name ))	;
		}
		return SubProject;
	}
	public class wrappTimeSheet
	{
		public Id projectId {set;get;}
		public Id SubprojectId {set;get;}
		public List<selectoption> subProjectList {get; set;}
	} 
}