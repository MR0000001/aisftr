/**
 * The Class XC_LCC066_Doxee.
 *
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation  10/10/2018
 * @date Modification
 * @description XC_LCC066_Doxee
 */
public without sharing class XC_LCC066_Doxee {

 private final static string PASSIVE_CONTRACT_RT=  Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_ContractPartner').getRecordTypeId();
    
    public class WrapperUser {
        @AuraEnabled public String userName, country, company, objectType, objectId;
        @AuraEnabled public Dossier dossier;
        @AuraEnabled public AdditionalInfoWrapper AdditionalInfo;
        @AuraEnabled public boolean error = false;
        @AuraEnabled public String parentId; //The parentId Object Type. to retrieve Logistic document parent Object
    }

    public class AdditionalInfoWrapper{
        @AuraEnabled public String NumberOfPages;
        @AuraEnabled public String SendMode;
        @AuraEnabled public AddressWrapper Address;
    }

    public class AddressWrapper{
        @AuraEnabled public String FirstName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String Address1;
        @AuraEnabled public String StreetNumber;
        @AuraEnabled public String Stair;
        @AuraEnabled public String Floor;
        @AuraEnabled public String Door;
        @AuraEnabled public String PostalCode;
        @AuraEnabled public String City;
        @AuraEnabled public String StateProvince;
        @AuraEnabled public String Country;
        @AuraEnabled public String DistributionGroup;
    }

    public class DossierCreationInputWrapper {
        public Contact contact;
        public XC_Address__c address;
        public User user;
        public XC_PersonalDocument__c document;
        public String fiscalCode;
        public String objectType;
        public String objectId;
        public List<String> signatureTypes;
    }

    public class Dossier {
        @AuraEnabled public String business_id = 'Enel X migrazione';
        @AuraEnabled public Object[] objects = new Object[]{};
        @AuraEnabled public Object[] signers = new Object[]{};
        @AuraEnabled public String serverSystemOTP;
        @AuraEnabled public String[] dossier_types;
        public Dossier(DossierCreationInputWrapper wrInput) {
            this.objects = buildObject(wrInput.objectType, wrInput.objectId);
            Boolean isB2B2G = false;
        	if(Schema.getGlobalDescribe().get(XC_UTIL_Sobject.getObjectType(wrInput.objectId)).newSObject().getSobjectType().getDescribe().fields.getMap().containsKey('XC_Segment__c')) {
                Map<Id, String> segmentMap = XC_SegmentUtilities.getSegmentFromObject(new Set<Id>{wrInput.objectId}, XC_UTIL_Sobject.getObjectType(wrInput.objectId));
                String segment = segmentMap.get(wrInput.objectId);
                isB2B2G = segment != 'B2C';
        	}
            if(!isB2B2G){
               if(XC_UTIL_Sobject.getObjectType(wrInput.objectId) == 'NE__Order__c'){
                    NE__Order__c conf = [SELECT Id, XC_LegalEntity__c FROM NE__Order__c WHERE Id =: wrInput.objectId LIMIT 1];
                    if(conf.XC_LegalEntity__c == 'EndesaX'){
						 Map<String,Object> signer = new Map<String,Object>{ 
                            	'signer' => new Map<String,Object>{
                                    'signer-id' => wrInput.contact?.id,
                                    'role' => 'cliente',
                                    'identity_assertion_policy' => 'inline.devisu',
                                    'default_redirect_url' => 'http://www.infocert.it',
                                    'person' => buildPerson(wrInput.contact, wrInput.address, wrInput.document, wrInput.fiscalCode),
                                    'signature-policy' => buildSignatureSpain(wrInput.contact, wrInput.address, 10)
                                }
                            };
                       
                        signers.add(signer);
                    }else{
                        Map<String,Object> signer = new Map<String,Object>{
                                'signer' => new Map<String,Object>{
                                        'signer-id' => wrInput.contact?.id,
                                        'role' => 'cliente',
                                        'identity_assertion_policy' => 'inline.devisu',
                                        'default_redirect_url' => 'http://www.infocert.it',
                                        'person' => buildPerson(wrInput.contact, wrInput.address, wrInput.document, wrInput.fiscalCode),
                                        'signature-policy' => buildSignature(wrInput.contact, wrInput.address)
                                }
                        };

                        signers.add(signer);
                    }
                } else{
                     Map<String,Object> signer = new Map<String,Object>{ 
                    'signer' => new Map<String,Object>{
                        'signer-id' => wrInput.contact?.id,
                        'role' => 'cliente',
                        'identity_assertion_policy' => 'inline.devisu',
                        'default_redirect_url' => 'http://www.infocert.it',
                        'person' => buildPerson(wrInput.contact, wrInput.address, wrInput.document, wrInput.fiscalCode),
                        'signature-policy' => buildSignature(wrInput.contact, wrInput.address)
                    }
                };
                
                signers.add(signer);
                }
            }else if(XC_UTIL_Sobject.getObjectType(wrInput.objectId) != 'Case'){
                Map<String,Object> signer = new Map<String,Object>{ 
                    'signer' => new Map<String,Object>{
                        'signer-id' => wrInput.contact?.id,
                        'role' => 'cliente',
                        'identity_assertion_policy' => 'inline.devisu',
                        'default_redirect_url' => 'http://www.infocert.it',
                        'person' => buildPerson(wrInput.contact, wrInput.address, wrInput.document, wrInput.fiscalCode),
                        'signature-policy' => buildSignature(wrInput.contact, wrInput.objectType, wrInput.objectId)
                    }
                };
                signers.add(signer);
            }
            if(!isB2B2G){
               Map<String,Object> agent = new Map<String,Object>{
                'signer' => new Map<String,Object>{
                    'signer-id' => wrInput.user.Id,
                    'role' => 'agente',
                    'certificate-alias' => wrInput.user.XC_Alias__c,
                    'certificate-domain' => wrInput.user.XC_Domain__c,
                    'identity_assertion_policy' => 'none',
                    'default_redirect_url' => 'http://www.infocert.it',
                    'person' => buildAgent(wrInput.user),
                    'signature-policy' => buildSignature(wrInput.user.Id, wrInput.objectType, wrInput.objectId)
                    }
                }; 
                 signers.add(agent);
            }else if(XC_UTIL_Sobject.getObjectType(wrInput.objectId) == 'Case' || XC_UTIL_Sobject.getObjectType(wrInput.objectId) == 'WorkOrderLineItem'){
               User procuratore = getProcurator(wrInput.objectId, XC_UTIL_Sobject.getObjectType(wrInput.objectId));
               Map<String,Object> agent = new Map<String,Object>{
                'signer' => new Map<String,Object>{
                    'signer-id' => procuratore.EmployeeNumber,
                    'role' => 'agente',
                    'certificate-alias' => procuratore.XC_Alias__c,
                    'certificate-domain' => procuratore.XC_Domain__c,
                    'identity_assertion_policy' => 'none',
                    'default_redirect_url' => 'http://www.infocert.it',
                    'person' => buildAgent(procuratore),
                    'signature-policy' => buildSignature(procuratore.EmployeeNumber, wrInput.objectType, wrInput.objectId)
                }
            }; 
                signers.add(agent);
            }else{
               Map<String,Object> agent = new Map<String,Object>{
                'signer' => new Map<String,Object>{
                    'signer-id' => wrInput.user.Id,
                    'role' => 'agente',
                    'certificate-alias' => wrInput.user.XC_Alias__c,
                    'certificate-domain' => wrInput.user.XC_Domain__c,
                    'identity_assertion_policy' => 'none',
                    'default_redirect_url' => 'http://www.infocert.it',
                    'person' => buildAgent(wrInput.user),
                    'signature-policy' => buildSignature(wrInput.user.Id, wrInput.objectType, wrInput.objectId)
                }
            }; 
                 signers.add(agent);
            }
            
            
           
        }
		
        private Map<String,Object> buildSignature(String userId, String objType, String objId){
            if(objType == 'Contract'){
                Contract contr = [SELECT id, XC_Segment__c FROM Contract WHERE id =: objId LIMIT 1];
                if(contr.XC_segment__c != 'B2C'){
                    return new Map<String,Object>{'keyword-signature-field' => buildKeywordField(userId, 10, 'FIRMA_UTENTE_INTERNO') };
                }
            }else if(objType == 'WorkOrder_LineItem'){
                WorkOrderLineItem woli  = [SELECT id, XC_Segment__c, XC_LCLDocument__c, XC_RequestType__c FROM WorkOrderLineItem WHERE id =: objId LIMIT 1];//FM fix CR729 add XC_RequestType__c
               	if(woli.XC_Segment__c != 'B2C' && (woli.XC_LCLDocument__c != null || woli.XC_RequestType__c != null)){//FM fix CR729 add check XC_RequestType__c
                   return new Map<String,Object>{'keyword-signature-field' => buildKeywordField(getProcuratoreId(woli), getNumberOfSignatureInt(woli.XC_LCLDocument__c != null ? woli.XC_LCLDocument__c : woli.XC_RequestType__c), 'FIRMA_UTENTE_INTERNO') };//FM fix CR729 add XC_RequestType__c
                }
            }else if(objType == 'Case'){
                Case caseToSign = [SELECT id, XC_Segment__c, SubCause__c, XC_WorkOrderLineItem__c FROM Case WHERE id =: objId LIMIT 1];
                if(caseToSign.XC_Segment__c != 'B2C'){
                   return new Map<String,Object>{'keyword-signature-field' => buildKeywordField(getProcuratoreId(caseToSign), getNumberOfSignatureInt(caseToSign.SubCause__c), 'FIRMA_UTENTE_INTERNO') };
                }
            }
            return null;
        }
        private Map<String,Object> buildSignature(Contact con, String objType, String objId){
            if(objType == 'WorkOrder_LineItem'){
                WorkOrderLineItem woli  = [SELECT id, XC_Segment__c, XC_LCLDocument__c, XC_RequestType__c FROM WorkOrderLineItem WHERE id =: objId LIMIT 1]; //FM fix CR729 add XC_RequestType__c
               	if(woli.XC_Segment__c != 'B2C' && (woli.XC_LCLDocument__c != null || woli.XC_RequestType__c != null)){//FM fix CR729 add check XC_RequestType__c
                   return new Map<String,Object>{'keyword-signature-field' => buildKeywordField(con?.id, getNumberOfSignatureExt(woli.XC_LCLDocument__c != null ? woli.XC_LCLDocument__c : woli.XC_RequestType__c))  };//FM fix CR729 add check XC_RequestType__c
                }
            }else if(objType == 'Case'){
                Case caseToSign = [SELECT id, XC_Segment__c, SubCause__c, XC_WorkOrderLineItem__c FROM Case WHERE id =: objId LIMIT 1];
                if(caseToSign.XC_Segment__c != 'B2C'){
                   return new Map<String,Object>{'keyword-signature-field' => buildKeywordField(con.id, getNumberOfSignatureExt(caseToSign.SubCause__c))  };
                }
            }else{
                return new Map<String,Object>{'keyword-signature-field' => buildKeywordField(con?.id, 10)  };
            }
            return null;
        }
        private Map<String,Object> buildSignature(Contact con, XC_Address__c addr) {
            Map<String,Object> res = new Map<String,Object>();
            if(con != null){// && addr != null){
                res = new Map<String,Object>{
                    //'signer-id' => con.id,
                    //'name' => 'FIRMA_CLIENTE_ACCETTAZIONE',
                    //'reason' => 'Firma cliente accettazione',
                    //'location' => addr.XC_City__c,
                    'keyword-signature-field' => buildKeywordField(con.id, 10) 
                };
            }
            return res; 
        }

        private List<Map<String,Object>> buildKeywordField(String conId, integer n) {
            List<Map<String,Object>> l = new List<Map<String,Object>>();
            for(integer i = 1; i<=n; i++){
                Map<String,Object> m = new Map<String,Object>{
                    'signer-id' => conId,
                    'keyword' => 'FIRMA_CLIENTE_ACCETTAZIONE'+i,
                    'offset-x' => '0',
                    'offset-y' => '0',
                    'width' => '100',
                    'height' => '25',
                    'reason' => 'Firma cliente accettazione',
                    'location' => ''
                };
                l.add(m);
            }
            return l;
        }
        private List<Map<String,Object>> buildKeywordField(String conId, integer n, string signatureKeyWord) {
            List<Map<String,Object>> l = new List<Map<String,Object>>();
            for(integer i = 1; i<=n; i++){
                Map<String,Object> m = new Map<String,Object>{
                    'signer-id' => conId,
                    'keyword' => signatureKeyWord +i,
                    'offset-x' => '0',
                    'offset-y' => '0',
                    'width' => '100',
                    'height' => '25',
                    'reason' => signatureKeyWord,
                    'location' => ''
                };
                l.add(m);
            }
            return l;
        }

        private List<Map<String,Object>> buildObject(String objType, String objId) {
            Map<String,Object> m = new Map<String,Object>{
                'objectType' => objType,
                'objectId' => objId
            };
            List<Map<String,Object>> l = new List<Map<String,Object>>();
            l.add(m);
            return l;
        }

        private Map<String,Object> buildAgent(User u) {
            return new Map<String,Object>{
                'first-name' => u.FirstName,
                'last-name' => u.LastName,
                'sex' => u.XC_Sex__c,
                'email' => u.Email,
                'mobile_number' => u.MobilePhone,
                'legal-id_country-code' => u.XC_Document_Country__c, //IT
                'legal-id_serial-type' => 'TIN',
                'legal-id_serial-number' => ((u.XC_Document_Type__c == 'CF' || u.XC_Document_Type__c == 'Codice Fiscale') ? u.XC_Document_Number__c : null)
                    
            };
        }

        private Map<String,Object> buildPerson(Contact con, XC_Address__c addr, XC_PersonalDocument__c doc, String cf) {
            Map<String,Object> tmp = new Map<String,Object>{};
            
            if (con != null) {
                //tmp.put('legal-id_serial-type', 'TIN');
                //tmp.put('legal-id_serial_number', (con.XC_ContactDocumentType__c == 'CF') ? con.XC_ContactDocumentNumber__c : null);
                tmp.put('first-name', con.FirstName);
                tmp.put('last-name', con.LastName);
                tmp.put('birth-date', parseDate(con.Birthdate));

                tmp.put('citizenship', con.XC_Citizenship__c); //I 
                tmp.put('sex', con.XC_Sex__c);
                tmp.put('birth-place', con.XC_Birth_Place__c);
                tmp.put('birth-province', con.XC_Birth_Province__c); //due lettere 
                tmp.put('birth-country', con.XC_Birth_Country__c); //I 
                tmp.put('email', con.Email);
                tmp.put('mobile_number', con.MobilePhone);
                //tmp.put('legal-id_country-code', 'Italy');
                tmp.put('legal-id_country-code', con.XC_CountryLegalEntity__c);
                tmp.put('legal-id_serial-type', 'TIN');
                tmp.put('legal-id_serial-number', cf);
          
            }
            tmp.put('address', buildAddress(addr));
            tmp.put('identity-document', buildIdentityDocument(doc));
            return tmp;
        }

        private Map<String,Object> buildAddress(XC_Address__c addr) {
            Map<String,Object> tmp = new Map<String,Object>{};
            if (addr != null) {
                tmp.put('street', addr.XC_StreetTypeText__c+' '+addr.XC_Address__c);
                tmp.put('number', addr.XC_StreetNumber__c);
                tmp.put('zip', addr.XC_PostalCode__c);
                tmp.put('city', addr.XC_City__c);
                tmp.put('province', addr.XC_AddressProvince__c); //due lettere 
                tmp.put('country', addr.XC_AddressCountry__c); //I 
            }
            return tmp;
        }

        private Map<String,Object> buildIdentityDocument(XC_PersonalDocument__c doc) { 
            Map<String,Object> tmp = new Map<String,Object>{};
            if (doc!= null) {  
                tmp.put('number' , doc.XC_DocumentNumber__c);
                string t = '';
                switch on doc.XC_DocumentType__c {
                    when 'Passport' {
                        t = 'PS';
                    }when 'PS' {
                        t = 'PS';
                    } when 'Driving license' {
                        t = 'PT';
                    } when 'PT' {
                        t = 'PT';
                    } when 'Identity Card' {
                        t = 'CI';
                    } when 'CI' {
                        t = 'CI';
                    } when else {
                        t = 'AL';
                    } 
                }
                tmp.put('type' , t);
                tmp.put('issue-date', parseDate(doc.XC_ReleaseDate__c));
                tmp.put('expiration-date', parseDate(doc.XC_ExpirationDate__c));
                tmp.put('issuer', doc.XC_Issued_By__c); 
                tmp.put('issue-place', doc.XC_Issue_Place__c); 
                tmp.put('issue-province', doc.XC_Issue_Province__c); //due lettere 
                tmp.put('issue-country', doc.XC_Issue_Country__c); //IT 
            }
            return tmp;
        }
    }

    /**
     * @description Fetch user.
     *
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper fetchUser(String recordId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;

        // query current user information
        Map<Id,User> oUserMap = new Map<Id,User>([SELECT Id, Name, TimeZoneSidKey, Username, Alias, Country, Country__c, Company__c,
                      Email, FirstName, LastName, IsActive, IsPortalEnabled
                      FROM User
                      WHERE Id =: userInfo.getUserId()]);

        User oUser = new User ();
        oUser = oUserMap.values();

        wr.resultMessage  = oUser.Username;
        wr.objectInfo  = getUserInformation(recordId);

        if(!String.isBlank(wr.resultMessage) && !String.isBlank(wr.objectinfo)){
            wr.success = true;
        }
        return wr;
    }

    /**
     * @description Gets the user information.
     *
     * @return the user information
     */
    @AuraEnabled
    public static String getUserInformation(String recordId){

        WrapperUser wrUser = new WrapperUser();
        wrUser.objectType = XC_UTIL_Sobject.getObjectType(recordId);
        Boolean isB2B2G = false;
        Id userId = UserInfo.getUserId();
        Map<Id,User> usrLstMap = new Map<Id,User>([SELECT UserName, Country__c, Company__c,XC_LegalEntity__c  FROM User WHERE Id = :userId]);
        String userLE = usrLstMap.values()[0].XC_LegalEntity__c;

        String orgId = UserInfo.getOrganizationId();
        
        String query = 'SELECT XC_DoxeeCountry__c , XC_DoxeeCompany__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: userLE AND XC_OrgId__c =: orgId';
        if(Schema.getGlobalDescribe().get(wrUser.objectType).newSObject().getSobjectType().getDescribe().fields.getMap().containsKey('XC_Segment__c')) {
            Map<Id, String> segmentMap = XC_SegmentUtilities.getSegmentFromObject(new Set<Id>{recordId}, wrUser.objectType);
            String segment = segmentMap.get(recordId);
            query += (String.isNotBlank(segment)) ? ' AND XC_Stream__c =: segment' : '';
            isB2B2G = segment != 'B2C';
        }
        query += ' LIMIT 1';
        List<XC_CM_LegalEntity_Configuration__mdt> cmLegalEntityConf = (List<XC_CM_LegalEntity_Configuration__mdt>) Database.query(String.escapeSingleQuotes(query));

        // List<XC_CM_LegalEntity_Configuration__mdt> CMLegalEntityConf = [SELECT XC_DoxeeCountry__c , XC_DoxeeCompany__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: userLE AND XC_OrgId__c =: orgId limit 1];

        System.debug('@@@ CMLegalEntityConf :' +CMLegalEntityConf);

        wrUser.userName = usrLstMap.values()[0].Username;
        wrUser.country = CMLegalEntityConf[0].XC_DoxeeCountry__c;
        wrUser.company = CMLegalEntityConf[0].XC_DoxeeCompany__c;

        // 20/11/19 PA NTT DATA - DDT retieve Logistic Document parent Object
        system.debug('@@@ getUserInformation:' + wrUser.objectType);
        wrUser.parentId = getIdParentObject(recordId, wrUser.objectType);
        wrUser.objectId = recordId;

        if(wrUser.objectType=='Case'){
            List<String> reason = new List<String>();
            List<String> cause = new List<String>();
            String[] listS = new String[]{'XC_Compliance1', 'XC_Compliance2', 'XC_Compliance3', 'XC_Compliance4', 'XC_Compliance5'};
            Map<Id,XC_CM_Case_Type_Setting__mdt> metaMap = new Map<Id,XC_CM_Case_Type_Setting__mdt>([
                SELECT XC_Case_Reason__c, XC_Sub_Cause__c, QualifiedApiName FROM XC_CM_Case_Type_Setting__mdt WHERE QualifiedApiName in: listS
            ]);
            for(XC_CM_Case_Type_Setting__mdt c : metaMap.values()){
                reason.add(c.XC_Case_Reason__c);
                cause.add(c.XC_Sub_Cause__c);
            }
            Map<Id,Case> caseMap = new Map<Id,Case>([
                SELECT Reason, SubCause__c, XC_Order__c, XC_WorkOrder__c,XC_ProvisioningStep__c, XC_LegalEntity__c FROM Case WHERE id =: recordId
            ]);
            if(reason.contains(caseMap.values()[0].Reason)&&cause.contains(caseMap.values()[0].SubCause__c)&&!string.isBlank(caseMap.values()[0].XC_Order__c)){
                wrUser.objectType = 'NE__Order__c';
                wrUser.objectId = caseMap.values()[0].XC_Order__c;

            } else if(caseMap.values()[0].Reason == ('XCMOT006') && caseMap.values()[0].SubCause__c == ('ATCL072') && !string.isBlank(caseMap.values()[0].XC_WorkOrder__c)){
                wrUser.objectType = 'WorkOrder';
                wrUser.objectId = caseMap.values()[0].XC_WorkOrder__c;

            }else if(caseMap.values()[0].Reason == ('XCMOT007') && caseMap.values()[0].SubCause__c == ('ATCL028') && String.isNotBlank(caseMap.values()[0].XC_ProvisioningStep__c)){
                wrUser.objectType = 'Case';
            } else if(caseMap.values()[0].XC_LegalEntity__c == 'EndesaX' || caseMap.values()[0].XC_LegalEntity__c == 'EnelXMobilitySpain'){
                //JJP - 24/01/2022 - Start
                //wrUser.error = true;
                wrUser.objectType = 'Case';
                //JJP - 24/01/2022 - End
            }else if(isB2B2G){
                    Case c = [
                    SELECT id, ContactId, XC_WorkorderLineItem__c, XC_WorkorderLineItem__r.WorkOrder.XC_Address__c, XC_Segment__c FROM Case
                    WHERE Id = :recordId LIMIT 1
                ];
                
                string addr = c.XC_WorkorderLineItem__r.WorkOrder.XC_Address__c;
                Contact con = getContact(c.ContactId);
                XC_Address__c address = getAddress(addr);

                List<String> signatureTypes = new List<String>{'ONESHOT_DEVISU'};
                setupDigitalSignatureData(wrUser, con, address, 'CASE', recordId, signatureTypes);
                wrUser.dossier.serverSystemOTP = 'GOSIGN';
                wrUser.dossier.dossier_types = new List<String>();

            }
        } else if (wrUser.objectType == 'NE__Order__c') {
            NE__Order__c order = [
                SELECT Id, NE__OptyId__r.XC_Contact__c, XC_OrderBillingAddress__c, XC_InstallationAddress__c, XC_DeliveryAddress__c,XC_ReceivingChannelFormula__c,XC_LegalEntity__c,NE__OptyId__c, /*INC000090394105 NicoloFodera 20220712 Added NE__OptyId__c*/
                    (select id,XC_Product_Subtype__c,XC_CreditAssignmentAvailable__c from NE__Order_Items__r where XC_Product_Subtype__c='Incentive')
                FROM NE__Order__c
                WHERE Id = :recordId
            ];
            
            string addr = order.XC_OrderBillingAddress__c;
            if(string.isblank(order.XC_OrderBillingAddress__c)){
                addr = order.XC_InstallationAddress__c;
            }             
            if(string.isblank(order.XC_InstallationAddress__c)){
                addr = order.XC_DeliveryAddress__c;
            }

            Contact con = getContact(order.NE__OptyId__r.XC_Contact__c);
            XC_Address__c address = getAddress(addr);

            List<String> signatureTypes = getSignatureTypes(order);
            setupDigitalSignatureData(wrUser, con, address, 'CONFIGURATION', recordId, signatureTypes);
            wrUser.dossier.serverSystemOTP = 'TOP'; //new integration
            wrUser.dossier.dossier_types = new List<String>();
            if(!isB2B2G){
                wrUser.dossier.dossier_types = signatureTypes;
            }
            setupAdditionalInfo(wrUser, con, address);

        } else if (wrUser.objectType == 'Contract') {
            Contract c = [
                SELECT Id, XC_Configurations__r.NE__OptyId__r.XC_Contact__c,RecordTypeId, XC_Configurations__r.XC_OrderBillingAddress__c, XC_Configurations__r.XC_InstallationAddress__c, XC_Configurations__r.XC_DeliveryAddress__c, AccountId
                FROM Contract 
                WHERE Id = :recordId
            ];
            
            string addr = c.XC_Configurations__r.XC_OrderBillingAddress__c;
            if(string.isblank(c.XC_Configurations__r.XC_OrderBillingAddress__c)){
                addr = c.XC_Configurations__r.XC_InstallationAddress__c;
            }             
            if(string.isblank(c.XC_Configurations__r.XC_InstallationAddress__c)){
                addr = c.XC_Configurations__r.XC_DeliveryAddress__c;
            }

            //Contact con = getContact(c.XC_Configurations__r.NE__OptyId__r.XC_Contact__c);
            
            string contactId = PASSIVE_CONTRACT_RT.equals(c.RecordTypeId) ? getContactIdFromAccId(c.AccountId) : c.XC_Configurations__r.NE__OptyId__r.XC_Contact__c;
            Contact con = getContact(contactId);

            XC_Address__c address = getAddress(addr);

            List<String> signatureTypes = new List<String>{'ONESHOT_DEVISU'};
            setupDigitalSignatureData(wrUser, con, address, 'CONTRACT', recordId, signatureTypes);
            wrUser.dossier.serverSystemOTP = 'TOP';
            wrUser.dossier.dossier_types = new List<String>();
            if(!isB2B2G){
                wrUser.dossier.dossier_types = signatureTypes;
            }

        } else if (wrUser.objectType == 'NE__Billing_Profile__c') {
            XC_BillingProfileLineItem__c billingProfile = [
                SELECT XC_SoldToContactId__c, XC_SoldToAddress__c
                FROM XC_BillingProfileLineItem__c
                WHERE XC_BillingProfile__c = :recordId
                LIMIT 1 //TODO: Da capire se è 1 o come bisogna fare altrimenti
            ];

            Contact con = getContact(billingProfile.XC_SoldToContactId__c);
            XC_Address__c addr = getAddress(billingProfile.XC_SoldToAddress__c);

            List<String> signatureTypes = new List<String>{'ONESHOT_DEVISU'};
            //TODO: based on requirements is not clear if this scenario go with TOP or GOSIGN.
            //TODO: wrUser.dossier.serverSystemOTP = 'FIX ME with TOP or GOSIGN';
            setupDigitalSignatureData(wrUser, con, addr, 'NE__Billing_Profile__c', recordId, signatureTypes);
        } else if (wrUser.objectType == 'WorkOrderLineItem') {
            WorkOrderLineItem c = [
                SELECT id, WorkOrder.ContactId, WorkOrder.XC_Address__c, XC_Segment__c, WorkOrder.XC_AssignedResource__r.XC_Contact__c FROM WorkOrderLineItem
                WHERE Id = :recordId LIMIT 1
            ];
            
            string addr = c.WorkOrder.XC_Address__c;
            if(c.WorkOrder.ContactId != null && !isB2B2G){
                Contact con = getContact(c.WorkOrder.ContactId);
                XC_Address__c address = getAddress(addr);

                List<String> signatureTypes = new List<String>{'ONESHOT_DEVISU'};
                setupDigitalSignatureData(wrUser, con, address, 'WORKORDER_LINEITEM', recordId, signatureTypes);
                wrUser.dossier.serverSystemOTP = 'TOP';
                wrUser.dossier.dossier_types = signatureTypes;

            }
            if(c.WorkOrder.XC_AssignedResource__r.XC_Contact__c != null && isB2B2G){
                Contact con = getContact(c.WorkOrder.XC_AssignedResource__r.XC_Contact__c);
                XC_Address__c address = getAddress(addr);

                List<String> signatureTypes = new List<String>{'ONESHOT_DEVISU'};
                setupDigitalSignatureData(wrUser, con, address, 'WORKORDER_LINEITEM', recordId, signatureTypes);
                if(isB2B2G){
                    wrUser.dossier.serverSystemOTP = 'GOSIGN';
                    wrUser.dossier.dossier_types = new List<String>();
                }                              
            }

        } else if (wrUser.objectType == 'Account') {
                        
            Account a = [ 
                SELECT id, RecordType.DeveloperName, XC_Segment__c FROM Account
                WHERE Id = :recordId LIMIT 1
            ];
            
            if(a.RecordType.DeveloperName == 'XC_Account_Partner' && a.XC_Segment__c == 'B2C'){
                wrUser.objectType = 'Account_Partner';
            }
            
        }
                
        String res = JSON.serialize(wrUser);
        res = res.replace('business_id','business-id');
        res = res.replace('dossier_types','dossier-types');
        
        system.debug('test: '+res);
        system.debug('test: '+res.contains('AdditionalInfo'));

        return res;
    }

    // 20/11/19 PA NTT DATA - DDT retieve Logistic Document parent Object
    private static String getIdParentObject(String recordId, String objName){
		string idParentObject='';
        string parentId='';
		//string objName = XC_UTIL_Sobject.getObjectType(recordId);
		system.debug('@@@ getIdParentObject - objType:' + objName);
        DDT_RetrieveParObj__c fieldLookUp = DDT_RetrieveParObj__c.getValues(objName);
		if(fieldLookUp!=null) {
            parentId = fieldLookUp.parentId__c;
            string query = 'SELECT ' + parentId + ' from ' + objName + ' where id =:recordId';
            system.debug('@@@ getIdParentObject - query:' + query);
            List<sObject> lista =  Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
            if(Lista.size()>0){
                for(sObject acc:lista)  {
                    idParentObject = (String)acc.get(parentId);
                    system.debug('@@@ getIdParentObject - idParentObject:' + idParentObject);

                }

            }
        }

        if(objName=='NE__OrderItem__c'){
            string query = 'SELECT Id, NE__OrderId__c FROM NE__OrderItem__c WHERE id=:recordId';
            List<NE__OrderItem__c> lista =  Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
            idParentObject = lista[0].NE__OrderId__c;

        } else if(objName=='WorkOrder'){
            string query = 'SELECT Id, XC_Configuration__c FROM WorkOrder WHERE id=:recordId';
            List<WorkOrder> lista =  Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
            idParentObject = lista[0].XC_Configuration__c;

        }

		return idParentObject;
    }

    
    private static void setupAdditionalInfo(WrapperUser wu, Contact con, XC_Address__c addr){
        AdditionalInfoWrapper add = new AdditionalInfoWrapper();
        AddressWrapper addWr = new AddressWrapper();

        addWr.FirstName = con.FirstName;
        addWr.LastName = con.LastName;
        addWr.Address1 = addr.XC_Address__c;
        addWr.StreetNumber = addr.XC_StreetNumber__c;
        addWr.Door = addr.XC_Door__c;
        addWr.Stair = addr.XC_Stair__c;
        addWr.Floor = addr.XC_Floor__c;
        addWr.PostalCode = addr.XC_PostalCode__c;
        addWr.City = addr.XC_City__c;
        addWr.StateProvince = addr.XC_AddressProvince__c;
        addWr.Country = addr.XC_AddressCountry__c;
        addWr.DistributionGroup = '';

        add.SendMode = 'ORD';
        add.NumberOfPages = '';
        add.Address = addWr;

        wu.AdditionalInfo = add;
    }

    private static void setupDigitalSignatureData(WrapperUser wu, Contact con, XC_Address__c addr, String objType, String objId, List<String> signatureTypes){

        DossierCreationInputWrapper wrInput = new DossierCreationInputWrapper();
        wrInput.Contact = con;
        wrInput.address = addr;
        wrInput.user = getUser();
        wrInput.objectType = objType;
        wrInput.objectId = objId;
        wrInput.document = getDocument(con);
        wrInput.fiscalCode = getCf(con);
        wrInput.signatureTypes = signatureTypes;

        wu.dossier = new Dossier(wrInput);
    }

    private static Contact getContact(Id objId){
        Contact[] tmp = [
            SELECT 
            Id,
            XC_ContactDocumentNumber__c,
            XC_ContactDocumentType__c,
            FirstName,
            LastName,
            Birthdate,
            XC_Nationality__c,
            XC_ContactDocumentCountry__c, 
            XC_ContactDocReleaseDate__c,
            XC_ContactDocExpirationDate__c,
            XC_Birth_Place__c, 
            XC_Birth_Country__c, 
            XC_Birth_Province__c,
            XC_Citizenship__c, 
            XC_Sex__c,
            Email,
            MobilePhone,
            XC_CountryLegalEntity__c,
            (   SELECT 
                Id, 
                XC_DocumentNumber__c, 
                XC_DocumentType__c, 
                XC_ReleaseDate__c, 
                XC_ExpirationDate__c,
                XC_Issue_Place__c,
                XC_Issue_Province__c, 
                XC_Issue_Country__c,
                XC_Issued_By__c, 
                XC_Country__c
                FROM Personal_Documents__r  ) 
            FROM Contact
            WHERE Id = :objId
        ];
        return tmp.size() > 0 ? tmp[0] : null;
    }
    //metodo per contratti passivi
    private static string getContactIdFromAccId(string accountID){
        List<Contact> contacts = [SELECT Id 
                                  FROM Contact 
                                  WHERE AccountID = :accountId order by XC_PrimaryContact__c DESC limit 1];
        return contacts.size() > 0 ? contacts.get(0).Id : '';
    }

    private static XC_Address__c getAddress(Id objId){
        XC_Address__c[] tmp = [
            SELECT 
            Id,
            XC_Address__c,
            XC_StreetNumber__c,
            XC_StreetTypeText__c,
            XC_PostalCode__c,
            XC_City__c,
            XC_AddressProvince__c,
            XC_AddressCountry__c,
            XC_Door__c,
            XC_Stair__c,
            XC_Floor__c
            FROM XC_Address__c
            WHERE Id = :objId
        ];
        return tmp.size() > 0 ? tmp[0] : null;
    }

    private static User getUser() {
        return [
            SELECT 
            Id, 
            FirstName, 
            LastName, 
            XC_Sex__c, 
            XC_Alias__c, 
            XC_Document_Country__c, 
            XC_Document_Number__c, 
            XC_Document_Type__c, 
            Email, 
            MobilePhone, 
            XC_Domain__c
            FROM User 
            WHERE Id = :userInfo.getUserId()
            ];
    }

    private static XC_PersonalDocument__c getDocument(Contact con){
        XC_PersonalDocument__c cf;
        XC_PersonalDocument__c ci;
        XC_PersonalDocument__c ps;
        XC_PersonalDocument__c pt;

        if(con==null||con.Personal_Documents__r.isEmpty()){
            return null;
        }

        for(XC_PersonalDocument__c d:con.Personal_Documents__r){
            switch on d.XC_DocumentType__c {
                when 'PT' {
                    pt = d;
                } when 'CI' { 
                    ci = d;
                } when 'PS' {
                    ps = d;
                } when else {
                    cf = d;
                } 
            }
        }

        if(ci!=null) {
            return ci;
        } else if(ps!=null) {
            return ps;
        } else if(pt!=null) {
            return pt;
        } else if(cf!=null) {
            return cf;
        }

        return null;
    }

    private static String getCf(Contact con){
        String cf;

        if(con==null||con.Personal_Documents__r.isEmpty()){
            return null;
        }

        for(XC_PersonalDocument__c d:con.Personal_Documents__r){
            if(d.XC_DocumentType__c == 'CF'){
                cf = d.XC_DocumentNumber__c;
            }else if (con.XC_CountryLegalEntity__c == 'Spain'){
                cf = d.XC_DocumentNumber__c;
                break;
            }
        }

        return cf;
    }

    private static String parseDate(Date d){
        if(d==null){
            return null;
        } 

        return (d+'.000+01:00').replace(' ','T');
    }
    public static List<Map<String,Object>> buildKeywordField(String conId, integer n, String keyword) {
            List<Map<String,Object>> l = new List<Map<String,Object>>();
            for(integer i = 1; i<=n; i++){
                Map<String,Object> m = new Map<String,Object>{
                    'signer-id' => conId,
                    'keyword' => keyword+i,
                    'offset-x' => '0',
                    'offset-y' => '0',
                    'width' => '100',
                    'height' => '25',
                    'reason' => keyword,
                    'location' => ''
                };
                l.add(m);
            }
            return l;
        }
        public static Map<String,Object> buildSignature(String con, integer n, String keyword  ) {
            Map<String,Object> res = new Map<String,Object>();
            if(con != null){// && addr != null){
                res = new Map<String,Object>{
                    //'signer-id' => con.id,
                    //'name' => 'FIRMA_CLIENTE_ACCETTAZIONE',
                    //'reason' => 'Firma cliente accettazione',
                    //'location' => addr.XC_City__c,
                    'keyword-signature-field' => buildKeywordField(con, 10, keyword) 
                };
            }
            return res; 
        }
    
    public static Integer getNumberOfSignatureInt(String typeOfDocument){
        List<XC_CM_NumberOfDigitalSignature__mdt> numberOfSignature = [SELECT XC_NumberOfInternalSignature__c FROM XC_CM_NumberOfDigitalSignature__mdt where XC_DocumentType__c =: typeOfDocument ];
        if(numberOfSignature.isEmpty()){
            return 0;
        }
        return Integer.valueOf(numberOfSignature[0].XC_NumberOfInternalSignature__c);
    } 
    public static Integer getNumberOfSignatureExt(String typeOfDocument){
        List<XC_CM_NumberOfDigitalSignature__mdt> numberOfSignature = [SELECT XC_NumberOfExternalSignature__c FROM XC_CM_NumberOfDigitalSignature__mdt where XC_DocumentType__c =: typeOfDocument ];
        if(numberOfSignature.isEmpty()){
            return 0;
        }
        return Integer.valueOf(numberOfSignature[0].XC_NumberOfExternalSignature__c);
    }  
    public static String getProcuratoreId (WorkOrderLineItem woli){
        List<ProcessInstance> process = [Select Id, TargetObjectId, LastActorId  from ProcessInstance  where TargetObjectId =: woli.id order by createddate desc];
        if(process.isEmpty() ){
            return userInfo.getUserId();
        }
        if(process[0].LastActorId==null){
           return userInfo.getUserId();
        }
        return process[0].LastActorId;
    }
    public static String getProcuratoreId (Case cas){
        List<ProcessInstance> process = [Select Id, TargetObjectId, LastActorId  from ProcessInstance  where TargetObjectId =: cas.XC_WorkOrderLineItem__c order by createddate desc];
        if(process.isEmpty()){
            return userInfo.getUserId();
        }
        return process[0].LastActorId;
    }
    
    public static User getProcurator (String objId, String objType){
        String userId =userInfo.getUserId();
        if(objType == 'Case'){
            Case c = [SELECT id, XC_WorkOrderLineItem__c from case where id = : objId LIMIT 1 ];
            userId = c.XC_WorkOrderLineItem__c != null? getProcuratoreId(c) : userInfo.getUserId();
        }else if(objType == 'WorkOrderLineItem'){
            WorkOrderLineItem woli = new WorkOrderLineItem();
            woli.id = objId;
            userId = woli.id != null? getProcuratoreId(woli) : userInfo.getUserId();
        }
        User procuratore = [SELECT FirstName, LastName, XC_Sex__c, Email, MobilePhone, XC_Document_Country__c, XC_Document_Type__c, XC_Document_Number__c, XC_Alias__c, XC_Domain__c, EmployeeNumber FROM User Where Id =: userId LIMIT 1];
        return procuratore;
    }

    /**
     * @param order
     *
     * @return a list of string. These values represent the signature type enabled for triplet 'legalEntity,receivingChannel,creditAssignment'
     */
    private static List<String> getSignatureTypes(NE__Order__c order){
        List<String> signatureTypes = new List<String>();

        Boolean creditAssignment = false;

        if(order.NE__Order_Items__r.size() > 0){
            NE__OrderItem__c oi = order.NE__Order_Items__r[0];
            creditAssignment = oi.XC_CreditAssignmentAvailable__c;
        }

        //INC000090394105 NicoloFodera 20220712 Added [start]
		List<NE__Order__c> listOfQuote = [SELECT Id, XC_ReceivingChannelFormula__c FROM NE__Order__c WHERE RecordType.DeveloperName =: Label.XC_CL_Configuration_RtQuote AND NE__OptyId__c =: order.NE__OptyId__c AND XC_Status__c =: Label.XC_CL_Configuration_QuoteAccepted];
        //INC000090394105  NicoloFodera 20220712 Added [end]
        String receivingChannel =  listOfQuote.isEmpty() ? order.XC_ReceivingChannelFormula__c : listOfQuote[0].XC_ReceivingChannelFormula__c;//order.XC_ReceivingChannelFormula__c; INC000090394105 NicoloFodera 20220712

        List<XC_Signature_Type__c> stList = [SELECT id,XC_Signature_Type__c
                                    FROM XC_Signature_Type__c
                                    WHERE XC_Legal_Entity__c = :order.XC_LegalEntity__c
                                        AND XC_Receiving_Channel__c = :receivingChannel
                                        AND XC_Credit_Assignment__c = :creditAssignment];

        if(stList.size() > 0 && stList[0].XC_Signature_Type__c != null){
            signatureTypes = stList[0].XC_Signature_Type__c.split(',');
        }else{
            signatureTypes.add('ONESHOT_DEVISU'); //AS IS SIGNATURE
        }

        return signatureTypes;

    }
    
    private static Map<String,Object> buildSignatureSpain(Contact con, XC_Address__c addr, Integer n) {
			List<Map<String,Object>> l = new List<Map<String,Object>>();
			for(integer i = 1; i<=n; i++){
				Map<String,Object> m = new Map<String,Object>{
					'signer-id' => con.Id,
					'keyword' => 'FIRMA_CLIENTE_ACCETTAZIONE'+i,
					'offset-x' => '0',
					'offset-y' => '0',
					'width' => '100',
					'height' => '25',
					'reason' => 'Firma cliente accettazione',
					'location' => ''
				};
				l.add(m);
			}
			Map<String,Object> m = new Map<String,Object>{
					'signer-id' => con.Id,
					'keyword' => 'CUSTOMER_SIGNATURE',
					'offset-x' => '0',
					'offset-y' => '0',
					'width' => '100',
					'height' => '25',
					'reason' => 'Firma cliente accettazione',
					'location' => ''
				};
			l.add(m);
            Map<String,Object> res = new Map<String,Object>();
            if(con != null){// && addr != null){
                res = new Map<String,Object>{
                    'keyword-signature-field' => l 
                };
            }
            return res; 
        }
    
}