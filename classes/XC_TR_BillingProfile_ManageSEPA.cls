/**
 * The Class XC_TR_BillingProfile_ManageSEPA.
 *
 * @author  Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
 * @date    31/07/2019
 * @description class for populates SEPA fields on Billing Profile
 */
public without sharing class XC_TR_BillingProfile_ManageSEPA {
	
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method for create SepaMandate Autonumber
     * @param listNew - a list of NE__Billing_Profile__c
    */
    public static void createSepaMandate(List<NE__Billing_Profile__c> listNew){


        Set<String> legalEntities = new Set<String>();

        for(NE__Billing_Profile__c bp : listNew){
            if(bp.NE__Payment__c=='Direct Debt' && String.isNotBlank(bp.XC_LegalEntity__c)){
                legalEntities.add(bp.XC_LegalEntity__c);
            }
        }

        //add configuration check on new CMDT 
        //TODO: Add segment management after deploy in UAT
        Map<String,XC_CM_SEPA_Configuration__mdt> leSEPAConfMap = new Map<String,XC_CM_SEPA_Configuration__mdt>();

        List<XC_CM_SEPA_Configuration__mdt> SEPAConfigurations = [SELECT 
        XC_LegalEntity__c,XC_MandateCodeFormat__c,XC_Segment__c,
        XC_SIASDDAgencyCode__c,XC_SIASDDRequestCause__c,XC_SIASDDSEPASchema__c,
        XC_SIASDDSequenceType__c,XC_SIASDDServiceLevel__c,XC_SIASDDCreditorCode__c 
        FROM XC_CM_SEPA_Configuration__mdt WHERE XC_LegalEntity__c IN :legalEntities];

        for(XC_CM_SEPA_Configuration__mdt SEPAConf : SEPAConfigurations){
            leSEPAConfMap.put(SEPAConf.XC_LegalEntity__c,SEPAConf);
        }


        List<NE__Billing_Profile__c> billingToUpdate = new List<NE__Billing_Profile__c>();
        for(NE__Billing_Profile__c bp : listNew){
            if(bp.NE__Payment__c=='Direct Debt'){
                System.Debug('SEPA MANDATE ENTERED');
                NE__Billing_Profile__c billingP = new NE__Billing_Profile__c(id=bp.id);
                Integer randomNumber = Math.round((Math.random() * (900000) + 100000));
                //billingP.XC_SepaMandateDate__c = System.now().date();   // NM LR - 2020/02/04
                billingP.XC_SepaMandateDate__c = DateTime.Now().dateGMT(); 


                if(String.isNotBlank(bp.XC_LegalEntity__c) && leSEPAConfMap.containsKey(bp.XC_LegalEntity__c)){
                    //update additional fields on BP and generate a new mandate string as defined in the XC_MandateCodeFormat__c field of configuration cmdt
                    XC_CM_SEPA_Configuration__mdt currentConf = leSEPAConfMap.get(bp.XC_LegalEntity__c);
                    String progressiveCode = '2'+bp.XC_SepaAutoNumber__c.substring(2);
                    billingP.XC_SepaMandate__c = (String.isBlank(bp.XC_SepaMandate__c)) ? currentConf.XC_MandateCodeFormat__c.replace('{autonumber}',progressiveCode) : bp.XC_SepaMandate__c;
                    billingP.XC_SIASDDAgencyCode__c = currentConf.XC_SIASDDAgencyCode__c;
                    billingP.XC_SIASDDRequestCause__c = currentConf.XC_SIASDDRequestCause__c;
                    billingP.XC_SIASDDSEPASchema__c = currentConf.XC_SIASDDSEPASchema__c;
                    billingP.XC_SIASDDSequenceType__c = currentConf.XC_SIASDDSequenceType__c;
                    billingP.XC_SIASDDServiceLevel__c = currentConf.XC_SIASDDServiceLevel__c;
                    billingP.XC_SIASDDCreditorCode__c = currentConf.XC_SIASDDCreditorCode__c;

                }else{
                    billingP.XC_SepaMandate__c = (String.isBlank(bp.XC_SepaMandate__c)) ? 'SEPA'+randomNumber+bp.XC_SepaAutoNumber__c+'XC'+String.valueof(DateTime.now().getTime()) : bp.XC_SepaMandate__c;
                }
                billingToUpdate.add(billingP);
                System.DEBUG('SEPA MANDATE END:: ' + JSON.serialize(billingP));
            }
            
        }
        XC_UTIL_Sobject.updateListRecords(billingToUpdate);
        
    }



}