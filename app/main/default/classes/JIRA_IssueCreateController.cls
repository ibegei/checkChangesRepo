public class JIRA_IssueCreateController {
    public String sObjId{get;set;}
    public String field1{get;set;}
    public String field2{get;set;}
    public boolean scsResp{get;set;}
    public boolean errorResp{get;set;}
    public String respMessage{get;set;}
    public List<SelectOption> selectList         { get; set; }
    public List<SelectOption> secondarySelectList{ get; set; }
    public Map<String, List<String>> picklistMap { get; set; }
    public List<SelectOption> Items{get;set;}
      private static final String DATE_FORMAT='yyyy-MM-dd';
    public Boolean issueCreateForm{get;set;}
    public List<String> issueFields{get;set;}
    public List<IssueWrapper> issue{get;set;}

    public List<IssueWrapper> issueCreateFieldForm{get;set;}
    
    public  PageReference  cancel(){
      return  new PageReference('/'+sObjId);

    }
    public JIRA_IssueCreateController(){
        errorResp=false;
        scsResp=false;
        sObjId='a071g0000013SY9';
        issueCreateForm=false;
        HttpResponse createmetaResponce=  JIRA_Requests.getProjects('GET','/rest/api/2/issue/createmeta.json'); 
        if(createmetaResponce.getStatusCode()==200){ 
            
            Items=new List<SelectOption>();
            List<Object> projects=getProjects(createmetaResponce.getBody());
            setupPickValMap(projects);
            getPrimaryPickVals();
            
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, createmetaResponce.getStatus()));  
        } 
        
        
    }
    public map<String,String> issueIds=new  map<String,String>();
    public void setupPickValMap(List<Object> projects){
        picklistMap = new Map<String, List<String>>();
        picklistMap.put('-None-', new String[]{});
        for(Object project : projects){ 
            Map<String, Object> projectAttributes = (Map<String, Object>)project;
            List<Object> issuetypes= (List<Object>)projectAttributes.get('issuetypes'); 
            System.debug(issuetypes.size()+'KEY ========> ' +projectAttributes.get('key')); 
            System.debug('ID =========> ' +projectAttributes.get('id')); 
            String[] issueType=new String[]{}; 
                for (Object item : issuetypes) { 
                   
                    Map<String, Object> i = (Map<String, Object>)item;
                     issueIds.put(String.valueOf(i.get('name')),String.valueOf(i.get('id')));
                    issueType.add(String.valueOf(i.get('name'))); 
                    System.debug(i.get('name')); 
                    
                } 
            picklistMap.put(String.valueOf(projectAttributes.get('key')), issueType);
        } 
    }
    
    
    public void getSecondaryPickVals(){ 
        if(field1 != null){
            secondarySelectList = new List<selectOption>();
            for(String s : picklistMap.get(field1))
                secondarySelectList.add(new SelectOption(s, s)); 
        }
    }
    
    public void getPrimaryPickVals(){
        selectList = new List<selectOption>(); 
        for(String s : picklistMap.keySet())
            selectList.add(new SelectOption(s, s)); 
    }
    public static List<Object> getProjects(String body){
        
        Map<String, Object> results =  (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> projects = (List<Object>)results.get('projects');
        
        for(Object project : projects){
            
            Map<String, Object> projectAttributes = (Map<String, Object>)project;
            List<Object> issuetypes= (List<Object>)projectAttributes.get('issuetypes');
            
            System.debug(issuetypes.size()+'KEY ========> ' +projectAttributes.get('key'));
            System.debug('ID =========> ' +projectAttributes.get('id'));
            
            for (Object item : issuetypes) {
                
                Map<String, Object> i = (Map<String, Object>)item;
                System.debug(i.get('name'));
                System.debug(i);
            }
            
        }
        return projects;
    }

    public void initCteateForm(){
        issueFields=new String[]{}; 
            issue=new List<IssueWrapper>(); 
        issueCreateForm=true;     
        HttpResponse createmetaResponce=  JIRA_Requests.getProjects('GET','/rest/api/2/issue/createmeta?projectKeys='+EncodingUtil.urlEncode(field1, 'UTF-8')+'&issuetypeNames=' +EncodingUtil.urlEncode(field2, 'UTF-8')+'&expand=projects.issuetypes.fields');
        system.debug(createmetaResponce.getBody());
        
        Map<String, Object> results =  (Map<String, Object>)JSON.deserializeUntyped(createmetaResponce.getBody());
        List<Object> projects = (List<Object>)results.get('projects');
        
        for(Object project : projects){
            
            Map<String, Object> projectAttributes = (Map<String, Object>)project;
            
            List<Object> issuetypes= (List<Object>)projectAttributes.get('issuetypes'); 
            System.debug(issuetypes.size()+'KEY ========> ' +projectAttributes.get('key')); 
            System.debug('ID =========> ' +projectAttributes.get('id')); 

            
            for (Object item : issuetypes) { 
                
                Map<String, Object> i = (Map<String, Object>)item; 
                
                Map<String, Object> fields=(Map<String, Object>)i.get('fields'); 
                
                for(String fieldName:fields.keySet()){ 
                    
                    System.debug(fieldName);
                    issueFields.add(fieldName); 
                    Object field=fields.get(fieldName);
                    Map<String, Object> fieldAttributes = (Map<String, Object>)field; 
                    
                    List<Object> op=(List<object>)fieldAttributes.get('operations'); 
                    String[] operations=new string[]{}; 
                        
                        for(Object obj:op){ 
                            
                            System.debug(obj); 
                            operations.add(String.valueOf(obj)); 
                        } 
                    
                    System.debug(operations);
                    List<AllowedValues> allowedValuesList=new List<AllowedValues>();
                    Object fShema=(Object)fieldAttributes.get('schema'); 
                    Map<String, Object> fShemaMap = (Map<String, Object>)fShema;
                    
                    for(String str:fShemaMap.keySet()){ 
                        
                    } 
                    
                    FieldSchema sch=new  FieldSchema( 
                        String.valueOf(fShemaMap.get('type')),
                        String.valueOf(fShemaMap.get('items')),
                        String.valueOf(fShemaMap.get('custom')),
                        Integer.valueOf(fShemaMap.get('customId')),
                        String.valueOf(fShemaMap.get('system')) 
                    ); 
                    
                    List<Object> allowedValues=(List<Object>)fieldAttributes.get('allowedValues');
                    system.debug('allowedValues>>>>>>>'+allowedValues);
                    
                    if(allowedValues!=null ){
                        
                        for(Object obj:allowedValues){
                            
                            Map<String, Object> p = (Map<String, Object>)obj;
                            
                            allowedValuesList.add(new AllowedValues(
                                String.valueOf(p.get('self')), 
                                String.valueOf(p.get('id')), 
                                String.valueOf(p.get('key')),
                                String.valueOf(p.get('name')),
                                String.valueOf(p.get('value')))
                                                 ); 
                        }    
                    } 
                    IssueWrapper is=new IssueWrapper( 
                        sch, 
                        allowedValuesList, 
                        operations, 
                        String.valueOf(fieldAttributes.get('key')),
                        String.valueOf(fieldAttributes.get('name')), 
                        Boolean.valueOf(String.valueOf(fieldAttributes.get('required'))), 
                        Boolean.valueOf(String.valueOf(fieldAttributes.get('hasDefaultValue')))  
                    ); 
                    
                    issue.add(is);
                } 
            }
        } 
        system.debug(issue);
issueCreateFieldForm = new List<IssueWrapper>();
        for(IssueWrapper is:issue){
            if(is.schema.fSystem!=null &&
               (is.schema.fSystem!='worklog' &&
                is.schema.fSystem!='issuelinks' &&
                is.schema.fSystem!='versions' &&
                is.schema.fSystem!='environment' &&
                is.schema.fSystem!='reporter' &&
                is.schema.fSystem!='timetracking' &&
                is.schema.fSystem!='resolution'
               )
              ){
                if(is.key!='issuetype' && is.key!='project' && is.key!='attachment'){
                    issueCreateFieldForm.add(is);
                    
                }
            }else{
                
            }
        }
    }
    public void saveIssue(){
        system.debug(field1);
        system.debug(field2);
      

 
           Map<String, Object> jsonBody= new Map<String, Object>{
                
                     'project' => new Map<String,Object> {
                        'key' => field1
                    }
                  
                    ,'issuetype' => new Map<String,Object> {
                        'id' => issueIds.get(field2)
                       
                }
            
            };
        for(IssueWrapper is:issueCreateFieldForm){
            if(is.schema.fSystem!=Null){
                if(is.schema.fSystem=='summary'){
                    if(!string.isEmpty(is.value) && is.value!=null){
                    jsonBody.put(is.key,is.value );
                    }
                }else if(is.schema.fSystem=='description'){
                    if(!string.isEmpty(is.value) && is.value!=null){
                         jsonBody.put(is.key,is.value );
                    }    
                }else if(is.schema.fSystem=='labels'){
                    if(!string.isEmpty(is.value) && is.value!=null){
                        jsonBody.put(is.key,new List<String>(is.value.split(',')) );
                    }
                    
                }else if(is.schema.fSystem=='priority'){
                    if(!string.isEmpty(is.value) && is.value!=null){
                        jsonBody.put(is.key,new Map<String,Object> {'id'=>is.value} );
                    }
                }else if(is.schema.fSystem=='fixVersions'){
                    if(!string.isEmpty(is.value) && is.value!=null){
                        jsonBody.put(is.key,new List<Object>{new Map<String,Object> {'name'=>is.value}});
                    }
                }else if(is.schema.fSystem=='components'){
                    if(!string.isEmpty(is.value) && is.value!=null){
                        jsonBody.put(is.key,new List<Object>{new Map<String,Object> {'id'=>is.value}});
                    }    
                }else if(is.schema.fSystem=='duedate'){
                     if(!string.isEmpty(is.value) && is.value!=null){
                    Date d=date.parse(is.value);
                    Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                    String dateString = dt.format(DATE_FORMAT); 
                    jsonBody.put(is.key, dateString);
                     }
                }else if(is.schema.fSystem==''){
                     
                }else if(is.schema.fSystem==''){
                     
                }
            }
        }
       
        
       system.debug(JSON.serialize( new Map<String, Object>{ 'fields' => jsonBody})); 
       HttpResponse res= JIRA_Requests.createIssue('POST', '/rest/api/2/issue',JSON.serialize( new Map<String, Object>{ 'fields' => jsonBody}));
        
        if(res.getStatusCode()==201){
            scsResp=true;
            respMessage=res.getBody();
            List<SF_to_Jira_Map__c> orders= new List<SF_to_Jira_Map__c>([SELECT id, JIRA_Keys__c,Name FROM SF_to_Jira_Map__c WHERE Name=:ApexPages.currentPage().getParameters().get('objId')]);
      ScsIssueCreate scs=      (ScsIssueCreate)JSON.deserialize(res.getBody(), ScsIssueCreate.class);
            set<String> linkedIssues=new Set<String>{scs.key};
            if(orders.isEmpty()){
                SF_to_Jira_Map__c ord=new SF_to_Jira_Map__c();
                ord.Name=ApexPages.currentPage().getParameters().get('objId');
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
            
            
            
            
            
        }else{
            errorResp=true;
           respMessage=res.getBody();
        }

                                  
                                
    }
    
    public class IssueWrapper{
        Public String value{get;set;}
        public Boolean required{get;set;}
        public String name{get;set;}
        public String key{get;set;}
        public Boolean hasDefaultValue{get;set;}
        public String[] operations{get;set;}
        public FieldSchema schema{get;set;}
        public List<AllowedValues> allowedValues{get;set;}
        public sObject defaultValue{get;set;}
        public List<SelectOption> items{get;set;}
        
        
        public IssueWrapper(
            FieldSchema schema, 
            List<AllowedValues> allowedValues, 

            
            String[] operations,
            
            String key,
            String name,
            Boolean required,
            Boolean hasDefaultValue
        ){
            
            this.allowedValues=allowedValues;
            if(this.allowedValues!=null && !this.allowedValues.isEmpty()){
                this.items=new List<SelectOption>();
                FOR(AllowedValues v:  this.allowedValues ){
                    system.debug(v.id);
                     system.debug(v.name);
                    this.items.add(new SelectOption(v.id, v.name!=null?v.name:v.value   ));
                }
            }
            this.schema=schema;
            this.operations=operations;
            this.hasDefaultValue=hasDefaultValue;
            this.key=key;
            this.name=name;
            this.required=required;
        }
    }
    public class AllowedValues{
        public String self{get;set;}
        public String id{get;set;}
        public String key{get;set;}
        public String name{get;set;}
        public String value{get;set;}
        
        public AllowedValues(String self,String id,String key,String name,String value){
            this.self=self;
            this.id=id;
            this.key=key;
            this.name=name;
            this.value=value;
            
        }
        
    }
    public class FieldSchema{
        public String fType      {get;set;}
        public String custom     {get;set;}
        public Integer customId  {get;set;} 
        public String fSystem    {get;set;}
        public String items      {get;set;}
        
        public FieldSchema(String fType, String items, String custom,Integer customId,String fSystem){
            this.fType=fType;
            this.items=items;            
            this.custom=custom;
            this.customId=customId;
            this.fSystem=fSystem;
        }
    }
    public class ScsIssueCreate{
        public String id;
        public String key;
        public String self;
    }
}