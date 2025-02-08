/**
 * The Class ZuoraWebserviceUtil.
 */
public class ZuoraWebserviceUtil {
    
    /**
     * Read field set.
     *
     * @param fieldSetName the field set name
     * @param ObjectName the object name
     * @return the list
     */
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }  
    
    /**
     * Generate fields to query from field set.
     *
     * @param fieldSetName the field set name
     * @param ObjectName the object name
     * @return the string
     */
    public static String generateFieldsToQueryFromFieldSet(String fieldSetName, String ObjectName){
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(fieldSetName, ObjectName);
        String fieldSet = '';
        List<String> apiNames = new List<String>();
        for(Integer i=0; i<fieldSetMemberList.size(); i++){
            String apiName = fieldSetMemberList[i].getFieldPath();
            if(i == 0){
                apiName = ','+apiName;
            }
            apiNames.add(apiName);   
        }
        if(apiNames.size() > 0){
            fieldSet = String.join(apiNames, ','); 
        } 
        return fieldSet;
    }
    

    
	/**
	 * Generate additional fields.
	 *
	 * @param fieldSetName the field set name
	 * @param ObjectName the object name
	 * @param obj the obj
	 * @return the string
	 */
	public static String generateAdditionalFields(String fieldSetName, String ObjectName, SObject obj){
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(fieldSetName,ObjectName);
        String additionalFields = '';
        for(Integer i = 0; i< fieldSetMemberList.size(); i++){
            String apiName = fieldSetMemberList[i].getFieldPath();
            System.debug('apiName-->'+apiName);
            Object raw = obj.get(apiName);
            Boolean isDate = raw instanceof Date;
            String value = '';
            if(isDate){
                Date data = (Date)raw;
                value = String.valueOf(obj.get(apiName)).SubStringBefore(' ');
            }else{
                value = String.valueOf(obj.get(apiName));
            }
            additionalFields += ',';
            additionalFields += '"'+apiName+'":';
            additionalFields += value == null ? 'null':'"'+value+'"';
            
        }
        System.debug('additionalFields-->'+additionalFields);

        return additionalFields;
        
    }
}