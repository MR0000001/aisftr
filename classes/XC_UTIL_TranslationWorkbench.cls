/**
* @author Nicolo Fodera – nicolo.fodera@enel.com
* @date Creation 21/02/2022
* @date Modification 21/02/2022
* @description XC_UTIL_TranslationWorkbench – Manage dinamically field value translation using VF rendering
*/
public class XC_UTIL_TranslationWorkbench {   
    
    /** 
    * @author Nicolo Fodera - nicolo.fodera@enel.com
    * @date 21/02/2022 
    * @description Translate field value "fieldsToBeTranslated" of record "recordId"  in the language "language"
    */
   /* public static Map<String,String> translate(Id recordId, String language, List<String> fieldsToBeTranslated){        
        Map<String,String> translatedFieldsMap = new Map<String,String>(); 
        Pagereference r = null;
        if(recordId.getSObjectType() == Case.sObjectType){
            r = Page.XC_VFP_CaseTranslationWorkbench;
        //else if(recordId.getSObjectType() == Asset.sObjectType){
        //  r = Page.XC_VFP_AssetTranslationWorkbench;  
        }else{ 
            for(String field : fieldsToBeTranslated){ 
                translatedFieldsMap.put(field, null);
            }
            return translatedFieldsMap;
        }
         
        r.getParameters().put('id', recordId); 
        r.getParameters().put('label_lang',language);
        String pageContent = r.getContent().toString(); 
        for(String field : fieldsToBeTranslated){ 
                translatedFieldsMap.put(field, getTagValue(field,pageContent));
        } 
        return translatedFieldsMap;     
    } */
    
    /** 
    * @author Nicolo Fodera - nicolo.fodera@enel.com 
    * @date 21/02/2022 
    * @description Retrieve field value rendered by the visualforce page 
    */
    /*private static String getTagValue(String startingPattern, String pageContent){  
            String tagValue = null;
            Integer startingIndex = pageContent.IndexOf(startingPattern);
            if(startingIndex > 0){
                    String substring = pageContent.substring(startingIndex + startingPattern.length() + 2, pageContent.length()); 
                    Integer endingIndex = substring.IndexOf('</'); 
                    if(endingIndex > 0){
                        substring = substring.substring(0,endingIndex).unescapeHtml4().trim();
                        tagValue = String.isBlank(substring.replaceAll('\\p{Z}','')) ? null : substring; 
                        System.debug('getTagValue' + startingPattern + '-->'+tagValue+ '-->');
                        
                    }
            }
            return tagValue;
    } */
    
    
     /** 
    * @author Nicolo Fodera - nicolo.fodera@enel.com 
    * @date 21/02/2022 
    * @description Put to toLabel keyword on query fields (e.g. "select column1, colomn2 from XC_SobjectName__c where"  according to the custom setting XC_APIDynamicFieldTranslation__c
    */
    public static String toLabelizeQueryFields(String sObjectName, String clientSystem, String queryFields) {
        String queryFieldToBeReturned = queryFields.toUpperCase().normalizeSpace();
        System.debug('toLabelizeQueryFields input: -> ' + sObjectName + ' - ' + clientSystem +  ' - ' + queryFields); 
        List<XC_APIDynamicFieldTranslation__c> csList = [select Id,   XC_SobjectName__c, XC_FieldAPINameList__c, XC_ClientSystem__c from XC_APIDynamicFieldTranslation__c where XC_SobjectName__c =: sObjectName and XC_ClientSystem__c =: clientSystem];
        if(!csList.isEmpty()){
            if(csList[0].XC_FieldAPINameList__c != null && csList[0].XC_FieldAPINameList__c != ''){
                    List<String> fieldAPINameList = csList[0].XC_FieldAPINameList__c.split(';');
                    for(String fieldAPIName : fieldAPINameList){
                        fieldAPIName = fieldAPIName.trim().toUpperCase();
                        queryFieldToBeReturned = queryFieldToBeReturned.replace(',' + fieldAPIName + ',' , ',' + 'toLabel('+ fieldAPIName + ')' + ',');
                        queryFieldToBeReturned = queryFieldToBeReturned.replace(',' + fieldAPIName + ' ' , ',' + 'toLabel('+ fieldAPIName + ')' + ' ');
                        queryFieldToBeReturned = queryFieldToBeReturned.replace(' ' + fieldAPIName + ',' , ' ' + 'toLabel('+ fieldAPIName + ')' + ',' ); 
                        queryFieldToBeReturned = queryFieldToBeReturned.replace(' ' + fieldAPIName + ' ' , ' ' + 'toLabel('+ fieldAPIName + ')' + ' ' ); 
                    } 
                    
            } 
        } 
        queryFieldToBeReturned = queryFieldToBeReturned + ' ';
        System.debug('toLabelizeQueryFields output: -> ' + sObjectName + ' - ' + clientSystem +  ' - ' + queryFieldToBeReturned); 
        return queryFieldToBeReturned;
    }

}