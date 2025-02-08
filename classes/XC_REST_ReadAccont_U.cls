/**
 * The Class XC_REST_ReadAccont_U.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.it
 * @date Creation 04/01/2019
 * @date Modification dd/mm/yyyy
 * @description XC_REST_ReadAccont_U - Class Utility of XC_REST_ReadAccon
 */
public class XC_REST_ReadAccont_U { 

    /**  
     * @description The Class WrapperResponse.
     */
    public class WrapperResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
        
        /** The Account. */
        public XC_REST_ReadAccont_U.WrapperAccount Account;
        
        /** The Address. */
        public XC_REST_ReadAccont_U.WrapperAddress Address;
    }
    
    /**
     *  @description The Class WrapperAccount.
     */
    public class WrapperAccount {
        
        /** The Unique ID. */
        public String UniqueID;
        
        /** The Account ID. */
        public String AccountID;
        
        /** The Primary email. */
        public String PrimaryEmail;
        
        /** The Identity number. */
        public String IdentityNumber;
        
        /** The Employee ID. */
        public String EmployeeID;
    }

    /**
     * @description The Class WrapperAddress.
     */
    public class WrapperAddress {
        
        /** The cups. */
        public String CUPS;
        
        /** The Street type. */
        public String StreetType;
        
        /** The Address. */
        public String Address;
        
        /** The Street number. */
        public String StreetNumber;
        
        /** The Appartment. */
        public String Appartment;
        
        /** The Door. */
        public String Door;
        
        /** The Stair. */
        public String Stair;
        
        /** The Zip code. */
        public String ZipCode;

        /** The Point of service. */
        public List<WrapperPOS> PointOfService;

    }

    /**
     * @description The Class WrapperPos
     */
    public class WrapperPos {
        
        /** The POS. */
        public String POS;
        
        /** The POSType. */
        public String POSType;
    }

    /**
     *@description The Class WrapperResponseHR.
     */
    public class WrapperResponseHR {
        
        /** The user profiles. */
        public List<WrapperUserProfile> userProfiles;
        
        /** The message. */
        public String message;
    }

    /**
     *@description  The Class WrapperUserProfile.
     */
    public class WrapperUserProfile {
      
        /** The person id. */
        public Integer person_id;
        
        /** The personnumber. */
        public Integer personnumber;
        
        /** The position. */
        public Integer position;
        
        /** The position desc. */
        public String position_desc;
        
        /** The position desc lang. */
        public String position_desc_lang;
        
        /** The job id. */
        public Integer job_id;
        
        /** The job description. */
        public String job_description;
        
        /** The job description lang. */
        public String job_description_lang;
        
        /** The userid 1. */
        public String userid_1;
        
        /** The userid 2. */
        public String userid_2;
        
        /** The userid 3. */
        public String userid_3;
        
        /** The userid 4. */
        public String userid_4;
        
        /** The u org. */
        public Integer u_org;
        
        /** The u org desc. */
        public String u_org_desc;
        
        /** The last name. */
        public String last_name;
        
        /** The second name. */
        public String second_name;
        
        /** The first name. */
        public String first_name;
        
        /** The birthday. */
        public String birthday; 
        
        /** The last name l. */
        public String last_name_l;
        
        /** The first name l. */
        public String first_name_l;
        
        /** The role. */
        public Integer role;
        
        /** The role desc. */
        public String role_desc;
        
        /** The gender. */
        public String gender;
        
        /** The language. */
        public String language;
        
        /** The nationality. */
        public String nationality;
        
        /** The nationality desc. */
        public String nationality_desc;
        
        /** The birth country. */
        public String birth_country;
        
        /** The birth place id. */
        public String birth_place_id;
        
        /** The birth place desc. */
        public String birth_place_desc;
        
        /** The starting date. */
        public String starting_date;
        
        /** The company. */
        public Integer company;
        
        /** The company desc. */
        public String company_desc;
        
        /** The pers area. */
        public String pers_area;
        
        /** The pers area desc. */
        public String pers_area_desc;
        
        /** The subarea. */
        public String subarea;
        
        /** The subarea desc. */
        public String subarea_desc;
        
        /** The country. */
        public String country;
        
        /** The country desc. */
        public String country_desc;
        
        /** The my hrbp. */
        public Integer my_hrbp;
        
        /** The my hrbp local. */
        public Integer my_hrbp_local;
        
        /** The perimeter. */
        public Integer perimeter;
        
        /** The perimeter desc. */
        public String perimeter_desc;
        
        /** The perimeter short. */
        public Integer perimeter_short;
        
        /** The state. */
        public Integer state;
        
        /** The emp group. */
        public String emp_group;
        
        /** The emp group desc. */
        public String emp_group_desc;
        
        /** The emp subgroup. */
        public String emp_subgroup;
        
        /** The emp subgroup desc. */
        public String emp_subgroup_desc;
        
        /** The level. */
        public Integer level;
        
        /** The wc code. */
        public Integer wc_code;
        
        /** The wc address. */
        public String wc_address;
        
        /** The wc cap. */
        public String wc_cap;
        
        /** The wc city. */
        public String wc_city;
        
        /** The wc region. */
        public String wc_region;
        
        /** The wc country. */
        public String wc_country;
        
        /** The person id man 1. */
        public Integer person_id_man_1;
        
        /** The person num man 1. */
        public Integer person_num_man_1;
        
        /** The type man 1. */
        public String type_man_1;
        
        /** The relat man 1. */
        public String relat_man_1;
        
        /** The relat desc man 1. */
        public String relat_desc_man_1;
        
        /** The person id man 2. */
        public Integer person_id_man_2;
        
        /** The person num man 2. */
        public Integer person_num_man_2;
        
        /** The type man 2. */
        public String type_man_2;
        
        /** The relat man 2. */
        public String relat_man_2;
        
        /** The relat desc man 2. */
        public String relat_desc_man_2;
        
        /** The person id man 3. */
        public Integer person_id_man_3;
        
        /** The person num man 3. */
        public Integer person_num_man_3;
        
        /** The type man 3. */
        public String type_man_3;
        
        /** The relat man 3. */
        public String relat_man_3;
        
        /** The relat desc man 3. */
        public String relat_desc_man_3;
        
        /** The person id man 4. */
        public Integer person_id_man_4;
        
        /** The person num man 4. */
        public Integer person_num_man_4;
        
        /** The type man 4. */
        public String type_man_4;
        
        /** The relat man 4. */
        public String relat_man_4;
        
        /** The relat desc man 4. */
        public String relat_desc_man_4;
        
        /** The person id man 5. */
        public Integer person_id_man_5;
        
        /** The person num man 5. */
        public Integer person_num_man_5;
        
        /** The type man 5. */
        public String type_man_5;
        
        /** The relat man 5. */
        public String relat_man_5;
        
        /** The relat desc man 5. */
        public String relat_desc_man_5;
        
        /** The person id man 6. */
        public Integer person_id_man_6;
        
        /** The person num man 6. */
        public Integer person_num_man_6;
        
        /** The type man 6. */
        public String type_man_6;
        
        /** The relat man 6. */
        public String relat_man_6;
        
        /** The relat desc man 6. */
        public String relat_desc_man_6;
        
        /** The flag head. */
        public Integer flag_head;
        
        /** The person id bp. */
        public Integer person_id_bp;
        
        /** The email. */
        public String email;
        
        /** The tel 1. */
        public String tel_1;
        
        /** The tel 2. */
        public String tel_2;
        
        /** The tel 3. */
        public String tel_3;
        
        /** The mobile 1. */
        public String mobile_1;
        
        /** The mobile 2. */
        public String mobile_2;
        
        /** The tel short 1. */
        public String tel_short_1;
        
        /** The tel short 2. */
        public String tel_short_2;
        
        /** The tel short 3. */
        public String tel_short_3;
        
        /** The tel secr 1. */
        public String tel_secr_1;
        
        /** The tel secr 2. */
        public String tel_secr_2;
        
        /** The tel secr 3. */
        public String tel_secr_3;
        
        /** The net salary. */
        public Double net_salary;
        
        /** The net salary curr. */
        public String net_salary_curr; 
        
        /** The last annual bonus. */
        public Double last_annual_bonus;
        
        /** The last annual bonus curr. */
        public String last_annual_bonus_curr;
        
        /** The current ral. */
        public Double current_ral;
        
        /** The current ral curr. */
        public String current_ral_curr;
        
        /** The per final result. */
        public Double per_final_result;
        
        /** The per final result des. */
        public String per_final_result_des;
        
        /** The pred attr. */
        public Integer pred_attr;
        
        /** The flpa key. */
        public Integer flpa_key;
        
        /** The flpa long text. */
        public String flpa_long_text;
        
        /** The attr prev cod. */
        public Integer attr_prev_cod;
        
        /** The attr prev desc. */
        public String attr_prev_desc;
        
        /** The attr prev abbr. */
        public String attr_prev_abbr;
        
        /** The bus line cod 1. */
        public Integer bus_line_cod_1;
        
        /** The bus line desc 1. */
        public String bus_line_desc_1;
        
        /** The bus line cod 2. */
        public Integer bus_line_cod_2;
        
        /** The bus line desc 2. */
        public String bus_line_desc_2;
        
        /** The bus line cod 3. */
        public Integer bus_line_cod_3;
        
        /** The bus line desc 3. */
        public String bus_line_desc_3;
        
        /** The bus line cod 4. */
        public Integer bus_line_cod_4;
        
        /** The bus line desc 4. */
        public String bus_line_desc_4;
        
        /** The bus line cod 5. */
        public Integer bus_line_cod_5;
        
        /** The bus line desc 5. */
        public String bus_line_desc_5;
        
        /** The serv cod 1. */
        public Integer serv_cod_1;
        
        /** The serv desc 1. */
        public String serv_desc_1;
        
        /** The serv cod 2. */
        public Integer serv_cod_2;
        
        /** The serv desc 2. */
        public String serv_desc_2;
        
        /** The serv cod 3. */
        public Integer serv_cod_3;
        
        /** The serv desc 3. */
        public String serv_desc_3;
        
        /** The staff cod 1. */
        public Integer staff_cod_1;
        
        /** The staff desc 1. */
        public String staff_desc_1;
        
        /** The staff cod 2. */
        public Integer staff_cod_2;
        
        /** The staff desc 2. */
        public String staff_desc_2;
        
        /** The org chart di. */
        public String org_chart_di;
        
        /** The central person. */
        public Integer central_person;
        
        /** The pernr exp. */
        public Integer pernr_exp;
        
        /** The company exp. */
        public Integer company_exp;
        
        /** The company desc exp. */
        public String company_desc_exp;
        
        /** The country exp. */
        public String country_exp;
        
        /** The country desc exp. */
        public String country_desc_exp;
        
        /** The userid 1 exp. */
        public String userid_1_exp;
        
        /** The email exp. */
        public String email_exp;
        
        /** The mobile 1 exp. */
        public String mobile_1_exp;
        
        /** The mobile 2 exp. */
        public String mobile_2_exp;
        
        /** The net salary exp. */
        public Double net_salary_exp; 
        
        /** The net salary curr exp. */
        public String net_salary_curr_exp;
        
        /** The last annual bonus exp. */
        public Double last_annual_bonus_exp;
        
        /** The last annual bonus curr exp. */
        public String last_annual_bonus_curr_exp;
        
        /** The current ral exp. */
        public Double current_ral_exp;
        
        /** The current ral curr exp. */
        public String current_ral_curr_exp;
        
        /** The start date imp. */
        public String start_date_imp;
        
        /** The end date imp. */
        public String end_date_imp;
        
        /** The onboarding. */
        public String onboarding;
    }

    /**
     * @description The Class WrapperResponseCommoditySpain.
     */
    public class WrapperResponseCommoditySpain {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
        
        /** The Account. */
        public XC_UTIL_Account.AccountIFWrapper Account = new XC_UTIL_Account.AccountIFWrapper();
        
        /** The Address. */
        public List<XC_UTIL_Address.AddressWrapper> Address = new List<XC_UTIL_Address.AddressWrapper>();
        
        /** The Address point of delivery. */
        //public List<WrapperAddressPointOfDelivery> Address_PointOfDelivery = new List<WrapperAddressPointOfDelivery>();
        
        /** The Interaction. */
        public List<XC_UTIL_Account.InteractionWrapper> Interaction = new List<XC_UTIL_Account.InteractionWrapper>();

        public List<XC_UTIL_Contract.ContractIFWrapper> Contracts;
        
        public List<XC_REST_ReadAccont_U.Invoices> Invoices;
        
        public List<XC_UTIL_Case.CaseRESTWrapper> Cases;
    }

    /**
     *@description The Class WrapperAddressPointOfDelivery.
     */
    public class WrapperAddressPointOfDelivery {
        
        /** The cups. */
        public String CUPS;
        
        /** The Distributor. */
        public String Distributor;
        
        /** The Business line. */
        public String BusinessLine;
        
        /** The cnae. */
        public String CNAE;
        
        /** The CNA edescription. */
        public String CNAEdescription;
        
        /** The Segment. */
        public String Segment;
        
        /** The Voltage type. */
        public String VoltageType;
        
        /** The Voltage. */
        public String Voltage;
        
        /** The Estimated annual consumption. */
        public String EstimatedAnnualConsumption;
        
        /** The Maximum authorized power. */
        public String MaximumAuthorizedPower;
        
        /** The Power assigned access. */
        public String PowerAssignedAccess;
        
        /** The PO daddress. */
        public String PODaddress;
        
        /** The Tariff. */
        public String Tariff;
        
        /** The Consumption. */
        public String Consumption;
        
        /** The Maximum contracted power. */
        public String MaximumContractedPower;
        
        /** The Self consumption. */
        public String SelfConsumption;
        
        /** The Contract not cuttable. */
        public String ContractNotCuttable;
        
        /** The Type of social bonus. */
        public String TypeOfSocialBonus;
        
        /** The Telemeasure. */
        public String Telemeasure;

        public String CIEExpirationDate;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Commodity Wrapper
     **/
    private class Invoices{
        public String InvoiceReference;
        public String InvoiceType;
        public String Contract;
        public String InvoiceCreationDate;
        public String InvoiceAddress;
        public String Amount;
        public String ProprietaryInvoice;
        public String ContactInvoice;
        public String DateOfIssue;
        public String ExpirationDate;
        public String PDFInvoice;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Method to have a map from an Object.
     * @param wrapperObject the wrapper object
     * @return the map
     */
    public static Map<String,Object> buildMapFromWrapperObject(Object wrapperObject){
        String stringObject = JSON.serialize(wrapperObject);
        //System.debug('buildMapFromWrapperObject >> stringObject='+stringObject);
        Map<String,Object> result = (Map<String, Object>) JSON.deserializeUntyped(stringObject);
        //System.debug('buildMapFromWrapperObject >> result='+result);
        //System.debug('buildMapFromWrapperObject >> keys='+result.keySet());
        return result;
    }
}