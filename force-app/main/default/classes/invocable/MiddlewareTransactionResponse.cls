global with sharing class MiddlewareTransactionResponse {
    global String invoiceNumber;
    global String paymentType;
    global String csuTransId;
    global String processorTransId;
    global String processorTransStatus;
    global Decimal amount;

    global Boolean isSuccessful;
    global Boolean isActual;
    global Datetime postedAt;

    global String failureReason;
}