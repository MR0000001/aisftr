/**
 *  
 * ===================================================================================.
 *
 * @author           VBV
 * @version          V0.1
 * @className        XC_AT_Constants
 * @description      Class with general constants of the application
 * @email            vbarquero@deloitte.es
 * @testClass        pte
 * @dateCreated      2018/12/13
 * ===================================================================================
 */
public class XC_AT_Constants {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_AT_Constants');
    /**
     * @description XC_AT_Constants.
    */
    public XC_AT_Constants(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_AT_Constants');
    }

    //RecordType
    public final static String CASE_RECORD_TYPE_XC_ATTENTION_ESPANA = 'XC_ESP_Case';
    
    public final static String TASK_RECORD_TYPE_XC_ATTENTION_ESPANA = 'XC_Task_Spain';
    public final static String WO_RECORD_TYPE_XC_ATTENTION_ESPANA = 'XC_ESP_WorkOrder';
    public final static String OPP_RECORD_TYPE_XC_ATTENTION_ESPANA = 'XC_Opportunity_Spain';

    public static final String TRIGGER_REASON_MOT001 = 'MOT001';
    public static final String TRIGGER_REASON_MOT002 = 'MOT002';
    public static final String TRIGGER_REASON_MOT003 = 'MOT003';
    public static final String TRIGGER_REASON_MOT004 = 'MOT004';
    public static final String TRIGGER_REASON_MOT005 = 'MOT005';
    public static final String TRIGGER_REASON_MOT006 = 'XCMOT006';

    public static final String TRIGGER_SUBCAUSE_ATCL002 = 'ATCL002';
    public static final String TRIGGER_SUBCAUSE_ATCL003 = 'ATCL003';
    public static final String TRIGGER_SUBCAUSE_ATCL004 = 'ATCL004';    
    public static final String TRIGGER_SUBCAUSE_ATCL006 = 'ATCL006';
    public static final String TRIGGER_SUBCAUSE_ATCL007 = 'ATCL007';
    public static final String TRIGGER_SUBCAUSE_ATCL010 = 'ATCL010';
    public static final String TRIGGER_SUBCAUSE_ATCL011 = 'ATCL011';
    public static final String TRIGGER_SUBCAUSE_ATCL016 = 'ATCL016';
    public static final String TRIGGER_SUBCAUSE_ATCL019 = 'ATCL019';
    public static final String TRIGGER_SUBCAUSE_ATCL020 = 'ATCL020';
    public static final String TRIGGER_SUBCAUSE_ATCL023 = 'ATCL023';
    public static final String TRIGGER_SUBCAUSE_ATCL024 = 'ATCL024';
    public static final String TRIGGER_SUBCAUSE_ATCL028 = 'ATCL028';

    public static final String CASE_TRIGGER_SUBTYPE_XC001 = 'XC001';
    public static final String CASE_TRIGGER_SUBTYPE_XC002 = 'XC002';
    public static final String CASE_TRIGGER_SUBTYPE_XC181 = 'XC181';
    public static final String TRIGGER_STATUS_ESTA001 = 'ESTA001';
    public static final String TRIGGER_STATUS_ESTA002 = 'ESTA002';
    public static final String TRIGGER_STATUS_ESTA003 = 'ESTA003';
    public static final String TRIGGER_STATUS_ESTA004 = 'ESTA004';
    public static final String TRIGGER_STATUS_ESTA007 = 'ESTA007';
    public static final String TRIGGER_STATUS_ESTA008 = 'ESTA008';

    public static final String CASE_SUBSTATUS_SUB001 = 'SUB001';
    public static final String CASE_SUBSTATUS_SUB002 = 'SUB002';
    public static final String CASE_SUBSTATUS_SUB003 = 'SUB003';
    public static final String CASE_SUBSTATUS_SUB004 = 'SUB004';
    public static final String CASE_SUBSTATUS_SUB005 = 'SUB005';
    public static final String CASE_SUBSTATUS_SUB006 = 'SUB006';
    public static final String CASE_SUBSTATUS_SUB007 = 'SUB007';
    public static final String CASE_SUBSTATUS_SUB008 = 'SUB008';
    public static final String CASE_SUBSTATUS_SUB009 = 'SUB009';
    public static final String CASE_SUBSTATUS_SUB010 = 'SUB010';

    public static final String WO_STATUS_COMPLETED = Label.XC_CL_Completed;
    public static final String WO_STATUS_CANNOT_COMPLETED  = 'Cannot Complete';
    public static final String WO_STATUS_CANCELED = 'Canceled';
    public static final String WO_STATUS_ONHOLD = 'On Hold';
    
    public static final String TASK_STATUS_COMPLETED  = 'Completed';
    public static final String TASK_STATUS_REJECTED = Label.XC_CL_Configuration_Rejected;
    public static final String TASK_STATUS_CANCELED = 'Canceled';
    public static final String TRIGGER_TASK_STATUS_NEW= 'New';

    public static final String TRIGGER_PRIORITY_0 = '0';    
    public static final String TRIGGER_PRIORITY_1 = '1';
    public static final String TRIGGER_PRIORITY_2 = '2';
    public static final String TRIGGER_COMMENT_ACTION_PLAN = 'Action Plan Enel X';
    public static final String ASSET_TYPE_PRODUCTO = 'AT001';

    public static final String TRIGGER_RESULT_RS003= 'RS003';
    
    //Vector and public key used in XC_util_CustomerInteractionGeneration_U
    public static final String INIT_VECTOR = 'wTlaBeI7TDhsbHL/';
    public static final String PUBLIC_KEY = '+eT4iCC9xNQXjDIKfwtztrbhz7wnLJLG';
}