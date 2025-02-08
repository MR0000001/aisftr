/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 03/05/2019
* @description XC_DF_OperatingHours – Data Factory for OperatingHours
*/
@isTest
public class XC_DF_OperatingHours {

    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Create OperatingHours Record for a given Name
     * @param OperatingHoursName
     * @return OperatingHours
    */
    public static operatingHours createOperatingHours(String OperatingHoursName){
        //Create OperatingHours record 
            OperatingHours op = new OperatingHours();
            op.Name = OperatingHoursName;      
        return op;
    }
    
}