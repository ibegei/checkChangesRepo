public class TotalNumberOfMetadataTypeController {
	@AuraEnabled
	public static String getDetails(Id recordId) {
        System.debug('recordId---'+recordId);
        Set<String> metadataSet = new Set<String>{'ApexClass','ApexTrigger','ApexPage','CustomObject','Report','CustomLabels','Workflow','RecordType'};
        Map<String,Integer> detailMap = new Map<String,Integer>();
       	Integer apexClassList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'ApexClass'];
        Integer apexPageList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'ApexPage' ];
        Integer customObjectList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'CustomObject' ];
        Integer apexTriggerList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'ApexTrigger' ];
        Integer customLabelsList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'CustomLabels' ];
        Integer workflowList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'Workflow' ];
        Integer recordTypeList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'RecordType' ];
        Integer reportList =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c = 'Report'];
        Integer otherMetadataTypeList  =  [Select count() From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId and Flosum__Component_Type__c Not IN : metadataSet ];
        if(apexClassList != null){
            detailMap.put('ApexClass',apexClassList);
        }
        if(apexPageList != null){
            detailMap.put('ApexPage',apexPageList);
        }
        if(customObjectList != null){
            detailMap.put('CustomObject',customObjectList);
        }
        if(apexTriggerList != null){
            detailMap.put('ApexTrigger',apexTriggerList);
        }if(customLabelsList != null){
            detailMap.put('CustomLabels',customLabelsList);
        }
        if(workflowList != null){
            detailMap.put('Workflow',workflowList);
        }if(recordTypeList != null){
            detailMap.put('RecordType',recordTypeList);
        }
        if(reportList != null){
            detailMap.put('Report',reportList);
        }
        if(otherMetadataTypeList != null){
            detailMap.put('Other',otherMetadataTypeList);
        }
       	string detailString = JSON.serialize(detailMap);
   		return detailString;
    }
}