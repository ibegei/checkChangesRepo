public class BitbucketQueueable implements Queueable,Database.AllowsCallouts {
    private List<Flosum__Metadata_Log__c> metadataLogs;
    private Type calloutType;
    private Boolean runOnce;
   private List<BitbucketRequest.BitbucketCallout> bitc=new List<BitbucketRequest.BitbucketCallout>();
    
    
    public BitbucketQueueable(List<Flosum__Metadata_Log__c> metadataLogs, Type calloutType){
        runOnce=false;
        this.metadataLogs=metadataLogs;
        this.calloutType=calloutType;
   
    }
    
    public void buildData(){

        	Set<id> depIds=new Set<id>();
            Set<id> RollbackIds=new Set<id>();
        for(Flosum__Metadata_Log__c meta:this.metadataLogs){
            if(meta.Flosum__Process_Type__c=='Deployment'){
                 depIds.add(meta.Flosum__Patch__c);
            }else if(meta.Flosum__Process_Type__c=='Rollback (Deployment)'){
                RollbackIds.add(meta.Flosum__Patch__c);
            }
           
           	
        }
         system.debug(this.metadataLogs);

        Map<id,Flosum__Patch__c> RollbackManifests = new Map<id,Flosum__Patch__c>([SELECT 
                                                                                   id ,
                                                                                   Name
                                                                                   FROM Flosum__Patch__c 
                                                                                   WHERE id IN:RollbackIds ]); 

        
        List<Attachment> RollbackAtt=new List<Attachment>([SELECT id, Name, Body,ParentId,CreatedDate  FROM Attachment WHERE parentId IN: RollbackManifests.keySet() AND Name='Rollback' ORDER BY CreatedDate ASC]); 

        
 		Map<id,Attachment> RollbAttsByLog=new Map<id,Attachment>();

        for(Attachment a:RollbackAtt){
            RollbAttsByLog.put(a.ParentId, a);
        }

		system.debug('@@@ RollbAttsByLog');
        system.debug(RollbAttsByLog);
        
        
        for(id logId:RollbAttsByLog.keySet()){
            system.debug(logId);
            Attachment atts=RollbAttsByLog.get(logId);
            BitbucketRequest.BitbucketCallout bitr = (BitbucketRequest.BitbucketCallout)calloutType.newInstance(); 
            if(bitr instanceof BitbucketRequest.ICommit){
                system.debug('instanceof BitbucketRequest.ICommit');
                BitbucketRequest.ICommit bitrc = (BitbucketRequest.ICommit)bitr;
              
                    bitrc.setData(new List<Attachment>{atts}, RollbackManifests.get(logId).Name+' Rollback');

             
                this.bitc.add((BitbucketRequest.BitbucketCallout)bitrc);
                  system.debug((BitbucketRequest.BitbucketCallout)bitrc);
            }
            
        }  
        

        
        Map<id,Flosum__Patch_Manifest__c> deploymentManifests = new Map<id,Flosum__Patch_Manifest__c>([SELECT 
                                                                                                       id ,
                                                                                                       Flosum__Patch__c,
                                                                                                       Flosum__Patch__r.Name
                                                                                                       FROM Flosum__Patch_Manifest__c 
                                                                                                       WHERE Flosum__Patch__c IN:depIds ]);
        
        system.debug('@@@ deploymentManifests');
        system.debug(deploymentManifests);
        
        Map<id,List<Flosum__Patch_Manifest__c>> manByPatch=new  Map<id,List<Flosum__Patch_Manifest__c>>();
        for(Flosum__Patch_Manifest__c pm:deploymentManifests.values()){
            if(manByPatch.containsKey(pm.Flosum__Patch__c)){
                List<Flosum__Patch_Manifest__c> m=manByPatch.get(pm.Flosum__Patch__c);
                m.add(pm);
                manByPatch.put(pm.Flosum__Patch__c,m);
            }else{
                manByPatch.put(pm.Flosum__Patch__c,new List<Flosum__Patch_Manifest__c>{pm});
            }
        }
        
        
        
      List<Attachment> depManAtt=new List<Attachment>([SELECT id, Name, Body,ParentId  FROM Attachment WHERE parentId IN: deploymentManifests.keySet()]);  
        map<id, Attachment> depAttToParrent = new map <id, Attachment> ();
        
        for(Attachment att : depManAtt){
            depAttToParrent.put(att.ParentId, att);
        }
        
        
        Map<id,List<Attachment>> attsByLog=new Map<id,List<Attachment>>();
        for(id parentId : manByPatch.keySet()){
            for(Flosum__Patch_Manifest__c fpm : manByPatch.get(parentId)){
                if(depAttToParrent.containsKey(fpm.id)){
                    system.debug(parentId);
                    system.debug(depAttToParrent.get(fpm.id));
                    if(attsByLog.containsKey(parentId)){
                     attsByLog.get(parentId).add(depAttToParrent.get(fpm.id));
                 }else{
                     attsByLog.put(parentId , new List <Attachment> {depAttToParrent.get(fpm.id)});
                 }
                }
            }
        }
   

        for(id logId:attsByLog.keySet()){
            List<Attachment> atts=attsByLog.get(logId);
            BitbucketRequest.BitbucketCallout bitr = (BitbucketRequest.BitbucketCallout)calloutType.newInstance(); 
            if(bitr instanceof BitbucketRequest.ICommit){
                BitbucketRequest.ICommit bitrc = (BitbucketRequest.ICommit)bitr;
                String name = '---';
                for(Flosum__Patch_Manifest__c dm: deploymentManifests.values()){
                    if(dm.Flosum__Patch__c==logId){
                        name = dm.Flosum__Patch__r.Name;
                        
                    }
                    
                }
                      bitrc.setData(atts, name);

             
                this.bitc.add((BitbucketRequest.BitbucketCallout)bitrc);
            }
            
        }    
   
    }
    
    public void execute(QueueableContext context) {     
        if(!runOnce){
            buildData();   
        }
       system.debug(this.bitc);
        if(this.bitc != null && !this.bitc.isEmpty()){
            system.debug('this.bitc != null');
            this.bitc[0].doProcess();
           system.debug('@@ process');
            this.bitc.remove(0);
            if(!this.bitc.isEmpty()){
                 System.enqueueJob(new BitbucketQueueable(this.bitc,this.runOnce));
            }
        }
    }
    public BitbucketQueueable(List<BitbucketRequest.BitbucketCallout> bitc, Boolean runOnce){
        this.bitc=bitc;
        this.runOnce = true;
        
    }
    
    
}