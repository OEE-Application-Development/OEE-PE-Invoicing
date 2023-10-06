BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id INTEGER NOT NULL, 
	"CSU_Online_Program__c" VARCHAR(255), 
	"Credentialing_Identifier__c" VARCHAR(255), 
	"Hand_Off_Program__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Program_Cost__c" VARCHAR(255), 
	"Program_Friendly_Name__c" VARCHAR(255), 
	"Program_Level__c" VARCHAR(255), 
	"Program_Title_Prefix__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Type__c" VARCHAR(255), 
	"Unit_Type__c" VARCHAR(255), 
	"Units__c" VARCHAR(255), 
	"hed__Billing_Address_Inactive__c" VARCHAR(255), 
	"hed__Billing_County__c" VARCHAR(255), 
	"hed__Credentialing_Email__c" VARCHAR(255), 
	"hed__School_Code__c" VARCHAR(255), 
	"hed__Shipping_County__c" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	"hed__Current_Address__c" VARCHAR(255), 
	"hed__Primary_Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES(1,'False','','False','Sample Account for Entitlements','','','','','','','','','False','','','','','','','');
INSERT INTO "Account" VALUES(2,'False','','False','OEE','','','','','','','','','False','','','','','','','');
INSERT INTO "Account" VALUES(3,'False','','False','Winterrowd Account','','','','','012Ox000000OSWDIA4','','','','False','','','learn.colostate.edu.936658','','','','1');
CREATE TABLE "Account_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OQaBIAW','Academic_Program');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OSWDIA4','Administrative');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OQaCIAW','Business_Organization');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OQaDIAW','Educational_Institution');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OQaEIAW','HH_Account');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OSkjIAG','LMS');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OQaFIAW','Sports_Organization');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OSmLIAW','University_College');
INSERT INTO "Account_rt_mapping" VALUES('012Ox000000OQaGIAW','University_Department');
CREATE TABLE "Contact" (
	id INTEGER NOT NULL, 
	"CSU_ID__c" VARCHAR(255), 
	"CSU_Online_Account_Email__c" VARCHAR(255), 
	"CanAllowPortalSelfReg" VARCHAR(255), 
	"Credentialing_Identifier__c" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"EID__c" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"Front_Door_ID__c" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Noncredit_ID__c" VARCHAR(255), 
	"hed__AlternateEmail__c" VARCHAR(255), 
	"hed__Chosen_Full_Name__c" VARCHAR(255), 
	"hed__Citizenship_Status__c" VARCHAR(255), 
	"hed__Citizenship__c" VARCHAR(255), 
	"hed__Contact_JSON__c" VARCHAR(255), 
	"hed__Country_of_Origin__c" VARCHAR(255), 
	"hed__Date_Deceased__c" VARCHAR(255), 
	"hed__Deceased__c" VARCHAR(255), 
	"hed__Disability_Status__c" VARCHAR(255), 
	"hed__Do_Not_Contact__c" VARCHAR(255), 
	"hed__Dual_Citizenship__c" VARCHAR(255), 
	"hed__Ethnicity__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Formal_Greeting__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Informal_Greeting__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Name__c" VARCHAR(255), 
	"hed__FERPA__c" VARCHAR(255), 
	"hed__Financial_Aid_Applicant__c" VARCHAR(255), 
	"hed__Former_First_Name__c" VARCHAR(255), 
	"hed__Former_Last_Name__c" VARCHAR(255), 
	"hed__Former_Middle_Name__c" VARCHAR(255), 
	"hed__Gender__c" VARCHAR(255), 
	"hed__HIPAA_Detail__c" VARCHAR(255), 
	"hed__HIPAA__c" VARCHAR(255), 
	"hed__Mailing_Address_Inactive__c" VARCHAR(255), 
	"hed__Mailing_County__c" VARCHAR(255), 
	"hed__Military_Background__c" VARCHAR(255), 
	"hed__Military_Service__c" VARCHAR(255), 
	"hed__Naming_Exclusions__c" VARCHAR(255), 
	"hed__Other_County__c" VARCHAR(255), 
	"hed__PreferredPhone__c" VARCHAR(255), 
	"hed__Preferred_Email__c" VARCHAR(255), 
	"hed__Primary_Address_Type__c" VARCHAR(255), 
	"hed__Race__c" VARCHAR(255), 
	"hed__Religion__c" VARCHAR(255), 
	"hed__SMS_Opt_Out__c" VARCHAR(255), 
	"hed__Secondary_Address_Type__c" VARCHAR(255), 
	"hed__Social_Security_Number__c" VARCHAR(255), 
	"hed__UniversityEmail__c" VARCHAR(255), 
	"hed__WorkEmail__c" VARCHAR(255), 
	"hed__WorkPhone__c" VARCHAR(255), 
	"hed__is_Address_Override__c" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ReportsToId" VARCHAR(255), 
	"HR_Directory_Entry__c" VARCHAR(255), 
	"Primary_Academic_Program__c" VARCHAR(255), 
	"Primary_Canvas_Account__c" VARCHAR(255), 
	"Primary_Department__c" VARCHAR(255), 
	"Primary_Educational_Institution__c" VARCHAR(255), 
	"Primary_Sports_Organization__c" VARCHAR(255), 
	"hed__Current_Address__c" VARCHAR(255), 
	"hed__Primary_Household__c" VARCHAR(255), 
	"hed__Primary_Language__c" VARCHAR(255), 
	"hed__Primary_Organization__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Contact" VALUES(1,'','winterrk@colostate.edu','False','','False','','Kyle','a6db74ab-1597-40a0-9656-763c0e103c95','False','False','Winterrowd','learn.colostate.edu.936658','','','','','','','','False','False','False','','','False','False','False','False','False','','','','','','False','False','','','False','','','','CSU Online Account Email','','','','False','','','','','','False','3','','','','','','','','','','','');
CREATE TABLE "EmailMessage" (
	id INTEGER NOT NULL, 
	"Incoming" VARCHAR(255), 
	"IsBounced" VARCHAR(255), 
	"IsClientManaged" VARCHAR(255), 
	"IsExternallyVisible" VARCHAR(255), 
	"IsPrivateDraft" VARCHAR(255), 
	"IsTracked" VARCHAR(255), 
	"Status" VARCHAR(255), 
	"ReplyToEmailMessageId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "EmailMessage" VALUES(1,'False','False','False','False','False','False','3','');
CREATE TABLE "Email_Simple_Request__c" (
	id INTEGER NOT NULL, 
	"Email_Body__c" VARCHAR(255), 
	"Email_Recipient_List__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Lead" (
	id INTEGER NOT NULL, 
	"Company" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"IsConverted" VARCHAR(255), 
	"IsUnreadByOwner" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Status" VARCHAR(255), 
	"hed__Area_Of_Interest__c" VARCHAR(255), 
	"hed__Birth_Date__c" VARCHAR(255), 
	"hed__Citizenship__c" VARCHAR(255), 
	"hed__Ethnicity__c" VARCHAR(255), 
	"hed__External_Id__c" VARCHAR(255), 
	"hed__GPA__c" VARCHAR(255), 
	"hed__Gender__c" VARCHAR(255), 
	"hed__Highest_Degree_Earned__c" VARCHAR(255), 
	"hed__Language__c" VARCHAR(255), 
	"hed__Most_Recent_School__c" VARCHAR(255), 
	"hed__Preferred_Enrollment_Date__c" VARCHAR(255), 
	"hed__Preferred_Enrollment_Status__c" VARCHAR(255), 
	"hed__Preferred_Teaching_Format__c" VARCHAR(255), 
	"hed__Recruitment_Stage__c" VARCHAR(255), 
	"hed__SMS_Opt_Out__c" VARCHAR(255), 
	"hed__SSN__c" VARCHAR(255), 
	"hed__Undergraduate_Major__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Marketing_Cloud_Journey_Event__c" (
	id INTEGER NOT NULL, 
	"Event_Type__c" VARCHAR(255), 
	"Event__c" VARCHAR(255), 
	"Key__c" VARCHAR(255), 
	"RelatedToId__c" VARCHAR(255), 
	"ContactWhoId__c" VARCHAR(255), 
	"LeadWhoId__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Noncredit_Invoice_Line_Item__c" (
	id INTEGER NOT NULL, 
	"Confirmed_At__c" VARCHAR(255), 
	"Debit_Trans_Id__c" VARCHAR(255), 
	"Fulfilled_At__c" VARCHAR(255), 
	"Is_Confirmed__c" VARCHAR(255), 
	"Is_Credit_Line_Item__c" VARCHAR(255), 
	"Is_Dropped__c" VARCHAR(255), 
	"Is_Open_Entry_Line_Item__c" VARCHAR(255), 
	"Is_Voided__c" VARCHAR(255), 
	"Line_Item_Amount__c" VARCHAR(255), 
	"Line_Item_ID__c" VARCHAR(255), 
	"Notes__c" VARCHAR(255), 
	"Requires_LMS_Fulfillment__c" VARCHAR(255), 
	"Section_Reference__c" VARCHAR(255), 
	"Canvas_Enrollment__c" VARCHAR(255), 
	"Course_Offering__c" VARCHAR(255), 
	"Noncredit_Invoice__c" VARCHAR(255), 
	"Sponsor_Payment_Invoice__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Noncredit_Invoice_Line_Item__c" VALUES(1,'','','','False','False','False','True','False','-60.0','','','True','2023SM-AGBB-2070-200','','1','1','');
CREATE TABLE "Noncredit_Invoice_Payment__c" (
	id INTEGER NOT NULL, 
	"Amount__c" VARCHAR(255), 
	"CSU_Trans_Id__c" VARCHAR(255), 
	"Failure_Reason__c" VARCHAR(255), 
	"Is_Actual__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Payment_Type__c" VARCHAR(255), 
	"Posted_At__c" VARCHAR(255), 
	"Processor_Trans_Id__c" VARCHAR(255), 
	"Processor_Trans_Status__c" VARCHAR(255), 
	"Successful__c" VARCHAR(255), 
	"Noncredit_Invoice_Line_Item__c" VARCHAR(255), 
	"Noncredit_Invoice__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Noncredit_Invoice__c" (
	id INTEGER NOT NULL, 
	"Cancel_At__c" VARCHAR(255), 
	"Escalate_Automatically__c" VARCHAR(255), 
	"Escalation_Sent__c" VARCHAR(255), 
	"Fulfilled_Email_Sent__c" VARCHAR(255), 
	"Intended_Payment_Method__c" VARCHAR(255), 
	"Invoice_Number__c" VARCHAR(255), 
	"Is_Cancelled__c" VARCHAR(255), 
	"Noncredit_ID__c" VARCHAR(255), 
	"Notes__c" VARCHAR(255), 
	"Registration_Id__c" VARCHAR(255), 
	"Registration_Method__c" VARCHAR(255), 
	"Send_Confirmation_Email__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Payer_Account__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Noncredit_Invoice__c" VALUES(1,'','True','False','False','Unspecified','467048','False','learn.colostate.edu.936658','','441895','','True','1','3');
CREATE TABLE "Registration_Batch__c" (
	id INTEGER NOT NULL, 
	"Default_Transfer__c" VARCHAR(255), 
	"Is_Ready__c" VARCHAR(255), 
	"Sponsor__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Registration_Request__c" (
	id INTEGER NOT NULL, 
	"Is_Credit__c" VARCHAR(255), 
	"Line_Item_ID__c" VARCHAR(255), 
	"Registration_Id__c" VARCHAR(255), 
	"Course_Offering__c" VARCHAR(255), 
	"Fulfilled_Enrollment__c" VARCHAR(255), 
	"Registration_Batch__c" VARCHAR(255), 
	"Student__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "csumidp__HR_Department__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"csumidp__HR_Department_Code__c" VARCHAR(255), 
	"csumidp__HR_Department_Description__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "csumidp__HR_Directory_Entry__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"csumidp__Address_Private__c" VARCHAR(255), 
	"csumidp__City__c" VARCHAR(255), 
	"csumidp__Country__c" VARCHAR(255), 
	"csumidp__Email_Active__c" VARCHAR(255), 
	"csumidp__Email_Private__c" VARCHAR(255), 
	"csumidp__FERPA_Private__c" VARCHAR(255), 
	"csumidp__First_Name__c" VARCHAR(255), 
	"csumidp__HR_Id__c" VARCHAR(255), 
	"csumidp__Has_HR_Data__c" VARCHAR(255), 
	"csumidp__Last_Name__c" VARCHAR(255), 
	"csumidp__MidPoint_Create_Date__c" VARCHAR(255), 
	"csumidp__MidPoint_Last_Updated_Date__c" VARCHAR(255), 
	"csumidp__Middle_Name__c" VARCHAR(255), 
	"csumidp__Midpoint_Id__c" VARCHAR(255), 
	"csumidp__Net_Id_Active__c" VARCHAR(255), 
	"csumidp__Net_Id_Expire_Cycle_End__c" VARCHAR(255), 
	"csumidp__Net_Id_Expire_Cycle_Start__c" VARCHAR(255), 
	"csumidp__Net_Id__c" VARCHAR(255), 
	"csumidp__Organization_Email__c" VARCHAR(255), 
	"csumidp__Phone_Private__c" VARCHAR(255), 
	"csumidp__Phone__c" VARCHAR(255), 
	"csumidp__Preferred_First_Name__c" VARCHAR(255), 
	"csumidp__Preferred_Last_Name__c" VARCHAR(255), 
	"csumidp__SIS_Person_Id__c" VARCHAR(255), 
	"csumidp__State__c" VARCHAR(255), 
	"csumidp__Street1__c" VARCHAR(255), 
	"csumidp__Street2__c" VARCHAR(255), 
	"csumidp__Title__c" VARCHAR(255), 
	"csumidp__Zip__c" VARCHAR(255), 
	"csumidp_hed__Department_Private__c" VARCHAR(255), 
	"csumidp_hed__Has_Student_Data__c" VARCHAR(255), 
	"csumidp_hed__Student_Class_Private__c" VARCHAR(255), 
	"csumidp_hed__Student_College_Private__c" VARCHAR(255), 
	"csumidp_hed__Student_Level_Private__c" VARCHAR(255), 
	"csumidp__HR_Department__c" VARCHAR(255), 
	"csumidp__HR_Employee_Type__c" VARCHAR(255), 
	"csumidp_hed__Student_Class__c" VARCHAR(255), 
	"csumidp_hed__Student_College__c" VARCHAR(255), 
	"csumidp_hed__Student_Department__c" VARCHAR(255), 
	"csumidp_hed__Student_Level__c" VARCHAR(255), 
	"csumidp_hed__Student_Program__c" VARCHAR(255), 
	"csumidp_hed__Term__c" VARCHAR(255), 
	"Primary_Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "csumidp__HR_Employee_Type__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"csumidp__Type_Code__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "csumidp_hed__Student_Class__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"csumidp_hed__Student_Class_Code__c" VARCHAR(255), 
	"csumidp_hed__Student_Class_Detail__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "csumidp_hed__Student_Level__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"csumidp_hed__Student_Level_Code__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Academic_Certification__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"hed__Academic_Level__c" VARCHAR(255), 
	"hed__Credentialing_Identifier__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__Extended_Name__c" VARCHAR(255), 
	"hed__Field_Of_Study__c" VARCHAR(255), 
	"hed__Issuer__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Academic_Certification__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
CREATE TABLE "hed__Address__c" (
	id INTEGER NOT NULL, 
	"hed__Address_Type__c" VARCHAR(255), 
	"hed__Default_Address__c" VARCHAR(255), 
	"hed__Inactive__c" VARCHAR(255), 
	"hed__Latest_End_Date__c" VARCHAR(255), 
	"hed__Latest_Start_Date__c" VARCHAR(255), 
	"hed__MailingCity__c" VARCHAR(255), 
	"hed__MailingCountry__c" VARCHAR(255), 
	"hed__MailingCounty__c" VARCHAR(255), 
	"hed__MailingPostalCode__c" VARCHAR(255), 
	"hed__MailingState__c" VARCHAR(255), 
	"hed__MailingStreet2__c" VARCHAR(255), 
	"hed__MailingStreet__c" VARCHAR(255), 
	"hed__Seasonal_End_Day__c" VARCHAR(255), 
	"hed__Seasonal_End_Month__c" VARCHAR(255), 
	"hed__Seasonal_End_Year__c" VARCHAR(255), 
	"hed__Seasonal_Start_Day__c" VARCHAR(255), 
	"hed__Seasonal_Start_Month__c" VARCHAR(255), 
	"hed__Seasonal_Start_Year__c" VARCHAR(255), 
	"hed__Parent_Account__c" VARCHAR(255), 
	"hed__Parent_Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Affiliation__c" (
	id INTEGER NOT NULL, 
	"hed__Description__c" VARCHAR(255), 
	"hed__EndDate__c" VARCHAR(255), 
	"hed__Primary__c" VARCHAR(255), 
	"hed__Role__c" VARCHAR(255), 
	"hed__StartDate__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	"hed__Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Course_Enrollment__c" (
	id INTEGER NOT NULL, 
	"RecordTypeId" VARCHAR(255), 
	"Student_Notified__c" VARCHAR(255), 
	"hed__Credentialing_Identifier__c" VARCHAR(255), 
	"hed__Credits_Attempted__c" VARCHAR(255), 
	"hed__Credits_Earned__c" VARCHAR(255), 
	"hed__Display_Grade__c" VARCHAR(255), 
	"hed__Grade__c" VARCHAR(255), 
	"hed__Primary__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	"hed__Verification_Status_Date__c" VARCHAR(255), 
	"hed__Verification_Status__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	"hed__Affiliation__c" VARCHAR(255), 
	"hed__Contact__c" VARCHAR(255), 
	"hed__Course_Offering__c" VARCHAR(255), 
	"hed__Program_Enrollment__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Course_Enrollment__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
CREATE TABLE "hed__Course_Offering_Schedule__c" (
	id INTEGER NOT NULL, 
	"Schedule_Reference__c" VARCHAR(255), 
	"hed__End_Time__c" VARCHAR(255), 
	"hed__Friday__c" VARCHAR(255), 
	"hed__Monday__c" VARCHAR(255), 
	"hed__Saturday__c" VARCHAR(255), 
	"hed__Start_Time__c" VARCHAR(255), 
	"hed__Sunday__c" VARCHAR(255), 
	"hed__Thursday__c" VARCHAR(255), 
	"hed__Tuesday__c" VARCHAR(255), 
	"hed__Wednesday__c" VARCHAR(255), 
	"hed__Course_Offering__c" VARCHAR(255), 
	"hed__Facility__c" VARCHAR(255), 
	"hed__Time_Block__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Course_Offering__c" (
	id INTEGER NOT NULL, 
	"CPS_ID__c" VARCHAR(255), 
	"Confirmed_Enrollments__c" VARCHAR(255), 
	"Minimum_Seats_Required__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Open_Entry__c" VARCHAR(255), 
	"Pending_Enrollments__c" VARCHAR(255), 
	"Requires_Canvas__c" VARCHAR(255), 
	"Subledger__c" VARCHAR(255), 
	"hed__Capacity__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Section_ID__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"lms_hed__LMS_Offering_ID__c" VARCHAR(255), 
	"lms_hed__LMS_Reference_Code__c" VARCHAR(255), 
	"Cross_Listed_To__c" VARCHAR(255), 
	"hed__Course__c" VARCHAR(255), 
	"hed__Facility__c" VARCHAR(255), 
	"hed__Faculty__c" VARCHAR(255), 
	"hed__Term__c" VARCHAR(255), 
	"hed__Time_Block__c" VARCHAR(255), 
	"lms_hed__Cross_Listed_To__c" VARCHAR(255), 
	"lms_hed__LMS_Course_Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "hed__Course_Offering__c" VALUES(1,'','0.0','0.0','AGBB 2070 200','False','0.0','False','','','','200','','','','','1','','','1','','','');
CREATE TABLE "hed__Course__c" (
	id INTEGER NOT NULL, 
	"CPS_ID__c" VARCHAR(255), 
	"Course_Code__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Short_Description__c" VARCHAR(255), 
	"hed__Academic_Level__c" VARCHAR(255), 
	"hed__Course_ID__c" VARCHAR(255), 
	"hed__Credentialing_Identifier__c" VARCHAR(255), 
	"hed__Credit_Hours__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__Extended_Description__c" VARCHAR(255), 
	"hed__Subject__c" VARCHAR(255), 
	"lms_hed__LMS_Reference_Code__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	"hed__Issuer__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "hed__Course__c" VALUES(1,'','AGBB 207','AGBB 2070','','','','AGBB 2070','','','','','','AGBB-2070','2','');
CREATE TABLE "hed__Course__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "hed__Course__c_rt_mapping" VALUES('012Ox000000OSnzIAG','Credit');
INSERT INTO "hed__Course__c_rt_mapping" VALUES('012Ox000000OSo0IAG','Noncredit');
CREATE TABLE "hed__Education_History__c" (
	id INTEGER NOT NULL, 
	"hed__Class_Percentile__c" VARCHAR(255), 
	"hed__Class_Rank_Scale__c" VARCHAR(255), 
	"hed__Class_Rank_Type__c" VARCHAR(255), 
	"hed__Class_Rank__c" VARCHAR(255), 
	"hed__Class_Size__c" VARCHAR(255), 
	"hed__Credentialing_Identifier__c" VARCHAR(255), 
	"hed__Credits_Earned__c" VARCHAR(255), 
	"hed__Degree_Earned__c" VARCHAR(255), 
	"hed__Details__c" VARCHAR(255), 
	"hed__Education_History_JSON__c" VARCHAR(255), 
	"hed__Educational_Institution_Name__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__GPA_Scale_Reporting__c" VARCHAR(255), 
	"hed__GPA_Scale_Type__c" VARCHAR(255), 
	"hed__GPA__c" VARCHAR(255), 
	"hed__Graduation_Date__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	"hed__Verification_Status_Date__c" VARCHAR(255), 
	"hed__Verification_Status__c" VARCHAR(255), 
	"hed__Academic_Certification__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	"hed__Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Facility__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Capacity__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__Facility_Type__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	"hed__Parent_Facility__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Language__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Program_Enrollment__c" (
	id INTEGER NOT NULL, 
	"hed__Admission_Date__c" VARCHAR(255), 
	"hed__Application_Submitted_Date__c" VARCHAR(255), 
	"hed__Class_Standing__c" VARCHAR(255), 
	"hed__Credits_Attempted__c" VARCHAR(255), 
	"hed__Credits_Earned__c" VARCHAR(255), 
	"hed__Eligible_to_Enroll__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Enrollment_Status__c" VARCHAR(255), 
	"hed__GPA__c" VARCHAR(255), 
	"hed__Graduation_Year__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	"hed__Affiliation__c" VARCHAR(255), 
	"hed__Contact__c" VARCHAR(255), 
	"hed__Education_History__c" VARCHAR(255), 
	"hed__Program_Plan__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Program_Plan__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Is_Primary__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	"hed__Total_Required_Credits__c" VARCHAR(255), 
	"hed__Version__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Term__c" (
	id INTEGER NOT NULL, 
	"CPS_ID__c" VARCHAR(255), 
	"Display_Order__c" VARCHAR(255), 
	"Is_Visible__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Programming_Active__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Grading_Period_Sequence__c" VARCHAR(255), 
	"hed__Instructional_Days__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Type__c" VARCHAR(255), 
	"lms_hed__LMS_Reference_Code__c" VARCHAR(255), 
	"hed__Account__c" VARCHAR(255), 
	"hed__Parent_Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "hed__Term__c" VALUES(1,'','','False','2023SM','False','','','','','','','2023SM','2','');
CREATE TABLE "hed__Term__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "hed__Term__c_rt_mapping" VALUES('012Ox000000OSo1IAG','Credit');
INSERT INTO "hed__Term__c_rt_mapping" VALUES('012Ox000000OSo2IAG','Noncredit');
CREATE TABLE "hed__Time_Block__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__End_Time__c" VARCHAR(255), 
	"hed__Start_Time__c" VARCHAR(255), 
	"hed__Educational_Institution__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "lms_hed__LMS_Account__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"lms_hed__Alternate_Login__c" VARCHAR(255), 
	"lms_hed__LMS_External_ID__c" VARCHAR(255), 
	"lms_hed__Primary_Login__c" VARCHAR(255), 
	"lms_hed__Account_Owner__c" VARCHAR(255), 
	"lms_hed__LMS__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "lms_hed__LMS_Course_Enrollment__c" (
	id INTEGER NOT NULL, 
	"lms_hed__Enrollment_Link__c" VARCHAR(255), 
	"lms_hed__LMS_External_ID__c" VARCHAR(255), 
	"lms_hed__Last_Activity__c" VARCHAR(255), 
	"lms_hed__Last_Attended__c" VARCHAR(255), 
	"lms_hed__Course_Connection__c" VARCHAR(255), 
	"lms_hed__Course_Offering__c" VARCHAR(255), 
	"lms_hed__LMS_Account__c" VARCHAR(255), 
	"lms_hed__LMS_Course_Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "lms_hed__LMS_Course_Term__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"lms_hed__Course_Term_Link__c" VARCHAR(255), 
	"lms_hed__LMS_Course_ID__c" VARCHAR(255), 
	"lms_hed__Course__c" VARCHAR(255), 
	"lms_hed__LMS__c" VARCHAR(255), 
	"lms_hed__Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
COMMIT;
