/**
* @author Monica Cutillo - monica.cutillo@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 06/11/2018
* @date Modification
* @description XC_UTIL_ResultWrapper - Generic result of backend call
*/
public class XC_UTIL_ResultWrapper {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ResultWrapper');

    @AuraEnabled
    public Boolean success = false;
    @AuraEnabled
    public String titleMessage = '';
    @AuraEnabled
    public String resultMessage = '';
    @AuraEnabled 
    public String typeMessage = '';
    @AuraEnabled
    public Boolean isValid = false; 
    @AuraEnabled
    public String recordId = '';
    @AuraEnabled
    public String objectInfo = '';
    @AuraEnabled
    public Boolean executeNextStep = false;
    @AuraEnabled
    public Boolean outcome = true;
    @AuraEnabled
    public String fieldName = '';
    @AuraEnabled
    public String fieldName2 = '';
     @AuraEnabled
     public String fieldName3 = '';
     @AuraEnabled
     public String fieldName4 = '';
     @AuraEnabled
     public String fieldName5 = '';
     @AuraEnabled
     public String parentObjectGlovia = ''; // 18/11/19 DDT Glovia Canvas Doxee
     @AuraEnabled
     public String legalEntity = '';
     @AuraEnabled
     public String objectResult;
    @AuraEnabled
    public boolean NR2626 = false; //added for NR2626
    //DeAv 04.07.2022 - NR2330 START 
    @AuraEnabled
    public String rtDevName = '';
    //DeAv 04.07.2022 - NR2330 END

    /** @description NON CANCELLARE!**/
    public XC_UTIL_ResultWrapper(){
        XC_UTIL_Debug.debug(false, 'XC_UTIL_ResultWrapper');
    }  

    /** 
     * @description Constructor with success value
     * @param isSuccess 
     */
    public XC_UTIL_ResultWrapper(Boolean isSuccess){
        success = isSuccess;
    }  

    /** 
     * @description Constructor to convert XC_UTIL_Sobject.WrapperResult to XC_UTIL_ResultWrapper
     * @param sobjectResult 
     */
    public XC_UTIL_ResultWrapper(XC_UTIL_Sobject.WrapperResult sobjectResult){
        success = sobjectResult.success;
        recordId = sobjectResult.recordId;
        objectInfo = sobjectResult.objectInfo;
        resultMessage = sobjectResult.errorMessage;
        if(String.isNotBlank(sobjectResult.errorfieldName)){
            resultMessage = resultMessage+': '+sobjectResult.errorfieldName;
        }
    } 

    /** 
     * @description Constructor to convert XC_LCC002_NewLead_W.InsertResultWrapper to XC_UTIL_ResultWrapper
     * @param insertWr 
     */
    public XC_UTIL_ResultWrapper(XC_LCC002_NewLead_W.InsertResultWrapper insertWr){
        success = insertWr.success;
        resultMessage = insertWr.errorMessage;
        recordId = insertWr.recordId;
        fieldName = insertWr.fieldName;
    } 
}