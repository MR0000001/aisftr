/**
 * BusinessDays Class
 * Use this class to operate only on business days 
 * and easily skip weekends and holidays from your logic
 * */
public class BusinessDays
{
    public BusinessHours bHours;
    /**
     * Constructor to set business hours name
     * */
    //get business hours
    public BusinessDays(String businessHoursName){bHours = [SELECT Id FROM BusinessHours WHERE Name =: businessHoursName];}
     
    //If no business hours name provided in paramaterized constructor, use deafault hours
    public BusinessDays(){bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];}
    

    /**
     * Add number of working days in a date
     * @param - startDate - date to operate on
     * @param - days - number of days to add
     * */
    public Datetime addDays(Datetime startDate, Integer days)
    {
        //If startdate is not within working days, take next working day
        startDate = BusinessHours.nextStartDate(bHours.Id, startDate);
		
        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Add 1 day
            startDate = startDate.addDays(1);
            
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate)) { startDate = BusinessHours.nextStartDate(bHours.Id, startDate);}
        }
        return startDate;
    }
    
    /**
     * Subtract number of working days in a date
     * @param - startDate - date to operate on
     * @param - days - number of days to subtract
     * */
    public Datetime subtractDays(Datetime startDate, Integer days)
    {
        //If startdate is not within working days, take previous working day
        startDate = getPreviousWorkingDay(startDate);
        for (Integer elapsed = 0; elapsed < days; elapsed++)
        { startDate = startDate.addDays(-1);
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate)) {startDate = getPreviousWorkingDay(startDate);}
        }
        return startDate;
    }
    
    /**
     * Recursive function to get previous working day
     * If date passed to this function is on a working day, this will return same date
     * If date passed to this function is not on a working day, this will return previous working day
     * *********************
     * For Example, if day passed to this function is Monday, this will return Monday
     * but if day passed to the function is Sunday, then this will return Friday
     * *********************
     * @param - d - Date to operate on
     * */
    public Datetime getPreviousWorkingDay(Datetime d){
        
        
         //Check if new date is within working days
        if (!BusinessHours.isWithin(bHours.Id, d))
        {d = d.addDays(-1);return getPreviousWorkingDay(d);} else{return d;}
    }
    
    /**
     * Function to get next working day
     * If date passed to this function is on a working day, this will return same date
     * If date passed to this function is not on a working day, this will return next working day
     * *********************
     * For Example, if day passed to this function is Monday, this will return Monday
     * but if day passed to the function is Sunday, then this will return Monday
     * *********************
     * @param - d - Date to operate on
     * */
    public Datetime getNextWorkingDay(Datetime d){
        return BusinessHours.nextStartDate(bHours.Id, d);
    }
    
    
    /**
     * Check if supplied date is working day or not
     * */
    public Boolean isWorkingDay(Datetime d){
        return BusinessHours.isWithin(bHours.Id, d);
    }
    
    /*
     * Get numbe of business days between two dates
	 * */
    public Integer getNoOfBusinessDaysBetweenDates(DateTime startDate, DateTime endDate){
        Integer count = 0;
        while(startDate <= endDate){
            if(BusinessHours.isWithin(bHours.Id, startDate)){count++;}
            startDate = startDate.addDays(1);
        }
        return count;
    }
}