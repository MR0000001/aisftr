/**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 27/11/2019
* @date Modification dd/mm/yyyy
* @description giic_UTIL_TransferOrderSharing – Utility class to implements Transfer Order Custom sharing rules.
*/
public without sharing class giic_UTIL_TransferOrderSharing {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_UTIL_TransferOrderSharing');
    public static boolean firstRun = true;
    
  public class Giic_SharingTOWrapper {
  	public Id transferOrderId;
  	public String firstAccount = '';
    public String secondAccount = '';
    public String thirdAccount = '';
    public String fourthAccount = '';
   

   public Giic_SharingTOWrapper(){
     System.debug('Giic_SharingTOWrapper');
   }
 }
       /**  
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 27/11/2019
* @date Modification dd/mm/yyyy
* @description To check warehouse change on Transfer orders in update.
* @param listNew -  List of Transfer orders
* @param mapOld -  List of old Transfer orders
* @param mapNew -  List of new Transfer orders
*/    
    public static void  startToShareInUpdate(List<gii__TransferOrder__c> listNew,Map<Id,gii__TransferOrder__c> mapOld, Map<Id,gii__TransferOrder__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In startToShareTOInUpdate');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'con '+listNew);
         XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOld = '+mapOld);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapNew = '+mapNew);
        List<String> fieldList = new List<String>{'gii__FromWarehouse__c', 'gii__TransferToWarehouse__c'};
        List<gii__TransferOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        system.debug('@@@ startToShareInUpdate - listChanged:' + listChanged);
        if(listChanged.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'startToShareTOInUpdate Empty list');
            return;
        }
        startToShare(listChanged);     
    }   
    
      /**  
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 27/11/2019
* @date Modification dd/mm/yyyy
* @description To retrieve all transfer order to share.
* @param listNew -  List of Transfer orders

*/    
    public static void startToShare(List<gii__TransferOrder__c>  listNew) {
          XC_UTIL_Debug.debug(DEBUGACTIVE,'In startToShare');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'con '+listNew);
          if(firstRun && !system.isBatch() && !Test.isRunningTest()){
              Giic_BA009_ShareTOPartner.executeShare(listNew) ;
              
              
              Giic_BA010_ShareTO3PL.executeShare(listNew) ;
            
              System.debug('chiamo BA010_ShareTO3PL ');
           
              firstRun = false;
          }
        
        
          XC_UTIL_Debug.debug(DEBUGACTIVE,'END startToShare ');
    
     }


   
    


   



     /**  
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 27/11/2019
* @date Modification dd/mm/yyyy
* @description To create all shareObject beetween transfer orders and User to share.
* @param transferOrdIdTouserOrGroupId -  to create Junction Object

*/    
    public static List<boolean> manualShareRead(map<Id,List<Id>> transferOrdIdTouserOrGroupId){
      XC_UTIL_Debug.debug(DEBUGACTIVE,'----------');
      XC_UTIL_Debug.debug(DEBUGACTIVE,'----------');
      XC_UTIL_Debug.debug(DEBUGACTIVE,'In manualShareRead ');
      XC_UTIL_Debug.debug(DEBUGACTIVE,'con '+transferOrdIdTouserOrGroupId);
      XC_UTIL_Debug.debug(DEBUGACTIVE,'----------');
      XC_UTIL_Debug.debug(DEBUGACTIVE,'----------');
      // Create new sharing object for the custom object Job.
      List<gii__TransferOrder__Share> objectToInsert = new  List<gii__TransferOrder__Share>();
      for(Id toId : transferOrdIdTouserOrGroupId.keySet()){
          for(Id userId : transferOrdIdTouserOrGroupId.get(toId)){
      			gii__TransferOrder__Share jobShr  = new gii__TransferOrder__Share();
   				// Set the ID of record being shared.
      			jobShr.ParentId = toId;
        		// Set the ID of user or group being granted access.
      			jobShr.UserOrGroupId = userId;  
        		// Set the access level.
      			jobShr.AccessLevel = 'Edit';
        		// Set rowCause to 'manual' for manual sharing.
      			// This line can be omitted as 'manual' is the default value for sharing objects.
      			jobShr.RowCause = 'Manual';
        		// Insert the sharing record and capture the save result. 
      			// The false parameter allows for partial processing if multiple records passed 
      			// into the operation.
      			objectToInsert.add(jobShr);
      	   }
      }
      List<Database.SaveResult> srList = Database.insert(objectToInsert,false);
      XC_UTIL_Debug.debug(DEBUGACTIVE,'----------');
      XC_UTIL_Debug.debug(DEBUGACTIVE,'srList = '+srList);
      XC_UTIL_Debug.debug(DEBUGACTIVE,'----------');
      XC_UTIL_Debug.debug(DEBUGACTIVE,'----------');
      List<Boolean> booleanResultList = new List<Boolean>();
      for(Database.SaveResult sr : srList){
      // Process the save results.
      if(sr.isSuccess()){
         // Indicates success
         booleanResultList.add(true);
      }
      else {
         // Get first save result error.
         Database.Error err = sr.getErrors()[0];
         
         // Check if the error is related to trival access level.
         // Access level must be more permissive than the object's default.
         // These sharing records are not required and thus an insert exception is acceptable. 
         if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                  err.getMessage().contains('AccessLevel')){
            // Indicates success.
            booleanResultList.add(true);
         }
         else{
            // Indicates failure.
            booleanResultList.add(false);
         }
       }
          
      }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'---------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'---------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'End manualShareRead ');
        return booleanResultList;
        
   }
   


}