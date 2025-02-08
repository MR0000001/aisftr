@isTest
public class BusinessDaysTest {
    
    static testMethod void testMethod1() {
        BusinessDays bd = new BusinessDays();
        
        System.debug('Inserting Todays Date' + Date.today());
        Date today = Date.today();
        DateTime startTime = DateTime.newInstanceGMT(today.year(), today.month(), today.day(), 2, 2, 3);
        
        Test.StartTest();
        
        // Add Days
        System.debug('Starting Add Days Test For 10 Days');
        DateTime response1 = bd.addDays(startTime, 10);
        System.assert(response1 != null);
        
        // Sub Days
        System.debug('Starting Subtract Days Test For 3 Days');
        DateTime response2 = bd.subtractDays(startTime, 2);
        System.assert(response2 != null);
        
        // Is Working Day
        System.debug('Starting Working Day Test – Is Final Add Day a Workday');
        Boolean response3 = bd.isWorkingDay(response1);
        System.assert(response3 != null);
        
        //Days Between
        System.debug('Starting to Counting Days between Final ADD Date and Subtract Date');
        Integer response4 = bd.getNoOfBusinessDaysBetweenDates(response1, Date.today());
        System.assert(response4 != null);
        
    }
}