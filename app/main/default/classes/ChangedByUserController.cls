public class ChangedByUserController {
	@AuraEnabled
	public static String getDetails(Id recordId) {
        Map<String,Integer> detailMap = new Map<String,Integer>();
        List<AggregateResult> patchApp = [Select count(id),Flosum__Developer__c From Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId Group By Flosum__Developer__c ];
        for(AggregateResult agg : patchApp){
            String userName = String.valueOf(agg.get('Flosum__Developer__c'));
            Integer deploymentCount = Integer.valueOf(agg.get('expr0'));
            detailMap.put(userName,deploymentCount);
        }
        System.debug(detailMap);
        string detailString = JSON.serialize(detailMap);
        System.debug(detailString);
   		return detailString;
	}
}