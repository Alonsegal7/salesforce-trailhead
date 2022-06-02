import SystemModstamp from "@salesforce/schema/AcceptedEventRelation.SystemModstamp";
import {api, LightningElement,track} from "lwc";

export default class calcEndDate extends LightningElement {
    @api Duration; 
    @api StartDate;
    @api EndDate; 
    @api required;

    addDuration(dt, dur){
        var date = new Date(dt);
        date.setMonth(parseInt(date.getMonth()) + parseInt(dur));
        return date;
    }
    deductDays(dt,days){
        var date = new Date(dt);
        date.setDate(date.getDate() - days);
        return date;
    }
    calcExpr() {
        try{
            var tempDate = new Date();
            tempDate = this.addDuration(this.StartDate, this.Duration);
            tempDate = this.deductDays(tempDate , 1);
            this.EndDate = new Date(tempDate);
            var DD = tempDate.getDate();
            var MM = tempDate.getMonth()+1;
            var YYYY = tempDate.getFullYear();
            this.EndDate = YYYY + '-' + MM + '-' + DD;
        } catch(e){
            console.error(e);
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
    }
    handleChangeDate(evt) {
        this.StartDate = evt.target.value;
        if (this.StartDate != null && this.StartDate != '' && this.Duration != null && this.Duration != ''){
            this.calcExpr();
        } else {
            this.EndDate = null;
        }
    }
    handleChangeDuration(evt) { 
        this.Duration = evt.target.value;
        if (this.StartDate != null && this.StartDate != '' && this.Duration != null && this.Duration != ''){
            this.calcExpr();
        } else {
            this.EndDate = null;
        }
    }
    @api
    validate(){ //validation 
        console.log('validate: required' + this.required);
        console.log('validate: Duration' + this.Duration);
        console.log('validate: StartDate' + this.StartDate);
        if(this.required == true || this.required == 'true'){ // fileds are mandatory
            if (this.Duration == null || this.Duration == '' 
                || this.StartDate == null || this.StartDate == '' || this.StartDate == undefined){
                var errorMessage = 'Start Date and Duration are mandatory fields';
                return { isValid: false, errorMessage: errorMessage };
            } else { // passed validation
                return { isValid: true };
            }
        } else { // fields not mandatory - no validation
            return { isValid: true };
        }
    }
}

