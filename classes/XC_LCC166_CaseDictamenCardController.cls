/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Date creation: 21-10-2019
*@Description: Component controller for XC_LCC166_CaseDictamenCardController
**/
public with sharing class XC_LCC166_CaseDictamenCardController {


    /**
	*@Author: Francesco Imperioli fimperioli@deloitte.it
	*@Date creation: 21-10-2019
	*@Description: Custom wrapper class for fieldset member
	**/
    public class FieldWrapper{
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String fieldLabel {get;set;}
        @AuraEnabled public String helpText {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public Boolean isHtmlFormatted {get;set;}
    }

    /**
	*@Author: Francesco Imperioli fimperioli@deloitte.it
	*@Date creation: 21-10-2019
	*@Description: Execute SOSL Query to find dictamenRecordId
	**/
    @AuraEnabled
    public static String getDictamenRecordId(String workOrderId){

        List<XC_DictamenItem__c> dictamens = [SELECT ID FROM XC_DictamenItem__c WHERE XC_WorkOrder__c = :workOrderId LIMIT 1];
        if(dictamens.isEmpty()){
            return '';
        }
        /*String result= !dictamens.isEmpty() ? dictamens[0].Id : '';
        return result;*/
		return dictamens[0].Id;
    }

    /**
	*@Author: Francesco Imperioli fimperioli@deloitte.it
	*@Date creation: 21-10-2019
	*@Description: returns fieldsetmembers fields
	**/
    @AuraEnabled
    public static List<FieldWrapper> getFields(String fieldSetName,String sObjectType){
        return getFieldSetFields(fieldSetName,sObjectType);
    }


    /**
	*@Author: Francesco Imperioli fimperioli@deloitte.it
	*@Date creation: 21-10-2019
	*@Description: Maps fieldset members to custom wrapper class
	**/
    private static List<FieldWrapper> getFieldSetFields (String fieldSetName,String sObjectName){

        List<FieldWrapper> result = new List<FieldWrapper>();
        if(String.isNotBlank(fieldSetName) && String.isNotBlank(sObjectName)){
            Schema.DescribeSObjectResult desResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
            Map<String,Schema.SObjectField> objFieldMap = desResult.fields.getMap();
            Schema.FieldSet fieldSetObj = desResult.FieldSets.getMap().get(fieldSetName);

            if(fieldSetObj!=null){
                for(Schema.FieldSetMember fsm : fieldSetObj.getFields()){

                    FieldWrapper fw = new FieldWrapper();
                    fw.fieldLabel = String.valueOf(fsm.getLabel());
                    fw.fieldName = String.valueOf(fsm.getFieldPath());
                    fw.isRequired = fsm.getRequired() || fsm.getDbRequired();
                    fw.helpText = objFieldMap.get(String.valueOf(fsm.getFieldPath())).getDescribe().getInlineHelpText();
                    fw.isHtmlFormatted = objFieldMap.get(String.valueOf(fsm.getFieldPath())).getDescribe().isHtmlFormatted() &&
                    objFieldMap.get(String.valueOf(fsm.getFieldPath())).getDescribe().isCalculated(); 

                    result.add(fw);
                }
            }
        }
        return result;
    }

}