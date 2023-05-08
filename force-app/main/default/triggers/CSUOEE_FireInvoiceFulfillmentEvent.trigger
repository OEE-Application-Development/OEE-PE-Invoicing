trigger CSUOEE_FireInvoiceFulfillmentEvent on lms_hed__LMS_Course_Enrollment__c (after insert) {
    List<csuoee__Record_Create__e> creates = new List<csuoee__Record_Create__e>();
    // Reduce queries by mapping
    Set<Id> lmsAccountIds = new Set<Id>();
    Set<Id> offeringIds = new Set<Id>();

    for(lms_hed__LMS_Course_Enrollment__c enrollment : (List<lms_hed__LMS_Course_Enrollment__c>)Trigger.new) {
        lmsAccountIds.add(enrollment.lms_hed__LMS_Account__c);
        offeringIds.add(enrollment.lms_hed__Course_Offering__c);
    }

    Map<Id, String> lmsAccountToNCIdMap = new Map<Id, String>();
    for(lms_hed__LMS_Account__c acct : (List<lms_hed__LMS_Account__c>) [select Id, csuoee__Noncredit_ID__c from lms_hed__LMS_Account__c where Id in :lmsAccountIds]) {
        lmsAccountToNCIdMap.put(acct.Id, acct.csuoee__Noncredit_ID__c);
    }

    Map<Id, String> offeringRefMap = new Map<Id, String>();
    for(hed__Course_Offering__c offering :[select Id, lms_hed__LMS_Reference_Code__c from hed__Course_Offering__c where Id in :offeringIds]) {
        offeringRefMap.put(offering.Id, offering.lms_hed__LMS_Reference_Code__c);
    }

    for(lms_hed__LMS_Course_Enrollment__c enrollment : (List<lms_hed__LMS_Course_Enrollment__c>)Trigger.new) {
        String ncId = lmsAccountToNCIdMap.get(enrollment.lms_hed__LMS_Account__c);
        if(ncId == null) continue;
        String ref = offeringRefMap.get(enrollment.lms_hed__Course_Offering__c);
        if(ref == null) continue;

        creates.add(new csuoee__Record_Create__e(
                csuoee__Object_Type__c = 'csuoee__Noncredit_Invoice_Line_Item__c', 
                csuoee__IdOrExternalId1__c = ncId,
                csuoee__IdOrExternalId2__c = ref,
                csuoee__JsonValue__c = JSON.serialize(enrollment, true)));
    }

    EventBus.publish(creates);
}