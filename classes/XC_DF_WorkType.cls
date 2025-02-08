/**
* @author Roberta Cossiga - rcossiga@deloitte.it 
* @date Creation 06/05/2019
* @description XC_DF_WorkType – Data Factory for WorkType
*/

@isTest
public class XC_DF_WorkType {

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it 
     * @description Method to create One WorkType
     * @param workTypeCategory 
     * @return WorkType
    */
    public static WorkType createWorkType (String workTypeCategory){
        WorkType workType = new WorkType();
        workType.Name = 'Commercial Visit - Boiler';
        workType.XC_LegalEntity__c = 'EndesaX';
        workType.XC_WorkTypeCategory__c = workTypeCategory;
        workType.DurationType = Label.XC_CL_WorkType_Hours;
        workType.EstimatedDuration = 1;
        return workType;
    }

    /**
    * @description create worktype with custom name
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 24/9/2019 
    * @param workTypeCategory 
    * @param workTypeName 
    * @return WorkType 
    **/
    public static WorkType createWorkTypeWithName(String workTypeCategory, String workTypeName){
        WorkType workType = new WorkType();
        workType.Name = workTypeName;
        workType.XC_WorkTypeCategory__c = workTypeCategory;
        workType.DurationType = Label.XC_CL_WorkType_Hours;
        workType.EstimatedDuration = 1;
        workType.XC_LegalEntity__c = 'EndesaX';
        return workType;
    }
}