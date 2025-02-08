/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 14/12/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Country – Util to retreave data about Country
*/
public class XC_UTIL_Country {
    
        /**
* @author Roberta  Porrega - roberta.porrega@nttdata.com && Simone Trenta strenta@deloitte.it
* @date Creation 07/05/2019
* @date Modification dd/mm/yyyy
*@param country
* @description retriveCountryCode – Util to retreave data about Country
* @return String
*/
    public static String retriveCountryCode(String country){
          if(country=='Spain'){
                return Country = 'ES';
            }else if(country == 'Italy'){
                return Country = 'IT';
            }else{
                return Country = country ;
            }        
    }

    /**
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @description serverSystem => Country Mapping
    * @param  serverSystem
    * @return the country matching
    */
    public static String serverSystemOnCountryMapping(String serverSystem){
        Map<String,String> mapping = new Map<String,String>
        {
            'CommoditySpainB2C'  =>  'Spain',
            'CommodityColombia'  =>  'Colombia',
            'CommodityChile'     =>  'Chile'
        };

        return mapping.get(serverSystem);
    }
    
    
    /**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 14/12/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Country – Util to retreave data about Country
* @return List<Map<String,String>>
*/

    public static List<Map<String,String>> retriveCountryPicklistValues(){
        List<Map<String,String>> result = new List<Map<String,String>>();  
        
        for(String value: COUNTRIES){
            Map<String,String> row = new Map<String,String>();
            row.put('key',value);
            row.put('value',value);
            result.add(row);
        }
        return result;
    } 

    public static final List<String> COUNTRIES = new List<String> {
        'Algeria'                      ,
        'Andorra'                      ,
        'Angola'                       ,
        'Anguilla'                     , 
        'Antigua Barbuda'              ,
        'Argentina'                    ,
        'Armenia'                      ,
        'Aruba'                        ,
        'Australia'                    ,
        'Austria'                      ,
        'Azerbaijan'                   ,
        'Bahamas'                      ,
        'Bahrain'                      ,
        'Bangladesh'                   ,
        'Barbados'                     ,
        'Belarus'                      ,
        'Belgium'                      ,
        'Belize'                       ,
        'Benin'                        ,
        'Bermuda'                      ,
        'Bhutan'                       ,
        'Bolivia'                      ,
        'Bosnia Herzegovina'           ,
        'Botswana'                     ,
        'Brazil'                       ,
        'Brunei'                       ,
        'Bulgaria'                     ,
        'Burkina Faso'                 ,
        'Burundi'                      ,
        'Cambodia'                     ,
        'Cameroon'                     ,
        'Canada'                       ,
        'Cape Verde Islands'           ,
        'Cayman Islands'               ,
        'Central African Republic'     ,
        'Chile'                        ,
        'China'                        ,
        'Colombia'                     ,
        'Comoros'                      ,
        'Congo'                        ,
        'Cook Islands'                 ,
        'Costa Rica'                   ,
        'Croatia'                      ,
        'Cuba'                         ,
        'Cyprus North'                 ,
        'Cyprus South'                 ,
        'Czech Republic'               ,
        'Denmark'                      ,
        'Djibouti'                     ,
        'Dominica'                     ,
        'Dominican Republic'           ,
        'Ecuador'                      ,
        'Egypt'                        ,
        'El Salvador'                  ,
        'Equatorial Guinea'            ,
        'Eritrea'                      ,
        'Estonia'                      ,
        'Ethiopia'                     ,
        'Falkland Islands'             ,
        'Faroe Islands'                ,
        'Fiji'                         ,
        'Finland'                      ,
        'France'                       ,
        'French Guiana'                ,
        'French Polynesia'             ,
        'Gabon'                        ,
        'Gambia'                       ,
        'Georgia'                      ,
        'Germany'                      ,
        'Ghana'                        ,
        'Gibraltar'                    ,
        'Greece'                       ,
        'Greenland'                    ,
        'Grenada'                      ,
        'Guadeloupe'                   ,
        'Guam'                         ,
        'Guatemala'                    ,
        'Guinea'                       ,
        'Guinea and Bissau'            ,
        'Guyana'                       ,
        'Haiti'                        ,
        'Honduras'                     ,
        'Hong Kong'                    ,
        'Hungary'                      ,
        'Iceland'                      ,
        'India'                        ,
        'Indonesia'                    ,
        'Iran'                         ,
        'Iraq'                         ,
        'Ireland'                      ,
        'Israel'                       ,
        'Italy'                        ,
        'Jamaica'                      ,
        'Japan'                        ,
        'Jordan'                       ,
        'Kazakhstan'                   ,
        'Kenya'                        ,
        'Kiribati'                     ,
        'Korea North'                  ,
        'Korea South'                  ,
        'Kuwait'                       ,
        'Kyrgyzstan'                   ,
        'Laos'                         ,
        'Latvia'                       ,
        'Lebanon'                      ,
        'Lesotho'                      ,
        'Liberia'                      ,
        'Libya'                        ,
        'Liechtenstein'                ,
        'Lithuania'                    ,
        'Luxembourg'                   ,
        'Macao'                        ,
        'Macedonia'                    ,
        'Madagascar'                   ,
        'Malawi'                       ,
        'Malaysia'                     ,
        'Maldives'                     ,
        'Mali'                         ,
        'Malta'                        ,
        'Marshall Islands'             ,
        'Martinique'                   ,
        'Mauritania'                   ,
        'Mayotte'                      ,
        'Mexico'                       ,
        'Micronesia'                   ,
        'Moldova'                      ,
        'Monaco'                       ,
        'Mongolia'                     ,
        'Montserrat'                   ,
        'Morocco'                      ,
        'Mozambique'                   ,
        'Myanmar'                      ,
        'Namibia'                      ,
        'Nauru'                        ,
        'Nepal'                        ,
        'Netherlands'                  ,
        'New Caledonia'                ,
        'New Zealand'                  ,
        'Nicaragua'                    ,
        'Niger'                        ,
        'Nigeria'                      ,
        'Niue'                         ,
        'Norfolk Islands'              ,
        'Northern Marianas'            ,
        'Norway'                       ,
        'Oman'                         ,
        'Palau'                        ,
        'Panama'                       ,
        'Papua New Guinea'             ,
        'Paraguay'                     ,
        'Peru'                         ,
        'Philippines'                  ,
        'Poland'                       ,
        'Portugal'                     ,
        'Puerto Rico'                  ,
        'Qatar'                        ,
        'Reunion'                      ,
        'Romania'                      ,
        'Russia'                       ,
        'Rwanda'                       ,
        'San Marino'                   ,
        'Sao Tome and Principe'        ,
        'Saudi Arabia'                 ,
        'Senegal'                      ,
        'Serbia'                       ,
        'Seychelles'                   ,
        'Sierra Leone'                 ,
        'Singapore'                    ,
        'Slovak Republic'              ,
        'Slovenia'                     ,
        'Solomon Islands'              ,
        'Somalia'                      ,
        'South Africa'                 ,
        'Spain'                        ,
        'Sri Lanka'                    ,
        'St. Helena'                   ,
        'St. Kitts'                    ,
        'St. Lucia'                    ,
        'Sudan'                        ,
        'Suriname'                     ,
        'Swaziland'                    ,
        'Sweden'                       ,
        'Switzerland'                  ,
        'Syria'                        ,
        'Taiwan'                       ,
        'Tajikstan'                    ,
        'Thailand'                     ,
        'Togo'                         ,
        'Tonga'                        ,
        'Trinidad and Tobago'          ,
        'Tunisia'                      ,
        'Turkey'                       ,
        'Turkmenistan'                 ,
        'Turkmenistan'                 ,
        'Turks and Caicos Islands'     ,
        'Tuvalu'                       ,
        'Uganda'                       ,
        'Ukraine'                      ,
        'United Arab Emirates'         ,
        'Uruguay'                      ,
        'UK'                           ,
        'USA'                          ,
        'Uzbekistan'                   ,
        'Vanuatu'                      ,
        'Vatican City'                 ,
        'Venezuela'                    ,
        'Vietnam'                      ,
        'Virgin Islands - British'     ,
        'Virgin Islands - US'          ,
        'Wallis and Futuna'            ,
        'Yemen (North)'                ,
        'Yemen (South)'                ,
        'Zambia'                       ,
        'Zimbabwe'
    };

    /**
    * @description returns an iso code configuration from legalEntity
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/4/2020 
    * @param legalEntity 
    * @return XC_CM_CountryISOCodeAssociation__mdt 
    **/
    public static XC_CM_CountryISOCodeAssociation__mdt getISOCodeByLegalEntity(String legalEntity){

        List<XC_CM_CountryLegalEntityAssociation__mdt> leCountryConfs = [SELECT XC_Country__c 
        FROM XC_CM_CountryLegalEntityAssociation__mdt 
        WHERE XC_LegalEntity__c = :legalEntity LIMIT 1];
        if(leCountryConfs.isEmpty()){
            return null;
        }

        List<XC_CM_CountryISOCodeAssociation__mdt> ISOCodeConfs = [SELECT XC_Country__c,XC_ISOCode__c,XC_ISOCode_3__c 
        FROM XC_CM_CountryISOCodeAssociation__mdt 
        WHERE XC_Country__c = :leCountryConfs[0].XC_Country__c];
        return ISOCodeConfs.isEmpty() ? null : ISOCodeConfs[0];
    }


}