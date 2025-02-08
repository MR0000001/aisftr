/**
 * @description       : validates italian fiscal code on given data basis
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 12-17-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   10-06-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
 * 1.1   04-11-2020   Marco Ottaviano  mottaviano@deloitte.it       Add new Regex Patter for omocody. Removed Omocody calculation on calculateCCCFPattern
 * 
**/
public without sharing class XC_UTIL_ITAFiscalCode {

    private static final String cfRegex = '^[a-zA-Z]{6}([0-9LMNPQRSTUVlmnpqrstuv]{2})[abcdehlmprstABCDEHLMPRST]{1}([0-9LMNPQRSTUVlmnpqrstuv]{2})[a-zA-Z]{1}([0-9]{3}||[0-9LMNPQRSTUVlmnpqrstuv]{3})[a-zA-Z]{1}$';
    private static final Set<String> vowels = new Set<String>{'A','E','I','O','U'};

    private static final Map<String, Integer> oddMap = new Map<String, Integer>{'0' => 1, '1' => 0, '2' => 5, '3' => 7, '4' => 9, '5' => 13, '6' => 15, 
           '7' => 17, '8' => 19, '9' => 21, 'A' => 1, 'B' => 0, 'C' => 5, 'D' => 7, 'E' => 9, 'F' => 13, 'G' => 15, 'H' => 17, 'I' => 19, 'J' => 21, 
           'K' => 2, 'L' => 4, 'M' => 18, 'N' => 20, 'O' => 11, 'P' => 3, 'Q' => 6, 'R' => 8, 'S' => 12, 'T' => 14, 'U' => 16, 'V' => 10, 'W' => 22, 
           'X' => 25, 'Y' => 24, 'Z' => 23};

    private static final Map<String, Integer> evenMap = new Map<String, Integer>{'0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, 
           '6' => 6, '7' => 7, '8' => 8, '9' => 9, 'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3, 'E' => 4, 'F' => 5, 'G' => 6, 'H' => 7, 
           'I' => 8, 'J' => 9, 'K' => 10, 'L' => 11, 'M' => 12, 'N' => 13, 'O' => 14, 'P' => 15, 'Q' => 16, 'R' => 17, 'S' => 18, 
           'T' => 19, 'U' => 20, 'V' => 21, 'W' => 22, 'X' => 23, 'Y' => 24, 'Z' => 25};

    private static final Map<Integer, String> moduleMap = new map<Integer, String>{0 => 'A', 1 => 'B', 2 => 'C', 3 => 'D', 4 => 'E', 
           5 => 'F', 6 => 'G', 7 => 'H', 8 => 'I', 9 => 'J', 10 => 'K', 11 => 'L', 12 => 'M', 13 => 'N', 14 => 'O', 
           15 => 'P', 16 => 'Q', 17 => 'R', 18 => 'S', 19 => 'T', 20 => 'U', 21 => 'V', 22 => 'W', 23 => 'X', 24 => 'Y', 25 => 'Z'};

    private static final Map<String, Integer> monthMap = new Map<String, Integer>{ 
            'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5,
            'H' => 6, 'L' => 7, 'M' => 8, 'P' => 9, 'R' => 10,
                'S' => 11, 'T' => 12
    };
    private static final Map<String, String> omocodyCodeMap = new Map<String, String>{ 
        'L' => '0', 'M' => '1', 'N' => '2', 'P' => '3', 'Q' => '4',
        'R' => '5', 'S' => '6', 'T' => '7', 'U' => '8', 'V' => '9'
    };

    private static final String SEX_MALE = 'M';
    private static final String SEX_FEMALE = 'F';
    private static final String FORMAT_ERROR = Label.XC_CL_CFValidation_FORMAT;
    private static final String CC_ERROR = Label.XC_CL_CFValidation_ControlChar;
    private static final String NAME_SURNAME_ERROR = Label.XC_CL_CFValidation_NameSurname;
    private static final String BIRTH_DATE_ERROR = Label.XC_CL_CFValidation_BirthDate;
    private static final String GENDER_ERROR = Label.XC_CL_CFValidation_SEX;



    public class CFDataWrapper{
        public String cfToValidate; //mandatory
        public String firstName;  //mandatory
        public String lastName; //mandatory
        public Date birthDate; 
        public String birthCityCode; 
        public String sex;
        public String recordId;
        public Boolean isValid = false;
        public String errorCode;
    }


    /**
    * @description validate italian fiscal code semantics with given data
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param wrapper 
    * @return CFDataWrapper 
    **/
    public static CFDataWrapper checkItalianCF(CFDataWrapper wrapper){

        //setting uppercase
        wrapper.cfToValidate = wrapper.cfToValidate.toUpperCase();
        wrapper.lastName = wrapper.lastName.deleteWhitespace();
        wrapper.firstName = wrapper.firstName.deleteWhitespace();


        //blocking checks on mandatory fields for contacts/accounts
        checkRegexCFPattern(wrapper);
        if(!wrapper.isValid){
            return wrapper;
        }

        checkNameCFPattern(wrapper);
        if(!wrapper.isValid){
            return wrapper;
        }

        checkControlCharCFPattern(wrapper);
        if(!wrapper.isValid){
            return wrapper;
        }

        //non blocking checks on additional fields
        checkBirthDateCFPattern(wrapper);
        checkGenderCFPattern(wrapper);
        
        return wrapper;

    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param wrapper 
    **/
    private static void checkRegexCFPattern(CFDataWrapper wrapper){
        wrapper.isValid = String.isNotBlank(wrapper.cfToValidate) && Pattern.matches(cfRegex,wrapper.cfToValidate);
        wrapper.errorCode = !wrapper.isValid ? FORMAT_ERROR : null;
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param wrapper 
    **/
    private static void checkNameCFPattern(CFDataWrapper wrapper){

        String namesPattern = wrapper.cfToValidate.substring(0,6).toUpperCase();

        //calculating names valid string
        if(String.isBlank(wrapper.firstName) || String.isBlank(wrapper.lastName)){
            wrapper.isValid = false;
            return;
        }

        String cleanedName = wrapper.firstName.toUpperCase().remove('\'');
        String cleanedSurname = wrapper.lastName.toUpperCase().remove('\'');

        String uFirstName = XC_UTIL_String.removeDiacritics(cleanedName);
        String uLastName = XC_UTIL_String.removeDiacritics(cleanedSurname);

        String nameString = calculateSurnameCFPattern(uLastName) + calculateNameCFPattern(uFirstName);

        wrapper.isValid = namesPattern.equalsIgnoreCase(nameString);
        wrapper.errorCode = !wrapper.isValid ? NAME_SURNAME_ERROR : null;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param wrapper 
    **/
    private static void checkControlCharCFPattern(CFDataWrapper wrapper){

        String controlChar = wrapper.cfToValidate.substring(15, 16);
        String calculatedCC = calculateCCCFPattern(wrapper.cfToValidate);

        wrapper.isValid = controlChar.equalsIgnoreCase(calculatedCC);
        wrapper.errorCode = !wrapper.isValid ? CC_ERROR : null;

    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param wrapper 
    **/
    private static void checkBirthDateCFPattern(CFDataWrapper wrapper){

        if(wrapper.birthDate == null){
            return;
        }

        Date codeBirthDate = calculateDateCFPattern(wrapper.cfToValidate);
        Date birthDate = wrapper.birthDate;

        wrapper.isValid = birthDate == codeBirthDate;
        wrapper.errorCode = !wrapper.isValid ? BIRTH_DATE_ERROR : null;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param wrapper 
    **/
    private static void checkGenderCFPattern(CFDataWrapper wrapper){

        if(String.isBlank(wrapper.sex)){
            return;
        }
        wrapper.isValid = calculateGenderCFPattern(wrapper.cfToValidate).equalsIgnoreCase(wrapper.sex);
        wrapper.errorCode = !wrapper.isValid ? GENDER_ERROR: null;
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param name 
    * @return String 
    **/
    public static String calculateSurnameCFPattern (String name){
        name = name.deleteWhitespace().toUpperCase();
        String result = '';

        for(Integer i =0; i< name.length(); i++){
            String charI = name.substring(i,i+1);
            if(!vowels.contains(charI) && result.length()<3){
                result += charI;
            }
        }


        System.Debug('SURNAME LENGTH ' + result.length());
        if(result.length()<3){
            for(Integer i =0; i< name.length(); i++){
                String charI = name.substring(i,i+1);
                if(vowels.contains(charI) && result.length()<3){
                    result += charI;
                }
            }

        }


        if(result.length()<3){
            result = result.rightPad(3,'X');
        }

        return result;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param name 
    * @return String 
    **/
    public static String calculateNameCFPattern (String name){
        name = name.deleteWhitespace().toUpperCase();
        String result = '';

        Integer numberOfNotVowels = 0;
        for(Integer i = 0; i<name.length();i++){
            String charI = name.substring(i,i+1);
            if(!vowels.contains(charI)){
                numberOfNotVowels++;
            }
        }


        if(numberOfNotVowels > 3){
            for(Integer i =0; i< name.length(); i++){
                String charI = name.substring(i,i+1);
                if(!vowels.contains(charI) && result.length()<4){
                    result += charI;
                }
            }
            result = result.substring(0,1) + result.substring(2,4);
        }else{

            for(Integer i =0; i< name.length(); i++){
                String charI = name.substring(i,i+1);
                if(!vowels.contains(charI) && result.length()<3){
                    result += charI;
                }
            }
        }

        if(result.length()<3){
            for(Integer i =0; i< name.length(); i++){
                String charI = name.substring(i,i+1);
                if(vowels.contains(charI) && result.length()<3){
                    result += charI;
                }
            }
        }

        if(result.length()<3){
            result = result.rightPad(3,'X');
        }

        return result;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param cfCode 
    * @return String 
    **/
    private static String calculateCCCFPattern (String cfCode){
        
        //cfCode = isNotOmocodic(cfCode) ? cfCode.toUpperCase().substring(0,15) : calculateOmocody(cfCode.toUpperCase()).toUpperCase().substring(0,15);
        cfCode = cfCode.toUpperCase().substring(0,15);
        Integer controlValue = 0;

        for(Integer i =0; i<cfCode.length(); i++){
            Integer valueToAdd = 0;
            String currentChar = cfCode.substring(i,i+1);
            Boolean isEven = Math.mod(i+1,2) == 0 ? true : false;
            if(isEven && evenMap.containsKey(currentChar)){
                valueToAdd = evenMap.get(currentChar);
            }else{
                if(oddMap.containsKey(currentChar)){
                    valueToAdd = oddMap.get(currentChar);
                }
            }
            controlValue+=valueToAdd;
        }

        return moduleMap.get(Math.mod(controlValue,26));
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param cfCode 
    * @return Date 
    **/
    private static Date calculateDateCFPattern (String cfCode){
        Date result;
        cfCode = isNotOmocodic(cfCode) ? cfCode.toUpperCase() : calculateOmocody(cfCode).toUpperCase();

        Integer year = 0;
        Integer month = 0;
        Integer day = 0;

        year = !String.isBlank(cfCode.substring(6,8)) ? Integer.valueOf(cfCode.substring(6,8)) : -1;
        month = monthMap.containsKey(cfCode.substring(8,9)) ? monthMap.get(cfCode.substring(8,9)):-1;
        day = !String.isBlank(cfCode.substring(9,11)) ? Integer.valueOf(cfCode.substring(9,11)):-1;

        if(year != -1){
                year +=2000;
        }
        if(year != -1 && (year > Date.today().year())){
            year = year - 100;
        }
        if(day != -1 && day > 40){
            day = day - 40;
        }
        if(year != -1 && day!=-1 && month != -1){
            result = Date.newInstance(year,month,day);
        }

        return result;
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param cfCode 
    * @return String 
    **/
    private static String calculateGenderCFPattern(String cfCode){

        String result = SEX_MALE;
        Integer day = Integer.valueOf(cfCode.substring(9,11));
        if(day>40){
            result = SEX_FEMALE;
        }
        return result;
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param cfCode 
    * @return Boolean 
    **/
    private static Boolean isNotOmocodic (String cfCode){
        cfCode = cfCode.toUpperCase();
        String subCF = cfCode.substring(6,8)+cfCode.substring(9,11)+cfCode.substring(12,15);
        return subCF.isNumeric();
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param cfCode 
    * @return String 
    **/
    @TestVisible
    private static String calculateOmocody (String cfCode){
        cfCode = cfCode.toUpperCase();

        String subCF3 = cfCode.substring(12,15);
        String subCF2 = cfCode.substring(9,11);
        String subCF1 = cfCode.substring(6,8);
        String NewCF;

        if(!subCF3.isNumeric()){
          subCF3 = manageDigitSubstitution(subCF3);
        }
        if(!subCF2.isNumeric()){
          subCF2 = manageDigitSubstitution(subCF2);
        }
        if(!subCF1.isNumeric()){
          subCF1 = manageDigitSubstitution(subCF1);
        }

        NewCF = cfCode.substring(0,6)+subCF1+cfCode.substring(8,9)+subCF2+cfCode.substring(11,12)+subCF3;
        NewCF = NewCF + calculateCCCFPattern(NewCF);

        return newCF;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param SubCF 
    * @return String 
    **/
    private static String manageDigitSubstitution(String SubCF){
        for(Integer i = 0; i <= SubCF.length()-1 ; i++){
            String tmpCfCode = SubCF.substring(i,i+1);
            if(!tmpCfCode.isNumeric()){
                if(omocodyCodeMap.containsKey(tmpCfCode)){
                    SubCF = SubCF.replace(tmpCfCode,omocodyCodeMap.get(tmpCfCode));
                }
            }
        }
        return SubCF;  
    }


}