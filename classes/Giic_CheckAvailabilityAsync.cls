/**
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation  03/03/2020
 * @date Modification 
 * @description Giic_CheckAvailabilityAsync
 */

public   without sharing  class Giic_CheckAvailabilityAsync implements Queueable{
    
    private List<gii__ProductInventory__c> piList; 
/**
 * @description 
 * @param piList the piList
 */
    public Giic_CheckAvailabilityAsync(List<gii__ProductInventory__c> piList)
    {
        this.piList = piList;
    }
  /**
 * @description 
 * @param context the piList
 */  
    
    public void execute(QueueableContext context){
    
        	giic_TR_CheckAvailability.checkAvailability(piList);
       
    }
   

}