/**
 * The Class XC_LCC141_BookNearMaintenance.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 24/09/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ServiceAppointment_FillFieldByWO_U – Util class for XC_TR_ServiceAppointment_U_FillFieldByWO
 */
public class XC_TR_ServiceAppointment_FillFieldByWO_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceAppointment_FillFieldByWO_U');
    public static Boolean forceDateTrigger = false;
    /**
     * @description Gets the max date time.
     * @param wrapperOfFields
     * @param wo
     * @param sa
     */
    public static void setDatesOnRepairWo (XC_TR_ServiceAppointment_U_FillFieldByWO.PopulateFieldsWrapper wrapperOfFields, WorkOrder wo, ServiceAppointment sa){
        if(wo.XC_WorkTypeCategory__c  == Label.XC_CL_WorkType_Repair){
            String typeOfRepair = '';
            if(wo.XC_Urgent_Repair__c && wo.ServiceAppointments.isEmpty()) {
                typeOfRepair = Label.XC_CL_Urgent;
                sa.XC_Urgent__c = wo.XC_Urgent_Repair__c;
            }else if (wo.XC_Commitment__c){
                typeOfRepair = Label.XC_CL_Commitment;
            }else{
                typeOfRepair =  Label.XC_CL_NonUrgent;
            }
            if(!forceDateTrigger){
                if(wrapperOfFields.mapRepairDates.get(typeOfRepair) != null) {
                    sa.EarliestStartTime = Datetime.now().addHours(Integer.valueOf(wrapperOfFields.mapRepairDates.get(typeOfRepair).XC_HourForEarliestStartTime__c));   
                
                    Integer hoursForDueDate = Integer.valueOf(wrapperOfFields.mapRepairDates.get(typeOfRepair).XC_HourForDueDate__c);
                    if(hoursForDueDate != 0) {
                        if(typeOfRepair == Label.XC_CL_Urgent){
                            sa.DueDate = sa.EarliestStartTime.addHours(hoursForDueDate);
                        } else { 
                            sa.DueDate = XC_UTIL_Date.addWorkingDays(Datetime.now(), hoursForDueDate);
                        }
                    } else if(wrapperOfFields.mapCountryDaysForRepairDueDate.get(sa.XC_Country__c) != null) {
                        //sa.DueDate = sa.EarliestStartTime.addDays(wrapperOfFields.mapCountryDaysForRepairDueDate.get(sa.XC_Country__c));
                        sa.DueDate = XC_UTIL_Date.addWorkingDays(sa.EarliestStartTime, wrapperOfFields.mapCountryDaysForRepairDueDate.get(sa.XC_Country__c));
                    } else {
                        //sa.DueDate = sa.EarliestStartTime.addDays(30);
                        sa.DueDate = XC_UTIL_Date.addWorkingDays(sa.EarliestStartTime, 30);
                    }
                }  
            }
        }
    }

}