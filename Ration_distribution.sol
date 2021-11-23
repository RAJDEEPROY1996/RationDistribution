/**
 *Submitted for verification at BscScan.com on 2021-11-23
Contract address is 0x21C443bafe3dadD487BD01DB6820D3F08CcF59AE
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) private pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) private pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) private pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) private pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) private pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

       function getDay(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }
        
       /* function getDay() public view returns (uint8) {
            uint timestamp=block.timestamp;
            return parseTimestamp(timestamp).day;
        }*/

        function getHour(uint timestamp) private pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) private pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) private pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) private pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }
}

contract Ration_distribution is DateTime
{
	struct State_Government{
		address state_government;
		string state_name;
	}
	struct item_in_ration{
		string item_name;
		uint below_poverty_line_price;     //0 for below_poverty_line_price
		uint above_poverty_line_price;    //1 for above_poverty_line_price
		uint weight_of_item;
	}
	struct individual_registration{
		string register_by_state_government;
		address Ethereum_address_of_individual;
		string individual_name;
		string address_of_individual;
		uint poverty_line;
		string identity_proof_name;
		string identity_proof;
		uint valid;
	}
	struct ration_registration{
		string register_by_state_government;
		address Ethereum_address_of_Ration_shop;
		string ration_dealer_name;
		string ration_dealer_address;
		uint valid;
	}
	struct Loading_of_Item_in_Ration_shop{
		string Load_by_state_name;
		address Ethereum_address_of_Ration_shop;
		string item_name;
		uint weight;
	}
	struct Ration_delivery_to_Public{
		address Ethereum_address_of_Ration_shop;
		address Ethereum_address_of_individual;
		string Item_name;
		uint price;
		uint weight;
		uint time_of_delivery;
		uint ReceiptNo;
	}	
	address public owner;
	State_Government[] public state_gov;
	item_in_ration[] public ListItem;
	uint i;
	mapping(address => individual_registration) public citizen;
	mapping(address => ration_registration) public shop;
	Loading_of_Item_in_Ration_shop[] public GoodsList;
	Ration_delivery_to_Public[] public Ration_delivery;	
	event State_Government_Details(address state_government,string state_name);
	event Items(string Name,uint BelowPovertyPrice,uint AbovePovertyPrice,uint Weight);
	event BeneficiaryRegistration(string StateName,address BeneficiaryEthAddress,string BeneficiaryName,string BeneficiaryAddress,uint BeneficiaryPovertyLine,string BeneficiaryIdentityProofName,string BeneficiaryIdentityProofNo,uint Validity);
	event RationShopRegistration(string StateName,address RationShopEthAddress,string RationShopOwner,string RationShopAddress,uint valid);
	event RationDelivery(address RationShopEthAddress,address BeneficiaryEthAddress,string ItemName,uint ItemPrice,uint ItemWeight,uint DeliveryTime,uint ReceiptNo);
	constructor(){
		owner = msg.sender;
	}
	
	function Registration_Of_State_Government(address ip_state_government, string memory ip_state_name) public{
	    require(msg.sender == owner, "Only owner can register a State Government.");
	    for(i=0; i < state_gov.length; i++)
		{
			require(state_gov[i].state_government!=ip_state_government,"Already Registered with the Ethereum Address....");
		}
		state_gov.push(State_Government(ip_state_government,ip_state_name));
		emit State_Government_Details(ip_state_government,ip_state_name);
	}
	function Add_Item(string memory ip_item_name, uint ip_below_poverty_line_price,uint ip_above_poverty_line_price, uint ip_weight_of_item) public{
		bool flag;
		require(msg.sender == owner, "Only owner can register a new Item.");
		for(i=0; i < ListItem.length; i++)
		{
			if(uint(keccak256(abi.encodePacked(ip_item_name))) == uint(keccak256(abi.encodePacked(ListItem[i].item_name))))
				flag = true;
		}
		require(flag == false,"Already Registered Item");
		ListItem.push(item_in_ration(ip_item_name,ip_below_poverty_line_price,ip_above_poverty_line_price,ip_weight_of_item));
		emit Items(ip_item_name,ip_below_poverty_line_price,ip_above_poverty_line_price,ip_weight_of_item);
	}
	function Edit_Add_Item_details(string memory ip_item_name,uint ip_above_poverty_line_price, uint ip_below_poverty_line_price,uint ip_weight_of_item)public{
		bool flag;
		uint temp;
		require(msg.sender == owner, "Only owner can register a new Item.");
		for(i=0; i < ListItem.length; i++)
		{
			if(uint(keccak256(abi.encodePacked(ip_item_name))) == uint(keccak256(abi.encodePacked(ListItem[i].item_name)))){
				flag = true;
				temp=i;
			}
		}
		require(flag == true,"Not a Registered Item.....");
		if(ip_above_poverty_line_price == 0 || ip_below_poverty_line_price == 0){
			ListItem[temp].item_name = ListItem[ListItem.length - 1].item_name;
			ListItem[temp].above_poverty_line_price = ListItem[ListItem.length - 1].above_poverty_line_price;
			ListItem[temp].below_poverty_line_price = ListItem[ListItem.length - 1].below_poverty_line_price;
			ListItem[temp].weight_of_item = ListItem[ListItem.length - 1].weight_of_item;
			ListItem.pop();
		}
		else{
			ListItem[temp].above_poverty_line_price = ip_above_poverty_line_price;
			ListItem[temp].below_poverty_line_price = ip_below_poverty_line_price;
			ListItem[temp].weight_of_item=ip_weight_of_item;
			emit Items(ip_item_name,ip_below_poverty_line_price,ip_above_poverty_line_price,ip_weight_of_item);
		}
	}
	
	function Registration_of_Individual_citizen(address ip_Ethereum_address_of_individual,string memory ip_individual_name,string memory ip_address_of_individual,uint ip_poverty_line,string memory ip_identity_proof_name,string memory ip_identity_proof)public{
		bool flag;
		uint temp;
		for(i=0; i < state_gov.length; i++)
		{
			if(uint(keccak256(abi.encodePacked(msg.sender))) == uint(keccak256(abi.encodePacked(state_gov[i].state_government)))){
				flag = true;
				temp=i;
			}
		}
		require(flag == true, "Only Registered State Government can register Individual User....");
		require(citizen[ip_Ethereum_address_of_individual].valid == 0, "Already registered user....");
		citizen[ip_Ethereum_address_of_individual].register_by_state_government = state_gov[temp].state_name;
		citizen[ip_Ethereum_address_of_individual].Ethereum_address_of_individual = ip_Ethereum_address_of_individual;
		citizen[ip_Ethereum_address_of_individual].individual_name = ip_individual_name;
		citizen[ip_Ethereum_address_of_individual].address_of_individual = ip_address_of_individual;
		citizen[ip_Ethereum_address_of_individual].poverty_line = ip_poverty_line;
		citizen[ip_Ethereum_address_of_individual].identity_proof_name = ip_identity_proof_name;
		citizen[ip_Ethereum_address_of_individual].identity_proof = ip_identity_proof;
		citizen[ip_Ethereum_address_of_individual].valid = 1;
		emit BeneficiaryRegistration(state_gov[temp].state_name,ip_Ethereum_address_of_individual,ip_individual_name,ip_address_of_individual,ip_poverty_line,ip_identity_proof_name,ip_identity_proof,1);
	}
	
	function Cancellation_of_Individual_Citizen(address ip_Ethereum_address_of_individual) public{
	    bool flag;
	    require(citizen[ip_Ethereum_address_of_individual].valid == 1, "Not a Registered Individual Citizen....");
	    for(i=0; i < state_gov.length; i++)
		{
			if(uint(keccak256(abi.encodePacked(citizen[ip_Ethereum_address_of_individual].register_by_state_government))) == uint(keccak256(abi.encodePacked(state_gov[i].state_name)))){
			    if(uint(keccak256(abi.encodePacked(msg.sender))) == uint(keccak256(abi.encodePacked(state_gov[i].state_government)))){
				    flag = true;
				}
			}
		}
		require(flag == true, "Only State Government can Cancel the Registration_of_Individual_citizen....");
	    citizen[ip_Ethereum_address_of_individual].valid = 0;
	}
	
	function Registration_of_Ration_Shop(address ip_Ethereum_address_of_Ration_shop,string memory ip_ration_dealer_name, string memory ip_ration_dealer_address) public{
		bool flag;
		uint temp;
		for(i=0; i < state_gov.length; i++)
		{
			if(uint(keccak256(abi.encodePacked(msg.sender))) == uint(keccak256(abi.encodePacked(state_gov[i].state_government)))){
				flag = true;
				temp=i;
			}
		}
		require(flag == true, "Only State Government can register Public Distribution Shop....");
		require(shop[ip_Ethereum_address_of_Ration_shop].valid == 0, "Already registered Public Distribution Shop....");
		shop[ip_Ethereum_address_of_Ration_shop].register_by_state_government=state_gov[temp].state_name;
		shop[ip_Ethereum_address_of_Ration_shop].Ethereum_address_of_Ration_shop = ip_Ethereum_address_of_Ration_shop;
		shop[ip_Ethereum_address_of_Ration_shop].ration_dealer_name = ip_ration_dealer_name;
		shop[ip_Ethereum_address_of_Ration_shop].ration_dealer_address=ip_ration_dealer_address;
		shop[ip_Ethereum_address_of_Ration_shop].valid = 1;
		emit RationShopRegistration(state_gov[temp].state_name,ip_Ethereum_address_of_Ration_shop,ip_ration_dealer_name,ip_ration_dealer_address,1);
	}
	function Cancellation_of_Ration_shop(address ip_Ethereum_address_of_Ration_shop) public{
	    bool flag;
	    require(shop[ip_Ethereum_address_of_Ration_shop].valid == 1, "Not a Registered Ration Shop....");
	    for(i=0; i < state_gov.length; i++)
		{
			if(uint(keccak256(abi.encodePacked(shop[ip_Ethereum_address_of_Ration_shop].register_by_state_government))) == uint(keccak256(abi.encodePacked(state_gov[i].state_name)))){
			    if(uint(keccak256(abi.encodePacked(msg.sender))) == uint(keccak256(abi.encodePacked(state_gov[i].state_government)))){
				    flag = true;
				}
			}
		}
		require(flag == true, "Only State Government can Cancel the License of Ration Shop....");
	    shop[ip_Ethereum_address_of_Ration_shop].valid = 0;
	}
	function Add_Item_In_Ration_Shop(address ip_Ethereum_address_of_Ration_shop,string memory ip_Item_name,uint ip_weight) public{
		bool flag;
		uint temp;
		for(i=0; i < state_gov.length; i++){
			if(uint(keccak256(abi.encodePacked(msg.sender))) == uint(keccak256(abi.encodePacked(state_gov[i].state_government)))){
				flag = true;
				temp=i;
			}
		}
		require(flag == true, "Only State Government can Add Item in Ration Shop....");
		flag = false;
		for(i=0; i < ListItem.length; i++){
		    if(uint(keccak256(abi.encodePacked(ip_Item_name))) == uint(keccak256(abi.encodePacked(ListItem[i].item_name)))){
				flag = true;
			}
		}
		require(flag == true, "This item is not registered for ration delivery....");
		flag=false;
		require(shop[ip_Ethereum_address_of_Ration_shop].valid == 1, "Not a Register Ration Shop....");
		for(i=0; i < GoodsList.length; i++){
			if(uint(keccak256(abi.encodePacked(state_gov[temp].state_name))) == uint(keccak256(abi.encodePacked(GoodsList[i].Load_by_state_name)))){
				if(uint(keccak256(abi.encodePacked(ip_Ethereum_address_of_Ration_shop))) == uint(keccak256(abi.encodePacked(GoodsList[i].Ethereum_address_of_Ration_shop)))){
					if(uint(keccak256(abi.encodePacked(ip_Item_name))) == uint(keccak256(abi.encodePacked(GoodsList[i].item_name)))){
						GoodsList[i].weight += ip_weight;
						flag = true;
					}
				}
			}
		}
		if(flag == false)
			GoodsList.push(Loading_of_Item_in_Ration_shop(state_gov[temp].state_name,ip_Ethereum_address_of_Ration_shop,ip_Item_name,ip_weight));	
	}
	  
	function Delete_Ration_Details() public{
	    uint Todaydate;
	    require(msg.sender==owner,"Only Owner Can Delete Details Of Ration");
	    Todaydate=getDay(block.timestamp);
	    if(Todaydate==1)
	        delete Ration_delivery;
	    else
	        revert("Today is not the first Day of the Month");
	}  
	function Ration_distribution_to_Public(address ip_Ethereum_address_of_individual,string memory ip_Item_name) public returns(uint){
	    bool flag;
	    uint temp;
	    uint Itemweight;
	    uint price;
	    uint poverty;
	    uint Todaydate;
		uint l;
	    Todaydate=getDay(block.timestamp);
	    if(Todaydate==1){
	        revert("Today Ration will not be provided... Kindly Visit Tomorrow to Last day of the Month For Ration");
	    }
	    else{
	        require(shop[msg.sender].valid == 1, "Not a Register Ration Shop...."); 
	        require(citizen[ip_Ethereum_address_of_individual].valid == 1, "Not a Register Citizen....");
	        poverty=citizen[ip_Ethereum_address_of_individual].poverty_line;
	        for(i=0; i < ListItem.length; i++){
		        if(uint(keccak256(abi.encodePacked(ip_Item_name))) == uint(keccak256(abi.encodePacked(ListItem[i].item_name)))){
	                flag=true;
	                Itemweight=ListItem[i].weight_of_item;
	                if(poverty==0)
	                       price=ListItem[i].below_poverty_line_price;
	               else
	                       price=ListItem[i].above_poverty_line_price;
		        }
	        }
	        require(flag==true,"This item is not registered for ration delivery.");
	        flag=false;
	        for(i=0; i < GoodsList.length; i++){
		        if(uint(keccak256(abi.encodePacked(msg.sender))) == uint(keccak256(abi.encodePacked(GoodsList[i].Ethereum_address_of_Ration_shop)))){
		            if(uint(keccak256(abi.encodePacked(ip_Item_name))) == uint(keccak256(abi.encodePacked(GoodsList[i].item_name)))){
		                if(GoodsList[i].weight>=Itemweight){
				            flag = true;
				            temp=i;
			            }
		            }
		        }
		    }
	        require(flag == true, "This item is not present in the Ration Shop....");
	        flag=false;
	        for(i=0; i < Ration_delivery.length; i++){
	            if(uint(keccak256(abi.encodePacked(ip_Ethereum_address_of_individual))) == uint(keccak256(abi.encodePacked(Ration_delivery[i].Ethereum_address_of_individual)))){
		            if(uint(keccak256(abi.encodePacked(ip_Item_name))) == uint(keccak256(abi.encodePacked(Ration_delivery[i].Item_name)))){
		                flag=true;
		            }
	            }
	        }
	        require(flag == false, "This item is already taken by the citizen.... Kindly buy this item in the next month....");
			l=Ration_delivery.length;			
	        Ration_delivery.push(Ration_delivery_to_Public(msg.sender,ip_Ethereum_address_of_individual,ip_Item_name,price,Itemweight,block.timestamp,l));
			emit RationDelivery(msg.sender,ip_Ethereum_address_of_individual,ip_Item_name,price,Itemweight,block.timestamp,l);
	        return(l);
	    }   
	}
	
}