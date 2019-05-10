public class OrgDeploymentDetailController {
	@AuraEnabled
	public static String getDetails(Id recordId) {
        Map<String,Integer> tempMap = new Map<String,Integer>();
        List<AggregateResult> patchApp = [SELECT count(Id),Flosum__User__r.name from Flosum__Patch_Application__c where Flosum__Org__c =: recordId GROUP BY Flosum__User__r.name];
        for(AggregateResult agg : patchApp){
            String userName = String.valueOf(agg.get('Name'));
            Integer deploymentCount = Integer.valueOf(agg.get('expr0'));
            tempMap.put(userName,deploymentCount);
        }
        string detailString = JSON.serialize(tempMap);
        System.debug(detailString);
   		return detailString;
	}
}