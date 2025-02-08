/**
 * Created by FMARCHEGIA00 on 15/06/2021.
 */

global class MilestoneTimeCalculatorController implements Support.MilestoneTriggerTimeCalculator {

    private static Set<String> mapWeekDays = new Set<String>();
    private static Set<Date> mapRecursiveAnnuals = new Set<Date>();
    private static Set<Date> mapNoRecursives = new Set<Date>();
    public static final Map<String, String> daysOfWeek = new Map<String, String>{
            'DOMENICA' => 'SUNDAY',
            'LUNEDÌ' => 'MONDAY',
            'MARTEDÌ' => 'TUESDAY',
            'MERCOLEDÌ' => 'WEDNESAY',
            'GIOVEDÌ' => 'THURSDAY',
            'VENERDÌ' => 'FRIDAY',
            'SABATO' => 'SATURDAY'
    };

    private static OrgManagement__c orgSetting = OrgManagement__c.getOrgDefaults();

    global static Integer calculateMilestoneTriggerTime(String caseId, String caseId2) {

        //caseId e caseId2 Nohting
        system.debug('caseId -> ' + caseId);
        system.debug('caseId2 -> ' + caseId2);
        Case singleCase = [SELECT CreatedDate FROM Case WHERE Id = :caseId];

        system.debug('singleCase -> ' + singleCase);

        Date dayForCheck = Date.valueOf(singleCase.CreatedDate); //Date.today();
        system.debug('dayForCheck -> ' + dayForCheck);
        system.debug('singleCase.CreatedDate -> ' + singleCase.CreatedDate);

        Datetime newGMTDatetime = Datetime.valueOfGmt(String.valueOf(singleCase.CreatedDate));
        //Datetime newGMTDatetime = singleCase.CreatedDate;
        system.debug('newGMTDatetime -> ' + newGMTDatetime);

        Long dayForCheckHours = newGMTDatetime.getTime();
        system.debug('dayForCheckHours -> ' + dayForCheckHours);
        Date dateToCheck = getFormattedDate(dayForCheck).addDays(Integer.valueOf(orgSetting.Sla__c));
        system.debug('dateToCheck -> ' + dateToCheck);

        List<Holidays__c> holidays = [
                SELECT HolidayDate__c,Id,Name,NoRecursive__c,RecursiveAnnual__c,RecursiveWeekly__c,WeekDay__c
                FROM Holidays__c
                WHERE isActive__c = true AND IsDeleted = false
        ];
        system.debug('holidays -> ' + holidays);

        for (Holidays__c singleHoliday : holidays) {
            if (singleHoliday.RecursiveWeekly__c == true) {
                mapWeekDays.add(singleHoliday.WeekDay__c);
            } else if (singleHoliday.RecursiveAnnual__c == true) {
                mapRecursiveAnnuals.add(singleHoliday.HolidayDate__c);
            } else if (singleHoliday.NoRecursive__c == true) {
                mapNoRecursives.add(singleHoliday.HolidayDate__c);
            } else {
                // Nothing
            }
        }
        //translate days
        system.debug('mapWeekDays -> ' + mapWeekDays);
        translateMapWeekDays();
        system.debug('mapWeekDays -> ' + mapWeekDays);
        system.debug('mapRecursiveAnnuals -> ' + mapRecursiveAnnuals);
        system.debug('mapNoRecursives -> ' + mapNoRecursives);

        //MAIN
        Date finalDate = recursiveDateCheck(dateToCheck);
        system.debug('finalDate -> ' + finalDate);

        //aggiungo le ore
        Integer hoursCase = newGMTDatetime.hourGMT();
        system.debug('hoursCase -> ' + hoursCase);
        Integer minuteCase = newGMTDatetime.minute();
        // aggiungo un minuto per calcolo per difetto dei minuti
        minuteCase += 1;
        system.debug('minuteCase -> ' + minuteCase);

        Datetime endDatetime = finalDate;
        endDatetime = endDatetime.addHours(hoursCase);
        endDatetime = endDatetime.addMinutes(minuteCase);
        system.debug('endDatetime -> ' + endDatetime);
        Long dayEndDatetimeHours = endDatetime.getTime();
        system.debug('dayEndDatetimeHours -> ' + dayEndDatetimeHours);

        Long millisecondsCalculated = dayEndDatetimeHours - dayForCheckHours;
        system.debug('millisecondsCalculated -> ' + millisecondsCalculated);
        Integer totalMinutes = Integer.valueOf(millisecondsCalculated / 60000);
        system.debug('totalMinutes -> ' + totalMinutes);

        return totalMinutes;
    }

    private static void translateMapWeekDays() {
        Set<String> tmpTranslated = new Set<String>();
        for (String singleWddkDays : mapWeekDays) {
            if (daysOfWeek.containsKey(singleWddkDays.toUpperCase())) {
                tmpTranslated.add(daysOfWeek.get(singleWddkDays.toUpperCase()));
            }
        }
        mapWeekDays = tmpTranslated;
    }

    private static Date recursiveDateCheck(Date dateToCheck) {
        if (!checkIfWeekDay(dateToCheck)) {
            if (!checkIfRecursiveAnnual(dateToCheck)) {
                if (!checkIfNoRecursive(dateToCheck)) {
                    //system.debug('trovato');
                    return dateToCheck;
                } else {
                    //system.debug('esiste un match con una data checkIfNoRecursive');
                    return recursiveDateCheck(dateToCheck.addDays(1));
                }
            } else {
                //system.debug('esiste un match con una data checkIfRecursiveAnnual');
                return recursiveDateCheck(dateToCheck.addDays(1));
            }
        } else {
            //system.debug('esiste un match con una data del girono della settimana checkIfWeekDay');
            return recursiveDateCheck(dateToCheck.addDays(1));
        }
    }

    private static Boolean checkIfWeekDay(Date originalDate) {
        system.debug('checkIfWeekDay, originalDate -> ' + originalDate);
        Datetime datetimeFromOriginal = DateTime.newInstance(originalDate.year(), originalDate.month(), originalDate.day());
        String dayOfWeekString = datetimeFromOriginal.format('EEEE').toUpperCase();
        system.debug('dayOfWeekString -> ' + dayOfWeekString);
        if (mapWeekDays.contains(dayOfWeekString)) {
            return true;
        }
        return false;
    }

    private static Boolean checkIfRecursiveAnnual(Date originalDate) {
        system.debug('checkIfRecursiveAnnual, originalDate -> ' + originalDate);
        Boolean isFinded = false;
        for (Date singleDate : mapRecursiveAnnuals) {
            if (checkIfSameDateWithoutYear(originalDate, singleDate)) {
                isFinded = true;
            }
        }
        if (isFinded) {
            return true;
        }
        return false;
    }

    private static Boolean checkIfNoRecursive(Date originalDate) {
        system.debug('checkIfNoRecursive, originalDate -> ' + originalDate);
        if (mapNoRecursives.contains(originalDate)) {
            return true;
        }
        return false;
    }

    private static Date getFormattedDate(String inputString) {
        return date.parse(inputString);
    }

    private static Date getFormattedDate(Datetime inputDatetime) {
        return date.newinstance(inputDatetime.year(), inputDatetime.month(), inputDatetime.day());
    }

    private static Boolean checkIfSameDateWithoutYear(Date firstDate, Date seconDate) {
        //system.debug('checkIfSameDateWithoutYear, firstDate -> '+firstDate);
        //system.debug('checkIfSameDateWithoutYear, seconDate -> '+seconDate);
        String dayFirstDate, daySecondDate, monthFirstDate, monthSecondDate;
        dayFirstDate = String.valueOf(firstDate.day());
        daySecondDate = String.valueOf(seconDate.day());
        monthFirstDate = String.valueOf(firstDate.month());
        monthSecondDate = String.valueOf(seconDate.month());
        if (dayFirstDate == daySecondDate && monthFirstDate == monthSecondDate) {
            //system.debug('same day and month');
            return true;
        }
        //system.debug('differente day and month');
        return false;
    }
}