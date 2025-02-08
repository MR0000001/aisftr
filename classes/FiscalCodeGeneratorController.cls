/**
 * Created by SNEKKANTI00 on 11/01/2021.
 */

public with sharing class FiscalCodeGeneratorController {
    private static String comunity ='';
    private static final List<String> VOWELS = new List<String>{'A', 'E', 'I', 'O', 'U'};
    private static final List<String> CONSONANTS = new List<String>{'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'};
    private static final List<String> MONTH_CODES = new List<String>{'A', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'P', 'R', 'S', 'T'};
    private static final List<String> CHECK_CODE_CHARS = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    private static final Map<String, Integer> CHECK_CODE_ODD = new Map<String, Integer> { '0' => 1,'1' => 0,'2' => 5,'3' => 7,'4' => 9,'5' => 13,'6' => 15,'7' => 17,'8' => 19,'9' => 21,'A' => 1,'B' => 0,'C' => 5,'D' => 7,'E' => 9,'F' => 13,'G' => 15,'H' => 17,'I' => 19,'J' => 21,'K' => 2,'L' => 4,'M' => 18,'N' => 20,'O' => 11,'P' => 3,'Q' => 6,'R' => 8,'S' => 12,'T' => 14,'U' => 16,'V' => 10,'W' => 22,'X' => 25,'Y' => 24,'Z' => 23
    };
    private static final Map<String, Integer> CHECK_CODE_EVEN = new Map<String, Integer> { '0' => 0,'1' => 1,'2' => 2,'3' => 3,'4' => 4,'5' => 5,'6' => 6,'7' => 7,'8' => 8,'9' => 9,'A' => 0,'B' => 1,'C' => 2,'D' => 3,'E' => 4,'F' => 5,'G' => 6,'H' => 7,'I' => 8,'J' => 9,'K' => 10,'L' => 11,'M' => 12,'N' => 13,'O' => 14,'P' => 15,'Q' => 16,'R' => 17,'S' => 18,'T' => 19,'U' => 20,'V' => 21,'W' => 22,'X' => 23,'Y' => 24,'Z' => 25
    };

    @AuraEnabled
    public static String getComputedFiscalCode(String accId) {
        String fiscalCode = '';
        Account account = AccountSelector.getAccountById(accId);

        if(account.PersonBirthdate == null ||
                account.Gender__pc == null || account.Gender__pc.equalsIgnoreCase('') ||
                account.Birthday_Place__pc == null || account.Birthday_Place__pc.equalsIgnoreCase('') ||
                account.Birthday_Zone__pc == null || account.Birthday_Zone__pc.equalsIgnoreCase('') ||
                account.Birthday_Nation__pc == null || account.Birthday_Nation__pc.equalsIgnoreCase('')) {
            throw new AuraHandledException(System.Label.fiscalCode_MissingFields);
        }
        if(account.FirstName == null) account.FirstName = '';

        fiscalCode = generateCF(account.LastName.toUpperCase().deleteWhitespace(), account.FirstName.toUpperCase().deleteWhitespace(), account.PersonBirthdate, account.Gender__pc.toUpperCase(), account.Birthday_Place__pc.toUpperCase(), account.Birthday_Zone__pc.toUpperCase(), account.Birthday_Nation__pc.toUpperCase());

        return fiscalCode;

        /*if(account.Fiscal_Code__pc == null || !account.Fiscal_Code__pc.equalsIgnoreCase(fiscalCode)) {
            System.debug('New fiscal code assignment');
            account.Fiscal_Code__pc = fiscalCode;
            try {
                UPDATE account;
            } catch(Exception e) {
                System.debug('Exception at FiscalCodeGeneratorController.getRecordDetails ' + e.getMessage());
                Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
                if(e.getMessage().containsIgnoreCase('DUPLICATE_VALUE')) {
                    throw new AuraHandledException(System.Label.fiscalCode_CFExists);
                }
                throw new AuraHandledException(e.getMessage());
            }
        }*/
    }

    private static String generateCF(String surname, String name, Date birthday, String gender, String birthCity, String birthProvince, String birthCountry) {
        String computedCodiceFiscale =
                getCFSurname(surname.toUpperCase()) +
                        getCFName(name.toUpperCase()) +
                        getCFDateCode(birthday.day(), birthday.month()-1, String.valueOf(birthday.year()), gender) +
                        getCFPlace(birthCity, birthProvince, birthCountry);

        computedCodiceFiscale += getCheckCode(computedCodiceFiscale);

        System.debug('computedCodiceFiscale ' + computedCodiceFiscale);

        return computedCodiceFiscale;
    }

    private static String getCFSurname(String surname) {
        String surnameCode = surname.replaceAll('[^BCDFGHJKLMNPQRSTVWXYZ]', '')+surname.replaceAll('[^AEIOU]','')+'XXX';
        System.debug('surnameCode ' + surnameCode);

        return surnameCode.substring(0, 3);
    }

    private static String getCFName(String name) {
        String nameCode = name.replaceAll('[^BCDFGHJKLMNPQRSTVWXYZ]', '');
        System.debug('nameCode1 ' + nameCode);
        if(nameCode.length() >= 4) {
            nameCode = nameCode.substring(0, 1) + nameCode.substring(2, 4);
            System.debug('nameCode2 ' + nameCode);
        } else {
            nameCode += name.replaceAll('[^AEIOU]', '')+'XXX';
            System.debug('nameCode3 ' + nameCode);
        }
        System.debug('nameCode4 ' + nameCode);

        return nameCode.substring(0, 3);
    }

    private static String getCFDateCode(Integer day, Integer month, String year, String gender) {
        System.debug('day ' + day);
        System.debug('month ' + month);
        System.debug('year ' + year);
        System.debug('gender ' + gender);
        String dob = '';
        dob += year.substring(year.length() - 2);
        System.debug('MONTH_CODES ' + MONTH_CODES.get(month));
        dob += MONTH_CODES.get(month);
        if (gender.equalsIgnoreCase('F')) day += 40;

        dob += (String.valueOf(day).length() > 1) ? String.valueOf(day) : String.valueOf(day).leftPad(2,'0');
        System.debug('dob ' + dob);

        return dob;
    }

    private static String getCFPlace(String birthCity, String birthProvince, String birthCountry) {
        try {
            if(birthCountry.equalsIgnoreCase('Italia'))
                comunity = CommunitiesSelector.getCommunityCodeByProvinceAndCity(birthProvince, birthCity);
            else
                    comunity = CommunitiesSelector.getCommunityCodeByCountry(birthCountry);

            System.debug('comunity ' + comunity);

            return comunity;
        } catch(Exception e) {
            System.debug('Exception at FiscalCodeGeneratorController.getCFPlace ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            throw new AuraHandledException(System.Label.fiscalCode_InvalidCommunity);
        }
    }

    private static String getCheckCode(String fiscalCode) {
        Integer val = 0;
        System.debug('val ' + val);
        List<String> splitFiscalCode = fiscalCode.split('');
        System.debug('splitFiscalCode ' + splitFiscalCode);
        System.debug('splitFiscalCode.size() ' + splitFiscalCode.size());
        for (Integer i = 0; i < fiscalCode.length(); i++) {
            String c = splitFiscalCode.get(i);
            val += (math.mod(i, 2) != 0) ? CHECK_CODE_EVEN.get(c) : CHECK_CODE_ODD.get(c);
        }
        val = math.mod(val, 26);
        System.debug('CHECK_CODE_CHARS[val] ' + CHECK_CODE_CHARS[val]);

        return CHECK_CODE_CHARS[val];
    }

    @AuraEnabled
    public static Account getExistingAccount(String fiscalCode) {
        Account acc = AccountSelector.getAccountByFiscalCode(fiscalCode);

        return acc;
    }
}