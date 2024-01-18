global with sharing class MiddlewareActionTxResponse {
    global Boolean success;
    global String message;
    global List<MiddlewareTransactionResponse> data;
    global Integer httpStatus;

    public MiddlewareActionTxResponse(){}
    public MiddlewareActionTxResponse(Boolean success, String message, List<MiddlewareTransactionResponse> data) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.httpStatus = httpStatus;
    }
}