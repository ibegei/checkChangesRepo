public class TFS_SearchWorkItemsController {
    public String searchStr{get;set;}
    public String  objId{get;set;}
    public List<searchRespLink> searchRespLinks{get;set;}
    public TFS_SearchWorkItemsController(){
        
        
        
        String  objId=   ApexPages.currentPage().getParameters().get('objId');
        system.debug(objId);
        
    }
            public  PageReference  cancel(){
      return  new PageReference('/'+ApexPages.currentPage().getParameters().get('objId'));

    }
    public void searchWI(){ 
        searchRespLinks=new List<searchRespLink>();
        system.debug(searchStr);
        String reqBody=
            '{'+
            '"searchText": "'+searchStr+'",'+
            ' "$skip": 0,'+
            ' "$top": 1000,'+
            '"filters": {'+
            '"System.TeamProject": ['+
            '  "test","flosum"'+
            ' ]'+
            
            ' },'+
            '"includeFacets": true'+
            '}';
        system.debug(reqBody);
        HttpResponse res=    TFSRequests.searchWorkItems('POST', 'https://almsearch.dev.azure.com/ibegei/_apis/search/workitemsearchresults?api-version=5.0-preview.1', reqBody);
        if(res.getStatusCode()==200){
            //  WorkItemSearchResults result=WorkItemSearchResults.parse(res.getBody());
            
            WorkItemSearchResults  searchResp=WorkItemSearchResults.parse(res.getBody());
            for(WorkItemSearchResults.results sres:searchResp.results){
                searchRespLinks.add(new SearchRespLink(sres,false));
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, res.getStatus()+'   '+res.getBody()));  
        }
        
    }
    public void linkToBranch(){
        
        set<Integer> linkedOrderIds=new Set<Integer>();
        
        for(SearchRespLink link:searchRespLinks){
            if(link.checked){
                system.debug(link.result.fields.system_id);
                linkedOrderIds.add(Integer.valueOf(link.result.fields.system_id));
                system.debug(objId);
                
                
                
            }
            List<Branch_Order__c> orders= new List<Branch_Order__c>([SELECT id, Order_ids__c FROM Branch_Order__c WHERE name=:ApexPages.currentPage().getParameters().get('objId')]);
            system.debug(orders);
            if(orders.isEmpty()){
                Branch_Order__c ord=new Branch_Order__c();
                ord.Name=objId;
                ord.Order_ids__c=  Json.serialize(linkedOrderIds);  
                insert ord;
            }else{
                Branch_Order__c   ord=orders.get(0);
                if(String.isEmpty(ord.Order_ids__c)){
                    ord.Order_ids__c=Json.serialize(linkedOrderIds);
                }else{
                    Set<Integer> ordIds=(Set<Integer>)Json.deserialize(ord.Order_ids__c,Set<Integer>.class);
                    ordIds.addAll(linkedOrderIds);
                    ord.Order_ids__c=Json.serialize(ordIds);
                    
                }
                update ord;
            } 
        }
    }
    public class SearchRespLink{
        public boolean checked{get;set;}
        public WorkItemSearchResults.Results result{get;set;}
        public SearchRespLink(WorkItemSearchResults.Results result, boolean checked){
            this.result=result;
            this.checked=checked;
        }
    }
    
    
}