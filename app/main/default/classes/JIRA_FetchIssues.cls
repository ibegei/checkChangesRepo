public class JIRA_FetchIssues {
    public  Flosum__Branch__c branch;
    public SF_to_Jira_Map__c jiraMap;
    public Jira_GetIssues issues{get;set;}
    public JIRA_FetchIssues(ApexPages.StandardController stdController){
        this.branch = (Flosum__Branch__c)stdController.getRecord();
        getIssueKeys();
        if(jiraMap!=Null && !string.isEmpty(jiraMap.JIRA_Keys__c) ){
            
            List<String> ids=(List<String>)Json.deserialize(jiraMap.JIRA_Keys__c,List<String>.class);
            if(!ids.isEmpty()){
                String keys = '';
                Integer index = 0;
                String json = '';
                For(String key:ids){
                    if(index == 0){
                        keys += 'key = '+key;
                        index++;
                    }else{
                        keys += ' or key = '+key;
                        index++;
                    }    
                }
                json = 
                    ' {"jql": "'+keys+'", '+
                    ' "startAt": 0, '+
                    ' "maxResults": 999, '+
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
                 HttpResponse res = JIRA_Requests.fetchJiraIssues('POST','/rest/api/2/search',json);
                if(res.getStatusCode()==200){
                    issues=Jira_GetIssues.parse(res.getBody());
                }
            }
        }
        
    }
    
    
        public void getIssueKeys(){
       
String branchId=String.valueOf(branch.Id).substring(0, 15);
            try{
                jiraMap=[SELECT id, JIRA_Keys__c, Name FROM SF_to_Jira_Map__c WHERE Name=:branchId];
            }catch(Exception e){
                system.debug(e.getMessage());
            }
            
      
    }
}