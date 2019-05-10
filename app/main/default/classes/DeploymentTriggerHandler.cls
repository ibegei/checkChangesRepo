public class DeploymentTriggerHandler  extends SObjectDomain{
    
    public DeploymentTriggerHandler(List<SObject> records){

        super(records);
    }
    
    public override void onAfterInsert(){
        for(Flosum__Metadata_Log__c patch : (List<Flosum__Metadata_Log__c>)records) {
            if(patch.Bitbucket_Synchronize__c){         
                 system.debug(patch.Flosum__Status__c); 
                 system.debug(patch.Flosum__Succeed__c);
                 system.debug(patch.Flosum__Job_Completed__c);
                 system.debug(patch.Flosum__Async_Request_Id__c);
            }
        }
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        
        List<Flosum__Metadata_Log__c> completedDepId=new List<Flosum__Metadata_Log__c>();
        for(Flosum__Metadata_Log__c patch : (List<Flosum__Metadata_Log__c>)records) {
            if(patch.Bitbucket_Synchronize__c){         
                Flosum__Metadata_Log__c oldPatch = (Flosum__Metadata_Log__c)existingRecords.get(patch.Id);
                system.debug(patch.Flosum__Status__c); 
                 system.debug(patch.Flosum__Succeed__c);
                 system.debug(patch.Flosum__Job_Completed__c);
                 system.debug(patch.Flosum__Async_Request_Id__c);
                
                if(patch.Flosum__Job_Completed__c && oldPatch.Flosum__Job_Completed__c!=patch.Flosum__Job_Completed__c 
                  && (patch.Flosum__Process_Type__c=='Deployment' || patch.Flosum__Process_Type__c=='Rollback (Deployment)')
                  ){
                     system.debug(patch); 
                    completedDepId.add(patch);
                }
                
                
                
                
                if(!completedDepId.isEmpty()){
                    // System.enqueueJob(new TFSQueueable(completedDepId, TFS_VersionControl.TFSCommit.class));
                   
                    System.enqueueJob(new BitbucketQueueable(completedDepId, BitbucketRequest.BitbucketCommit.class));
                }
            }
        }
        

        
    }
    
        public class Constructor implements SObjectDomain.IConstructable{
            
        public SObjectDomain construct(List<SObject> sObjectList){
            
            return new DeploymentTriggerHandler(sObjectList);
        }
    }

}