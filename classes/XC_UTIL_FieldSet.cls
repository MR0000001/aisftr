/**
 * @author Francesco Imperioli
 * @description an Utility Class to manage fieldsets
 * @created date 02-03-2020
 */
public without sharing class XC_UTIL_FieldSet {

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
        @AuraEnabled public Boolean isReadonly {get;set;}
    }

    /**
	*@Author: Francesco Imperioli fimperioli@deloitte.it
	*@Date creation: 21-10-2019
	*@Description: Maps fieldset members to custom wrapper class
	**/
    public static List<FieldWrapper> getFieldSetFields (String fieldSetName,String sObjectName){

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
                    fw.isReadonly = false;

                    result.add(fw);
                }
            }
        }
        return result;
    }


}