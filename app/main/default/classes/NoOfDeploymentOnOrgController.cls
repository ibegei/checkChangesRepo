public class NoOfDeploymentOnOrgController {
	@AuraEnabled
	public static String getDetails(Id recordId) {
        Map<String,Integer> detailMap = new Map<String,Integer>();
        List<AggregateResult> patchApp = [SELECT count(Id),Flosum__Org__r.Name from Flosum__Patch_Application__c where Flosum__Patch__c =: recordId GROUP BY Flosum__Org__r.Name];
        for(AggregateResult agg : patchApp){
            String userName = String.valueOf(agg.get('Name'));
            Integer deploymentCount = Integer.valueOf(agg.get('expr0'));
            detailMap.put(userName,deploymentCount);
        }
   		string detailString = JSON.serialize(detailMap);
        System.debug(detailString);
   		return detailString;
	}
}