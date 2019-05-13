trigger MetadataLogTrigger on Flosum__Metadata_Log__c (after insert , after update) {

    SObjectDomain.triggerHandler(DeploymentTriggerHandler.class);
}
