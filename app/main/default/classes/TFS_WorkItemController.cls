public class TFS_WorkItemController {
    public List<SelectOption> selectList  { get; set; }
    public List<SelectOption> projectList { get; set; }
    public TFS_WorkItemController(){
        wItem=new WorkItem();
        selectList = new List<selectOption>(); 
        selectList.add(new SelectOption('Bug', 'Bug'));
        selectList.add(new SelectOption('Epic', 'Epic'));
        selectList.add(new SelectOption('Feature', 'Feature'));
        selectList.add(new SelectOption('Issue', 'Issue'));
        selectList.add(new SelectOption('Task', 'Task'));
        projectList=new List<selectOption>(); 
        projectList.add(new SelectOption('test', 'test'));
        projectList.add(new SelectOption('flosum', 'flosum'));
    }
    public WorkItem wItem{get;set;}
    
    public pageReference saveWI(){
        String body=      
            '['+
            ' {'+
            '"op": "add",'+
            '"path": "/fields/System.Title",'+
            ' "from": null,'+
            ' "value": "'+wItem.title+'"'+
            ' },'+
            '{'+
            ' "op": "add",'+
            ' "path": "/fields/System.Description",'+
            ' "from": null,'+
            '"value": "'+wItem.description+'"'+
            ' }'+
            
            ']';
        
        
        
        HttpResponse res=    TFSRequests.createWorkItems('POST','/ibegei/test/_apis/wit/workitems/$'+wItem.name+'?api-version=5.0',body);
        

        if(res.getStatusCode()==200){
              WorkItemCreateResp resp=WorkItemCreateResp.parse(res.getBody());
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Work Item created. '+resp.x_links.html.href)); 
              String  objId=   ApexPages.currentPage().getParameters().get('id');
        List<Branch_Order__c> orders= new List<Branch_Order__c>([SELECT id, Order_ids__c FROM Branch_Order__c WHERE name=:objId]);
            if(orders.isEmpty()){
                Branch_Order__c ord=new Branch_Order__c();
                ord.Name=objId;
                ord.Order_ids__c=  Json.serialize(new List<Integer>{resp.id});  
                insert ord;
            }else{
             Branch_Order__c   ord=orders.get(0);
                if(String.isEmpty(ord.Order_ids__c)){
                    ord.Order_ids__c=Json.serialize(new List<Integer>{resp.id});
                }else{
                    Set<Integer> ordIds=(Set<Integer>)Json.deserialize(ord.Order_ids__c,Set<Integer>.class);
                    ordIds.add(Integer.valueOf(resp.id));
                    ord.Order_ids__c=Json.serialize(ordIds);
                    
                }
                update ord;
            }
            
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, res.getStatus()+'   '+res.getBody()));  
        }
      
    
        return null;
    }
    public class WorkItem{
        public  String project {get;set;}
        public  String name{get;set;}
        public  String title{get;set;}
        public  String description{get;set;}
        
    }
    
}