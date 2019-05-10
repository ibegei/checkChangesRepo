public class JIRA_SearchIssues {
    public String  objId{get;set;}
    public List<Issue> issues{get;set;}
    public ChkOptions[] chkOptions {get;set;}
    public String searchKey{get;set;}
    public  JIRA_SearchIssues (){
        String  objId=   ApexPages.currentPage().getParameters().get('objId');
        system.debug(objId);
        
        chkOptions = New ChkOptions[]{};
            getCreatemeta();
        
    }
    public pageReference searchJiraIssues(){
        issues=new List<Issue>();
        List<String> inProjects=new List<String>();
        for(ChkOptions opt:chkOptions){
            if(opt.isSelected){
                inProjects.add(opt.label);
            }
        }
        String json = 
            ' {"jql": "'+
            
            'project in ('+String.join(inProjects, ', ')+')'+
            ' and summary ~ \\"'+searchKey+'\\"'+
            
            '",'+ 
            ' "startAt": 0, '+
            ' "maxResults": 100, '+
            '"fields": [  '+
            ' "issuetype",  '+
            '"summary",'    +
            '"status", '   +
            '"comment",'   +
            '"assignee",' +
            '"priority",' +
            
            ' "project" ],'  +
            '"fieldsByKeys": false'+
            '} ';
        system.debug(json);
        HttpResponse res = JIRA_Requests.fetchJiraIssues('POST','/rest/api/2/search',json);
        if(res.getStatusCode()==200){
            Jira_GetIssues  jissues=Jira_GetIssues.parse(res.getBody());
            for(Jira_GetIssues.Issues ji:jissues.issues){
                issues.add(new Issue(false, ji));
            }
        }
        return null;
    }
    public void getCreatemeta(){ 
        HttpResponse createmetaResponce=  JIRA_Requests.getProjects('GET','/rest/api/2/issue/createmeta.json'); 
        if(createmetaResponce.getStatusCode()==200){ 
            getProjects(createmetaResponce.getBody());
        }else{
            
        } 
    }
    
    public void getProjects(String body){
        Map<String, Object> results =  (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> projects = (List<Object>)results.get('projects');
        for(Object project : projects){
            Map<String, Object> projectAttributes = (Map<String, Object>)project;
            List<Object> issuetypes= (List<Object>)projectAttributes.get('issuetypes');
            chkOptions.add( New ChkOptions(String.valueOf(projectAttributes.get('key')), true));
        }
    }
        public  PageReference  cancel(){
      return  new PageReference('/'+ApexPages.currentPage().getParameters().get('objId'));

    }
    public void linkToBranch(){
        
        set<String> linkedIssues=new Set<String>();
        
        for(Issue i:issues){
            if(i.isChecked){
                linkedIssues.add(i.issue.key);
            }
            
            
            List<SF_to_Jira_Map__c> orders= new List<SF_to_Jira_Map__c>([SELECT id, JIRA_Keys__c,Name FROM SF_to_Jira_Map__c WHERE Name=:ApexPages.currentPage().getParameters().get('objId')]);
            
            if(orders.isEmpty()){
                SF_to_Jira_Map__c ord=new SF_to_Jira_Map__c();
                ord.Name=objId;
                ord.JIRA_Keys__c=  Json.serialize(linkedIssues);  
                insert ord;
            }else{
                SF_to_Jira_Map__c   ord=orders.get(0);
                if(String.isEmpty(ord.JIRA_Keys__c)){
                    ord.JIRA_Keys__c=Json.serialize(linkedIssues);
                }else{
                    Set<String> ordIds=(Set<String>)Json.deserialize(ord.JIRA_Keys__c,Set<String>.class);
                    ordIds.addAll(linkedIssues);
                    ord.JIRA_Keys__c=Json.serialize(ordIds);
                    
                }
                update ord;
            } 
        }
    }
    public class ChkOptions{
        
        public string label {get;set;}
        public boolean isSelected {get;set;}
        public chkOptions(string label, boolean isSelected){
            this.label = label;
            this.isSelected=isSelected;
        }
    }
    
    Public class Issue{
        public boolean isChecked{get;set;}
        public Jira_GetIssues.Issues issue{get;set;}
        public Issue(boolean isChecked,Jira_GetIssues.Issues issue){
            this.isChecked=isChecked;
            this.issue=issue;
        }
    }
    
}