public class fetchWorkItemsController {

    public TFS_FeatchWorkItems workItems{get;set;}
    public  Flosum__Branch__c branch;

   public Branch_Order__c orders{get;set;}
    public fetchWorkItemsController(ApexPages.StandardController stdController){
        this.branch = (Flosum__Branch__c)stdController.getRecord();

        
        getOrdersId();
        if(orders!=null && !String.isEmpty(orders.Order_ids__c)){

            List<Integer> ids=(List<Integer>)Json.deserialize(orders.Order_ids__c,List<Integer>.class);
            system.debug(ids);
            String   endpoin= 'https://dev.azure.com/ibegei/_apis/wit/workitems?ids='+ String.join(ids, ',')+'&$expand=all&api-version=5.0';
            
            
            HttpResponse res= TFSRequests.fetchWorkItems( 'GET',  endpoin);
            if(res!=null && res.getStatusCode()==200){
                workItems=TFS_FeatchWorkItems.parse(res.getBody());
            }
        }else{
            
        }
    }
    
    public void getOrdersId(){
       
String branchId=String.valueOf(branch.Id).substring(0, 15);
            try{
                orders=[SELECT id, Order_ids__c FROM Branch_Order__c WHERE name=:branchId];
            }catch(Exception e){
                system.debug(e.getMessage());
            }
            
      
    }
    
}