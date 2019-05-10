public class TFSQueueable implements Queueable,Database.AllowsCallouts {
    private List<Flosum__Metadata_Log__c> metadataLogs;
    private Type calloutType;
    private Boolean runOnce=false;
   private List<TFS_VersionControl.TFSCallout> bitc=new List<TFS_VersionControl.TFSCallout>();
    
    
    public TFSQueueable(List<Flosum__Metadata_Log__c> metadataLogs, Type calloutType){
        this.metadataLogs=metadataLogs;
        this.calloutType=calloutType;
   
    }
    
    public void buildData(){
        Set<id> depIds=new Set<id>();
        for(Flosum__Metadata_Log__c meta:this.metadataLogs){
            depIds.add(meta.Flosum__Patch__c);
        }
        system.debug(this.metadataLogs);
        Map<id,Flosum__Patch_Manifest__c> deploymentManifests = new Map<id,Flosum__Patch_Manifest__c>([SELECT 
                                                                                                       id ,
                                                                                                       Flosum__Patch__r.Name
                                                                                                       FROM Flosum__Patch_Manifest__c 
                                                                                                       WHERE Flosum__Patch__c IN:depIds ]);
        List<Attachment> depManAtt=new List<Attachment>([SELECT id, Name, Body,ParentId  FROM Attachment WHERE parentId IN: deploymentManifests.keySet()]);
        system.debug(depManAtt);
        Map<id,List<Attachment>> attsByLog=new Map<id,List<Attachment>>();
        for(Attachment att:depManAtt){
            system.debug(att);
            if(attsByLog.containsKey(att.ParentId)){
                List<Attachment> atts=attsByLog.get(att.ParentId);
                atts.add(att);
                attsByLog.put(att.ParentId,atts);
            }else{
                attsByLog.put(att.ParentId,new List<Attachment>{att});
            }
        }
        
        for(id logId:attsByLog.keySet()){
            List<Attachment> atts=attsByLog.get(logId);
            TFS_VersionControl.TFSCallout bitr = (TFS_VersionControl.TFSCallout)calloutType.newInstance(); 
            if(bitr instanceof TFS_VersionControl.ICommit){
                TFS_VersionControl.ICommit bitrc = (TFS_VersionControl.ICommit)bitr;
                bitrc.setData(atts, deploymentManifests.get(logId).Flosum__Patch__r.Name);
                this.bitc.add((TFS_VersionControl.TFSCallout)bitrc);
            }
            
        }    
    }
    
    public void execute(QueueableContext context) {
        if(!runOnce){
            buildData();   
        }

        if(this.bitc != null && !this.bitc.isEmpty()){
            this.bitc[0].doProcess();
            this.bitc.remove(0);
            if(!this.bitc.isEmpty()){
                 System.enqueueJob(new TFSQueueable(this.bitc,this.runOnce));
            }
        }
    }
    public TFSQueueable(List<TFS_VersionControl.TFSCallout> bitc, Boolean runOnce){
        this.bitc=bitc;
        
    }
    
    
}