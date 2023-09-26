global with sharing class GetLineItemData {

    @InvocableMethod(Label='Get Line Item LMS Data' Description='Get LMS data Map (offeringId, lmsAccountId, lmsCourseTermId)')
    global static List<LineItemDataResponse> getLineItemData(List<LineItemDataRequest> requests) {
        List<LineItemDataResponse> results = new List<LineItemDataResponse>();
        for(LineItemDataRequest request : requests) {
            Map<String, Object> dataMap = LineItemButtonHandler.getLineItemData(request.lineItemId);

            results.add(new LineItemDataResponse((Id)dataMap.get('offeringId'), (Id)dataMap.get('lmsAccountId'), (Id)dataMap.get('lmsCourseTermId')));
        }
        return results;
    }

    global class LineItemDataRequest {
        @InvocableVariable(Required=true Description='Id of the Line Item to get LMS data for.')
        global Id lineItemId;
    }

    global class LineItemDataResponse {

        @InvocableVariable
        global Id offeringId;
        @InvocableVariable
        global Id lmsAccountId;
        @InvocableVariable
        global Id lmsCourseTermId;

        public LineItemDataResponse(){}
        public LineItemDataResponse(Id offeringId, Id lmsAccountId, Id lmsCourseTermId) {
            this.offeringId = offeringId;
            this.lmsAccountId = lmsAccountId;
            this.lmsCourseTermId = lmsCourseTermId;
        }

    }
    
}