



/*==========================================================================*/
/*																			*/
/* This is the same location (for simulation purposes) that the simulated	*/
/* address data set is saved in												*/
/*																			*/
%LET DATA = C:\Users\johnr\OneDrive\Desktop\Work\Road to Zero\Work;
libname doc 	"&DATA.";


/*==========================================================================*/
/*																			*/
/* The address used in this data set are derived from the following freely	*/
/* available data:															*/
/*																			*/
/* This work is licensed under a Creative Commons Attribution 4.0 License.	*/
/* The Data is provided "as is" without warranty or any representation of 	*/
/* accuracy, timeliness or completeness. This readme describes the GeoNames */
/* Postal Code dataset. The main GeoNames gazetteer data extract is here: 	*/
/*																			*/
/* 		http://download.geonames.org/export/dump/							*/
/*																			*/


proc import file	 = "&DATA\US.txt"
    		out		 = US
    		dbms	 = tab
			replace;
			getnames = no;
run;


%macro address(STATE = , ABBREVIATION = );

		data &STATE;
			/* length for each variable is assigned based on eHARS data dictionary */
			length 	state_cd 			$2.	
					county_name			$64.		
					facility_uid 		$16.    	
					zip_cd 				$10.
					name1 				$300.
					name2 				$300.
					facility_type_cd	$10.;
		
			format state_cd county_name zip_cd name1 name2 facility_uid facility_type_cd ship_flag Latitude Longitude Accuracy SIM;
			set US(rename = (VAR1  = Country
							 VAR2  = zip
							 VAR3  = name2
							 VAR5  = state_cd
							 VAR6  = County
							 VAR10 = Latitude
							 VAR11 = Longitude
							 VAR12 = Accuracy));
		
			where state_cd = "&ABBREVIATION.";
			SIM =_N_; 
		
			zip_cd 		 	 = compress(put(zip,8.));
			facility_uid 	 = compress(state_cd)||"00-"||compress(SIM)||compress(zip)||"-1";
			county_name  	 = compress(County)||" Co.";
			name1 		 	 = "";
			facility_type_cd = "";
			ship_flag 	 	 = "1";
		
				 if OBNUM < 100 		   		 then setting_cd = "   ";
			else if OBNUM >= 100 AND OBNUM < 300 then setting_cd = "001";
			else 									  setting_cd = "010";
		
			keep state_cd county_name zip_cd name1 name2 facility_uid facility_type_cd ship_flag Latitude Longitude Accuracy SIM;
		run;

%mend address;

%address(STATE = ALABAMA, 		ABBREVIATION = AL);
%address(STATE = LOUISIANA, 	ABBREVIATION = LA);
%address(STATE = MISSISSIPPI, 	ABBREVIATION = MS);


data doc.address_sim;
	set ALABAMA LOUISIANA MISSISSIPPI;
run;





