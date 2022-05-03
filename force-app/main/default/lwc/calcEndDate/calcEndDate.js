import {api, LightningElement,track} from "lwc";

export default class calcEndDate extends LightningElement {
    @api Duration; 
    @api StartDate;
    @api EndDate; 
    @track StartDate;
    @track Duration;
    @track EndDate;

    addDuration(dt, dur){
        var date = new Date(dt);
        date.setMonth(parseInt(date.getMonth()) + parseInt(dur));
        console.log('addDuration post set: '+ date);
        return date;
    }
    deductDays(dt,days){
        var date = new Date(dt);
        date.setDate(date.getDate() - days);
        console.log('Date after change '+ date);
        return date;
    }
    calcExpr() {
        try{
            var tempDate = new Date();
            tempDate = this.addDuration(this.StartDate, this.Duration);
            console.log('tempDate addDuration: '+tempDate);
            tempDate = this.deductDays(tempDate , 1);
            console.log('tempDate deductDays: '+tempDate);
            this.EndDate = new Date(tempDate);
            var DD = tempDate.getDate();
            var MM = tempDate.getMonth()+1;
            var YYYY = tempDate.getFullYear();
            this.EndDate = YYYY + '-' + MM + '-' + DD;
            console.log('End date final '+this.EndDate);
        } catch(e){
            console.error(e);
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
    }
    handleChangeDate(evt) {
        this.StartDate = evt.target.value;
        if (this.StartDate != null && this.Duration != null){
            this.calcExpr();
        if (this.StartDate =null && this.Duration !=null){
            this.EndDate=''
        }
        }
    }
    handleChangeDuration(evt) { 
        this.Duration = evt.target.value;
        if (this.StartDate != null && this.Duration != null){
            this.calcExpr();
        }
    }
}

