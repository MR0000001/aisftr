/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_BA004_PlanningPerfKPICalc_U – Class to compute data to be used for the Planning Performance KPI
 */
public without sharing class XC_BA004_PlanningPerfKPICalc_U {

    private static final String COMPLETED = 'Completed';
    private static final String PLANNING_PERFORMANCE = 'Planning Performance';
    
    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description Compute numerator for Planning Performance KPI
    *@param workOrders WorkOrders used for the calculation
    *@return Numerator used for the Planning Performance KPI
    **/
    public static Decimal computeNum(List<WorkOrder> workOrders) {
        Decimal num = 0;
        for(WorkOrder wo : workOrders) {
            if(wo.XC_ScheduledStart__c != NULL && wo.XC_ScheduleDateTimestamp__c < wo.XC_ScheduledStart__c && wo.XC_ScheduledStart__c.dateGMT() == wo.XC_Overall_EndDate__c) {
                num++;
            }
        }
        return num;
    }

    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description Compute denominator for Planning Performance KPI
    *@param workOrders WorkOrders used for the calculation
    *@return Denominator used for the Planning Performance KPI
    **/
    public static Decimal computeDenom(List<WorkOrder> workOrders) {
        return workOrders.size();
    }

    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description It inserts one Planning Performance KPI Detail record 
    *@param requestId Id of the master Request record
    *@param accountId Account Id for which the KPI is calculated
    *@param legalEntity Legal Entity to be considered in the computation 
    *@param country Country to be considered in the computation
    *@return Planning Performance Request Detail to insert
    **/
    public static XC_KPI_Planning_Performance_Detail__c createKPIDetail(Id requestId, Id accountId, String country) {
        XC_KPI_Planning_Performance_Detail__c d = new XC_KPI_Planning_Performance_Detail__c();
        XC_KPI_Planning_Performance__c request = [
            SELECT Id, XC_Request_Date__c, XC_Request_Start_Date__c, XC_Request_End_Date__c, XC_Request_Type__c, XC_User__c
            FROM XC_KPI_Planning_Performance__c
            WHERE Id = :requestId
            LIMIT 1
        ];
        List<XC_CS013_PlanningPerformanceWorkTypes__c> workTypesSettings = XC_CS013_PlanningPerformanceWorkTypes__c.getAll().values();
        Set<String> products = XC_UTIL_PlanningPerfWorkTypes.getProducts(country);
        List<WorkOrder> wos = [
            SELECT Id, XC_AssignedPartner__c, EndDate, XC_ScheduledStart__c, XC_ScheduleDateTimestamp__c, XC_Overall_EndDate__c
            FROM WorkOrder 
            WHERE XC_AssignedPartner__c = :accountId AND XC_WorkTypeLabel__c IN :products AND Status = :COMPLETED 
                AND DAY_ONLY(EndDate) >= :Date.valueOf(request.XC_Request_Start_Date__c) AND DAY_ONLY(EndDate) <= :Date.valueOf(request.XC_Request_End_Date__c)
        ];

        List<WorkOrder> filteredWos = getWorkOrdersLicenseNotSuspended(wos, XC_UTIL_SafetyPointWalletHistory.getSuspensionRanges(accountId));    
        Decimal num = computeNum(filteredWos);
        Decimal denom = computeDenom(filteredWos);
        XC_UTIL_SafetyPointKPI.ThresholdData  thresholdData = (denom != 0) ? XC_UTIL_SafetyPointKPI.computeBonusMalus((num / denom) * 100, PLANNING_PERFORMANCE, country) : new XC_UTIL_SafetyPointKPI.ThresholdData(null, null, 0);
        d.XC_KPI_Planning_Performance__c = requestId;
        d.XC_Scheduled_Installations__c = num;
        d.XC_Achieved_Installations__c = denom;
        d.XC_Planning_Performance_Percentage__c = (denom != 0) ? (num / denom) * 100 : null;
        d.XC_Request_Date__c = request.XC_Request_Date__c;
        d.XC_User__c = request.XC_User__c;
        d.XC_Account__c = accountId;
        d.XC_Request_Start_Date__c = Date.valueOf(request.XC_Request_Start_Date__c);
        d.XC_Request_End_Date__c = Date.valueOf(request.XC_Request_End_Date__c);
        d.XC_LowerThreshold__c = thresholdData?.lowerThreshold;
        d.XC_UpperThreshold__c = thresholdData?.upperThreshold;
        d.XC_SPs_Added__c = thresholdData.bonusMalus;
        d.XC_Request_Type__c = request.XC_Request_Type__c;
        d.XC_Request_Status__c = 'Completed';
        return d;
    }

    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description It inserts one Planning Performance KPI Detail error record 
    *@param requestId Id of the master Request record
    *@param accountId Account Id for which the KPI is calculated
    *@param legalEntity Legal Entity to be considered in the computation 
    *@param country Country to be considered in the computation
    *@param message Error message to be saved
    *@return Planning Performance Request Detail error to insert
    **/
    public static XC_KPI_Planning_Performance_Detail__c createKPIDetailError(String requestId, String accountId, String country, String message) {
        XC_KPI_Planning_Performance__c request = [
            SELECT Id, XC_Request_Date__c, XC_Request_Start_Date__c, XC_Request_End_Date__c, XC_Request_Type__c, XC_User__c
            FROM XC_KPI_Planning_Performance__c
            WHERE Id = :requestId
            LIMIT 1
        ];
        XC_KPI_Planning_Performance_Detail__c d = new XC_KPI_Planning_Performance_Detail__c();
        d.XC_KPI_Planning_Performance__c = requestId;
        d.XC_Request_Date__c = request.XC_Request_Date__c;
        d.XC_User__c = request.XC_User__c;
        d.XC_Account__c = accountId;
        d.XC_Request_Start_Date__c = Date.valueOf(request.XC_Request_Start_Date__c);
        d.XC_Request_End_Date__c = Date.valueOf(request.XC_Request_End_Date__c);
        d.XC_Request_Type__c = request.XC_Request_Type__c;
        d.XC_Request_Status__c = 'Error';
        d.XC_Request_Details__c = message;
        return d;
    }

    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description Filter workOrders ended during License suspension  
    *@param workOrders workOrders to be filtered
    *@param dateRanges Date Ranges in which the license has been suspended
    *@return Filtered list of workOrders in which the license was active
    **/
    public static List<WorkOrder> getWorkOrdersLicenseNotSuspended(List<WorkOrder> workOrders, XC_UTIL_SafetyPointWalletHistory.DateRanges dateRanges) {
        List<WorkOrder> filteredWos = new List<WorkOrder>();
        for(WorkOrder wo : workOrders) {
            if(!dateRanges.isInsideRange(wo.EndDate)) {
                filteredWos.add(wo);
            }
        }
        return filteredWos;
    }
}