/**
* Created by SNEKKANTI00 on 11/06/2021.
*/

global with sharing class MockHttpResponseCitizenWallet implements HttpCalloutMock {
    
    private String responseOutcome;
    global MockHttpResponseCitizenWallet(String responseOutcome) {
        this.responseOutcome = responseOutcome;
    }
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('req.getEndpoint() ' + req.getEndpoint());
        HttpResponse res = new HttpResponse();
        res.setHeader('Accept', 'application/json');

        if(req.getEndpoint().containsIgnoreCase('WSO2')) {
            res.setBody(getJSONBodyWso2());
        } else if(req.getEndpoint().containsIgnoreCase('transactions')) {
            res.setBody(getJSONBodyTransactions());
            if(this.responseOutcome.equalsIgnoreCase('OK')) {
                res.setStatusCode(200);
            } else {
                res.setStatusCode(400);
            }
        } else {
            res.setBody(getJSONBodyCardInfo());
            if(this.responseOutcome.equalsIgnoreCase('OK')) {
                res.setStatusCode(200);
            } else {
                res.setStatusCode(400);
            }
        }
        return res;
    }

    private string getJSONBodyWso2() {

        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String json = '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';
        return json;
    }
    
    private string getJSONBodyCardInfo() {
        
        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String json;
        if(this.responseOutcome.equalsIgnoreCase('OK')) {
            json = '{"result": {"expiryDate": "2030-12-31T00:00:00","activationDate": "2020-09-08T16:01:33.41","serialNumber": "0280092416710000218857295764336494","webSerialNumber": "7041021037343944","issueDate": "2020-09-08T16:00:26.75","cardStatus": "Active","wallets": [{"walletID": 1,"name": "Currency piggy bank","description": "Currency piggy bank description","type": 20,"unit": 10,"supportsTransfer": true,"balance": {"value": 100.00},"referenceID": "93845180bffd496xa255f86fa3c5b6cc"}, {"walletID": 2,"name": "Currency piggy bank2","description": "Currency piggy bank description2","type": 20,"unit": 10,"supportsTransfer": true,"balance": {"value": 200.00},"referenceID": "93845180bffd496xa255f86fa3c5b6cc"}],"correlationReferenceID": "f59bddae15134c05a187042f8574381b"},"messages": [{"message": "Operation completed successfully","tags": []}]}';
        } else if(this.responseOutcome.equalsIgnoreCase('KO')) {
            json = '{"result": null,"messages": [{"errorCode": "3","reasons": [],"message": "Unable to find the Shop with the ID provided in input","tags": []}]}';
        } else {
            json = '<>';
        }
        return json;
    }

    private string getJSONBodyTransactions() {

        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String json;
        if(this.responseOutcome.equalsIgnoreCase('OK')) {
            json = '{"result": {"transactions": {"pageIndex": 1,"pageSize": 100,"totalPage": 1,"totalCount": 18,"totalUnfiltered": 0,"items": [{"transactionID": 838246,"value": 0.00,"amount": 0.00,"transactionDate": "2020-09-08T16:00:26.763","notes": "","transactionStatus": 4,"transactionType": 1,"authorizationCode": "00000000000","piggyBankID": 1,"piggyBankName": "Currency piggy bank","piggyBankDescription": " Currency piggy bank description","receipt": "","externalTxID": "","shop": "DEFAULT_SHOP","terminal": "DEFAULT_TERM","correlationReferenceId": "98c13482b9ee42c0a0ee0b088fae354d","referenceId": "b12d35311b7e138b9b343c317b1e2c76"},{"transactionID": 839679,"value": 50.00,"amount": 50.00,"transactionDate": "2020-09-14T12:22:27.853","notes": "Membership purchase","transactionStatus": 4,"transactionType": 41,"authorizationCode": "00000000000","piggyBankID": 2,"piggyBankName": "Membership piggy bank","piggyBankDescription": "Membership piggy bank description","receipt": "","externalTxID": "","shop": "POS_1","terminal": "TERM_1","correlationReferenceId": "x4d32ecc772943de9eb1ddf222add7e8","referenceId": "d833747cer604e00901519a7188de539"}]},"expiryDate": "2030-12-31T00:00:00","activationDate": "2020-09-08T16:01:33.41","serialNumber": "0280092416710000218857295764336494","webSerialNumber": "7041021037343944","issueDate": "2020-09-08T16:00:26.75","cardStatus": "Active","wallets": [],"correlationReferenceID": null},"messages": [{"message": "Operation completed successfully","tags": []}]}';
        } else if(this.responseOutcome.equalsIgnoreCase('KO')) {
            json = '{"result": null,"messages": [{"errorCode": "3","reasons": [],"message": "Unable to find the Shop with the ID provided in input","tags": []}]}';
        } else {
            json = '<>';
        }
        return json;
    }
}