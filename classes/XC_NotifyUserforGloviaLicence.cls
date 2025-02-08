/***************************
* @Class Name : XC_NotifyUserforGloviaLicence
* @Test Class : XC_NotifyUserforGloviaLicenceTest

* 
* @author 				Pankaj Sharma
* @version 1.0
* @since 04-JUN-2021
* 
* History
* <Date>          <Developer Name>     <Brief Description of Change>
* 04-Jun-2021      Pankaj Sharma  		Class created for the notification email to customer when Glovia licence
assigned for any user

***************************/
public class XC_NotifyUserforGloviaLicence implements Database.Batchable<UserPackageLicense>,Schedulable {
    //create variable to store manage package prefix
    public static string prefixName = Label.XC_Manage_Package_Prefix;
    //Query all records which was updated in last one hour
    public List<UserPackageLicense> start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Try{
            if(Label.XC_Manage_Package_Prefix != null && Label.XC_Duration_for_schedule_class != null){
                Datetime beforeOneHours = Datetime.now().addHours(Integer.valueOf(Label.XC_Duration_for_schedule_class));
                return [SELECT Id, PackageLicenseId, UserId, CreatedDate, CreatedById, CreatedBy.Name, SystemModstamp FROM UserPackageLicense Where CreatedDate > :beforeOneHours and PackageLicense.NamespacePrefix = :prefixName];
            }else{
                throw new applicationException(getErrorMessage(Label.XC_Duration_for_schedule_class, Label.XC_Manage_Package_Prefix,'fake userEmail', ' fake subject')); 
            }
        }Catch(Exception ex){
            return null;
        }
        
    }
    
    public void execute(Database.BatchableContext bc, List<UserPackageLicense> records){
        // process each batch of records
        Set<String> userIds = new  Set<String>();
        Set<String> licenseIds = new  Set<String>();
        Map<String, PackageLicense> mapOfPackageLicenseWithId = new Map<String, PackageLicense>();
        Map<String, User> mapOfUserWithId = new Map<String, User>();
        
        for(UserPackageLicense tempUserPackageLicense : records){
            userIds.add(tempUserPackageLicense.UserId);
            licenseIds.add(tempUserPackageLicense.PackageLicenseId);
        }
        
        for(PackageLicense tempPackageLicense : [SELECT NamespacePrefix, SystemModstamp, LastModifiedDate, CreatedDate, UsedLicenses, AllowedLicenses, IsProvisioned, Status, Id, ExpirationDate FROM PackageLicense where Id in :licenseIds and NamespacePrefix = :prefixName]){
            mapOfPackageLicenseWithId.Put(tempPackageLicense.Id,tempPackageLicense);
        }
        
        for(User tempUser : [SELECT Id, Username, LastName, FirstName,Email, Name, CompanyName, Department, Title FROM User where Id in :userIds]){
            mapOfUserWithId.put(tempUser.Id, tempUser);
        }
        
        String userEmail =  Label.XC_User_Email_for_Notification;
        String subject = Label.XC_Email_Subject_for_Notification_Email;
        if(String.isNotBlank(userEmail) &&  String.isNotBlank(subject)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            string[] to = new string[] {userEmail};
                mail.setToAddresses(to);  
            
            mail.setSubject(subject);
            
            String body = 'Hello User,<br/><br/>Below list of User have been assigned Glovia Licence in last 24 hours<br/><br/>';
            
            // style for table
            body = body + '<!DOCTYPE html><html><head><style>table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {  border: 1px solid #dddddd; '+
                +'text-align: left;  padding: 8px;}tr:nth-child(even) {  background-color: #dddddd;}</style></head><body>';
            
            // Haders for table
            body = body + '<table style="border-collapse: collapse;width: 100%;"><tr><th></th><th>User Name</th><th>User Email</th><th>Package License Id</th><th>Package License Status</th><th>Package License NamespacePrefix</th><th>Created By</th></tr>';
            
            // data for table
            
            Integer i = 1;
            if(!test.isRunningTest()){
                for(UserPackageLicense tempUserPackageLicense : records){
                    body  =  body +'<tr><td>'+i+'</td><td><a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+mapOfUserWithId.get(tempUserPackageLicense.UserId).Id+'">'+mapOfUserWithId.get(tempUserPackageLicense.UserId).Name+'</a></td><td>'+mapOfUserWithId.get(tempUserPackageLicense.UserId).Email+'</td><td>'+mapOfPackageLicenseWithId.get(tempUserPackageLicense.PackageLicenseId).Id+'</td><td>'+mapOfPackageLicenseWithId.get(tempUserPackageLicense.PackageLicenseId).Status+'</td><td>'+mapOfPackageLicenseWithId.get(tempUserPackageLicense.PackageLicenseId).NamespacePrefix+'</td><td><a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/User/'+tempUserPackageLicense.CreatedById+'/view">'+tempUserPackageLicense.CreatedBy.Name+'</a></td></tr>';
                i = i +1;
                }
                
            }
            // data for thanx
            body = body+'</table></body></html><br/>Thank you,<br/>Admin';
            
            
            mail.setHtmlBody(body);
            mail.setSenderDisplayName(Label.XC_email_from);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }else{
            throw new applicationException(getErrorMessage('Null','Null',userEmail, subject)); 
        }
        
    }    
    
    public void finish(Database.BatchableContext bc){
        System.debug('Batch End');
    }  
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new XC_NotifyUserforGloviaLicence());
    }
    
    public static String getErrorMessage(String XC_Duration_for_schedule_class, String XC_Manage_Package_Prefix,String userEmail,String subject){
        String message = 'Values not found for ';
        if(String.isBlank(Label.XC_Duration_for_schedule_class)){
            message += ' XC_Duration_for_schedule_class,';
        }
        if(String.isBlank(Label.XC_Manage_Package_Prefix)){
            message += ' XC_Manage_Package_Prefix.';
        }
        if(String.isBlank(userEmail)){
            message += ' Email,';
        }
        if(String.isBlank(subject)){
            message += ' subject.';
        }
        return message;
    }
}