/** 
* @author Federico Manni - federico.manni@accenture.com
* @date Creation 10/10/2021
* @date Modification 27/10/2021 Denise Avolio - denise.avolio@accenture.com
* @description - XC_LCC_ValidateButton is custom controller for the lightning component XC_LCP_ValidateButton.
 */
public without sharing class XC_LCC_ValidateButton {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC_ValidateButton');
    
    public final static XC_CaseForAffBen__c CASE_TYP = XC_CaseForAffBen__c.getInstance('CaseManagement');
    
    public final static String CASE_REASON           = Test.isRunningTest() ? 'XCMOT022' : CASE_TYP.XC_CaseReason__c; 
    public final static String CASE_SUBCAUSE         = Test.isRunningTest() ? 'ATCL202' : CASE_TYP.XC_SubCause__c;
    public final static String CASE_STATUS_CLOSED    = 'ESTA007';
    public final static String CASE_STATUS_CANCELLED = 'ESTA008';
    
    public final static List<String> CASE_STATUS_LIST = new List<String>{
        CASE_STATUS_CLOSED, CASE_STATUS_CANCELLED
    };

    public class WrapperResult{
        @AuraEnabled
        public Boolean errorResult;
        @AuraEnabled
        public String errorMessage;

        public WrapperResult(){
            errorResult = false;
            errorMessage = '';
        }
    }

    /**
     * Description
     * @param recordId id
     * @returns void
     */
    @AuraEnabled
    public static WrapperResult validate(String recId){
        system.debug('recordId ' + recId);
        Id recordId = (Id)recId;
        SObject sobj = recordId.getSObjectType().newSObject(recordId);
        system.debug('sobj ' + sobj);
        WrapperResult wrresult;
        String plan = '';
        String code = ''; 
        
        //in case of Asset
        if(sobj instanceof Asset){

            List<NE__AssetItemAttribute__c> listAtt = checkAssetAtt(recordId);
            
            if(!listAtt.isEmpty() && !checkCase(recordId)){

                for(NE__AssetItemAttribute__c att : listAtt){
                    switch on att.Name{

                        when 'Plan' {
                            plan = att.NE__Value__c;
                        }
                        when 'AffBen_Code'{
                            code = att.NE__Value__c;
                        } 
                    }
                }

                wrresult = validate(plan, code, recordId, 'Asset');

            } else {
                wrresult = new WrapperResult();
                wrresult.errorResult = true;
                wrresult.errorMessage = Label.XC_CL_AffBen_GenericError;
            }
        } else if(sobj instanceof NE__OrderItem__c){ 
            //in case of Order Item
            List<NE__Order_Item_Attribute__c> listAtt = checkOrderItemAtt(recordId);
            
            if(!listAtt.isEmpty()){                                                   
                for(NE__Order_Item_Attribute__c att : listAtt){
                    switch on att.Name{
                        when 'Plan' {
                            plan = att.NE__Value__c;
                        }
                        when 'AffBen_Code'{
                            code = att.NE__Value__c;
                        } 
                    }
                }        

                wrresult = validate(plan, code, recordId, 'OrderItem');

            } else {
                wrresult = new WrapperResult();
                wrresult.errorResult = true;
                wrresult.errorMessage = Label.XC_CL_AffBen_GenericError;
            }
        }
        
        return wrresult;
    }

    private static Boolean checkCase(Id recordId){
        List<Case> cases = [SELECT id 
                            FROM Case
                            WHERE AssetId =: recordId
                            AND Reason =: CASE_REASON
                            AND SubCause__c =: CASE_SUBCAUSE
                            AND Status NOT IN :CASE_STATUS_LIST];

        return cases.isEmpty();
    }
    /**
     * Description
     * @param {any} Stringplan
     * @param {any} Stringcode
     * @param {any} IdrecordId
     * @param {any} Stringsobj
     * @returns {any}
     */
    private static WrapperResult validate(String plan, String code, Id recordId, String sobj){
        
        WrapperResult wrresult = new WrapperResult();

        Integer numAffiliate=0;
        Integer numAffiliateHolder=0;

        Integer numBeneficiary=0;
        Integer numBeneficiaryPercentage=0;

        Integer maxNumOfAffiliate=0;
        Integer minNumOfAffiliate=0;
        Integer maxNumOfBeneficiary=0;
        Integer minNumOfBeneficiary=0;

        List<XC_AffiliateBeneficiaryConfiguration__c> confs = retrieveConfigurations(plan, code);
        system.debug('confs ' + confs.size());
        List<XC_Affiliate_Beneficiary__c> affBens;
        
        Boolean toUpdate=true;

        if(!confs.isEmpty()){
            affBens = retrieveAffAndBen(recordId, sobj);

            for(XC_AffiliateBeneficiaryConfiguration__c conf : confs){
                if('XC_Affiliate'.equalsIgnoreCase(conf.XC_RecordType__c)){
                    maxNumOfAffiliate = Integer.valueof(conf.XC_MaxNumberOfType__c);
                    minNumOfAffiliate = Integer.valueof(conf.XC_MinNumberOfType__c);
                } else {
                    maxNumOfBeneficiary = Integer.valueof(conf.XC_MaxNumberOfType__c);
                    minNumOfBeneficiary = Integer.valueof(conf.XC_MinNumberOfType__c);
                }
            }
        
            if(!affBens.isEmpty()){

                for(XC_Affiliate_Beneficiary__c affBen : affBens){
                    if('Affiliate'.equalsIgnoreCase(affBen.RecordType.Name)){
                        numAffiliate++;
                        if('Holder'.equalsIgnoreCase(affBen.XC_Relationship__c)){
                            numAffiliateHolder++;
                        }
                    } else {
                        numBeneficiary++;
                        numBeneficiaryPercentage = numBeneficiaryPercentage + Integer.valueof(affBen.XC_Partecipation_Percentage__c);
                    }
                }
                /** Check on Affiliate */
                if(numAffiliate < minNumOfAffiliate || numAffiliate > maxNumOfAffiliate){
                    wrresult.errorResult = true;
                    wrresult.errorMessage = Label.XC_CL_AffBen_ErrorAffiliateNumber;
                    toUpdate=false;
                }
                if(numAffiliateHolder > 1 || numAffiliateHolder==0){
                    wrresult.errorResult = true;
                    wrresult.errorMessage = Label.XC_CL_AffBen_ErrorAffiliateHolder;
                    toUpdate=false;
                }

                /** Check on Beneficiary */
                if(numBeneficiary < minNumOfBeneficiary || numBeneficiary > maxNumOfBeneficiary){
                    wrresult.errorResult = true;
                    wrresult.errorMessage = Label.XC_CL_AffBen_ErrorBeneficiaryNumber;
                    toUpdate=false;
                }
                if(numBeneficiary > 0 && numBeneficiaryPercentage != 100){
                    wrresult.errorResult = true;
                    wrresult.errorMessage = Label.XC_CL_AffBen_ErrorBeneficiaryPercentage;
                    toUpdate=false;
                }
            } else {
                wrresult.errorResult = true;
                wrresult.errorMessage = Label.XC_CL_AffBen_GenericError;
                toUpdate = false;
            }
        } else {
            wrresult.errorResult = true;
            wrresult.errorMessage = Label.XC_CL_AffBen_GenericError;
            toUpdate = false;
        }

        if(toUpdate){
            wrresult.errorResult = false;
            wrresult.errorMessage = Label.XC_CL_AffBen_SuccessValidate;
            updateAffAndBen(affBens);
        }

        return wrresult;
    }

    private static void updateAffAndBen(List<XC_Affiliate_Beneficiary__c> affBens){
        for(XC_Affiliate_Beneficiary__c affBen : affBens){
            affBen.XC_Status__c = 'Validated';
        }
        update affBens;
    }

    /**
     * Description
     * @param {any} IdrecordId
     * @param {any} StringsobjType
     * @returns {any}
     */
    private static List<XC_Affiliate_Beneficiary__c> retrieveAffAndBen(Id recordId, String sobjType){
        List<XC_Affiliate_Beneficiary__c> affBens;
        if('Asset'.equalsIgnoreCase(sobjType)){
            affBens = [SELECT Id, RecordType.Name, XC_Relationship__c, XC_Partecipation_Percentage__c, XC_Status__c
                        FROM XC_Affiliate_Beneficiary__c
                        WHERE XC_Asset__c =: recordId];
        } else {
            affBens = [SELECT Id, RecordType.Name, XC_Relationship__c, XC_Partecipation_Percentage__c, XC_Status__c
                        FROM XC_Affiliate_Beneficiary__c
                        WHERE XC_OrderItem__c =: recordId];
        }
        return affBens;
    }

    /**
     * Description
     * @param {any} IdrecordId
     * @returns {any}
     */
    private static List<NE__Order_Item_Attribute__c> checkOrderItemAtt(Id recordId){
        Boolean result = false;
        List<NE__Order_Item_Attribute__c> oItemAtt = [SELECT id, Name, NE__Value__c 
                                                    FROM NE__Order_Item_Attribute__c 
                                                    WHERE NE__Order_Item__c =: recordId
                                                    AND Name in ('Plan','AffBen_Code')];
        return oItemAtt;
    }

    /**
     * Description
     * @param {any} IdrecordId
     * @returns {any}
     */
    private static List<NE__AssetItemAttribute__c> checkAssetAtt(Id recordId){
        Boolean result = false;
        List<NE__AssetItemAttribute__c> oItemAtt = [SELECT id, Name, NE__Value__c 
                                                    FROM NE__AssetItemAttribute__c 
                                                    WHERE NE__Asset__c =: recordId
                                                    AND Name in ('Plan','AffBen_Code')];
        return oItemAtt;
    }

    /**
     * Description
     * @param {any} Stringplan
     * @param {any} Stringcode
     * @returns {any}
     */
    private static List<XC_AffiliateBeneficiaryConfiguration__c> retrieveConfigurations(String plan, String code){
        List<XC_AffiliateBeneficiaryConfiguration__c> conf = [SELECT id, XC_ProductPlan__c, XC_ConfigurationCode__c, XC_MaxNumberOfType__c, XC_MinNumberOfType__c, XC_RecordType__c
                                                                FROM XC_AffiliateBeneficiaryConfiguration__c
                                                                WHERE XC_ConfigurationType__c = 'Configuration Validation'
                                                                AND XC_ProductPlan__c = :plan
                                                                AND XC_ConfigurationCode__c =:code];                                       
        return conf;
    }

   
}