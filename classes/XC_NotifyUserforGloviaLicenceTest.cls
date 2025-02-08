@isTest
public class XC_NotifyUserforGloviaLicenceTest {
    
    @Testsetup
    static void setup(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'system administrator' LIMIT 1];
        User u = new User();
        u.FirstName         = 'Elsa';
        u.LastName          = 'of Arendelle';
        u.Email             = 'elsa@disney.com';
        u.Alias             = 'elsa';
        u.Username          = 'elsaTest@disney.com';
        u.LocaleSidKey      = 'en_US';
        u.TimeZoneSidKey    = 'GMT';
        u.ProfileID         =  profileId.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        insert u;
    }
    
    @isTest
    public static void XC_NotifyUserforGloviaLicenceTestMethod(){
        XC_NotifyUserforGloviaLicence pro = new XC_NotifyUserforGloviaLicence();
        
        Database.executeBatch(pro);
        
        pro.start(null);
        try{
            pro.execute(null,Database.query('SELECT Id, PackageLicenseId, UserId, CreatedDate, CreatedById, SystemModstamp FROM UserPackageLicense'));
        }catch(Exception ex){
            System.debug('');
        }
        pro.Finish(null);
        
        pro.execute(null);
        
        delete [SELECT Id, PackageLicenseId, UserId, CreatedDate, CreatedById, SystemModstamp FROM UserPackageLicense];
        
        pro.start(null);
        
        XC_NotifyUserforGloviaLicence.getErrorMessage(null, null, null, null);
        
        try{
            applicationException ce=new applicationException('fake subject');
           
            throw new applicationException('fake subject'); 
        }catch(Exception ex){}
        
    }
}