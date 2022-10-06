import { LightningElement, track, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import getMyTeamQuoats from '@salesforce/apex/TeamQuotaComponentHelper.getMyTeamQuoats';
import getAVGDistributedScore from '@salesforce/apex/TeamQuotaComponentHelper.getAVGDistributedScore';
import getCountriesAndSegment from '@salesforce/apex/TeamQuotaComponentHelper.getCountriesAndSegment';

const segmentsMap = new Map([["50-99","SMB"],["100-1500","MM"],["1500+","ENT"]]);

export default class TeamQuotaComponent extends LightningElement {

    //Will hold the data from the apex method using @wire 
    @track teamMembers;
    @track teamMembersMap;
    @track teamMembersCountryAndSegmentMap;

    //If we get data from @wire then dispay the records of the team members else dont 
    @track isDataAvilable =false;

    @api userId = Id;
    // @track myTeamData; -- Check if can be deleted

    //Control the popup window the value is being passed fron the child component of the member record
    @track openModal =false;

    //Being passed to the popup component in order to edit the quotas #
    @track selectedQuota;


    //Get the list of all team members unser the currnet manger after reciving the list call another apex function in order to load the countries and the segments
    @wire(getMyTeamQuoats, {userId: '$userId'})
    teamMembersList(result){
        if(result.data){
            console.log('From wire line 22 ' , result.data);//To be delted
            this.teamMembers = result.data;
            this.isDataAvilable = true; //Set the flag to be true in order to display the team member list

            //Call the getCountriesAndSegment wire function in order to get the countrys and segments
            getCountriesAndSegment({userId:this.userId})
            .then((result)=>{

                    const mapOfUserCountryAndSegment = new Map();
                    
                    //Convert the result of the query 'teamMembersCountryAndSegments' to map in order to reduce duplecated segments and countrys for users
                    for(const obj of result){
                    if(obj.Country__c != undefined && obj.Segment__c != undefined){

                        //Check if the record exsist in the new map using the LeanData__User_Owner__c (Id of the user)
                        if(mapOfUserCountryAndSegment.has(obj.LeanData__User_Owner__c)){

                            //check if the country is not part of the countyrs that is assgined to the user alredy in order to prevent dupleacted records
                            if(!mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).countrys.includes(obj.Country__c) &&  obj.Country__c != undefined){
                                mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).countrys.push(obj.Country__c);
                            }

                            //check if the segment is not part of the countyrs that is assgined to the user alredy in order to prevent dupleacted records
                            if(!mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).segment.includes(segmentsMap.get(obj.Segment__c))  &&  obj.Segment__c != undefined){
                                mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).segment.push(segmentsMap.get(obj.Segment__c));
                            }
                        }else{

                            //If we are not able to find the record as part of map then create a new record in the map.
                            mapOfUserCountryAndSegment.set(obj.LeanData__User_Owner__c, {countrys: [obj.Country__c], segment:  [segmentsMap.get(obj.Segment__c)]});
                        }
                    }
                    }
        
                    //Save the new Map into the teamMembersCountryAndSegmentMap
                    this.teamMembersCountryAndSegmentMap = mapOfUserCountryAndSegment;

                    //Call addCountryAndSegments function in order to add the country and segment key to each record of the team members
                    this.addCountryAndSegments(this.teamMembersCountryAndSegmentMap);

            })
            .catch((error)=>{
                console.log('Line 47 error ', error);
            })


            //Call the getAVGDistributedScore wire function in order to get the avg DistributedScore
            getAVGDistributedScore({userId:this.userId})
            .then(result=>{
                     this.teamMembersMap = new Map(result.map(obj => [ obj.Owner_Name_Initial__c, obj.expr0]));

                     //Call addAvgScoreToTeamMembers function in order to add avg DistributedScore to each team member record
                     this.addAvgScoreToTeamMembers(this.teamMembersMap);
            })
            .catch(error=>{
                    console.log('Line 47 ', error);
            })

            //Call isDailyLidsPassdTotalLeads in order to set the class for Total Open Leads 
            this.isDailyLidsPassdTotalLeads();

        }else if(result.error){
            console.log('Wasnt able to fatch data ', result.error);
        }
    }


    //Adding the Avg Score To Team Members list , getting map of owner_id - avg_score
    addAvgScoreToTeamMembers(scoreMap){
        const newArray =  this.teamMembers.map(member => {
             if(scoreMap.get(member.Name) == undefined || scoreMap.get(member.Name) == null ){
                 return{...member, avgScore:0}
                 
             }else{
                 return{...member, avgScore: scoreMap.get(member.Name)}
             }
             });
 
             this.teamMembers = newArray;
     }


     //In order to set the correct color for each record in the Total Open Leads colum, 
     //check if Open_Leads_Actual__c > Open_Leads_Limit__c and add the new class name to the records object
     isDailyLidsPassdTotalLeads(){
        const newArray =  this.teamMembers.map(member => {
    
            if(member.Lead_Caps__r){
                if(member.Lead_Caps__r[0].Open_Leads_Actual__c > member.Lead_Caps__r[0].Open_Leads_Limit__c){
                    return{...member, color:'red'}
                }else{
                    return{...member, color:'green'}
                }
            }else{
                //Not all the users have a total open leads number in this case we are keeping the record as is.
                return{...member}
            }
            });

            this.teamMembers = newArray;
     }


    addCountryAndSegments(countryAndSegmentMap){

        const teamMembersUpdatedList = this.teamMembers.map(member => {

        //Check if the team member have a country/segment in the countryAndSegmentMap if so then add to the teamMembers list else set - and - 
        if(countryAndSegmentMap.has(member.Id)){

                return{...member, countries: countryAndSegmentMap.get(member.Id).countrys.toString() , segment: countryAndSegmentMap.get(member.Id).segment.toString() }

        }else{
                return{...member, countries: '-' , segment: '-' }
        }
        });

            this.teamMembers = teamMembersUpdatedList;
    }


    //When user clicks on a single record of team member in order ro change the Daily Quota get the id 
    //from the child component save the select record in the parent and padd to the other child the pop edit window
    handleDailyQuotaChanged(event){
        this.teamMembers.forEach(member => {
            if(member.Id == event.detail.Id){
                this.selectedQuota = member;
            }
        });
   
       this.openModal= true;
    }


    //Once the user is closing the popup window or press on the X button change the modal state 
    closePopUp(event){
        this.openModal = event.openWindow;
    }

    //custom event from popup window child component
    @api
    refresh(event){
        // forcing refresh on the page
        window.location.reload();
    }


        // @wire(getCountriesAndSegment, {userId:'$userId'})
    // teamMembersCountryAndSegments(result){
    //     if(result.data){

    //         console.log('Line 63 teamMembersCountryAndSegments ', JSON.stringify(result.data));
    //         const mapOfUserCountryAndSegment = new Map();
            
    //         //Convert the result of the query 'teamMembersCountryAndSegments' to map in order to reduce duplecated segments and countrys for users
    //         for(const obj of result.data){
    //         if(obj.Country__c != undefined && obj.Segment__c != undefined){
    //             if(mapOfUserCountryAndSegment.has(obj.LeanData__User_Owner__c)){
    //                 if(!mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).countrys.includes(obj.Country__c) &&  obj.Country__c != undefined){
    //                     mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).countrys.push(obj.Country__c);
    //                 }
                    
    //                 if(!mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).segment.includes(obj.Segment__c)  &&  obj.Segment__c != undefined){
    //                     mapOfUserCountryAndSegment.get(obj.LeanData__User_Owner__c).segment.push(obj.Segment__c);
    //                 }
    //             }else{
    //                 mapOfUserCountryAndSegment.set(obj.LeanData__User_Owner__c, {countrys: [obj.Country__c], segment:  [obj.Segment__c]});
    //             }
    //         }
    //         }

    //         this.teamMembersCountryAndSegmentMap = mapOfUserCountryAndSegment;//Save the new Map into the teamMembersCountryAndSegmentMap
    //         console.log('Line 55 ', this.teamMembersCountryAndSegmentMap);
    //         // this.addCountryAndSegments(this.teamMembersCountryAndSegmentMap);
            
    //     }else if(result.error){
    //         console.log('Line 67 Error ', result.error);
    //     }
    // }


    // get the AVG Score Today for each team member using apex function
    // @wire(getAVGDistributedScore, {userId:'$userId'})
    // teamMembersDistributedScore(result){
    //     if(result.data){
    //         console.log('Line 45', JSON.stringify(result.data));

    //          this.teamMembersMap = new Map(result.data.map(obj => [ obj.Owner_Name_Initial__c, obj.expr0]));
    //          //Call addAvgScoreToTeamMembers function in order to add avg files to each team member record
    //          this.addAvgScoreToTeamMembers(this.teamMembersMap);

    //     }else if(result.error){
    //         console.log('Line 47 ', result.error);
    //     }
    // }
}