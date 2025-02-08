/**
 * The Class XC_UTIL_RESTInbound.
 *
 * @author            : Federico Amici - federico.amici@nttdata.com
 * @date Creation     : 27/12/2018
 * @date Modification : dd/mm/yyyy
 * @description       : Util class for handling REST inbound
 **/ 


public class XC_UTIL_RESTInbound {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_RESTInbound');

    /** 
     * CheckHeader.
     *
     * @param mapParameters tha parameters map
     * @return the wrapper result
     * @description method to check the required parameters of header
     */
    public static XC_UTIL_Integration.WrapperResult checkHeader(Map<String, String> mapParameters) {
   
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();

        if(String.isBlank(mapParameters.get('TransactionID'))) {
            wr.errorMessage = 'Missing field: TransactionID';
            wr.errorFlag = true;
            return wr;
        }

        if(String.isBlank(mapParameters.get('DateTimeMessage'))) {
            wr.errorMessage = 'Missing field: DateTimeMessage';
            wr.errorFlag = true;
            return wr;
        }

        if(String.isBlank(mapParameters.get('Operation'))) {
            wr.errorMessage = 'Missing field: Operation';
            wr.errorFlag = true;
            return wr;
        }
        
        if(String.isBlank(mapParameters.get('Functionality'))) {
            wr.errorMessage = 'Missing field: Functionality';
            wr.errorFlag = true;
            return wr;
        }

        if(String.isBlank(mapParameters.get('ClientSystem'))) {
            wr.errorMessage = 'Missing field: ClientSystem';
            wr.errorFlag = true;
            return wr;
        }

        if(String.isBlank(mapParameters.get('ServerSystem'))) {
            wr.errorMessage = 'Missing field: ServerSystem';
            wr.errorFlag = true;
            return wr;
        }

        return wr;
    }


    /** 
     * GetIntegrationHeader.
     *
     * @param mapParameters tha parameters map
     * @return the header
     * @description method to set che header wrapper
     */
    public static XC_UTIL_Integration.Header getIntegrationHeader(Map<String, String> mapParameters) {

        XC_UTIL_Integration.Header header = new XC_UTIL_Integration.Header();

        header.TransactionID = mapParameters.get('TransactionID');
        header.DateTimeMessage = Datetime.valueOf(mapParameters.get('DateTimeMessage'));
        header.Operation = mapParameters.get('Operation');
        header.Functionality = mapParameters.get('Functionality');
        header.ClientSystem = mapParameters.get('ClientSystem');
        header.ServerSystem = mapParameters.get('ServerSystem');

        return header;

    }
	
    
    /** 
     * IsDateValid.
     *
     * @param dateValue the string of date
     * @return boolean for correct format of date
     * @description the method verifies that the dateValue argument is formatted as YYYY-MM-DD HH:mm:ss OR YYYY-MM-DDTHH:mm:ss
     */
    public static Boolean isDateValid(String dateValue){
        try{
           String[] elements = dateValue.split('-');
            if(elements.size() != 3){
                return false;
            }
            
            if(elements[0].length() != 4 || elements[1].length() != 2 || elements[2].length() != 2){
                return false;
            }
            
            Integer y = Integer.valueOf(elements[0]);
            Integer d = Integer.valueOf(elements[1]);
            Integer m = Integer.valueOf(elements[2]);
            
            return true;

        }catch(Exception e){
           System.debug('error parsing date value' + e);
           return false;
        }
    }


    /** 
     * CheckDate.
     *
     * @param dateValue the string of date
     * @return boolean for correct format of date
     * @description the method verifies that the dateValue argument is formatted as YYYY-MM-DD HH:mm:ss OR YYYY-MM-DDTHH:mm:ss
     */
    public static Boolean checkDate(String dateValue){
        
        Pattern patternCompile = Pattern.compile('(20|19)([0-9][0-9])([-])([0][0-9]|[1][0-2])([-])([012][0-9]|3[01])([\\s | T])([01][0-9]|2[0-3])([:])([0-5][0-9])([:])([0-5][0-9])(([.][0-9][0-9][0-9])?)');//[TP - 2021.12.18 - TPB substitution first 4 digit regex - old (2[0-9][0-9][0-9])]
        Pattern shortPatternCompile = Pattern.compile('(20|19)([0-9][0-9])([-])([0][0-9]|1[0-2])([-])([012][0-9]|3[01])');

        // Then instantiate a new Matcher object "MyMatcher"
        Matcher matcherPattern = patternCompile.matcher(dateValue);
        Matcher matcherShortPattern = shortPatternCompile.matcher(dateValue);
        
        return (matcherPattern.matches() || matcherShortPattern.matches()) ;

    }

    
    /** 
     * CheckDateISO.
     *
     * @param dateValue the string of date
     * @return boolean for correct format of date
     * @description the method verifies that the dateValue argument is formatted as YYYY-MM-DD HH:mm:ss OR YYYY-MM-DDTHH:mm:ss
     */
    public static Boolean checkDateISO(String dateValue){
        
        Pattern patternCompile = Pattern.compile('(20[0-9][0-9])([-])([0][0-9]|[1][0-2])([-])([012][0-9]|3[01])([\\s | T])([01][0-9]|2[0-3])([:])([0-5][0-9])([:])([0-5][0-9])([.])([0-9][0-9][0-9])');

        // Then instantiate a new Matcher object "MyMatcher"
        Matcher matcherPattern = patternCompile.matcher(dateValue);
        
        return (matcherPattern.matches()) ;

    }

    
	/**
     * checkPermissionOnObject
     * @description Check if the current user can execute a specific dml operation on a given object.
     * @param objectName the object api name 
     * @param operation the dml operation ('read', 'create', 'update')
     * @return true if the operation is permitted
     * @author Simone Trenta - strenta@deloitte.it
     */
    public static XC_UTIL_Integration.WrapperResult checkObjectPermission(String objectName, String operation){
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        Boolean permitted = false;
        SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        
        switch on operation {
            when 'read' {  
                permitted = sObjectType.getDescribe().isAccessible();
            } 
            when 'create' {
                permitted = sObjectType.getDescribe().isCreateable();
            } 
            when 'update' { 
                permitted = sObjectType.getDescribe().isUpdateable();
            } 
            when else { 
                permitted = false;
            }
        }

        if(!permitted){
            wr.errorMessage = 'Operation not allowed';
            wr.errorFlag = true;
            return wr;
        } 
        
        return wr;
    }

	/**
     * WSO2AuthCheck
     * @description Check if the current user can execute an operation on a given account or lead.
     * @param iDfield account or lead id
     * @param header the header
     * @return true if the operation is permitted
     * @author Simone Trenta - strenta@deloitte.it
     */
    public static XC_UTIL_Integration.WrapperResult wso2AuthCheck(String iDfield, Map<String,String> header){
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();  
        Map<String,String> fieldToCheck = getCheckFields(iDfield);
        
        if(fieldToCheck==null){
            wr.errorMessage = 'Object not found: '+iDfield;
            wr.errorFlag = true;
            wr.errorCode = '400';
            return wr;
        }

        Boolean filledUniqueId = String.isNotBlank(header.get('X-UniqueID'));
        Boolean sameUniqueId = fieldToCheck.get('X-UniqueID')==header.get('X-UniqueID');
        Boolean filledEmailAndPhone = (String.isNotBlank(header.get('X-EmailAddress'))&&String.isNotBlank(header.get('X-Mobile')));
        Boolean sameEmailAndPhone = fieldToCheck.get('X-Mobile')==header.get('X-Mobile')&&fieldToCheck.get('X-EmailAddress')==header.get('X-EmailAddress');
        Boolean differentEmailAndPhone = fieldToCheck.get('X-Mobile')!=header.get('X-Mobile')&&fieldToCheck.get('X-EmailAddress')!=header.get('X-EmailAddress');
        Boolean filledEmail = (String.isNotBlank(header.get('X-EmailAddress'))&&String.isBlank(header.get('X-Mobile')));
        Boolean sameEmail = fieldToCheck.get('X-EmailAddress')==header.get('X-EmailAddress');
        Boolean filledPhone = (String.isNotBlank(header.get('X-Mobile'))&&String.isBlank(header.get('X-EmailAddress')));
        Boolean samePhone = fieldToCheck.get('X-Mobile')==header.get('X-Mobile');
   
        if( filledUniqueId && sameUniqueId ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'same uniqueId');
            wr.errorMessage = 'Authenticated and Authorized';
            wr.errorFlag = false;
            wr.errorCode = '200';
            return wr;
        }

        if( (filledEmailAndPhone && sameEmailAndPhone) || (filledEmail && sameEmail) || (filledPhone && samePhone) || (filledEmailAndPhone && (sameEmail||samePhone) && !moreThanOneWithKeys(fieldToCheck, header)) ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledEmailAndPhone && sameEmailAndPhone: '+(filledEmailAndPhone && sameEmailAndPhone));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledEmail && sameEmail: '+(filledEmail && sameEmail));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledPhone && samePhone: '+(filledPhone && samePhone));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledEmailAndPhone && (sameEmail||samePhone): '+(filledEmailAndPhone && (sameEmail||samePhone))); 

            return updateUniqueId(fieldToCheck.get('Id'), fieldToCheck.get('Entity'), header.get('X-UniqueID'));

        } else if( (filledEmailAndPhone && differentEmailAndPhone) || (filledEmail && !sameEmail) || (filledPhone && !samePhone) || (!filledPhone && !filledEmail && !filledEmailAndPhone) ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledEmailAndPhone && differentEmailAndPhone: '+(filledEmailAndPhone && differentEmailAndPhone));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledEmail && !sameEmail: '+(filledEmail && !sameEmail));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledPhone && !samePhone: '+(filledPhone && !samePhone));
            XC_UTIL_Debug.debug(DEBUGACTIVE, '!filledPhone && !filledEmail && !filledEmailAndPhone: '+(!filledPhone && !filledEmail && !filledEmailAndPhone));
            
            wr.errorMessage = 'Authentication failed';
            wr.errorFlag = true;
            wr.errorCode = '401';
            return wr;

        } else if( filledEmailAndPhone && moreThanOneWithKeys(fieldToCheck, header)){ 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'filledEmailAndPhone: '+(filledEmailAndPhone));

            wr.errorMessage = 'Authentication failed';
            wr.errorFlag = true;
            wr.errorCode = '402';
            return wr;

        }
        
        return wr;
    }

    private static Map<String,String> getCheckFields(String iDfield){
        Map<String,String> fieldToCheck = new Map<String,String>();

        if(((id)iDfield).getSobjectType().getDescribe().getName() == 'Account'){
            Map<Id,Account> mapAcc = new Map<Id,Account>([
                SELECT Id, PrimaryEmail__c, XC_UniqueId__c, XC_AccountPhone__c 
                FROM Account
                WHERE Id =: iDfield
            ]);
            
            if(mapAcc.values().isEmpty()){
                return null;
            }
            
            Account accToCheck = mapAcc.values()[0];
            fieldToCheck.put('X-UniqueID',accToCheck.XC_UniqueId__c);
            fieldToCheck.put('X-EmailAddress',accToCheck.PrimaryEmail__c);
            fieldToCheck.put('X-Mobile',accToCheck.XC_AccountPhone__c);
            fieldToCheck.put('Entity','Account');
            fieldToCheck.put('Id',accToCheck.Id);

        } else if(((id)iDfield).getSobjectType().getDescribe().getName() == 'Lead'){
            Map<Id,Lead> mapLead = new Map<Id,Lead>([
                SELECT Id, XC_UniqueId__c, Email, Phone
                FROM Lead
                WHERE Id =: iDfield
            ]);
            
            if(mapLead.values().isEmpty()){
                return null;
            }
            
            Lead leadToCheck = mapLead.values()[0];
            fieldToCheck.put('X-UniqueID',leadToCheck.XC_UniqueId__c);
            fieldToCheck.put('X-EmailAddress',leadToCheck.Email);
            fieldToCheck.put('X-Mobile',leadToCheck.Phone);
            fieldToCheck.put('Entity','Lead');
            fieldToCheck.put('Id',leadToCheck.Id);

        } else if(((id)iDfield).getSobjectType().getDescribe().getName() == 'NE__Order__c'){
            Map<Id,NE__Order__c> mapAcc = new Map<Id,NE__Order__c>([
                SELECT NE__AccountId__c, NE__AccountId__r.PrimaryEmail__c, NE__AccountId__r.XC_UniqueId__c, NE__AccountId__r.XC_AccountPhone__c 
                FROM NE__Order__c
                WHERE Id =: iDfield
            ]);
            
            if(mapAcc.values().isEmpty()){
                return null;
            }
            
            NE__Order__c orderToCheck = mapAcc.values()[0];
            fieldToCheck.put('X-UniqueID',orderToCheck.NE__AccountId__r.XC_UniqueId__c);
            fieldToCheck.put('X-EmailAddress',orderToCheck.NE__AccountId__r.PrimaryEmail__c);
            fieldToCheck.put('X-Mobile',orderToCheck.NE__AccountId__r.XC_AccountPhone__c);
            fieldToCheck.put('Entity','Account');
            fieldToCheck.put('Id',orderToCheck.NE__AccountId__c);

        } else if(((id)iDfield).getSobjectType().getDescribe().getName() == 'NE__OrderItem__c'){
            Map<Id,NE__OrderItem__c> mapAcc = new Map<Id,NE__OrderItem__c>([
                SELECT NE__OrderId__r.NE__AccountId__c, NE__OrderId__r.NE__AccountId__r.PrimaryEmail__c, NE__OrderId__r.NE__AccountId__r.XC_UniqueId__c, NE__OrderId__r.NE__AccountId__r.XC_AccountPhone__c 
                FROM NE__OrderItem__c
                WHERE Id =: iDfield
            ]);
            
            if(mapAcc.values().isEmpty()){
                return null;
            }
            
            NE__OrderItem__c orderItToCheck = mapAcc.values()[0];
            fieldToCheck.put('X-UniqueID',orderItToCheck.NE__OrderId__r.NE__AccountId__r.XC_UniqueId__c);
            fieldToCheck.put('X-EmailAddress',orderItToCheck.NE__OrderId__r.NE__AccountId__r.PrimaryEmail__c);
            fieldToCheck.put('X-Mobile',orderItToCheck.NE__OrderId__r.NE__AccountId__r.XC_AccountPhone__c);
            fieldToCheck.put('Entity','Account');
            fieldToCheck.put('Id',orderItToCheck.NE__OrderId__r.NE__AccountId__c);

        } else if(((id)iDfield).getSobjectType().getDescribe().getName() == 'Asset'){
            Map<Id,Asset> mapAcc = new Map<Id,Asset>([
                SELECT AccountId, Account.PrimaryEmail__c, Account.XC_UniqueId__c, Account.XC_AccountPhone__c 
                FROM Asset
                WHERE Id =: iDfield
            ]);
                        
            if(mapAcc.values().isEmpty()){
                return null;
            }
            
            Asset assToCheck = mapAcc.values()[0];
            fieldToCheck.put('X-UniqueID',assToCheck.Account.XC_UniqueId__c);
            fieldToCheck.put('X-EmailAddress',assToCheck.Account.PrimaryEmail__c);
            fieldToCheck.put('X-Mobile',assToCheck.Account.XC_AccountPhone__c);
            fieldToCheck.put('Entity','Account');
            fieldToCheck.put('Id',assToCheck.AccountId);

        } else if(((id)iDfield).getSobjectType().getDescribe().getName() == 'Opportunity'){
            Map<Id,Opportunity> mapAcc = new Map<Id,Opportunity>([
                SELECT AccountId, Account.PrimaryEmail__c, Account.XC_UniqueId__c, Account.XC_AccountPhone__c 
                FROM Opportunity
                WHERE Id =: iDfield
            ]);
                        
            if(mapAcc.values().isEmpty()){
                return null;
            }
            
            Opportunity oppToCheck = mapAcc.values()[0];
            fieldToCheck.put('X-UniqueID',oppToCheck.Account.XC_UniqueId__c);
            fieldToCheck.put('X-EmailAddress',oppToCheck.Account.PrimaryEmail__c);
            fieldToCheck.put('X-Mobile',oppToCheck.Account.XC_AccountPhone__c);
            fieldToCheck.put('Entity','Account');
            fieldToCheck.put('Id',oppToCheck.AccountId);

        } 
        return fieldToCheck;
    }

    private static Boolean moreThanOneWithKeys(Map<String,String> fieldToCheck, Map<String,String> header){
        Boolean moreThanOneFound = false;

        if(fieldToCheck.get('Entity')=='Lead'){
            Map<Id,Lead> mapLead = new Map<Id,Lead>([
                SELECT Id
                FROM Lead
                WHERE Email =: header.get('X-EmailAddress') OR Phone =: header.get('X-Mobile')
            ]);
            moreThanOneFound = mapLead.values().size()==2;

        } else if(fieldToCheck.get('Entity')=='Account'){
            Map<Id,Account> mapAcc = new Map<Id,Account>([
                SELECT Id
                FROM Account
                WHERE PrimaryEmail__c =: header.get('X-EmailAddress') OR XC_AccountPhone__c =: header.get('X-Mobile')
            ]);
            moreThanOneFound = mapAcc.values().size()==2;

        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'moreThanOneFound: '+(moreThanOneFound));

        return moreThanOneFound;
    }

    private static XC_UTIL_Integration.WrapperResult updateUniqueId(String id, String entity, String uniqueId){
        XC_UTIL_Integration.WrapperResult res = new XC_UTIL_Integration.WrapperResult();
        SObject obj;
        if(entity=='Account'){
            Account a = new Account();
            a.id = id;
            a.XC_UniqueId__c = uniqueId;
            obj = a;
        } else if(entity=='Lead'){
            Lead l = new Lead();
            l.id = id;
            l.XC_UniqueId__c = uniqueId;
            obj = l;
        }

        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(obj);
        if(wr.success){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'updateUniqueId: success');
            res.errorMessage = 'Authenticated and Authorized';
            res.errorFlag = false;
            res.errorCode = '200';
            return res;

        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'updateUniqueId: error - '+wr.errorMessage);
            res.errorMessage = wr.errorMessage;
            res.errorFlag = true;
            res.errorCode = '500';
            return res;
        }
    }
    
}