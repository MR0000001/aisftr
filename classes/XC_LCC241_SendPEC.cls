/**
* The Class XC_LCC241_SendPEC
* @author Simone Trenta - strenta@deloitte.it
* @description controller for XC_LCP241_SendPEC component
*/
public without sharing class XC_LCC241_SendPEC {
	
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @date Modification dd/mm/yyyy
     * @description for init component 241 
     * @param caseId
     * @return map
     */ 
    @AuraEnabled 
    public static Map<String,Object> retrieveInformation(String caseId){
        Map<String,Object> res = new Map<String,Object>();

        Map<Id,Case> mapCase = new Map<Id,Case>([
           SELECT id, 
               XC_CheckList__r.XC_ContractorCompany__r.Name, XC_CheckList__r.XC_ContractorCompany__r.XC_CertifiedEmail__c, 
               XC_CheckList__r.XC_Contract__r.XC_ContractSAP__c, XC_NonComplianceWorkOrder__r.WorkOrderNumber, XC_NonComplianceWorkOrder__r.Account.Name, 
               XC_CheckList__r.XC_CheckDate__c, XC_NonComplianceWorkOrder__r.XC_Address__r.Name, XC_LegalEntity__c, XC_CheckList__r.XC_PartnerVATNumber2__c, XC_CheckList__r.Owner.Name,  XC_CheckList__r.Owner.Email
           FROM Case 
           WHERE Id =: caseId
        ]);

        Boolean noChecklist = String.isBlank(mapCase.values()[0].XC_CheckList__c);

        res.put('PartnersName', 'Non Conformità - '+mapCase.values()[0].XC_CheckList__r.XC_ContractorCompany__r.Name+'('+mapCase.values()[0].XC_CheckList__r.XC_PartnerVATNumber2__c+') - '+mapCase.values()[0].XC_CheckList__r.Owner.Name+': '+mapCase.values()[0].XC_CheckList__r.Owner.Email);

        res.put('PEC', mapCase.values()[0].XC_CheckList__r.XC_ContractorCompany__r.XC_CertifiedEmail__c);
        res.put('SAPContract', mapCase.values()[0].XC_CheckList__r.XC_Contract__r.XC_ContractSAP__c);
        res.put('WorkOrder', mapCase.values()[0].XC_NonComplianceWorkOrder__r.WorkOrderNumber);
        res.put('Customer', mapCase.values()[0].XC_NonComplianceWorkOrder__r.Account.Name);
        res.put('InspectionDate', mapCase.values()[0].XC_CheckList__r.XC_CheckDate__c);
        res.put('InspectionLocation', mapCase.values()[0].XC_NonComplianceWorkOrder__r.XC_Address__r.Name);
        res.put('Summary', noChecklist?'':getSummary(mapCase.values()[0].XC_CheckList__c));

        res.put('LegalEntity', mapCase.values()[0].XC_LegalEntity__c);

        res.put('ChecklistError', noChecklist);

        Map<Id,User> oUserMap = new Map<Id,User>([
            SELECT Id, XC_CanSendPEC__c
            FROM User
            WHERE Id =: userInfo.getUserId()]);

        res.put('CanSendPec', oUserMap.values()[0].XC_CanSendPEC__c);

        return res;
    }


   
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @date Modification dd/mm/yyyy
     * @description 
     * @param req
     * @return map
     */ 
    @AuraEnabled 
    public static String sendPec(String req){

        Map<String,String> inp = (Map<String,String>) JSON.deserialize(req, Map<String,String>.class);

        String partnersName = inp.get('PartnersName');
        String pec = inp.get('PEC');
        String sapContract = inp.get('SAPContract');
        String workOrder = inp.get('WorkOrder');
        String customer = inp.get('Customer');
        String inspectionDate = inp.get('InspectionDate');
        String inspectionLocation = inp.get('InspectionLocation');
        String summary = inp.get('Summary');
        String legalEntity = inp.get('LegalEntity');
        String caseId = inp.get('CaseId');

        Map<Id,User> oUserMap = new Map<Id,User>([
            SELECT Id, Name
            FROM User
            WHERE Id =: userInfo.getUserId()]);

        XC_REST_SendPEC_U.RequestWrapper wr = new XC_REST_SendPEC_U.RequestWrapper();
        
        wr.sendpec.receiver_pec = pec;
        wr.sendpec.body = sapContract+'|'+workOrder+'|'+inspectionDate+'|'+inspectionLocation+'|'+summary+'|'+oUserMap.values()[0].Name+'|'+customer;
        wr.sendpec.subject = partnersName;
        wr.sendpec.sender_pec = 'enel'; //tbd
        wr.sendpec.legal_entity = legalEntity;
        wr.sendpec.email_type = 'PEC';
        
        XC_REST_SendPEC_U.ResponseWrapper wrRes = XC_REST_SendPEC.sendRequest(wr);

        return JSON.serialize(wrRes,true);
    }


    private static String getSummary(String qcid) {   

        String summary = '';

        Map<String,String> mapcom = new Map<String,String>();
        Map<String,String> mapans = new Map<String,String>();
        Map<String,String> mapgra = new Map<String,String>();

        XC_B2BG_QualityCheck__c qc = (XC_B2BG_QualityCheck__c)XC_UTIL_Sobject.selectAllFields(qcid)[0];

        List<String> listQuestion = new List<String>();
        Map<String, Object> mapObjectTemp = qc.getPopulatedFieldsAsMap();
        for(String field : mapObjectTemp.keySet()) {
            if(field.toLowerCase().contains('answer') && mapObjectTemp.get(field) == 'NC') {
                listQuestion.add('toLabel('+field.replace('XC_Answer','XC_Question')+')');

                String code = field.removeEnd('__c').removeStart('XC_Answer');

                String answerValue = (String) mapObjectTemp.get(field);

                mapans.put(code,answerValue);

                String fieldDescription = field.replace('XC_Answer','XC_NotCompliance_Comments');
                String commentValue = (String) mapObjectTemp.get(fieldDescription);

                mapcom.put(code,commentValue);

                String gravityField = 'XC_'+code+'Gravity__c';
                String gravityValue = (String) mapObjectTemp.get(gravityField);

                mapgra.put(code,gravityValue);

            }
        }
        
        if(listQuestion.isEmpty()) {
            return summary;
        }


        String queryString = 'SELECT ' + string.join(listQuestion,',') + ' FROM XC_B2BG_QualityCheck__c WHERE Id =: qcid ';    
        XC_B2BG_QualityCheck__c res = (XC_B2BG_QualityCheck__c)Database.query(String.escapeSingleQuotes(queryString))[0];

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('XC_B2BG_QualityCheck__c');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        listQuestion = new List<String>();
        mapObjectTemp = res.getPopulatedFieldsAsMap();
        for(String field : mapObjectTemp.keySet()) {
            if(field.toLowerCase().contains('question')) {
                String valueDescription = (String) mapObjectTemp.get(field);
                String code = field.removeEnd('__c').removeStart('XC_Question');
                summary += code+': '+valueDescription+'\n';
                if(!String.isBlank(mapcom.get(code))){
                    summary += fieldMap.get('XC_NotCompliance_Comments'+code+'__c').getDescribe().getLabel()+': '+mapcom.get(code)+'\n';
                }
                if(!String.isBlank(mapans.get(code))){
                    summary += fieldMap.get('XC_Answer'+code+'__c').getDescribe().getLabel()+': '+mapans.get(code)+'\n';
                }
                if(!String.isBlank(mapgra.get(code))){
                    summary += fieldMap.get('XC_'+code+'Gravity__c').getDescribe().getLabel()+': '+mapgra.get(code)+'\n';
                }
            }
        }

        return summary;
    }
   
}