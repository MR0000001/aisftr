/**
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 27/04/2019
 * @date Modification DD/MM/YYYY
 * @description XC_UTIL_DependentPicklist – UTIL to retrieve dependent Picklist data
 */
public class XC_UTIL_DependentPicklist {
    
    private static String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

    /**
     * @description PicklistWrapper class
     */
    public class PicklistWrapper{
    	public Map<String, List<String>> pickListMap;
        public String parentFieldLabel;
        public String childFieldLabel;      
    }
        
    /**
     * @description PicklistEntryWrapper class
     */
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue;
        public String label;
        public String value;
        public String validFor;
    }
    
    /**
     * @description get Dependent Picklist data wrapper
     * @param objectName object name
     * @param parentField parent Field name
     * @param childField child Field name
     * @return wrapper result
     */
    public static PicklistWrapper getDependentPicklist(String objectName, string parentField, string childField) {
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(objectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
 
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(objectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            /*pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());*/
            pickListMap.put(ple.getValue(), new List<String>());
            controllingValues.add(ple.getValue());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.value);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
    /**
     * @description decimalToBinary
     * Refer from here https://salesforce.stackexchange.com/questions/4462/get-lists-of-dependent-picklist-options-in-apex
     * @param val
     * @return result value
     */
    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    /**
     * @description base64ToBits
     * @param validFor
     * @return result value
     */
    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) {
            return '';
        }
        
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
}