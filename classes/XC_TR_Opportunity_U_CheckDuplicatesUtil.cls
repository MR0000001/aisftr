/**
* @description XC_TR_Opportunity_U_CheckDuplicatesUtil – Util Class for XC_TR_Opportunity_U_CheckDuplicates
*/ 
public class XC_TR_Opportunity_U_CheckDuplicatesUtil { 

    private static final Integer NOT_DUPLICATE = 0;
    private static final Integer SIMPLE_DUPLICATE = 1;
    private static final Integer DUPLICATE_WITHIN_NHOURS = 2;

    /** 
    * @description Check the key-fields on the opportunity: if they all are equals to another opp, so they are duplicated.   
    * @param dupWr
    * @param o
    * @return Boolean
    * @author Simone Trenta - strenta@deloitte.it
    */
    public static Boolean checkFields(XC_TR_Opportunity_U_CheckDuplicates.DuplicateWrapper dupWr, Opportunity o){
        Boolean check = false;

        Map<String,String> mapFields = new Map<String,String>{
            dupWr.a.Name => o.XC_Address__r.Name,
            dupWr.a.XC_AddressCountry__c => o.XC_Address__r.XC_AddressCountry__c,
            dupWr.a.XC_AddressProvince__c => o.XC_Address__r.XC_AddressProvince__c,
            dupWr.a.XC_Category__c => o.XC_Address__r.XC_Category__c,
            dupWr.a.XC_City__c => o.XC_Address__r.XC_City__c,
            dupWr.a.XC_door__c => o.XC_Address__r.XC_door__c,
            dupWr.a.XC_floor__c => o.XC_Address__r.XC_floor__c,
            dupWr.a.XC_postalCode__c => o.XC_Address__r.XC_postalCode__c,
            dupWr.a.XC_stair__c => o.XC_Address__r.XC_stair__c,
            dupWr.a.XC_streetNumber__c => o.XC_Address__r.XC_streetNumber__c,
            dupWr.a.XC_streetType__c => o.XC_Address__r.XC_streetType__c,
            dupWr.opp.AccountId => o.AccountId
        };

        for(String field : mapFields.KeySet()) {
            if(field != mapFields.get(field)) {
                check = false;
                break;
            } else {
                check = true;
            }
        }

        system.debug('dupcheck: '+mapFields);
        
        return check;
    }

    /**
    * @description utilityMethod
    * @param dupWr
    * @param o
    * @return check integer
    */
    public static Integer utilityMethod(XC_TR_Opportunity_U_CheckDuplicates.DuplicateWrapper dupWr, Opportunity o){
        Integer numberDuplicate;
        Long dt1Long;
        Long dt2Long;
        Long milliseconds;
        Long seconds;
        Long minutes;
        Long hours;

        if(String.isNotBlank(String.valueOf(o.XC_ClosureDateTime__c))) {
            
            dt1Long = (o.XC_ClosureDateTime__c).getTime();
            dt2Long = DateTime.now().getTime();
            milliseconds = dt2Long - dt1Long;
            seconds = milliseconds / 1000;
            minutes = seconds / 60;
            hours = minutes / 60;

            if(checkIfCondition(dupWr, o, hours)) {
                numberDuplicate = DUPLICATE_WITHIN_NHOURS;
            }

        } else if(((dupWr.opp.StageName == Label.XC_CL_Opportunity_Draft)||(dupWr.opp.StageName == Label.XC_CL_Opportunity_InProgress)) && ((o.StageName == Label.XC_CL_Opportunity_Draft)||(o.StageName == Label.XC_CL_Opportunity_InProgress))) {
            numberDuplicate = SIMPLE_DUPLICATE;

        }

        return numberDuplicate;
    }

    private static Boolean checkIfCondition(XC_TR_Opportunity_U_CheckDuplicates.DuplicateWrapper dupWr, Opportunity o, Long hours){
        Boolean check = false;
        if ((o.StageName == Label.XC_CL_Opportunity_ClosedLost || o.StageName == Label.XC_CL_Opportunity_ClosedWon) &&
            hours <= dupWr.numberOfHours &&
            (o.XC_ClosingUser__c == UserInfo.getUserId())){
                check = true;
        }
        
        return check;
    }

}