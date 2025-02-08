/**
* The Class XC_LCC007_CheckFlagEmployee.
*
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Modification 10_10_2018 by Riccardo Cossu - riccardo.cossu@nttdata.com
* @date Modification 24/10/2018 by Fabrizio Antonioli - Fabrizio.Antonioli@nttdata.com & Giovanni Schioppa - Giovanni.Schioppa@nttdata.com
* @date Modification 31/10/2018 by Federico Amici - federico.amici@nttdata.com, Added the wrapper containing the fields returned by the callout
* @description XC_LCC006_AccountBlacklistCheck – STUB Controller for XC_LCP006_AccountBlacklistCheck Component
*/
public without sharing class XC_LCC007_CheckFlagEmployee {

     /**
     * @description The Class responseWrapper.
     */
public class responseWrapper{
    /** @description The resultWrapper */
    @AuraEnabled
    public resultWrapper result {get; set;} 
    /** @description The employeeWrapper */
    @AuraEnabled 
    public employeeWrapper employee {get; set;} 
    
}
    /**
     * @description The Class resultWrapper.
     */
public class resultWrapper{
     /** @description The errorCode */
     @AuraEnabled
    public String errorCode {get; set;} 
     /** @description The message */
     @AuraEnabled
    public String message {get; set;} 
}
     /**
     * @description The Class employeeWrapper.
     */
public class employeeWrapper{
    /** @description The personID */
     @AuraEnabled
    public integer personID {get; set;} 
    /** @description The personNumber */
     @AuraEnabled
    public integer personNumber {get; set;} 
    /** @description firstName */
     @AuraEnabled
    public String firstName {get; set;} 
    /** @description lastName */
     @AuraEnabled
    public String lastName {get; set;} 

}



/**
 * 
 * @description Retrieve account.
 * @param recordId the record id
 * @return the account
 
*/
@AuraEnabled
public static Account retrieveAccount(String recordId){
    
    String query = 'SELECT Id, XC_Employee_Id__c, XC_isEmployee__c, Account_Type__c FROM Account WHERE Id=:recordId';
    return (Account)Database.query(query)[0];  
}

/**
 * 
 * @description Update account.
 * @param acc the acc
 
*/
@AuraEnabled
public static void updateAccount(Account acc){

    
    acc.XC_isEmployee__c = true;
    acc.XC_Employee_Id__c = acc.id;

    XC_UTIL_Sobject.updateRecord(acc);

}


/**
 * 
 * @description Call external system.
 * @param recordId the record id
 * @return the result wrapper
 
*/
@AuraEnabled
public static XC_UTIL_ResultWrapper callExternalSystem(Id recordId){
    XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
    Account a = retrieveAccount(recordId);
    result.success=false; 
    //NEW
    
    if (!a.XC_isEmployee__c) {
    Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface('CheckFlagEmployee');
        if(activeInterface){                
            String url = '';
            String requestString = '';
            HttpRequest request = XC_UTIL_RESTCallout.createRequest(url, requestString);
            HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request,'XC_LCC007_CheckFlagEmployee');
            result = manageResponse(response); 
        } else {
            updateAccount(a);
            String fakeResponse = 'The account isn\'t in the blacklist. ';
            result = manageResponseFake(fakeResponse);

        }
        
    } else{
        result.resultMessage = System.Label.XC_CL_Account_CantEditEmployeeId;
    }
    return result;
}



/**
 * 
 * @description Manage response fake.
 * @param fakeResponse the fake response
 * @return the result wrapper
 
*/
@TestVisible
private static XC_UTIL_ResultWrapper manageResponseFake(String fakeResponse){
    XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
    
    result.success = true;
    result.resultMessage=fakeResponse;

    return result;
}

/**
 * @description Manage response.
 * @param response the response
 * @return the result wrapper
 
*/
private static XC_UTIL_ResultWrapper manageResponse(HttpResponse response){
    XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
    result.success=true;
    return result;
}


/*
@AuraEnabled
public static void updateRecord(Id recordId, String newID){
    list<Account> account = [SELECT Id, XC_Employee_Id__C from Account WHERE ID =:recordId Limit 1];
    if(account.get(0) != null)
        account.get(0).XC_Employee_Id__c = newID;

    update account.get(0);
}

// Get the value on the checkList field of the account and fill it with the external call.
public static list<Account> checklistValue(Id recordId){
    list<Account> accountchecklist = [SELECT Id, XC_Notes__c from Account WHERE ID =:recordId Limit 1];
    if(accountchecklist.size() > 0) {
        return accountchecklist; 
    }
    else return null;
}

*/
}